// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Ownable.sol";
import "./ERC20.sol";
import "./SafeMath.sol";

contract Bank is Ownable {

    // different events for the contract
    event onTransfer(address indexed _from, address indexed _to, uint256 _amount);
    event depositToken(address indexed _from, uint256 _amount);
    event onReceived(address indexed _from, uint256 _amount);


    // setting constants
    address public owner;
    mapping(address => mapping(address => uint256)) internal tokenOwnerBalance;
    mapping(bytes32 => address) internal tokensAllowed;
    mapping(address => uint256) internal _tokenSupply;
    ERC20 token;

    constructor() {
        owner = msg.sender;
    }

    // function to withdraw tokens from bank
    function withdraw(bytes32 _symbol, uint256 _amount) onlyOwner external {
        address _tokenAddress = tokensAllowed[_symbol];
        uint256 _tokenBalance = tokenOwnerBalance[_tokenAddress][owner];
        token = ERC20(_tokenAddress);
        require(_amount <= _tokenBalance);
        if (_amount > 0) {
            _tokenSupply[_tokenAddress] = SafeMath.sub(_tokenSupply[_tokenAddress], _amount);
            tokenOwnerBalance[_tokenAddress][owner] = SafeMath.sub(tokenOwnerBalance[_tokenAddress][owner], _amount);
        }
        require(token.transferFrom(address(this), owner, _amount) == true, "Transfer not complete");
        emit onTransfer(owner, address(0), _amount);
    }

    // function to deposit tokens into bank
    function deposit(bytes32 _symbol, uint256 _amount) payable external {
        require(msg.value == _amount);
        address _tokenAddress = tokensAllowed[_symbol];
        require(_amount > 0, "You need to deposit more tokens.");
        if (_tokenSupply[_tokenAddress] > 0) {
            _tokenSupply[_tokenAddress] = SafeMath.add(_tokenSupply[_tokenAddress], _amount);
        } else {
            _tokenSupply[_tokenAddress] = _amount;
        }

        tokenOwnerBalance[_tokenAddress][owner] = SafeMath.add(tokenOwnerBalance[_tokenAddress][owner], _amount);

        require(token.transferFrom(owner, address(this), _amount) == true, "Transfer not complete");

        emit depositToken(owner, _amount);
    }

    function addToken(bytes32 _symbol, address _tokenAddress) external {
        tokensAllowed[_symbol] = _tokenAddress;
    }

    // shows the total supply of tokens in the bank
    function totalTokenSupply(bytes32 _symbol) public view returns (uint256) {
        address _tokenAddress = tokensAllowed[_symbol];
        return _tokenSupply[_tokenAddress];
    }

    // shows the customers balance
    function balanceOf(bytes32 _symbol, address _customerAddress) public view returns (uint256) {
        address _tokenAddress = tokensAllowed[_symbol];
        return tokenOwnerBalance[_tokenAddress][_customerAddress];
    }


}
