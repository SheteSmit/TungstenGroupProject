pragma solidity >=0.4.22 <0.9.0;

import "./ERC20.sol";

contract PeriodicLoan {
    /**
     * @dev mapping used to store all loan information with the key of borrower address
     *  and value of Loan struct with all loan information
     */
    mapping(address => Loan) loanBook;
    ERC20 token;

    /**
     * @dev Struct used to calculate interest rate
     */
    struct Rational {
        uint256 numerator;
        uint256 denominator;
    }
    /**
     * @dev Struct created so save all loan information
     */
    struct Loan {
        address borrower;
        uint256 dueDate;
        Rational interestRate;
        uint256 paymentPeriod;
        uint256 remainingBalance;
        uint256 minimumPayment;
        uint256 collateralPerPayment;
    }

    /**
     * @dev Recalculates interest and also conducts check and balances
     */
    function newLoan(
        uint256 interestRateNumerator,
        uint256 interestRateDenominator,
        uint256 _paymentPeriod,
        uint256 _minimumPayment,
        uint256 principal,
        uint256 units // User puts in the number for collateral .(no go must fix)
    ) public {
        loanBook[msg.sender] = Loan(
            msg.sender,
            (block.timestamp + _paymentPeriod),
            Rational(interestRateNumerator, interestRateDenominator),
            _paymentPeriod,
            principal,
            _minimumPayment,
            units
        );

        uint256 x = _minimumPayment * units;
        require(
            x / units == _minimumPayment,
            "minimumPayment * collateralPerPayment overflows"
        );
    }

    /**
     * @dev Prevents overflows
     *
     */
    function multiply(uint256 x, Rational memory r)
        internal
        pure
        returns (uint256)
    {
        return (x * r.numerator) / r.denominator;
    }

    /**
     * @dev Recalculates interest and also conducts check and balances
     *
     */
    function calculateComponents(uint256 amount)
        internal
        view
        returns (uint256 interest, uint256 principal)
    {
        interest = multiply(
            loanBook[msg.sender].remainingBalance,
            loanBook[msg.sender].interestRate
        );
        
        require(amount >= interest); //intrest would go back to treasury an be common goods

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
        uint256 product = loanBook[msg.sender].collateralPerPayment * payment;
        require(
            product / loanBook[msg.sender].collateralPerPayment == payment,
            "payment causes overflow"
        );
        units = product / loanBook[msg.sender].minimumPayment;
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
    function processPeriod(
        uint256 interest,
        uint256 principal,
        address recipient
    ) internal {
        uint256 units = calculateCollateral(interest + principal);

        loanBook[msg.sender].remainingBalance -= principal;

        loanBook[msg.sender].dueDate += loanBook[msg.sender].paymentPeriod;

        require(token.transfer(recipient, units));
    }

    /**
     * @dev Function for the user to make a payment with ETH
     *
     */
    function makePayment() public payable {
        require(now <= loanBook[msg.sender].dueDate);

        uint256 interest;
        uint256 principal;
        (interest, principal) = calculateComponents(msg.value);

        require(principal <= loanBook[msg.sender].remainingBalance);
        require(
            msg.value >= loanBook[msg.sender].minimumPayment ||
                principal == loanBook[msg.sender].remainingBalance
        );

        processPeriod(interest, principal, msg.sender);
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
        require(now > loanBook[msg.sender].dueDate);

        uint256 interest;
        uint256 principal;
        (interest, principal) = calculateComponents(
            loanBook[msg.sender].minimumPayment
        );

        if (principal > loanBook[msg.sender].remainingBalance) {
            principal = loanBook[msg.sender].remainingBalance;
        }

        processPeriod(interest, principal, );
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
        require(loanBook[msg.sender].remainingBalance == 0);

        uint256 amount = token.balanceOf(this);
        require(token.transfer(loanBook[msg.sender].borrower, amount));
    }
}
