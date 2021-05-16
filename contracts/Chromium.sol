// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./interfaces/UniversalERC20.sol";
import './interfaces/Ownable.sol';
import './ExchangeOracle.sol';
import './interfaces/IUniswap.sol';

contract Chromium is Ownable{
    using UniversalERC20 for IERC20;

    // used to keep track of tokens in contract
    mapping(IERC20 => uint) public liquidityAmount;

    // weth address that i am using for eth
    IERC20 private constant WETH_MAINNET = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 private constant WETH_KINKEBY = IERC20(0xc778417E063141139Fce010982780140Aa0cD5Ab);

    // initializing objects
    ExchangeOracle oracle;
    IERC20 cbltToken;
    IUniswap uniswap;

    // emits when chromium is used
    event ChromiumTrade(address indexed _from, address _fromToken, uint256 _fromAmount, uint _cbltAmount);

    // emits when uniswap is used
    event UniswapTrade(
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
        cbltToken = IERC20(_cbltToken);
        uniswap = IUniswap(_uniswapRouter);
    }

    /** this sets the treasury, and oracle */
    function setOracle(address _oracle) external onlyOwner {
        oracle = ExchangeOracle(_oracle);
    }

    // sets CBLT token
    function setCbltToken(address _cblt) external onlyOwner {
        cbltToken = IERC20(_cblt);
    }

    // sets uniswap router
    function setUniswapRouter(address _router) external onlyOwner {
        uniswap = IUniswap(_router);
    }

    /************ chromium functions ************/
    /*
     * @dev this function will get the exchagne rate for the token being exchanged for cblt token
     * it will call on the oracle to make the calculation. the returnAmount is going to be
     * three times larger than the actual amount (so that we can get decimals) which means the returnAmount
     * will need to be divided by 1000 by the frontend to get the correct amount that will be swapped
    */
    function getCbltExchangeRate(
        IERC20 fromToken,
        uint256 amount
    )
    public
    view
    returns(uint returnAmount)
    {
        (uint256 sellTokenValue, uint256 buyTokenValue) = oracle.priceOfPair(address(fromToken), address(cbltToken));
        returnAmount = SafeMath.mul(amount,
            SafeMath.findRate(sellTokenValue, buyTokenValue)
        );

    }

    /**
     * @dev this function will swap cblt tokens for tokens that are allowed
    */
    function swapForCblt(
        IERC20 fromToken,
        uint256 amount,
        uint256 returnAmount
    )
    external
    payable
    {
        require(cbltToken.universalBalanceOf(address(this)) >= returnAmount, "Not enough tokens in Treasury.");

        fromToken.universalTransferFrom(msg.sender, address(this), amount);
        cbltToken.universalTransfer(msg.sender, returnAmount);
        liquidityAmount[fromToken] = SafeMath.add(liquidityAmount[fromToken], amount);

        emit ChromiumTrade(msg.sender, address(fromToken), amount, returnAmount);
    }

    /************ uniswap functions ************/

    /**
     * this function will get the exchange erc20 tokens for erc20 tokens through uniswap
     * this requires an input from the amount the user wants to exchange
    */
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
        emit UniswapTrade(fromToken, amountIn, path[1], amounts[1]);
    }

    /**
     * this function will get the exchange ETH for erc20 tokens through uniswap
     * this requires an input from the amount the user wants to exchange
    */
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, uint deadline)
    external
    payable
    returns (uint[] memory amounts) {
        amounts = uniswap.swapExactETHForTokens{value: msg.value}(amountOutMin, path, msg.sender, deadline);
        emit UniswapTrade(address(WETH_MAINNET), msg.value, path[1], amounts[1]);
    }

    /**
     * this function will get the exchange erc20 tokens for ETH through uniswap
     * this requires an input from the amount the user wants to exchange
    */
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, uint deadline)
    external
    returns (uint[] memory amounts)
    {
        address fromToken = path[0];

        IERC20(fromToken).universalTransferFromSenderToThis(amountIn);
        IERC20(fromToken).universalApprove(address(uniswap), amountIn);

        amounts = uniswap.swapExactTokensForETH(amountIn, amountOutMin, path, msg.sender, deadline);
        emit UniswapTrade(fromToken, amountIn, path[1], amounts[1]);
    }

    // fallback function
    receive() external payable {}
}
