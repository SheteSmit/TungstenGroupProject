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
import "./interfaces/IOneSplit.sol";
import './ExchangeOracle.sol';
import "./Bank.sol";

contract Chromium {
    using UniversalERC20 for IERC20;

    mapping(IERC20 => uint256) public balancePerToken;
    mapping(IERC20 => bool) public allowedTokens; // tokens that are allowed to be exchanged
    address oracleAddress;

    Bank treasury;
    ExchangeOracle oracle;
    IOneSplit public oneSplitImpl; // pass in 1inch protocol contract address

    IERC20 private constant ZERO_ADDRESS = IERC20(0x0000000000000000000000000000000000000000); // eth address substitute
    IERC20 private constant ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE); // eth address substitute

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
    * this sets the 1inch protocol
    * @param _oneAuditImpl the 1inch protol address (0xC586BeF4a0992C495Cf22e1aeEE4E446CECDee0E)
    */
    function setOneProtocol(IOneSplit _oneAuditImpl) public {
        oneSplitImpl = _oneAuditImpl;
    }

    /**
     * @dev Calculate expected returning amount of `destToken`
     * @param fromToken (IERC20) Address of token or `address(0)` for Ether
     * @param destToken (IERC20) Address of token or `address(0)` for Ether
     * @param amount (uint256) Amount for `fromToken`
     * @param parts (uint256) Number of pieces source volume could be splitted,
     * works like granularity, higly affects gas usage. Should be called offchain,
     * but could be called onchain if user swaps not his own funds, but this is still considered as not safe.
     * @param flags (uint256) Flags for enabling and disabling some features, default 0
     * @param destTokenEthPriceTimesGasPrice (uint256) destToken price to ETH multiplied by gas price
    */
    function getExpectedReturnWithGas(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags, // See constants in IOneSplit.sol
        uint256 destTokenEthPriceTimesGasPrice
    )
    public
    view
    returns(
        uint256 returnAmount,
        uint256 estimateGasAmount,
        uint256[] memory distribution
    )
    {
        return oneSplitImpl.getExpectedReturnWithGas(
            fromToken,
            destToken,
            amount,
            parts,
            flags,
            destTokenEthPriceTimesGasPrice
        );
    }

    /**
     * @dev Swap `_sellAmount` of `_sellToken` to `_buyToken`
     * @param fromToken (IERC20) Address of token or `address(0)` for Ether
     * @param destToken (IERC20) Address of token or `address(0)` for Ether
     * @param amount (uint256) Amount for `fromToken`
     * @param minReturn (uint256) Minimum expected return, else revert
     * @param distribution (uint256[]) Array of weights for volume distribution returned by `getExpectedReturnWithGas`
     * @param flags (uint256) Flags for enabling and disabling some features, default 0
    */
    function exchangeTokens(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory distribution,
        uint256 flags
    ) external payable returns (uint256 _amountReturned) {

        // pulls the price of both tokens from an oracle using call without abi
        // (bool result, bytes memory data) =
        //     oracleAddress.call(
        //         abi.encodeWithSignature(
        //             "priceOfPair(address,address)",
        //             _sellToken,
        //             _buyToken
        //         )
        //     );

        // // Decode bytes data
        // (uint256 sellTokenValue, uint256 buyTokenValue) =
        //     abi.decode(data, (uint256, uint256));

        // //Calculate tokens bought
        // uint256 buyingAmount =
        //     SafeMath.mul(
        //         _sellAmount,
        //         SafeMath.div(sellTokenValue, buyTokenValue)
        //     );

        if (_exchangeWithChromium(fromToken, destToken, amount)) {
            // checks to see if there are enough tokens in the contract to make the exchange
            require(minReturn <= treasury.totalTokenSupply(address(destToken)));

            fromToken.universalTransferFrom(msg.sender, address(treasury), amount);
            balancePerToken[fromToken] = SafeMath.add(balancePerToken[fromToken], amount);

            destToken.universalTransfer(msg.sender, minReturn);
            balancePerToken[destToken] = SafeMath.sub(balancePerToken[destToken], minReturn);

            emit tokensExchanged(address(fromToken), amount, address(destToken), minReturn);
            _amountReturned = minReturn;
        } else {
            _amountReturned = oneSplitImpl.swap(fromToken, destToken, amount, minReturn, distribution, flags);
            emit tokensExchanged(address(fromToken), amount, address(destToken), minReturn);
        }
    }


    /**
     * @dev this will accept erc20 tokens to be added to the contracts liquidity pool
     */
    function addLiquidity(IERC20 _token, uint256 _tokenAmount)
    external
    payable
    {
        //Check if token is not supported by bank
        require(allowedTokens[_token] == true, "Token is not supported");
        _token.approve(address(this), _tokenAmount);

        balancePerToken[_token] = SafeMath.add(
            balancePerToken[_token],
            _tokenAmount
        );

        _token.universalTransferFrom(msg.sender, address(this), _tokenAmount);
        emit depositToken(msg.sender, _tokenAmount);
    }

    /**
     * @dev allows for tokens to be added to the exchange
     * this needs to be done before adding any liquidity for the token
     */
    function _allowToken(IERC20 _token) public {
        allowedTokens[_token] = true;
    }

    /**
     * @dev method determines if chromium is able to make the exchange, if chromium cant make the exchange
     * then it will return false and the 1inch protocol will complete the exchange
     * @param _minReturn is the _minReturn that is returned from "getExpectedReturnWithGas"
    */
    function _exchangeWithChromium(IERC20 _sellToken, IERC20 _buyToken, uint _minReturn) internal view returns (bool) {
        if (allowedTokens[_sellToken] == true && allowedTokens[_buyToken] == true) {
            if (balancePerToken[_buyToken] >= _minReturn) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
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
