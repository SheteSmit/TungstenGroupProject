pragma solidity >=0.6.0 <0.8.0;

contract NFTLoan {
    
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    
    string internal nftName;
    
    mapping (uint256 => address) internal ownerId;
    mapping (address => uint256) private ownerToNFTokenCount;
    mapping (uint256 => string) internal idToUri;
    
    
    function _mint(address _to, uint256 _tokenId) internal virtual {
        
        require(_to != address(0)); 
        require(ownerId[_tokenId] == address(0)); 

        _addNFToken(_to, _tokenId);

        emit Transfer(address(0), _to, _tokenId);
    }
  
    function _addNFToken(address _to, uint256 _tokenId) internal virtual {
        require(ownerId[_tokenId] == address(0));

        ownerId[_tokenId] = _to;
        ownerToNFTokenCount[_to] = ownerToNFTokenCount[_to] + 1;
    }
    
    function _removeNFToken(address _from, uint256 _tokenId) internal virtual {
        require(ownerId[_tokenId] == _from); 
        ownerToNFTokenCount[_from] = ownerToNFTokenCount[_from] - 1;
        delete ownerId[_tokenId];
    }
  
    //testing
    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0)); 
        return _getOwnerNFTCount(_owner);
    }
  
    function _getOwnerNFTCount(address _owner) internal virtual view returns (uint256) {
        return ownerToNFTokenCount[_owner];
    }
  
    //testing
    function ownerOf(uint256 _tokenId) external view returns (address _owner) {
        _owner = ownerId[_tokenId];
        require(_owner != address(0)); 
    }
    
    function _setTokenUri(uint256 _tokenId, string memory _uri) internal validNFToken(_tokenId){
        idToUri[_tokenId] = _uri;
        nftName = _uri;
    }
  
    modifier validNFToken(uint256 _tokenId) {
        require(ownerId[_tokenId] != address(0));
        _;
    }
    
    //testing
    function name() external view returns (string memory _name) {
        _name = nftName;
    }
    
    function _safeTransferFrom(address _from, address _to, uint256 _tokenId) private canTransfer(_tokenId) validNFToken(_tokenId) {
        address tokenOwner = ownerId[_tokenId];
        require(tokenOwner == _from);
        require(_to != address(0));

        _transfer(_to, _tokenId);
    }
    
    modifier canTransfer(uint256 _tokenId) {
        address tokenOwner = ownerId[_tokenId];
        require(tokenOwner == msg.sender);
        _;
    }
    
    function _transfer(address _to, uint256 _tokenId) internal {
        address from = ownerId[_tokenId];
        _removeNFToken(from, _tokenId);
        _addNFToken(_to, _tokenId);

        emit Transfer(from, _to, _tokenId);
    }
    
    function mint(address _to, uint256 _tokenId, string memory _uri) public {
        _mint(_to, _tokenId);
        _setTokenUri(_tokenId, _uri);
    }
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external {
        _safeTransferFrom(_from, _to, _tokenId);
    }
    
}
