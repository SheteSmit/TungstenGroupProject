// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import './ERC20.sol';
import './ExchangeOracle.sol';
import './SafeMath.sol';

contract Chromium {

    mapping(address => uint) public balancePerToken;
    mapping(address => bool) public allowedTokens; // tokens that are allowed to be exchanged
    uint public ethSupply; // amount of eth in contract

    ERC20 buyToken;
    ERC20 sellToken;
    ExchangeOracle oracle;

    event depositToken(address indexed _from, uint256 _amount);
    event onTransfer(
        address indexed _from,
        address indexed _to,
        uint256 _amount
    );
    event tokensExchanged(address indexed _sendingToken, uint _amountSent, address indexed _receivedToken, uint _amountRecieved);

    /**
    * pass in the oracle contract so that it can pull info from it
    */
    constructor(address _oracle) {
        oracle = ExchangeOracle(_oracle);
    }

    /**
    * @dev function that will exchange erc20 tokens
    * @param _sellToken the token that the user wants to sell/trade
    * @param _sellAmount amount of tokens to be sold
    * @param _buyToken the token that is going to be purchased
    * you need to enter the rate of each token in the oracle and then function will do the calculations
    */
    function exchangeTokens(address _sellToken, uint _sellAmount, address _buyToken) external payable {

        uint buyingAmount = SafeMath.mul(_sellAmount, SafeMath.div(oracle.getValue(_sellToken), oracle.getValue(_buyToken)));

        // checks to see if there are enough tokens in the contract to make the exchange
        require(buyingAmount <= balancePerToken[_buyToken]);
        balancePerToken[_buyToken] = SafeMath.sub(balancePerToken[_buyToken], buyingAmount);
        balancePerToken[_sellToken] = SafeMath.add(balancePerToken[_sellToken], _sellAmount);

        sellToken = ERC20(address(_sellToken));
        sellToken.approve(address(this), _sellAmount);
        sellToken.transferFrom(msg.sender, address(this), _sellAmount);

        buyToken = ERC20(address(_buyToken));
        buyToken.transferFrom(address(this), msg.sender, buyingAmount);

        emit tokensExchanged(_sellToken, _sellAmount, _buyToken, buyingAmount);
    }

    /**
    * @dev function that will exchange erc20 tokens for eth
    * @param _sellToken the token that you want to exchange/sell
    * @param _sellAmount amount of tokens that will be sold
    */
    function exchangeTokenForEth(address _sellToken, uint _sellAmount) external payable {

        uint ethAmount = SafeMath.mul(_sellAmount, SafeMath.div(oracle.getValue(_sellToken), oracle.getValue(0x0000000000000000000000000000000000000000)));

        // checks to see if the contract has enough eth
        require(ethAmount <= ethSupply, "You don't have enough tokens");
        balancePerToken[_sellToken] = SafeMath.add(balancePerToken[_sellToken], _sellAmount);
        ethSupply = SafeMath.sub(ethSupply, ethAmount);

        sellToken = ERC20(address(_sellToken));
        sellToken.transferFrom(msg.sender, address(this), _sellAmount);

        // have to wrate msg.sender in payable to make it payable
        payable(msg.sender).transfer(ethAmount);
    }

    /**
    * @dev function that will exchange eth for erc20 tokens
    * @param _buyToken the token that you want to buy
    */
    function exchangeEthForToken(address _buyToken) external payable {

        uint tokenAmount = SafeMath.mul(msg.value, SafeMath.div(msg.value, oracle.getValue(_buyToken)));

        // checks to see if there are enough tokens in contract to make exchange
        require(tokenAmount <= balancePerToken[_buyToken]);
        balancePerToken[_buyToken] = SafeMath.sub(balancePerToken[_buyToken], tokenAmount);
        ethSupply = SafeMath.add(ethSupply, msg.value);

        buyToken = ERC20(address(_buyToken));
        buyToken.transferFrom(address(this), msg.sender, tokenAmount);
    }

    /**
    * @dev this will accept erc20 tokens to be added to the contracts liquidity pool
    */
    function addLiquidity(address _tokenAddress, uint256 _tokenAmount)
    external
    payable
    {
        //Check if token is not supported by bank
        require(allowedTokens[_tokenAddress] == true, "Token is not supported");
        sellToken = ERC20(address(_tokenAddress));
        sellToken.approve(address(this), _tokenAmount);

        balancePerToken[_tokenAddress] = SafeMath.add(
            balancePerToken[_tokenAddress],
            _tokenAmount
        );

        require(
            sellToken.transferFrom(msg.sender, address(this), _tokenAmount) == true,
            "Transfer not complete"
        );

        emit depositToken(msg.sender, _tokenAmount);
    }

    /**
    * @dev allows for eth to be deposited into liquidity pool
    */
    function addEthLiquidity() external payable {
        ethSupply = SafeMath.add(ethSupply, msg.value);

        emit depositToken(msg.sender, msg.value);
    }

    /**
    * @dev allows for tokens to be added to the exchange
    * this needs to be done before adding any liquidity for the token
    */
    function allowToken(address _token) public {
        allowedTokens[_token] = true;
    }

    // fallback function
    receive() external payable {

    }
}
