// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Ownable.sol";
import "./ERC20.sol";
import "./SafeMath.sol";

contract Bank is Ownable {

    event onTransfer(address indexed _from, address indexed _to, uint256 _amount);
    event depositToken(address indexed _from, uint256 _amount);

    address public owner;
    /**
    * @dev a list for each token and each user that has deposited some of that
    * token into the bank
    */
    mapping(address => mapping(address => uint256)) public tokenOwnerBalance;
    /**
    * @dev a list of all supported tokens
    */
    mapping(string => address) public tokensAllowed;
    /**
    * @dev a ledger of the amount of each token in the bank
    */
    mapping(address => uint256) public _tokenSupply;

    ERC20 token;

    constructor() {
        owner = msg.sender;
    }

    /**
    * @dev method that will withdraw tokens from the bank if the caller
    * has tokens in the bank
    */
    function withdraw(string memory _symbol, uint256 _amount) onlyOwner external {
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

    /**
    * @dev method to deposit tokens into the bank
    */
    function deposit(string memory _symbol, uint256 _amount) payable external {
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

    /**
    * @dev function that will add a token to the list of supported tokens
    */
    function addToken(string memory _symbol, address _tokenAddress) external returns(bool) {
        tokensAllowed[_symbol] = _tokenAddress;
        return true;
    }

    /**
    * @dev method that will show the total amount of tokens in the bank for
    */
    function totalTokenSupply(string memory _symbol) public view returns (uint256) {
        address _tokenAddress = tokensAllowed[_symbol];
        return _tokenSupply[_tokenAddress];
    }

    /**
    * @dev method that will show the balance that the caller has
    * for a certain token
    */
    function balanceOf(string memory _symbol, address _customerAddress) public view returns (uint256) {
        address _tokenAddress = tokensAllowed[_symbol];
        return tokenOwnerBalance[_tokenAddress][_customerAddress];
    }


}
