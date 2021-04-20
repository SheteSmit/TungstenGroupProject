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

pragma solidity ">=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract LoanNFT is ERC721 {

}

// pragma solidity >=0.6.0 <0.8.0;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

// contract LoanNFT is ERC721, Ownable {
//     using Counters for Counters.Counter;
//     Counters.Counter private _tokenIds;

//     constructor() ERC721("NFT-Example", "NEX") {}
// }
//     // Token name
//     string private _name;

//     // Token symbol
//     string private _symbol;

//     /* Emitted when `owner` enables `approved` to manage the `tokenId` token.*/
//     event Approval(
//         address indexed owner,
//         address indexed approved,
//         uint256 indexed tokenId
//     );

//     /* Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.*/
//     event ApprovalForAll(
//         address indexed owner,
//         address indexed operator,
//         bool approved
//     );

//     /* @dev Returns the number of tokens in ``owner``'s account. */
//     function balanceOf(address owner) external view returns (uint256 balance);

//     /* @dev Returns the owner of the `tokenId` token. Requirements: - `tokenId` must exist.*/
//     function ownerOf(uint256 tokenId) external view returns (address owner);

//     // Mapping from token ID to owner address
//     mapping(uint256 => address) private _owners;

//     // Mapping owner address to token count
//     mapping(address => uint256) private _balances;

//     // Mapping from token ID to approved address
//     mapping(uint256 => address) private _tokenApprovals;

//     // Mapping from owner to operator approvals
//     mapping(address => mapping(address => bool)) private _operatorApprovals;

//     /**
//      * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
//      */
//     constructor(string memory name_, string memory symbol_) {
//         _name = name_;
//         _symbol = symbol_;
//     }

//     /**
//      * @dev See {IERC721-balanceOf}.
//      */
//     function balanceOf(address owner)
//         public
//         view
//         virtual
//         override
//         returns (uint256)
//     {
//         require(
//             owner != address(0),
//             "ERC721: balance query for the zero address"
//         );
//         return _balances[owner];
//     }

//     /**
//      * @dev See {IERC721-ownerOf}.
//      */
//     function ownerOf(uint256 tokenId)
//         public
//         view
//         virtual
//         override
//         returns (address)
//     {
//         address owner = _owners[tokenId];
//         require(
//             owner != address(0),
//             "ERC721: owner query for nonexistent token"
//         );
//         return owner;
//     }

//     /**
//      * @dev See {IERC721Metadata-name}.
//      */
//     function name() public view virtual override returns (string memory) {
//         return _name;
//     }

//     /**
//      * @dev See {IERC721Metadata-symbol}.
//      */
//     function symbol() public view virtual override returns (string memory) {
//         return _symbol;
//     }

//     /**
//      * @dev See {IERC721Metadata-tokenURI}.
//      */
//     function tokenURI(uint256 tokenId)
//         public
//         view
//         virtual
//         override
//         returns (string memory)
//     {
//         require(
//             _exists(tokenId),
//             "ERC721Metadata: URI query for nonexistent token"
//         );

//         string memory baseURI = _baseURI();
//         return
//             bytes(baseURI).length > 0
//                 ? string(abi.encodePacked(baseURI, tokenId.toString()))
//                 : "";
//     }

//     interface ERC721Metadata {
//     function name() external view returns (string name);
//     function symbol() external view returns (string symbol);
//     function tokenURI(uint256 tokenId) external view returns (string);
// }

//     /**
//      * @dev Base URI for computing {tokenURI}. Empty by default, can be overriden
//      * in child contracts.
//      */
//     function _baseURI() internal view virtual returns (string memory) {
//         return "";
//     }

//     /**
//      * @dev See {IERC721-approve}.
//      */
//     function approve(address to, uint256 tokenId) public virtual override {
//         address owner = ERC721.ownerOf(tokenId);
//         require(to != owner, "ERC721: approval to current owner");

//         require(
//             _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
//             "ERC721: approve caller is not owner nor approved for all"
//         );

//         _approve(to, tokenId);
//     }

//     /**
//      * @dev See {IERC721-getApproved}.
//      */
//     function getApproved(uint256 tokenId)
//         public
//         view
//         virtual
//         override
//         returns (address)
//     {
//         require(
//             _exists(tokenId),
//             "ERC721: approved query for nonexistent token"
//         );

//         return _tokenApprovals[tokenId];
//     }

//     /**
//      * @dev See {IERC721-setApprovalForAll}.
//      */
//     function setApprovalForAll(address operator, bool approved)
//         public
//         virtual
//         override
//     {
//         require(operator != _msgSender(), "ERC721: approve to caller");

//         _operatorApprovals[_msgSender()][operator] = approved;
//         emit ApprovalForAll(_msgSender(), operator, approved);
//     }

//     /**
//      * @dev See {IERC721-isApprovedForAll}.
//      */
//     function isApprovedForAll(address owner, address operator)
//         public
//         view
//         virtual
//         override
//         returns (bool)
//     {
//         return _operatorApprovals[owner][operator];
//     }

//     /**
//      * @dev Returns whether `tokenId` exists.
//      *
//      * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
//      *
//      * Tokens start existing when they are minted (`_mint`),
//      * and stop existing when they are burned (`_burn`).
//      */
//     function _exists(uint256 tokenId) internal view virtual returns (bool) {
//         return _owners[tokenId] != address(0);
//     }

//     /**
//      * @dev Returns whether `spender` is allowed to manage `tokenId`.
//      *
//      * Requirements:
//      *
//      * - `tokenId` must exist.
//      */
//     function _isApprovedOrOwner(address spender, uint256 tokenId)
//         internal
//         view
//         virtual
//         returns (bool)
//     {
//         require(
//             _exists(tokenId),
//             "ERC721: operator query for nonexistent token"
//         );
//         address owner = ERC721.ownerOf(tokenId);
//         return (spender == owner ||
//             getApproved(tokenId) == spender ||
//             isApprovedForAll(owner, spender));
//     }

//     /**
//      * @dev Safely mints `tokenId` and transfers it to `to`.
//      *
//      * Requirements:
//      *
//      * - `tokenId` must not exist.
//      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
//      *
//      * Emits a {Transfer} event.
//      */
//     function _safeMint(address to, uint256 tokenId) internal virtual {
//         _safeMint(to, tokenId, "");
//     }

//     /**
//      * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
//      * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
//      */
//     function _safeMint(
//         address to,
//         uint256 tokenId,
//         bytes memory _data
//     ) internal virtual {
//         _mint(to, tokenId);
//         require(
//             _checkOnERC721Received(address(0), to, tokenId, _data),
//             "ERC721: transfer to non ERC721Receiver implementer"
//         );
//     }

//     /**
//      * @dev Mints `tokenId` and transfers it to `to`.
//      *
//      * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
//      *
//      * Requirements:
//      *
//      * - `tokenId` must not exist.
//      * - `to` cannot be the zero address.
//      *
//      * Emits a {Transfer} event.
//      */
//     function _mint(address to, uint256 tokenId) internal virtual {
//         require(to != address(0), "ERC721: mint to the zero address");
//         require(!_exists(tokenId), "ERC721: token already minted");

//         _beforeTokenTransfer(address(0), to, tokenId);

//         _balances[to] += 1;
//         _owners[tokenId] = to;

//         emit Transfer(address(0), to, tokenId);
//     }

//     /**
//      * @dev Destroys `tokenId`.
//      * The approval is cleared when the token is burned.
//      *
//      * Requirements:
//      *
//      * - `tokenId` must exist.
//      *
//      * Emits a {Transfer} event.
//      */
//     function _burn(uint256 tokenId) internal virtual {
//         address owner = ERC721.ownerOf(tokenId);

//         _beforeTokenTransfer(owner, address(0), tokenId);

//         // Clear approvals
//         _approve(address(0), tokenId);

//         _balances[owner] -= 1;
//         delete _owners[tokenId];

//         emit Transfer(owner, address(0), tokenId);
//     }

//     /**
//      * @dev Approve `to` to operate on `tokenId`
//      *
//      * Emits a {Approval} event.
//      */
//     function _approve(address to, uint256 tokenId) internal virtual {
//         _tokenApprovals[tokenId] = to;
//         emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
//     }

//     /**
//      * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
//      * The call is not executed if the target address is not a contract.
//      *
//      * @param from address representing the previous owner of the given token ID
//      * @param to target address that will receive the tokens
//      * @param tokenId uint256 ID of the token to be transferred
//      * @param _data bytes optional data to send along with the call
//      * @return bool whether the call correctly returned the expected magic value
//      */
//     function _checkOnERC721Received(
//         address from,
//         address to,
//         uint256 tokenId,
//         bytes memory _data
//     ) private returns (bool) {
//         if (to.isContract()) {
//             try
//                 IERC721Receiver(to).onERC721Received(
//                     _msgSender(),
//                     from,
//                     tokenId,
//                     _data
//                 )
//             returns (bytes4 retval) {
//                 return retval == IERC721Receiver(to).onERC721Received.selector;
//             } catch (bytes memory reason) {
//                 if (reason.length == 0) {
//                     revert(
//                         "ERC721: transfer to non ERC721Receiver implementer"
//                     );
//                 } else {
//                     // solhint-disable-next-line no-inline-assembly
//                     assembly {
//                         revert(add(32, reason), mload(reason))
//                     }
//                 }
//             }
//         } else {
//             return true;
//         }
//     }
// }
