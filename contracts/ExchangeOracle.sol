// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./interfaces/Ownable.sol";
import "./interfaces/SafeMath.sol";

contract ExchangeOracle is Ownable {
    uint256 USDpriceETH = 200000;
    mapping(address => Token) tokenData; // Token information accessed by token address

    // **************************************** DEV VOTE ************************************************

    struct Dev {
        bool active;
        bool vote;
    }

    mapping(address => Dev) devBook;
    address[] devArray;

    address[] contractSupported;

    address addressProposed;
    string proposedChange;
    uint256 intProposed;
    uint256 intProposed2;
    uint256 intProposed3;
    uint256 intProposed4;
    uint256 intProposed5;
    uint256 intProposed6;
    bool boolProposed;

    modifier validEntry {
        bool cleared;

        for (uint256 i = 0; i < contractSupported.length; i++) {
            if (msg.sender == contractSupported[i]) {
                cleared = true;
            }
        }

        require(
            cleared == true,
            "This contract cant interact with the dev panel"
        );
        _;
    }

    modifier onlyDev {
        bool cleared;

        for (uint256 i = 0; i < devArray.length; i++) {
            if (msg.sender == devArray[i]) {
                cleared = true;
            }
        }

        require(cleared == true, "Caller needs to be a dev");
        _;
    }

    function clearedAction(
        uint256 _percentage,
        string memory _callingFunctionChange
    ) public view {
        uint256 votes;
        uint256 totalVotes;

        for (uint256 i = 0; i < devArray.length; i++) {
            if (
                devBook[devArray[i]].vote == true &&
                devBook[devArray[i]].active == true
            ) {
                votes++;
            }
            if (devBook[devArray[i]].active == true) {
                totalVotes++;
            }
        }

        require(SafeMath.multiply(votes, totalVotes, 100) >= _percentage);
        require(
            keccak256(abi.encodePacked(proposedChange)) ==
                keccak256(abi.encodePacked(_callingFunctionChange))
        );
    }

    function acceptDev() public onlyDev {
        address newDev = addressChange(80, "acceptDev");
        devArray.push(newDev);
        devBook[newDev].active = true;
    }

    function deleteDev() public onlyDev {
        address status = addressChange(80, "deleteDev");
        devBook[status].active = false;
    }

    function vote() public onlyDev {
        devBook[msg.sender].vote = true;
    }

    function proposeBoolChange(bool _bool, string memory _proposedChange)
        public
        onlyDev
    {
        for (uint256 i = 0; i < devArray.length; i++) {
            devBook[devArray[i]].vote = false;
        }
        boolProposed = _bool;
        proposedChange = _proposedChange;
    }

    function boolChange(uint256 _percent, string memory _proposedChange)
        public
        onlyDev
        returns (bool)
    {
        clearedAction(_percent, _proposedChange);

        for (uint256 i = 0; i < devArray.length; i++) {
            devBook[devArray[i]].vote = false;
        }
        return (boolProposed);
    }

    function proposeNumberChange(uint256 _num, string memory _proposedChange)
        public
        onlyDev
    {
        for (uint256 i = 0; i < devArray.length; i++) {
            devBook[devArray[i]].vote = false;
        }
        intProposed = _num;
        proposedChange = _proposedChange;
    }

    function numberChange(uint256 _percent, string memory _proposedChange)
        public
        validEntry
        returns (uint256)
    {
        clearedAction(_percent, _proposedChange);

        for (uint256 i = 0; i < devArray.length; i++) {
            devBook[devArray[i]].vote = false;
        }
        return (intProposed);
    }

    function proposeAddressChange(
        address _address,
        string memory _proposedChange
    ) public onlyDev {
        for (uint256 i = 0; i < devArray.length; i++) {
            devBook[devArray[i]].vote = false;
        }

        addressProposed = _address;
        proposedChange = _proposedChange;
    }

    function addressChange(uint256 _percent, string memory _proposedChange)
        public
        validEntry
        returns (address)
    {
        clearedAction(_percent, _proposedChange);

        for (uint256 i = 0; i < devArray.length; i++) {
            devBook[devArray[i]].vote = false;
        }

        return addressProposed;
    }

    function proposeTierChange(
        uint256 _amountTier,
        uint256 _timeTier,
        uint256 _interest,
        uint256 _amountStakersLeft,
        uint256 _tierDuration,
        string memory _proposedChange
    ) public {
        for (uint256 i = 0; i < devArray.length; i++) {
            devBook[devArray[i]].vote = false;
        }
        intProposed = _amountTier;
        intProposed2 = _timeTier;
        intProposed3 = _interest;
        intProposed4 = _amountStakersLeft;
        intProposed5 = _tierDuration;

        proposedChange = _proposedChange;
    }

    function tierChange(uint256 _percent, string memory _proposedChange)
        public
        validEntry
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        clearedAction(_percent, _proposedChange);

        for (uint256 i = 0; i < devArray.length; i++) {
            devBook[devArray[i]].vote = false;
        }
        return (
            intProposed,
            intProposed2,
            intProposed3,
            intProposed4,
            intProposed5
        );
    }

    // ******************************** Token Data **********************************
    struct Token {
        uint256 value;
        bool active;
    }

    modifier activeToken(address _tokenAddress) {
        require(
            tokenData[_tokenAddress].active == true,
            "Token not currently supported."
        );
        _;
    }

    // Events
    event deletedToken(address token);

    event tokenUpdatedData(uint256 _value);

    constructor() {
        tokenData[0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE] = Token(
            1000000000000000000,
            true
        );
        // rinkeby weth address to work with uniswap
        tokenData[0xc778417E063141139Fce010982780140Aa0cD5Ab] = Token(
            53000000000000,
            true
        );
        tokenData[0x433C6E3D2def6E1fb414cf9448724EFB0399b698] = Token(
            53000000000000,
            true
        );
    }

    function updateToken(
        address _tokenAddress,
        uint256 _value,
        bool _status
    ) public {
        tokenData[_tokenAddress] = Token(_value, _status);
        emit tokenUpdatedData(_value);
    }

    function priceOfPair(address _sellTokenAddress, address _buyTokenAddress)
        public
        view
        returns (
            uint256 sellTokenPrice,
            uint256 buyTokenPrice,
            bool success
        )
    {
        if (tokenData[_sellTokenAddress].active) {
            return (
                tokenData[_sellTokenAddress].value,
                tokenData[_buyTokenAddress].value,
                true
            );
        } else {
            return (0, 0, false);
        }
    }

    function priceOfETHandCBLT(address _cbltToken)
        public
        view
        returns (uint256, uint256)
    {
        return (tokenData[_cbltToken].value, USDpriceETH);
    }

    function priceOfETH() public view returns (uint256) {
        return (USDpriceETH);
    }

    function priceOfToken(address _tokenAddress)
        public
        view
        activeToken(_tokenAddress)
        returns (uint256)
    {
        return (tokenData[_tokenAddress].value);
    }

    function testConnection()
        public
        pure
        returns (uint256 sellTokenPrice, uint256 buyTokenPrice)
    {
        return (1, 1);
    }
}
