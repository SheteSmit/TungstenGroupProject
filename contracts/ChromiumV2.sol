// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./interfaces/UniversalERC20.sol";
import "./interfaces/Ownable.sol";
import "./interfaces/IUniswap.sol";
import "./ExchangeOracle.sol";

contract ChromiumV2 {
    using UniversalERC20 for IERC20;

    event Received(address, uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);

    // ********************************** CONTRACT CONTROL *********************************

    /**
     * @dev ERC20 type for CBLT token.
     */
    IERC20 public token;

    /**
     * @dev Cobalt oracle contract.
     */
    ExchangeOracle public oracle;

    /**
     * @dev total contract balance in ETH.
     */
    uint256 public contractBalance;

    /**
     * @dev Exchange status. True - On / False - Off
     */
    bool public chromiumStatus;

    /**
     * @dev Bool enables the sellCBLT function. True - On / False - Off
     */
    bool public buyStatus;

    /**
     * @dev Setter function changes the address of CBLT token.
     */
    function setToken() public {
        // only devs
        address newToken = oracle.addressChange(50, "setToken");
        token = IERC20(newToken);
    }

    /**
     * @dev
     */
    function getContractBalance() public view returns (uint256) {
        return contractBalance;
    }

    /**
     * @dev
     */
    function setOracle() public {
        // only devs
        address newOracle = oracle.addressChange(50, "setOracle");
        oracle = ExchangeOracle(newOracle);
    }

    /**
     * @dev
     */
    function setChromiumStatus() public {
        // only devs
        bool status = oracle.boolChange(50, "setChromiumStatus");
        chromiumStatus = status;
    }

    /**
     * @dev
     */
    function setBuyStatus() public {
        // only devs
        bool status = oracle.boolChange(50, "setBuyStatus");
        buyStatus = status;
    }

    /**
     * @dev
     */
    constructor(address _oracleAddress) {
        token = IERC20(address(0x433C6E3D2def6E1fb414cf9448724EFB0399b698));
        oracle = ExchangeOracle(_oracleAddress);
        chromiumStatus = true;
        buyStatus = true;
        feeThreshold = 5e18;
        poolThreshold = 10000;
        flatFee = 3;
        percentFee = 3;
    }

    /**
     * @dev
     */
    receive() external payable {
        contractBalance = SafeMath.add(contractBalance, msg.value);
        emit Received(msg.sender, msg.value);
    }

    // ************************************ EXCHANGE ******************************************

    /**
     * @dev
     */
    uint256 public poolThreshold;

    /**
     * @dev
     */
    uint256 public highTokenPool;

    /**
     * @dev
     */
    uint256 public lowTokenPool;

    /**
     * @dev
     */
    function getPoolBalance(uint256 _poolNum) public view returns (uint256) {
        if (_poolNum == 1) {
            return highTokenPool;
        } else {
            return lowTokenPool;
        }
    }

    /**
     * @dev
     */
    function setThreshold() public {
        // only devs
        uint256 newLimit = oracle.numberChange(50, "setThreshold");
        poolThreshold = newLimit;
    }

    function fundTokenPool(uint256 _poolType, uint256 _amount) public {
        // only devs
        if (_poolType == 1) {
            IERC20(token).universalTransferFromSenderToThis(_amount);
            highTokenPool = SafeMath.add(highTokenPool, _amount);
        } else if (_poolType == 2) {
            IERC20(token).universalTransferFromSenderToThis(_amount);
            lowTokenPool = SafeMath.add(lowTokenPool, _amount);
        }
    }

    /**
     * @dev
     */
    modifier validBuy() {
        require(
            msg.value >= 15e15,
            "Error, deposit must be higher than 0.015 ETH"
        );
        require(
            chromiumStatus == true,
            "Exchange is currently offline, please try again later."
        );
        _;
    }

    /**
     * @dev
     */
    modifier validSell() {
        require(
            chromiumStatus == true,
            "Exchange is currently offline, please try again later."
        );
        require(buyStatus == true, "Buying feature is currently offline");

        _;
    }

    /**
     * @dev
     */
    function expectedBuyReturn(uint256 _amount)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 priceOfToken = oracle.priceOfToken(address(token));
        uint256 balance;
        uint256 tokenExpectedReturn;
        uint256 fee;

        (balance, fee) = calculateFee(_amount);
        tokenExpectedReturn = SafeMath.mul(
            1e18,
            SafeMath.div(balance, priceOfToken)
        );
        return (tokenExpectedReturn, balance, fee);
    }

    /**
     * @dev
     */
    function expectedSellReturn(uint256 _amount)
        public
        view
        returns (uint256, uint256)
    {
        uint256 priceOfToken;
        uint256 balance;
        uint256 fee;

        priceOfToken = oracle.priceOfToken(address(token));
        (balance, fee) = calculateFee(SafeMath.mul(_amount, priceOfToken));
        return (balance, fee);
    }

    /**
     * @dev
     */
    function calculateFee(uint256 _amount)
        public
        view
        returns (uint256, uint256)
    {
        uint256 newBalance;
        uint256 fee;

        if (_amount > feeThreshold) {
            fee = SafeMath.multiply(_amount, percentFee, 1000);
            newBalance = SafeMath.sub(_amount, fee);
        } else {
            uint256 ETHprice = oracle.priceOfETH();
            uint256 ETHinUSD = SafeMath.div(100000000000000000000, ETHprice);
            fee = SafeMath.mul(ETHinUSD, flatFee);
            newBalance = SafeMath.sub(_amount, fee);
        }

        return (newBalance, fee);
    }

    /**
     * @dev
     */
    function buyCBLT() public payable validBuy {
        uint256 tokensOwed;
        uint256 newBalance;
        uint256 fee;

        (tokensOwed, newBalance, fee) = expectedBuyReturn(msg.value);

        if (tokensOwed >= poolThreshold) {
            require(
                tokensOwed < highTokenPool,
                "Pool is currently depleted for this amount promised."
            );
            highTokenPool = SafeMath.sub(highTokenPool, tokensOwed);
        } else {
            require(
                tokensOwed < lowTokenPool,
                "Pool is currently depleted for this amount promised."
            );
            lowTokenPool = SafeMath.sub(lowTokenPool, tokensOwed);
        }

        totalFeeBalance = SafeMath.add(totalFeeBalance, fee);
        contractBalance = SafeMath.add(contractBalance, newBalance);
        IERC20(token).universalTransfer(msg.sender, tokensOwed);
    }

    /**
     * @dev
     */
    function sellCBLT(uint256 _amount) public payable {
        uint256 newBalance;
        uint256 fee;

        (newBalance, fee) = expectedSellReturn(_amount);
        require(
            newBalance < contractBalance,
            "Expected ETH return is higher than contract's balance."
        );
        totalFeeBalance = SafeMath.add(totalFeeBalance, fee);

        IERC20(token).universalTransferFromSenderToThis(
            SafeMath.mul(_amount, 1e18)
        );
        payable(msg.sender).transfer(newBalance);
    }

    //**************************************** FEE *****************************************

    /**
     * @dev
     */
    address public WithdrawContract;

    /**
     * @dev
     */
    uint256 public feeThreshold;

    /**
     * @dev Variable for staking flat fee.
     */
    uint256 public flatFee;

    /**
     * @dev Variable for staking flat fee.
     */
    uint256 public percentFee;

    /**
     * @dev Saving running fee total
     */
    uint256 public totalFeeBalance;

    /**
     * @dev
     */
    function setContract() public {
        address treasuryAddress = oracle.addressChange(50, "setContract");
        WithdrawContract = treasuryAddress;
    }

    /**
     * @dev
     */
    function getTotalBalance() public view returns (uint256) {
        return totalFeeBalance;
    }

    /**
     * @dev transfers funds to an approved contract
     */
    function withdrawFees(uint256 _amount) public payable onlyTreasury {
        require(
            _amount <= totalFeeBalance,
            "Treasury doesn't have sufficient funds."
        );
        totalFeeBalance = SafeMath.sub(totalFeeBalance, _amount);
        payable(msg.sender).transfer(_amount);
    }

    /**
     * @dev Setter for staking flat fee.
     * @notice This action can only be perform under dev vote.
     */
    function newFlatFee() public {
        uint256 newFee = oracle.numberChange(50, "newFlatFee");
        flatFee = newFee;
    }

    /**
     * @dev
     */
    function newPercentFee() public {
        uint256 newFee = oracle.numberChange(50, "newPercentFee");
        percentFee = newFee;
    }

    modifier onlyTreasury {
        require(
            msg.sender == WithdrawContract,
            "This address can't withdraw funds from treasury"
        );
        _;
    }

    //*********************************** Exchange Migration *************************************

    /**
     * @dev
     */
    address public migrationExchange;

    /**
     * @dev
     */
    function setExchangeAddress() public {
        // Only devs
        address newExchange = oracle.addressChange(50, "setExchangeAddress");
        migrationExchange = newExchange;
    }

    /**
     * @dev
     */
    function assetsMigration() public payable {
        uint256 totalTokenBalance = token.balanceOf(address(this));
        uint256 totalETHBalance = address(this).balance;

        IERC20(token).universalTransfer(migrationExchange, totalTokenBalance);
        payable(msg.sender).transfer(totalETHBalance);
    }
}
