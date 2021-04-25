// pragma solidity >=0.4.22 <0.9.0;

// contract Bank {
//     // **************************** Staking *******************************

//     mapping(address => User) userBook;

//     struct User {
//         uint256 timeBalanceChanged;
//         uint256 firstDepositTime;
//         uint256 rewardWallet;
//         uint256 ethBalance;
//         uint256 timeLocked;
//     }

//     function calculateReward() public returns (uint256) {
//         uint256 timeBetweenDeposits =
//             SafeMath.div(
//                 SafeMath.sub(
//                     block.timestamp, // Current time
//                     userBook[msg.sender].timeBalanceChanged // Time of last deposit
//                 ),
//                 2629743
//             ); // Month in epoch value

//         (bool result, bytes memory data) =
//             oracleAddress.call(abi.encodeWithSignature("ETHPrice()"));
//         // Decode bytes data
//         (uint256 ETHpriceNumerator, uint256 ETHpriceDenominator) =
//             abi.decode(data, (uint256, uint256));

//         uint256 newNumerator =
//             SafeMath.mul(rewardRate.numerator, timeBetweenDeposits);

//         // Calculate the amount Staked
//         uint256 stakingReward =
//             SafeMath.multiply(
//                 userBook[msg.sender].ethBalance,
//                 newNumerator,
//                 rewardRate.denominator
//             );

//         return stakingReward;
//     }

//     function depositEth(uint256 _timeLocked) public payable {
//         require(msg.value >= 1e16, "Error, deposit must be >= 0.01 ETH");

//         // Calculates staking reward
//         uint256 stakingReward = calculateReward();

//         // Save reward in wallet
//         userBook[msg.sender].rewardWallet = SafeMath.add(
//             userBook[msg.sender].rewardWallet,
//             stakingReward
//         );
//         // Save new eth deposit
//         userBook[msg.sender].ethBalance = SafeMath.add(
//             userBook[msg.sender].ethBalance,
//             msg.value
//         );
//         // Change the latest time of deposit
//         userBook[msg.sender].timeBalanceChanged = block.timestamp;

//         emit onReceived(msg.sender, msg.value);
//     }

//     function withdrawEth(uint256 _amount) public {
//         // Calulate how many days since first staked
//         uint256 daysAfterDeposit =
//             SafeMath.div(
//                 SafeMath.sub(
//                     block.timestamp,
//                     userBook[msg.sender].firstDepositTime
//                 ),
//                 86400
//             );

//         // Make sure user
//         require(daysAfterDeposit >= 30, "Wait 30 days to withdraw");
//         // Calculate staking reward
//         uint256 stakingReward = calculateReward();

//         // Save reward in wallet
//         userBook[msg.sender].rewardWallet = SafeMath.add(
//             userBook[msg.sender].rewardWallet,
//             stakingReward
//         );

//         // Substract eth from user account
//         userBook[msg.sender].ethBalance = SafeMath.sub(
//             userBook[msg.sender].ethBalance,
//             _amount
//         );
//         // Change the latest time of deposit
//         userBook[msg.sender].timeBalanceChanged = block.timestamp;

//         payable(msg.sender).transfer(_amount);
//     }

//     function withdrawStaking() public payable {
//         require(
//             userBook[msg.sender].rewardWallet >= 50,
//             "Reward wallet does not have 50$"
//         );
//     }

//     function changeAPR(uint256 _numerator, uint256 _denominator)
//         public
//         onlyOwner
//     {
//         rewardRate.numerator = _numerator;
//         rewardRate.denominator = _denominator;
//     }
// }
