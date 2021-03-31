// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import './ERC20.sol';
import './SafeMath.sol';

contract Chromium {

    event TokensPurchased(
        address account,
        address token,
        uint amount
    );

    event TokensSold(
        address account,
        address token,
        uint amount
    );

    function buyTokens(address _tokenAddress, uint256 _amountToSell, uint256 _priceOfSellToken, uint256 _priceOfBuyToken) public payable {

        token = ERC20(address(_tokenAddress));
        uint256 _exchangeRate = SafeMath.mul(_amountToSell, SafeMath.div(_priceOfSellToken, _priceOfBuyToken));

        // Require that Chromium has enough tokens
        require(token.balanceOf(address(this)) >= _exchangeRate);

        // Transfer tokens to the user
        token.transfer(msg.sender, _exchangeRate);

        // Emit an event
        emit TokensPurchased(msg.sender, address(token), _exchangeRate);
    }

}
