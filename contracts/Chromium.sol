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
import "./interfaces/IOneSplit.sol";
import './ExchangeOracle.sol';
import "./Bank.sol";

contract Chromium is Ownable{
    using UniversalERC20 for IERC20;

    mapping(IERC20 => bool) public allowedTokens; // tokens that are allowed to be exchanged
    address oracleAddress;

    Bank treasury;
    ExchangeOracle oracle;

    IERC20 private constant ZERO_ADDRESS = IERC20(0x0000000000000000000000000000000000000000); // eth address substitute
    IERC20 private constant ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE); // eth address substitute
    IOneSplit private constant oneSplitImpl = IOneSplit(0xc3037b2A1a9E9268025FF6d45Fe7095436446D52); // sets 1inch protocol

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
    * this sets the treasury, and oracle
    */

    function setTreasury(address payable _treasury) public onlyOwner {
        treasury = Bank(_treasury);
    }

    function setOracle(address _oracle) public onlyOwner {
        oracle = ExchangeOracle(_oracle);
        oracleAddress = _oracle;
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
    */
    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags // See constants in IOneSplit.sol
    )
    public
    view
    returns(
        uint256 returnAmount,
        uint256[] memory distribution
    )
    {
        return oneSplitImpl.getExpectedReturn(
            fromToken,
            destToken,
            amount,
            parts,
            flags
        );
    }

    /**
     * @dev Swap `amount` of `fromToken` to 'destToken`
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
    ) external payable {
        // makes sure tokens aren't the same and amount is greater than 0
        require(fromToken != destToken && amount > 0, "Unable to swap");
        // makes sure msg.value is only being used for eth
        require((msg.value != 0) == fromToken.isETH(), "msg.value can only be used for eth");

        if (_exchangeWithChromium(fromToken, destToken, minReturn)) {
            fromToken.universalApprove(address(this), amount);

            fromToken.universalTransferFrom(msg.sender, address(treasury), amount);
            destToken.universalTransferFrom(address(treasury), msg.sender, minReturn);

            emit tokensExchanged(address(fromToken), amount, address(destToken), minReturn);
        } else {
            uint fromTokenBalanceBefore = SafeMath.sub(fromToken.universalBalanceOf(address(this)), msg.value);
            uint destTokenBalanceBefore = destToken.universalBalanceOf(address(this));

            fromToken.universalTransferFromSenderToThis(amount);
            fromToken.universalApprove(address(oneSplitImpl), amount);

            oneSplitImpl.swap{value:msg.value}(
                fromToken,
                destToken,
                amount,
                minReturn,
                distribution,
                flags
            );

            uint fromTokenBalanceAfter = fromToken.universalBalanceOf(address(this));
            uint destTokenBalanceAfter = destToken.universalBalanceOf(address(this));
            uint returnAmount = SafeMath.sub(destTokenBalanceAfter, destTokenBalanceBefore);

            require(returnAmount >= minReturn, "actual return amount is less than min return amount");
            destToken.universalTransfer(msg.sender, returnAmount);

            if (fromTokenBalanceAfter > fromTokenBalanceBefore) {
                fromToken.universalTransfer(msg.sender, SafeMath.sub(fromTokenBalanceAfter, fromTokenBalanceBefore));
            }
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
        _token.universalTransferFrom(msg.sender, address(treasury), _tokenAmount);
        emit depositToken(msg.sender, _tokenAmount);
    }

    /**
     * @dev allows for tokens to be added to the exchange
     * this needs to be done before adding any liquidity for the token
     */
    function _allowToken(IERC20 _token) public onlyOwner {
        allowedTokens[_token] = true;
    }

    /**
     * @dev method determines if chromium is able to make the exchange, if chromium cant make the exchange
     * then it will return false and the 1inch protocol will complete the exchange
     * @param _minReturn is the _minReturn that is returned from "getExpectedReturnWithGas"
    */
    function _exchangeWithChromium(IERC20 _fromToken, IERC20 _destToken, uint _minReturn) internal view returns (bool) {
        if (allowedTokens[_fromToken] == true && allowedTokens[_destToken] == true) {
            if (_minReturn <= treasury.totalTokenSupply(address(_destToken))) {
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

        if(result) {
            (uint256 sellTokenValue, uint256 buyTokenValue) =
            abi.decode(data, (uint256, uint256));
            value = sellTokenValue + buyTokenValue;
        }

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
    }

    // fallback function
    receive() external payable {}
}
