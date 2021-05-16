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
    IERC20 private constant cbltToken = IERC20(0x433C6E3D2def6E1fb414cf9448724EFB0399b698);

    // initializing objects
    ExchangeOracle oracle;
    IERC20 cblt_Token;

    // emits when chromium is used
    event ChromiumTrade(address indexed _from, address _fromToken, uint256 _fromAmount, uint _cbltAmount);

    /**
     * pass in the oracle contract so that it can pull info from it
     */
    constructor(address _oracle) {
        oracle = ExchangeOracle(_oracle);
    }

    /** this sets the treasury, and oracle */
    function setOracle(address _oracle) external onlyOwner {
        oracle = ExchangeOracle(_oracle);
    }

    // sets CBLT token
    function setCbltToken(address _cblt) external onlyOwner {
        cblt_Token = IERC20(_cblt);
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
        uint256 amount
    )
    external
    payable
    {
        (uint256 sellTokenValue, uint256 buyTokenValue) = oracle.priceOfPair(address(fromToken), address(cbltToken));
        uint returnAmount = SafeMath.mul(amount,
            SafeMath.findRate(sellTokenValue, buyTokenValue)
        );

        returnAmount = SafeMath.div(returnAmount, 1000000);

        require(cbltToken.universalBalanceOf(address(this)) >= returnAmount, "Not enough tokens in Treasury.");

        fromToken.universalTransferFrom(msg.sender, address(this), amount);
        cbltToken.universalTransfer(msg.sender, returnAmount);
        liquidityAmount[fromToken] = SafeMath.add(liquidityAmount[fromToken], amount);

        emit ChromiumTrade(msg.sender, address(fromToken), amount, returnAmount);
    }

    // fallback function
    receive() external payable {}
}
