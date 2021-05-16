// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/**
 * getExpectedReturnWithGas is a method on the 1inch protocol that is free to call and will return
 * a distribution array. each element in array shows an exchange and represents a fraction of trading volume.
 * it will also return the amount the minimum amount tokens that will be received by the caller based on the amount
 * that they are selling. it also returns the amount of gas that is being used.
 *
 * I removed the oracle because i figured we can use the _minReturn from getExpectedReturnWithGas as the conversion
 * rate for the two tokens instead of having our own oracle.
 *
 * the exchangeTokens method will first check if the tokens are allowed in our contract and if we have enough
 * tokens in the contract to make the exchange. if we do then the exchange will happen here. if we dont, then
 * the 1inch swap protocol will be called to complete the exchange
*/

import "./interfaces/UniversalERC20.sol";
import './interfaces/Ownable.sol';
import './ExchangeOracle.sol';
import './interfaces/IUniswap.sol';

contract Chromium is Ownable{
    using UniversalERC20 for IERC20;

    mapping(IERC20 => uint) public liquidityAmount;
    IERC20 private constant WETH_MAINNET = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 private constant WETH_KINKEBY = IERC20(0xc778417E063141139Fce010982780140Aa0cD5Ab);

    ExchangeOracle oracle;
    IERC20 cblt_token;
    IUniswap uniswap;

    event depositToken(address indexed _from, uint256 _amount);
    event onTransfer(
        address indexed _from,
        address indexed _to,
        uint256 _amount
    );
    event tokensExchanged(
        address indexed _sendingToken,
        uint256 _amountSent,
        address indexed _receivedToken,
        uint256 _amountRecieved
    );

    /**
     * pass in the oracle contract so that it can pull info from it
     * @param _uniswapRouter address is 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
     */
    constructor(address _oracle, address _cbltToken, address _uniswapRouter) {
        oracle = ExchangeOracle(_oracle);
        cblt_token = IERC20(_cbltToken);
        uniswap = IUniswap(_uniswapRouter);
    }

    /** this sets the treasury, and oracle */
    function setOracle(address _oracle) external onlyOwner {
        oracle = ExchangeOracle(_oracle);
        oracleAddress = _oracle;
    }

    function setCbltToken(address _cblt) external onlyOwner {
        cblt_token = IERC20(_cblt);
    }

    function setUniswapRouter(address _router) external onlyOwner {
        uniswap = IUniswap(_router);
    }

    /************ chromium functions ************/
    /**
     * @dev this function will get the exchagne rate for the token being exchanged for cblt token
     * it will call on the oracle to make the calculation. the returnAmount is going to be a factor
     * of three larger than the actual amount which means the returnAmount will need to be divided by
     * 1000 to get the correct amount that will be swapped
    */
    function getCbltExchangeRate(
        IERC20 fromToken,
        IERC20 cbltToken,
        uint256 amount
    )
    public
    view
    returns(uint returnAmount)
    {
        require(_checkIfDestTokenIsCblt(cbltToken));
        (uint256 sellTokenValue, uint256 buyTokenValue) = oracle.priceOfPair(address(fromToken), address(cbltToken));
        returnAmount = SafeMath.mul(amount,
            SafeMath.findRate(sellTokenValue, buyTokenValue)
        );

    }

    /**
     * @dev this function will swap cblt tokens for tokens that are allowed in the bank
     * it calls on a function inside of the bank to do the exchange since no tokens are going
     * to be held in the exchange
    */
    function swapForCblt(
        IERC20 fromToken,
        IERC20 cbltToken,
        uint256 amount,
        uint256 returnAmount
    )
    external
    payable
    {
        require(_checkIfDestTokenIsCblt(cbltToken));
        require(cbltToken.universalBalanceOf(address(this)) >= returnAmount, "Not enough tokens in Treasury.");

        fromToken.universalTransferFromSenderToThis(amount);
        cbltToken.universalTransfer(msg.sender, returnAmount);

        liquidityAmount[fromToken] = SafeMath.add(liquidityAmount[fromToken], amount);
    }

    /*************** Uniswap **************/
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        uint deadline
    ) external returns (uint[] memory amounts)
    {
        address fromToken = path[0];

        IERC20(fromToken).universalTransferFromSenderToThis(amountIn);
        IERC20(fromToken).universalApprove(address(uniswap), amountIn);

        amounts = uniswap.swapExactTokensForTokens(amountIn, amountOutMin, path, msg.sender, deadline);
    }

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, uint deadline)
    external
    payable
    returns (uint[] memory amounts) {
        amounts = uniswap.swapExactETHForTokens{value: msg.value}(amountOutMin, path, msg.sender, deadline);
    }

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, uint deadline)
    external
    returns (uint[] memory amounts)
    {
        address fromToken = path[0];

        IERC20(fromToken).universalTransferFromSenderToThis(amountIn);
        IERC20(fromToken).universalApprove(address(uniswap), amountIn);

        amounts = uniswap.swapExactTokensForETH(amountIn, amountOutMin, path, msg.sender, deadline);
    }

    /**
     * @dev this function will check to see if the both tokens are correct when wanting
     * to make the exchange with chromium
    */
    function _checkIfDestTokenIsCblt(IERC20 cbltToken)
    internal
    view
    returns(bool)
    {
        if ( cbltToken == cblt_token) {
            return true;
        } else {
            return false;
        }
    }

    function _checkUniswapTokens(
        IERC20 fromToken,
        IERC20 destToken,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) internal
    {
        if(fromToken != WETH_MAINNET && destToken != WETH_MAINNET) {
            uniswap.swapExactTokensForTokens(
                amountIn,
                amountOutMin,
                path,
                to,
                deadline
            );
        }
    }

    function balanceOfToken(IERC20 _token) public view returns(uint) {
        return _token.universalBalanceOf(address(this));
    }

    function testCall() public view returns (uint256 value) {
        (uint256 sellTokenValue, uint256 buyTokenValue) = oracle.testConnection();
        value = sellTokenValue + buyTokenValue;

    }

    // fallback function
    receive() external payable {}
}
