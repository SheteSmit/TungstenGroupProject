pragma solidity >=0.4.22 <0.9.0;

import "./interfaces/Ownable.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/SafeMath.sol";
import "./interfaces/UniversalERC20.sol";
import "./Chromium.sol";

contract Bank is Ownable {
    using UniversalERC20 for IERC20;

    /**
     * @dev modifier so that chromium can withdraw cblt form bank
     */
    modifier onlyChromium() {
        require(msg.sender == chromiumAddress);
        _;
    }
    /**
     * @dev storing CBLT token in ERC20 type
     */
    IERC20 token;

    /**
     * @dev CobaltLend oracle for scoring and CBLT price
     */
    address oracleAddress;

    /**
     * @dev chromium address for modifier
     */
    address chromiumAddress;

    /**
     * @dev reward rate ratio for staking
     */
    Rational rewardRate = Rational(1, 20);

    /**
     * @dev mapping used to store all loan information with the key of borrower address
     *  and value of Loan struct with all loan information
     */
    mapping(address => Loan) loanBook;
    mapping(uint256 => mapping(address => bool)) voteBook; // Signature key => mapping( voters => voted)

    constructor(
        address[] memory addresses,
        address _CBLT,
        address _oracle
    ) {
        for (uint256 i = 0; i < addresses.length; i++) {
            tokensAllowed[addresses[i]] = true;
        }
        oracleAddress = _oracle;
        token = IERC20(_CBLT);
        stakingRewardRate[1][1] = 5;
        stakingRewardRate[1][2] = 6;
        stakingRewardRate[1][3] = 7;
        stakingRewardRate[1][4] = 8;
        stakingRewardRate[1][5] = 9;
        //
        stakingRewardRate[2][1] = 6;
        stakingRewardRate[2][2] = 7;
        stakingRewardRate[2][3] = 8;
        stakingRewardRate[2][4] = 9;
        stakingRewardRate[2][5] = 10;
        //
        stakingRewardRate[3][1] = 7;
        stakingRewardRate[3][2] = 8;
        stakingRewardRate[3][3] = 9;
        stakingRewardRate[3][4] = 10;
        stakingRewardRate[3][5] = 14;
        //
        stakingRewardRate[4][1] = 9;
        stakingRewardRate[4][2] = 11;
        stakingRewardRate[4][3] = 13;
        stakingRewardRate[4][4] = 15;
        stakingRewardRate[4][5] = 17;
        //
        stakingRewardRate[5][1] = 10;
        stakingRewardRate[5][2] = 13;
        stakingRewardRate[5][3] = 16;
        stakingRewardRate[5][4] = 19;
        stakingRewardRate[5][5] = 20;
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
        bool active;
        bool initialized;
        uint256 timeCreated;
        uint256 yes;
        uint256 no;
        uint256 totalVote;
    }

    struct Vote {
        bool voted;
    }

    /**
     * @dev Struct used to store decimal values
     */
    struct Rational {
        uint256 numerator;
        uint256 denominator;
    }

    /**
     * @dev Events emitted
     */
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

    /**
     * @dev sets the chromium address
     */
    function setChromium(address payable _chromium) public onlyOwner {
        chromiumAddress = _chromium;
    }

    /**
     * @dev allows for chromium contract to see which tokens
     * are allowed to be deposited into treasury
     */
    function isTokenAllowed(address _token) public view returns (bool) {
        return tokensAllowed[_token];
    }

    /**
     * @dev allows for CBLT Tokens to be withdrawn from treasury
     * by chromium
     */
    function withdrawCbltForExchange(
        IERC20 fromToken,
        IERC20 cbltToken,
        address to,
        uint256 amount,
        uint256 minReturn
    ) public payable onlyChromium {
        require(
            amount <= totalTokenSupply(address(cbltToken)),
            "Not enough cblt tokens"
        );
        require(amount != 0, "withdraw amount cannot be equal to 0");

        fromToken.universalTransferFrom(msg.sender, address(this), amount);
        _tokenSupply[address(fromToken)] = SafeMath.add(_tokenSupply[address(fromToken)], amount);
        tokenOwnerBalance[address(fromToken)][chromiumAddress] = SafeMath.add(
            tokenOwnerBalance[address(fromToken)][chromiumAddress], amount);

        require(cbltToken.universalTransfer(to, minReturn), "Transaction failed to send.");
        _tokenSupply[address(cbltToken)] = SafeMath.sub(
            _tokenSupply[address(cbltToken)],
            minReturn
        );
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

        token = IERC20(address(_tokenAddress));

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

        payable(msg.sender).transfer(_amount);

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
        token = IERC20(address(_tokenAddress));

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
    function balanceOf() public view returns (uint256) {
        return etherBalance[msg.sender];
    }

    function balanceOfToken(address _tokenAddress)
        public
        view
        returns (uint256)
    {
        return tokenOwnerBalance[_tokenAddress][msg.sender];
    }

    /**
     * @dev fallback function to receive any eth sent to this contract
     */
    receive() external payable {
        etherBalance[address(this)] = SafeMath.add(
            etherBalance[address(this)],
            msg.value
        );
        emit onReceived(msg.sender, msg.value);
    }

    function swapTokensForCblt(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory distribution,
        uint256 flags
    ) external payable onlyOwner {
        require(minReturn <= tokenOwnerBalance[address(destToken)][chromiumAddress], "Chromium doesn't have enough tokens");

        tokenOwnerBalance[address(fromToken)][chromiumAddress] = SafeMath.sub(
            tokenOwnerBalance[address(fromToken)][chromiumAddress], amount);
        _tokenSupply[address(fromToken)] = SafeMath.sub(_tokenSupply[address(fromToken)], amount);

        uint returnAmount = chromium.swap{value: msg.value}(
            fromToken,
            destToken,
            amount,
            minReturn,
            distribution,
            flags);

        tokenOwnerBalance[address(destToken)][chromiumAddress] = SafeMath.add(
            tokenOwnerBalance[address(destToken)][chromiumAddress], returnAmount);
        _tokenSupply[address(destToken)] = SafeMath.add(_tokenSupply[address(destToken)], returnAmount);
    }

    // ****************************** Lending **********************************

    /**
     * @dev Recalculates interest and also conducts check and balances
     */
    function newLoan(
        uint256 interestRateNumerator,
        uint256 interestRateDenominator,
        uint256 _paymentPeriod,
        uint256 _minimumPayment,
        uint256 principal,
        uint256 units
    ) public payable {
        // Needs user approve on transfer funds amount
        // token.approve(address(this), _minimumPayment);
        // loanbook[msg.sender] -> loanbook[uint signature]

        require(loanBook[msg.sender].initialized == false);
        require(
            token.transferFrom(msg.sender, address(this), units * 12) == true,
            "Payment was not approved."
        );

        loanBook[msg.sender] = Loan(
            msg.sender,
            (block.timestamp + _paymentPeriod),
            Rational(interestRateNumerator, interestRateDenominator),
            _paymentPeriod,
            principal,
            _minimumPayment,
            units,
            false,
            true,
            block.timestamp,
            0,
            0,
            0
        );

        uint256 x = _minimumPayment * units;
        require(
            x / units == _minimumPayment,
            "minimumPayment * collateralPerPayment overflows"
        );
    }

    function tallyVotes() public {}

    /**
     * @dev Prevents overflows
     *
     */
    function multiplyDecimal(uint256 x, Rational memory r)
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
        // interest = multiply(
        //     loanBook[msg.sender].remainingBalance,
        //     loanBook[msg.sender].interestRate
        // );
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
        if (recipient == 0x0000000000000000000000000000000000000000) {
            uint256 units = calculateCollateral(interest + principal);

            loanBook[msg.sender].remainingBalance -= principal;

            loanBook[msg.sender].dueDate += loanBook[msg.sender].paymentPeriod;
        } else {
            uint256 units = calculateCollateral(interest + principal);

            loanBook[msg.sender].remainingBalance -= principal;

            loanBook[msg.sender].dueDate += loanBook[msg.sender].paymentPeriod;

            require(token.transfer(recipient, units));
        }
    }

    /**
     * @dev Function for the user to make a payment with ETH
     *
     */
    function makePayment() public payable {
        require(block.timestamp <= loanBook[msg.sender].dueDate);

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
        require(block.timestamp > loanBook[msg.sender].dueDate);

        uint256 interest;
        uint256 principal;
        (interest, principal) = calculateComponents(
            loanBook[msg.sender].minimumPayment
        );

        if (principal > loanBook[msg.sender].remainingBalance) {
            principal = loanBook[msg.sender].remainingBalance;
        }

        processPeriod(
            interest,
            principal,
            0x0000000000000000000000000000000000000000
        );
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

        uint256 amount = token.balanceOf(address(this));
        require(token.transfer(msg.sender, amount));
    }

    /**
     * @dev Deletes loan instance once the user has paid his first loan in full
     */
    function cleanSlate() public {
        require(loanBook[msg.sender].remainingBalance == 0);
        delete loanBook[msg.sender];
    }

    // **************************** Voting *******************************

    enum State {Created, Voting, Ended}
    State public state;

    modifier inState(State _state) {
        require(state == _state);
        _;
    }

    /**
     * @dev starts the voting process
     *
     */
    function startVote() internal inState(State.Created) {
        state = State.Voting;
    }

    /**
     * @dev DOES the vote takes in the voter choice
     *
     */

    function doVote(uint256 _signature, bool _vote)
        public
        inState(State.Voting)
        returns (bool voted)
    {
        // bool found = false;
        require(
            voteBook[_signature][msg.sender] == false,
            "You have already voted."
        );

        voteBook[_signature][msg.sender] = true;

        if (_vote == true) {
            loanBook[msg.sender].yes++;
        } else {
            loanBook[msg.sender].no++;
        }
        loanBook[msg.sender].totalVote++;

        return true;
    }

    /**
     * @dev Ends the voting
     *
     */

    // function endVote() internal inState(State.Voting) {
    //     state = State.Ended;
    //     finalResult = countResult;
    //     emit voteEnded(finalResult);
    // }

    // if voting is past 7 days then loan ends. Must be take take 21 votes

    // **************************** Staking *******************************

    mapping(uint256 => mapping(uint256 => uint256)) stakingRewardRate;

    mapping(address => User) userBook;

    uint256 CBLTReserve = 1000000000000000000000000000000000;

    struct User {
        uint256 depositTime;
        uint256 rewardWallet;
        uint256 ethBalance;
        uint256 cbltReserved;
        uint256 timeStakedTier;
        uint256 ethStaked;
    }

    function calculateReward(
        uint256 _amount,
        uint256 _timeStakedTier,
        uint256 _amountStakedTier
    ) public returns (uint256) {
        // Pull token price from oracle
        // (bool result, bytes memory data) =
        //     oracleAddress.call(
        //         abi.encodeWithSignature(
        //             "getValue(address)",
        //             0x29a99c126596c0Dc96b02A88a9EAab44EcCf511e
        //         )
        //     );
        // Decode bytes data
        // uint256 tokenPrice = abi.decode(data, (uint256));

        uint256 tokenPrice = 2000000000000;

        return
            SafeMath.div(
                SafeMath.multiply(
                    _amount,
                    stakingRewardRate[_timeStakedTier][_amountStakedTier],
                    100
                ),
                tokenPrice
            );
    }

    function depositEth(uint256 _timeStakedTier) public payable {
        // Check the amountStakedTier based on deposit
        uint256 _amountStakedTier;

        if (msg.value <= 4e17) {
            _amountStakedTier = 1;
        } else if (msg.value <= 2e18) {
            _amountStakedTier = 2;
        } else if (msg.value <= 5e18) {
            _amountStakedTier = 3;
        } else if (msg.value <= 25e18) {
            _amountStakedTier = 4;
        } else {
            _amountStakedTier = 5;
        }

        userBook[msg.sender].ethStaked = _amountStakedTier;

        // Minimum deposit of 0.015 ETH
        require(msg.value >= 15e16, "Error, deposit must be >= 0.015 ETH");

        // Checks the amount of CBLT tokens that need to be reserved
        uint256 cbltReserved =
            calculateReward(msg.value, _timeStakedTier, _amountStakedTier);

        // Treasury must have that amount open
        require(cbltReserved <= CBLTReserve, "Treasury is currently depleted");

        // Substract CBLT tokens reserved for stake from treasury
        CBLTReserve = SafeMath.sub(CBLTReserve, cbltReserved);

        // Saves the amount of CBLT tokens reserved in user struct
        userBook[msg.sender].cbltReserved = SafeMath.add(
            userBook[msg.sender].cbltReserved,
            cbltReserved
        );

        // Save information on the time tier
        userBook[msg.sender].timeStakedTier = _timeStakedTier;

        // Save new eth deposit in user account
        userBook[msg.sender].ethBalance = SafeMath.add(
            userBook[msg.sender].ethBalance,
            msg.value
        );

        // Change the time of deposit
        userBook[msg.sender].depositTime = block.timestamp;

        // emit onReceived(msg.sender, msg.value);
    }

    function withdrawEth(uint256 _amount) public {
        // Calulate how many months since first staked

        uint256 monthsAfterDeposit =
            SafeMath.div(
                SafeMath.sub(block.timestamp, userBook[msg.sender].depositTime),
                2629743
            );
        // Make sure user staked for at least 1 month
        // require(monthsAfterDeposit >= 1, "Wait 30 days to withdraw");

        uint256 _amountStakedTier;

        uint256 userBalance = userBook[msg.sender].ethBalance;

        if (userBalance <= 4e17) {
            _amountStakedTier = 5;
        } else if (userBalance <= 2e18) {
            _amountStakedTier = 4;
        } else if (userBalance <= 5e18) {
            _amountStakedTier = 3;
        } else if (userBalance <= 25e18) {
            _amountStakedTier = 2;
        } else {
            _amountStakedTier = 1;
        }

        uint256 stakedPeriodMonths;

        if (userBook[msg.sender].timeStakedTier == 1) {
            stakedPeriodMonths = 1;
        } else if (userBook[msg.sender].timeStakedTier == 2) {
            stakedPeriodMonths = 2;
        } else if (userBook[msg.sender].timeStakedTier == 3) {
            stakedPeriodMonths = 3;
        } else if (userBook[msg.sender].timeStakedTier == 4) {
            stakedPeriodMonths = 6;
        } else {
            stakedPeriodMonths = 12;
        }

        // Recalculate total CBLT tokens based on current token value
        uint256 stakingReward =
            calculateReward(
                userBook[msg.sender].ethBalance,
                userBook[msg.sender].timeStakedTier,
                _amountStakedTier
            );
        // Calculate staking reward based on months staked
        uint256 monthBasedReward =
            SafeMath.multiply(
                stakingReward,
                monthsAfterDeposit,
                stakedPeriodMonths
            );

        // Save reward in wallet
        userBook[msg.sender].rewardWallet = SafeMath.add(
            userBook[msg.sender].rewardWallet,
            stakingReward
        );

        // Substract eth from user account
        userBook[msg.sender].ethBalance = SafeMath.sub(
            userBook[msg.sender].ethBalance,
            _amount
        );
        // Change the latest time of deposit
        userBook[msg.sender].depositTime = block.timestamp;

        payable(msg.sender).transfer(_amount);
    }

    function testUserData()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            userBook[msg.sender].ethBalance,
            userBook[msg.sender].depositTime,
            userBook[msg.sender].cbltReserved,
            userBook[msg.sender].timeStakedTier,
            userBook[msg.sender].ethStaked
        );
    }

    function withdrawStaking(uint256 _amount) public payable {
        // Pull token price from oracle
        // (bool result, bytes memory data) =
        //     oracleAddress.call(
        //         abi.encodeWithSignature(
        //             "getValue(address)",
        //             0x29a99c126596c0Dc96b02A88a9EAab44EcCf511e
        //         )
        //     );
        // Decode bytes data

        // uint256 tokenPrice = abi.decode(data, (uint256));

        require(
            userBook[msg.sender].rewardWallet >= 50,
            "Reward wallet does not have 50$"
        );

        token.universalTransferFrom(address(this), msg.sender, _amount);
        userBook[msg.sender].cbltReserved = 0;
    }
    // Voting
    // Lending
    // Cobalt tokens saved on amount staked
    // Wallet only updated when user deposits or withdraws
    // Fixed period loans
    // Functions check the current balance the treasury has avaliable to stake
    // Tier system in place
    // Function to recalculate amount of cblt tokens reserved based on amount staked
    // 30 60 90 180 365
}

// 7 days
// 3 missed payments back to back
// 4 missed payment overall
// 6 years 100k ++++
// 2 years 100k ----

// ************************************* CHANGES ************************************

// mapping (uint id => Loan) loanBook;
// signature NFT

// loanBook[id]
// loanBook[id].signature // NFT

// function borrow() {
//     require(loanBook[id].signature == NFT.value)
// }

// ******************************** INCENTIVE SYSTEM *******************************

// tier 1 - Loan  50k - Max voters 100 - 5 per head
//        - msg.sender CBLTs > 300$ worth of ETH
// tier 2 - Loan 100k - Max voters 150 - 7.5 per head
//        - msg.sender CBLTs > 200
// tier 3 - Loan 200k - Max voters 200 - 10 per head
//        - msg.sender CBLTs > 400

// ************************************** TODOS ************************************

// Starting period, 12-24 months
// Collateral paid on loan application
// Create new function to handle application
// Create a new function to check if loan is ready to loan
// Array of all voters
// Save interest amount on loan to an specific

// Calling oracle from ABI

// (bool result, bytes memory data) =
//             oracleAddress.call(
//                 abi.encodeWithSignature(
//                     "priceOfPair(address,address)",
//                     _sellToken,
//                     _buyToken
//                 )
//             );
//         // Decode bytes data
//         (uint256 sellTokenValue, uint256 buyTokenValue) =
//             abi.decode(data, (uint256, uint256));
