// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Ownable.sol";
import "./ERC20.sol";
import "./SafeMath.sol";

contract Bank is Ownable {

    uint public rate = 10;

    event onReceived(address indexed _from, uint256 _amount);
    event onTransfer(address indexed _from, address indexed _to, uint256 _amount);
    event depositToken(address indexed _from, uint256 _amount);

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

    /**
    * @dev method that will withdraw tokens from the bank if the caller
    * has tokens in the bank
    */
    function withdraw(string memory _symbol, uint256 _amount) external {
        address _tokenAddress = tokensAllowed[_symbol];
        uint256 _tokenBalance = tokenOwnerBalance[_tokenAddress][msg.sender];
        token = ERC20(address(_tokenAddress));
        require(_amount <= _tokenBalance);
        if (_amount > 0) {
            _tokenSupply[_tokenAddress] = SafeMath.sub(_tokenSupply[_tokenAddress], _amount);
            tokenOwnerBalance[_tokenAddress][msg.sender] = SafeMath.sub(tokenOwnerBalance[_tokenAddress][msg.sender], _amount);
        }

        require(token.approve(msg.sender, _amount) == true, "Transfer not complete");
        emit onTransfer(msg.sender, address(0), _amount);
    }

    /**
    * @dev method to deposit tokens into the bank
    */
    function deposit(string memory _symbol) payable external {
        uint _amount = msg.value * rate;
        address _tokenAddress = tokensAllowed[_symbol];
        token = ERC20(address(_tokenAddress));

        if (_tokenSupply[_tokenAddress] > 0) {
            _tokenSupply[_tokenAddress] = SafeMath.add(_tokenSupply[_tokenAddress], _amount);
            tokenOwnerBalance[_tokenAddress][msg.sender] = SafeMath.add(tokenOwnerBalance[_tokenAddress][msg.sender], _amount);
        } else {
            _tokenSupply[_tokenAddress] = _amount;
            tokenOwnerBalance[_tokenAddress][msg.sender] = _amount;
        }

        emit depositToken(msg.sender, _amount);
    }

    /**
    * @dev function that will add a token to the list of supported tokens
    */
    function addToken(string memory _symbol, address _tokenAddress) external returns(bool) {
        tokensAllowed[_symbol] = _tokenAddress;
        return true;
    }

    /**
    * @dev function that will remove token from list of supported tokens
    */
    function removeToken(string memory _symbol) external onlyOwner returns (bool) {
        delete(tokensAllowed[_symbol]);
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
    function balanceOf(string memory _symbol) public view returns (uint256) {
        address _tokenAddress = tokensAllowed[_symbol];
        return tokenOwnerBalance[_tokenAddress][msg.sender];
    }

    /**
    * @dev fallback function to receive any eth sent to this contract
    */
    receive() payable external {
        emit onReceived(msg.sender, msg.value);
    }
}
