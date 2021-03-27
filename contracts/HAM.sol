// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract HAM {
    string public name = "HAMToken";
    string public symbol = "HAM";
    uint8 public decimals = 18;
    uint256 public _totalSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => uint256) timestamp; // timestamp of last borrowed time

    // Events
    event Borrowed(address borrower, uint256 amount, uint256 timestamp);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(
        address indexed _tokenOwner,
        address indexed _spender,
        uint256 _amount
    );

    constructor() public {
        _totalSupply = 10000000000000;
        balances[msg.sender] = _totalSupply;
    }

    // this function will return the total amount of tokens
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // will return the number of tokens the msg sender has left
    function balanceOf(address _tokenOwner) public view returns (uint256) {
        return balances[_tokenOwner];
    }

    // sets allowance
    function allowance(address _tokenOwner, address _spender)
        public
        view
        returns (uint256)
    {
        return allowed[_tokenOwner][_spender];
    }

    // transfers tokens from one user to another
    function transfer(address _to, uint256 _amount) public returns (bool) {
        uint256 senderBalance = balances[msg.sender];
        require(senderBalance >= _amount, "You don't have enough tokens");
        balances[msg.sender] = senderBalance - _amount;
        balances[_to] += _amount;

        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    // approves the transaction
    function approve(address _spender, uint256 _amount) public returns (bool) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    // transfer to accounts not from the msg sender
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool) {
        // make sure the sender has enough tokens
        uint256 senderBalance = balances[_from];
        require(senderBalance >= _amount, "You don't have enough tokens");
        balances[_from] = senderBalance - _amount;
        balances[_to] += _amount;

        emit Transfer(_from, _to, _amount);

        uint256 currentAllowance = allowed[_from][_to];
        require(currentAllowance >= _amount, "You don't have enough tokens");
        allowed[_from][_to] = _amount;
        emit Approval(_from, _to, _amount);

        return true;
    }

    function borrow(address _borrower, uint256 _amount) public payable {
        require(_amount <= 100000);
        balances[_borrower] =
            balances[_borrower] +
            (_amount * 1000000000000000000);
        timestamp[_borrower] = block.timestamp;
        emit Borrowed(_borrower, _amount, block.timestamp);
    }

    function donate(address _donator, uint256 _amount) public payable {
        require(balances[_donator] >= _amount * 1000000000000000000);
        balances[_donator] = balances[_donator] - _amount * 1000000000000000000;
    }
}
