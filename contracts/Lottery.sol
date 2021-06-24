// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./interfaces/Ownable.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/SafeMath.sol";
import "./interfaces/UniversalERC20.sol";
import "./ExchangeOracle.sol";
import "./NFTLoan.sol";

contract Lottery {
    address private API;

    bool public lotteryStatus;

    uint256 flatTicketPrice;

    function setAPI(address _newAPI) public {
        API = _newAPI;
    } // Only dev contract // Deployed on Binance

    function setLottery(bool _status) public {
        lotteryStatus = _status;
    } // Only dev contract // Deployed on Binance

    function setTicketPrice(uint256 _amount) public {
        flatTicketPrice = _amount;
    } // Only dev contract // Deployed on Binance

    // ****************************** Lottery - Staking ******************************

    uint256 lotteryTicketCap;

    struct Lotteryticket {
        address[] participants;
        address[] winners;
        uint256 dateCreated;
        bool ended;
    }

    mapping(uint256 => Lotteryticket) lotteryBook;

    function getLotteryParticipants(uint256 _lotteryTicket)
        public
        view
        returns (address[] memory)
    {
        return lotteryBook[_lotteryTicket].participants;
    }

    function getLotteryWinners(uint256 _lotteryTicket)
        public
        view
        returns (address[] memory)
    {
        return lotteryBook[_lotteryTicket].winners;
    }

    modifier validEntry(uint256 _lotteryTicket) {
        require(lotteryStatus == true, "Lottery is currently offline");
        require(
            lotteryBook[_lotteryTicket].dateCreated > 0,
            "Ticket does not exist"
        );
        require(
            lotteryBook[_lotteryTicket].ended == false,
            "Lottery ticket instance ended"
        );
        require(
            msg.value >= flatTicketPrice,
            "Value sent is less than ticket price"
        );
        _;
    }

    function createTicket(uint256 _numParticipants, uint256 _numWinners)
        public
    {
        lotteryBook[lotteryTicketCap] = Lotteryticket(
            new address[](_numParticipants),
            new address[](_numWinners),
            block.timestamp,
            false
        );
    } // Only dev contract // Deployed on Binance

    function buyLotteryTicket(uint256 _lotteryTicket)
        public
        payable
        validEntry(_lotteryTicket)
    {
        lotteryBook[_lotteryTicket].participants.push(msg.sender);
    }
}
