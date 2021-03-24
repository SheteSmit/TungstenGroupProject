pragma solidity >=0.6.0 <0.8.0;

// ----------------------------------------------------------------------------
// Safe Math Library
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}

contract SmitCoin is SafeMath {
    string public name;
    string public symbol;
    uint8 public decimals; // 18 decimals is the strongly suggested default, avoid changing it

    uint256 public _totalSupply;

    mapping(address => uint256) balances; // user balance of tokens
    mapping(address => mapping(address => uint256)) allowed; // allowed accounts for spend
    mapping(address => uint256) timestamp; // timestamp of last borrowed time

    // Events

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
    event Borrowed(address borrower, uint256 amount, uint256 timestamp);

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor() public {
        name = "SmitCoin";
        symbol = "SMC";
        decimals = 18;
        _totalSupply = 100000000000000000000000000;

        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply - balances[address(0)];
    }

    function balanceOf(address tokenOwner)
        public
        view
        returns (uint256 balance)
    {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender)
        public
        view
        returns (uint256 remaining)
    {
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint256 tokens)
        public
        returns (bool success)
    {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
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

    function transfer(address to, uint256 tokens)
        public
        returns (bool success)
    {
        require(balances[msg.sender] >= tokens);

        balances[msg.sender] -= tokens;
        balances[to] += tokens;

        emit Transfer(msg.sender, to, tokens);

        return true;

        //balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        //balances[to] = safeAdd(balances[to], tokens);
        //emit Transfer(msg.sender, to, tokens);
        //return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public returns (bool success) {
        if (
            balances[from] >= tokens &&
            allowed[from][msg.sender] >= tokens &&
            tokens > 0
        ) {
            balances[to] += tokens;
            balances[from] -= tokens;
            allowed[from][msg.sender] -= tokens;
            emit Transfer(from, to, tokens);
            return true;
        } else {
            return false;
        }

        /*balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
        */
    }
}
