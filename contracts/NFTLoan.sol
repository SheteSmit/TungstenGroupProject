// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;
import "./interfaces/SafeMath.sol";

contract NFTLoan {
    string internal nftName;

    mapping(uint256 => address) internal ownerId;

    mapping(address => string) public data;

    mapping(address => uint256) private ownerToNFTokenCount;

    mapping(uint256 => string) public idToUri;

    modifier canTransfer(uint256 _tokenId) {
        address tokenOwner = ownerId[_tokenId];
        require(tokenOwner == msg.sender);
        _;
    }

    modifier validNFToken(uint256 _tokenId) {
        require(ownerId[_tokenId] != address(0));
        _;
    }

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    constructor() {
        nftName = "CNFT";
    }

    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0));
        return _getOwnerNFTCount(_owner);
    }

    function ownerOf(uint256 _tokenId) external view returns (address _owner) {
        _owner = ownerId[_tokenId];
        require(_owner != address(0));
    }

    function _safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) private canTransfer(_tokenId) validNFToken(_tokenId) {
        address tokenOwner = ownerId[_tokenId];
        require(tokenOwner == _from);
        require(_to != address(0));

        _transfer(_to, _tokenId);
    }

    function _transfer(address _to, uint256 _tokenId) internal {
        address from = ownerId[_tokenId];
        _removeNFToken(from, _tokenId);
        _addNFToken(_to, _tokenId);

        emit Transfer(from, _to, _tokenId);
    }

    function name() external view returns (string memory _name) {
        _name = nftName;
    }

    function _setTokenUri(uint256 _tokenId, string memory _uri)
        internal
        validNFToken(_tokenId)
    {
        idToUri[_tokenId] = _uri;
    }

    function _mint(address _to, uint256 _tokenId) internal {
        require(_to != address(0));
        require(ownerId[_tokenId] == address(0));

        _addNFToken(_to, _tokenId);

        emit Transfer(address(this), _to, _tokenId);
    }

    function mintBorrower(
        address _to,
        uint256 _tokenId,
        string memory _uri,
        string memory _data
    ) public {
        _mint(_to, _tokenId);
        _setTokenUri(_tokenId, _uri);
        setEncrypted(_to, _data);
    }

    function _addNFToken(address _to, uint256 _tokenId) internal {
        require(ownerId[_tokenId] == address(0));

        ownerId[_tokenId] = _to;
        ownerToNFTokenCount[_to] = ownerToNFTokenCount[_to] + 1;
    }

    function _removeNFToken(address _from, uint256 _tokenId) internal {
        require(ownerId[_tokenId] == _from);
        ownerToNFTokenCount[_from] = ownerToNFTokenCount[_from] - 1;
        delete ownerId[_tokenId];
    }

    function _getOwnerNFTCount(address _owner)
        internal
        view
        virtual
        returns (uint256)
    {
        return ownerToNFTokenCount[_owner];
    }

    function setEncrypted(address _to, string memory _data) internal {
        data[_to] = _data;
    }

    function seeData(address _from) public view returns (string memory _data) {
        return data[_from];
    }
}
