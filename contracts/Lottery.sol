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

    function setAPI(address _newAPI) public {
        API = _newAPI;
    } // Only dev contract // Deployed on Binance

    function setLottery(bool _status) public {
        lotteryStatus = _status;
    } // Only dev contract // Deployed on Binance

    // ****************************** Lottery ******************************

    modifier validEntry() {
        require(lotteryStatus == true, "Lottery is currently offline");
        _;
    }
}
