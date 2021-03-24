pragma solidity >=0.4.22 <0.9.0;

contract HAM {
    string public name = "HAMToken";
    string public symbol = "HAM";
    uint8 public decimals = 18;

    uint256 public _totalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => uint256) timestamp; // timestamp of last borrowed time

    // an event that is triggered whenever a transaction is approved
    event Approval(
        address indexed _tokenOwner,
        address indexed _spender,
        uint256 _amount
    );
    event Borrowed(address borrower, uint256 amount, uint256 timestamp);

    // an event that is triggered whenever a transaction is transferred
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);

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
        return balances[msg.sender];
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
        _transfer(msg.sender, _to, _amount);
        return true;
    }

    // approves the transaction
    function approve(address _spender, uint256 _amount) public returns (bool) {
        _approve(msg.sender, _spender, _amount);
        return true;
    }

    // transfer to accounts not from the msg sender
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool) {
        _transfer(_from, _to, _amount);

        uint256 currentAllowance = allowed[_from][msg.sender];
        require(currentAllowance >= _amount, "You don't have enough tokens");
        _approve(_from, msg.sender, currentAllowance - _amount);

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

    // requirements for the transfer function
    function _transfer(
        address _sender,
        address _to,
        uint256 _amount
    ) internal virtual {
        // make sure that the sender isn't using the token's address
        require(_sender != address(0), "You cant transfer from this contract");
        require(_to != address(0), "You can send tokens to this contract");

        // make sure the sender has enough tokens

        uint256 senderBalance = balances[_sender];
        require(senderBalance >= _amount, "You don't have enough tokens");
        balances[_sender] = senderBalance - _amount;
        balances[_to] += _amount;

        emit Transfer(_sender, _to, _amount);
    }

    // approves the transactions
    function _approve(
        address _owner,
        address _to,
        uint256 _amount
    ) internal virtual {
        // make sure you arent sending from or to token contract
        require(_owner != address(0), "Can't use token contract");
        require(_to != address(0), "Can't use token contract");

        allowed[_owner][_to] = _amount;
        emit Approval(_owner, _to, _amount);
    }
}
