// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./interfaces/Ownable.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/SafeMath.sol";
import "./interfaces/UniversalERC20.sol";

contract Staking {
    address oracleAddress;

    constructor() {
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

    function calc() public payable returns (uint256) {
        return
            SafeMath.div(1000000000000000000, SafeMath.mul(2000000000, 2843));
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

        // cbltToken.universalTransferFrom(address(this), to, _amount);
        userBook[msg.sender].cbltReserved = 0;
    }
}
