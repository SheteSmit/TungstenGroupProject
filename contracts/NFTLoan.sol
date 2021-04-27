// SPDX-License-Identifier: MIT

/*
name
symbol
Risk Factor
# of Collateral
Past & Current Loans:
Loan Amount
Amount Remaining
Interest Rate
Payment Details
Time Period on Payments
Type of currency
USD Value
Total number of payments/loans
Total Interest
# of Voters - Payout Amount
Any failed loans

Ask: Do we need to make info public when loan is missed? Isnt it better to just show the voters all the info upfront? What kind of info should we show at the start vs make public?
*/
pragma solidity >=0.6.0 <0.8.0;

contract NFTLoan {
    address[16] public loan;
    uint256 item;
    uint256 price;
    bytes32 status;
    string[] public defaults;

    mapping(string => bool) _loanExists;

    //  Adding Loan
    function addingLoan(uint256 loanId) public returns (uint256) {
        require(loanId >= 0 && loanId <= 15);

        loan[loanId] = msg.sender;

        return loanId;
    }

    // Retrieving the loan
    function getLoan() public view returns (address[16] memory) {
        return loan;
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _mint(address to, uint256 tokenId) private {
        super._mint(to, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    // Mint Loan
    function mint(string memory _loan) public {
        require(!_loanExists[_loan]);
        uint256 _id = defaults.push(_loan);
        _mint(msg.sender, _id);
        _loanExists[_loan] = true;
    }
}
