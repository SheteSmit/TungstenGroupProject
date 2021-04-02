// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./ERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

contract Chromium is Ownable {
    ERC20 sellToken;
    ERC20 buyToken;
    address oracle;

    constructor(address _oracle) {
        oracle = _oracle;
    }

    mapping(address => uint256) tokenBalance;

    event TokensPurchased(address account, address token, uint256 amount);

    event TokensSold(address account, address token, uint256 amount);

    /**
     * @dev function that will allow people to exchange tokens
     * @param _sellTokenAddress the address of the token the user wants to exchange
     * @param _amountToSell the amount the user wants to exchange
     * @param _buyTokenAddress the address of the token the user wants to obtain
     * @param _priceOfSellToken price of the token that is being sold (obtain by api call to etherscan)
     * @param _priceOfBuyToken price of the token that is being obtained (obtain by api call to etherscan)
     */
    function exchangeTokens(
        address _sellTokenAddress,
        uint256 _amountToSell,
        address _buyTokenAddress,
        uint256 _priceOfSellToken,
        uint256 _priceOfBuyToken
    ) public payable {
        (bool result, bytes memory data) =
            oracle.call(
                abi.encodeWithSignature(
                    "priceOfPair(address,address)",
                    _sellTokenAddress,
                    _buyTokenAddress
                )
            );

        (uint256 sellTokenValue, uint256 buyTokenValue) =
            abi.decode(data, (uint256, uint256));

        sellToken = ERC20(address(_sellTokenAddress));
        buyToken = ERC20(address(_buyTokenAddress));
        uint256 _exchangeRate =
            SafeMath.mul(
                _amountToSell,
                SafeMath.div(_priceOfSellToken, _priceOfBuyToken)
            );

        // Require that Chromium has enough tokens
        require(tokenBalance[_buyTokenAddress] >= _exchangeRate);

        tokenBalance[_buyTokenAddress] = SafeMath.sub(
            tokenBalance[_buyTokenAddress],
            _exchangeRate
        );
        tokenBalance[_sellTokenAddress] = SafeMath.add(
            tokenBalance[_sellTokenAddress],
            _amountToSell
        );

        // Transfer tokens to the user
        buyToken.transfer(msg.sender, _exchangeRate);

        // Emit an event
        emit TokensPurchased(msg.sender, _buyTokenAddress, _exchangeRate);
    }

    function testCall() public payable returns (uint256 value) {
        (bool result, bytes memory data) =
            oracle.call(abi.encodeWithSignature("testConnection()"));

        (uint256 sellTokenValue, uint256 buyTokenValue) =
            abi.decode(data, (uint256, uint256));

        return sellTokenValue;
    }

    function updateOracle(address _newOracle) public onlyOwner {
        oracle = _newOracle;
    }
}
