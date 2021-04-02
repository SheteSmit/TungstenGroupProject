
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Ownable.sol";

contract ExchangeOracle is Ownable {
    address[] trackedTokens; // Stores all address of supported tokens
    mapping(address => Token) public tokenData; // Token information accessed by token address

    // Struct saving token data
    struct Token {
        string name;
        string symbol;
        string img;
        uint256 value;
        bool active;
    }
    // Events
    event deletedToken(address token);
    event tokenUpdatedData(
        string _name,
        string _symbol,
        string _img,
        uint256 _value
    );

    function addToken(
        address _tokenAddress,
        string memory _name,
        string memory _symbol,
        string memory _img,
        uint256 _value
    ) public onlyOwner {
        // Add token struct to mapping using token contract address
        tokenData[_tokenAddress] = Token(_name, _symbol, _img, _value, true);
        // Push address to array of tokens tracked
        trackedTokens.push(_tokenAddress);
        // Push address of token added to trackedTokens
        emit tokenUpdatedData(_name, _symbol, _img, _value);
    }

    function updateToken(
        address _tokenAddress,
        string memory _name,
        string memory _symbol,
        string memory _img,
        uint256 _value,
        bool _active
    ) public onlyOwner {
        // Update token data
        tokenData[_tokenAddress] = Token(_name, _symbol, _img, _value, _active);
        // Emit event with new token information
        emit tokenUpdatedData(_name, _symbol, _img, _value);
    }
    
    function getValue(address _tokenAddress) public view returns(uint) {
        return tokenData[_tokenAddress].value;
    }
}
