// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Ownable.sol";
import "./ERC20.sol";
import "./SafeMath.sol";

contract PeriodicLoan{
    
   
    

   
    

    

    


    
}




contract Bank is Ownable {
    uint256 public rate = 10;

    /**
     * @dev Added the Struct into from loan contract into the bank sol
     * 
     */

    struct Rational{
        uint256 numerator;
        uint256 denominator;
    }

    /**
     * @dev  Using variables needed to use theloan function properly
     */
    address lender;
    address borrower;
    Rational public interestRate;
    uint256 public dueDate;
    uint256 paymentPeriod;

    uint256 public remainingBalance;
    uint256 minimumPayment;

    ERC20 token;
    uint256 collateralPerPayment;

   

    event onReceived(address indexed _from, uint256 _amount);
    event onTransfer(
        address indexed _from,
        address indexed _to,
        uint256 _amount
    );
    event depositToken(address indexed _from, uint256 _amount);

    /**
     * @dev a list for each token and each user that has deposited some of that
     * token into the bank
     */
    mapping(address => mapping(address => uint256)) public tokenOwnerBalance;
    /**
     * @dev a list of all supported tokens
     */
    mapping(address => bool) public tokensAllowed;
    /**
     * @dev a ledger of the amount of each token in the bank
     */
    mapping(address => uint256) public _tokenSupply;

    /**
     * @dev a ledger of the amount of each token in the bank
     */
    mapping(address => uint256) public etherBalance;

    

    

    constructor(address[] _arrayAddress, ERC20 _token,

    address _lender,
    address _borrower,
    uint256 interestRateNumerator,
    uint256 interestRateDenominator,
    uint256 _paymentPeriod,
    uint256 _minimumPayment,
    uint256 principal,
    uint256 units) 
    public {  
    lender = _lender;
    borrower = _borrower;
    interestRate = Rational(interestRateNumerator, interestRateDenominator);
    paymentPeriod = _paymentPeriod;
    minimumPayment = _minimumPayment;
    remainingBalance = principal;
    token = _token;
    collateralPerPayment = units;
    
    uint256 x = minimumPayment * collateralPerPayment;
        require(x / collateralPerPayment == minimumPayment,
            "minimumPayment * collateralPerPayment overflows");

        dueDate = now + paymentPeriod;

    
    }

    /**
     * @dev method that will withdraw tokens from the bank if the caller
     * has tokens in the bank
     */
    function withdrawTokens(address _tokenAddress, uint256 _amount) external {
        //Check if token is not supported by bank
        require(tokensAllowed[_tokenAddress] == true, "Token is not supported");
        // Is the user trying to withdraw more tokens than he has in balance?
        require(_amount <= tokenOwnerBalance[_tokenAddress][msg.sender]);
        // Withdraw cannot be equal to zero
        require(_amount != 0, "Withdraw amount cannot be equal to 0");

        token = ERC20(address(_tokenAddress));

        _tokenSupply[_tokenAddress] = SafeMath.sub(
            _tokenSupply[_tokenAddress],
            _amount
        );
        tokenOwnerBalance[_tokenAddress][msg.sender] = SafeMath.sub(
            tokenOwnerBalance[_tokenAddress][msg.sender],
            _amount
        );

        require(
            token.transfer(msg.sender, _amount) == true,
            "Transfer not complete"
        );
        emit onTransfer(msg.sender, address(0), _amount);
    }

    /**
     * @dev method to withdraw eth from account
     */

    function withdraw(uint256 _amount) external {
        require(_amount <= etherBalance[msg.sender]);
        require(_amount != 0, "Withdraw amount cannot be equal to 0");

        etherBalance[msg.sender] = SafeMath.sub(
            etherBalance[msg.sender],
            _amount
        );

        msg.sender.transfer(_amount);

        emit onTransfer(msg.sender, address(0), _amount);
    }

    /**
     * @dev method to deposit tokens into the bank
     */
    function depositTokens(address _tokenAddress, uint256 _tokenAmount)
        external
        payable
    {
        //Check if token is not supported by bank
        require(tokensAllowed[_tokenAddress] == true, "Token is not supported");
        token = ERC20(address(_tokenAddress));

        _tokenSupply[_tokenAddress] = SafeMath.add(
            _tokenSupply[_tokenAddress],
            _tokenAmount
        );
        tokenOwnerBalance[_tokenAddress][msg.sender] = SafeMath.add(
            tokenOwnerBalance[_tokenAddress][msg.sender],
            _tokenAmount
        );

        require(
            token.transferFrom(msg.sender, address(this), _tokenAmount) == true,
            "Transfer not complete"
        );

        emit depositToken(msg.sender, _tokenAmount);
    }

    /**
     * @dev method to deposit eth into the bank
     */
    function deposit() external payable {
        etherBalance[msg.sender] = SafeMath.add(
            etherBalance[msg.sender],
            msg.value
        );

        emit depositToken(msg.sender, msg.value);
    }

    /**
     * @dev function that will add a token to the list of supported tokens
     */
    function addToken(address _tokenAddress) external onlyOwner returns (bool) {
        tokensAllowed[_tokenAddress] = true;
        return true;
    }

    /**
     * @dev function that will remove token from list of supported tokens
     */
    function removeToken(address _tokenAddress)
        external
        onlyOwner
        returns (bool)
    {
        delete (tokensAllowed[_tokenAddress]);
        return true;
    }

    /**
     * @dev method that will show the total amount of tokens in the bank for
     */
    function totalTokenSupply(address _tokenAddress)
        public
        view
        returns (uint256)
    {
        return _tokenSupply[_tokenAddress];
    }

    /**
     * @dev method that will show the balance that the caller has
     * for a certain token
     */
    function balanceOf(address _tokenAddress) public view returns (uint256) {
        if (_tokenAddress == 0x0) {
            return etherBalance[msg.sender];
        } else {
            return tokenOwnerBalance[_tokenAddress][msg.sender];
        }
    }

    /**
     * @dev fallback function to receive any eth sent to this contract
     */

    receive() external payable {
        emit onReceived(msg.sender, msg.value);
    }



    // All loan contract functions Here

    /**
     * @dev 
     * 
     */
    function multiply(uint256 x, Rational r) internal pure returns (uint256) {
        return x * r.numerator / r.denominator;
    }

    /**
     * @dev 
     * 
     */

      function calculateComponents(uint256 amount)
        internal
        view
        returns (uint256 interest, uint256 principal)
    {
        interest = multiply(remainingBalance, interestRate);
        require(amount >= interest);
        principal = amount - interest;
        return (interest, principal);
    }


     /**
     * @dev he loan is parameterized with collateralPerPayment, 
     *which represents the amount of collateral that will be returned
     * or forfeited based on a minimumPayment. If the borrower pays an 
     *amount different than the minimum, the amount of collateral returned 
     * is adjusted proportionally.
     * 
     */

     function calculateCollateral(uint256 payment)
        internal
        view
        returns (uint256 units)
    {
        uint256 product = collateralPerPayment * payment;
        require(product / collateralPerPayment == payment, "payment causes overflow");
        units = product / minimumPayment;
        return units;
    }


     /**
     * @dev a symmetry between accepting loan payments and handling missed payments. 
     * In both cases, there is an adjustment to the remaining principal balance and a 
     * corresponding transfer of tokens. The only difference is that the tokens are 
     * returned to the borrower after a payment, but they are forfeited to the lender 
     * after a missed payment
     * 
     *Additional Note: the code above does the token transfer last, which follows the 
     * Checks-Effects-Interactions pattern to avoid potential reentrancy vulnerabilities
     */
     function processPeriod(uint256 interest, uint256 principal, address recipient) internal {
        uint256 units = calculateCollateral(interest+principal);

        remainingBalance -= principal;

        dueDate += paymentPeriod;

        require(token.transfer(recipient, units));
    }

      /**
     * @dev 
     * 
     */
     function makePayment() public payable {
        require(now <= dueDate);

        uint256 interest;
        uint256 principal;
        (interest, principal) = calculateComponents(msg.value);

        require(principal <= remainingBalance);
        require(msg.value >= minimumPayment || principal == remainingBalance);

        processPeriod(interest, principal, borrower);
    }



    
     

      /**
     * @dev  computes the principal component of the missed payment. 
     * This assumes the payment was the minimum amount, which is true
     * for all but, possibly, the last payment. The conditional handles 
     * the boundary condition when the principal remaining is less than 
     * the principal component of a minimum payment.
     * 
     */
    function missedPayment() public {
        require(now > dueDate);

        uint256 interest;
        uint256 principal;
        (interest, principal) = calculateComponents(minimumPayment);

        if (principal > remainingBalance) {
            principal = remainingBalance;
        }



    
      /**
     * @dev  smart contract allows borrowers to pay more than the minimum, 
     * which will ultimately lead to less total paid because of avoided interest.
     * If used, this feature will lead to excess collateral owned by the loan contract
     * after it’s been fully paid off. This collateral belongs to the borrower. 
     * The simplest way to handle that is to allow excess tokens to be claimed when the remainingBalance is zero:
     * 
     */
     function returnCollateral() public {
        require(remainingBalance == 0);

        uint256 amount = token.balanceOf(this);
        require(token.transfer(borrower, amount));
    }



// Big problem Bank allready has an withdraw but this loan contract has a withdrawal as well.
    function withdraw() public {
    lender.transfer(address(this).balance);
    }
        processPeriod(interest, principal, lender);
    }

}
