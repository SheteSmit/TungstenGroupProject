// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./ERC20.sol";
import "./ExchangeOracle.sol";
import "./SafeMath.sol";
import "./Bank.sol";

contract Chromium {
    mapping(address => uint256) public balancePerToken;
    mapping(address => bool) public allowedTokens; // tokens that are allowed to be exchanged
    uint256 public ethSupply; // amount of eth in contract
    address oracleAddress;

    ERC20 buyToken;
    ERC20 sellToken;
    ExchangeOracle oracle;
    Bank treasury;

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
     */
    constructor(address _oracle, address payable _treasury) {
        oracle = ExchangeOracle(_oracle);
        treasury = Bank(_treasury);
        oracleAddress = _oracle;
    }

    /**
     * @dev function that will exchange erc20 tokens
     * @param _sellToken the token that the user wants to sell/trade
     * @param _sellAmount amount of tokens to be sold
     * @param _buyToken the token that is going to be purchased
     * you need to enter the rate of each token in the oracle and then function will do the calculations
     */
    function exchangeTokens(
        address _sellToken,
        uint256 _sellAmount,
        address _buyToken
    ) external payable {
        // pulls the price of both tokens from an oracle using call without abi
        (bool result, bytes memory data) =
            oracleAddress.call(
                abi.encodeWithSignature(
                    "priceOfPair(address,address)",
                    _sellToken,
                    _buyToken
                )
            );

        // Decode bytes data
        (uint256 sellTokenValue, uint256 buyTokenValue) =
            abi.decode(data, (uint256, uint256));

        //Calculate tokens bought
        uint256 buyingAmount =
            SafeMath.mul(
                _sellAmount,
                SafeMath.div(sellTokenValue, buyTokenValue)
            );

        // checks to see if there are enough tokens in the contract to make the exchange
        require(buyingAmount <= treasury.totalTokenSupply(_buyToken));

        sellToken = ERC20(address(_sellToken));
        sellToken.transferFrom(msg.sender, address(treasury), _sellAmount);

        buyToken = ERC20(address(_buyToken));
        buyToken.transferFrom(address(treasury), msg.sender, buyingAmount);

        emit tokensExchanged(_sellToken, _sellAmount, _buyToken, buyingAmount);
    }

    /**
     * @dev function that will exchange erc20 tokens for eth
     * @param _sellToken the token that you want to exchange/sell
     * @param _sellAmount amount of tokens that will be sold
     */
    function exchangeTokenForEth(address _sellToken, uint256 _sellAmount)
        external
        payable
    {
        address ethAddress = 0x0000000000000000000000000000000000000000;

        // pulls the price of both tokens from an oracle using call without abi
        (bool result, bytes memory data) =
            oracleAddress.call(
                abi.encodeWithSignature(
                    "priceOfPair(address,address)",
                    _sellToken,
                    ethAddress
                )
            );
        // Decode bytes data
        (uint256 sellTokenValue, uint256 ethTokenValue) =
            abi.decode(data, (uint256, uint256));

        uint256 ethAmount =
            SafeMath.mul(
                _sellAmount,
                SafeMath.div(sellTokenValue, ethTokenValue)
            );

        // checks to see if the contract has enough eth
        require(ethAmount <= ethSupply, "You don't have enough tokens");
        balancePerToken[_sellToken] = SafeMath.add(
            balancePerToken[_sellToken],
            _sellAmount
        );
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
        address ethAddress = 0x0000000000000000000000000000000000000000;

        // pulls the price of both tokens from an oracle using call without abi
        (bool result, bytes memory data) =
            oracleAddress.call(
                abi.encodeWithSignature(
                    "priceOfPair(address,address)",
                    ethAddress,
                    _buyToken
                )
            );

        // Decode bytes data
        (uint256 ethValue, uint256 buyTokenValue) =
            abi.decode(data, (uint256, uint256));

        uint256 tokenAmount =
            SafeMath.mul(msg.value, SafeMath.div(ethValue, buyTokenValue));

        // checks to see if there are enough tokens in contract to make exchange
        require(tokenAmount <= balancePerToken[_buyToken]);
        balancePerToken[_buyToken] = SafeMath.sub(
            balancePerToken[_buyToken],
            tokenAmount
        );
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
            sellToken.transferFrom(msg.sender, address(this), _tokenAmount) ==
                true,
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

    function testCall() public payable returns (uint256 value) {
        (bool result, bytes memory data) =
            oracleAddress.call(abi.encodeWithSignature("testConnection()"));

        (uint256 sellTokenValue, uint256 buyTokenValue) =
            abi.decode(data, (uint256, uint256));
        return sellTokenValue + buyTokenValue;
    }

    // fallback function
    receive() external payable {}
}
