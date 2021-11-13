pragma solidity ^0.8.0;
// // SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BuidlBagde_1 is ERC721URIStorage, Ownable {

    // limit delegations
    uint256 public constant D_LIMIT = 1;

    uint256 public tokenCounter = 1;
    string public tokenURI;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(address => uint256) public delegateLimit;

    constructor(string memory _baseURI) ERC721 ("BuidlGuidl Badge 1", "BG1") {
        tokenURI = _baseURI;
        transferOwnership(0x1c3FC6b664DB646Cbf91211c23b545b518F5919C);
    }

    function mint(address recipient) public onlyOwner returns (uint256) {
        _mint(recipient, tokenCounter);

        _setTokenURI(tokenCounter, tokenURI);

        tokenCounter = tokenCounter + 1;

        return tokenCounter;
    }

    function delegate(address to, uint256 tokenId) public returns (uint256) {
        // must hold the tokenId to delegate, must not have delegated
        require(msg.sender == ownerOf(tokenId),
            "you don't own that token."
        );
        require(
            delegateLimit[msg.sender] < D_LIMIT,
            "no delegation chains, anon."
        );

        _mint(to, tokenCounter);

        _setTokenURI(tokenCounter, tokenURI);

        tokenCounter = tokenCounter + 1;

            // neither address involved can delegate again
         delegateLimit[msg.sender] = delegateLimit[msg.sender] + 1;
         delegateLimit[to] = delegateLimit[to] + 1;

    return tokenCounter;
    }
    
    //Block Transfers
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        virtual
        override(ERC721)
    {
        require(from == address(0) || to == address(0), "NonTransferrableERC721Token: non transferrable");
        super._beforeTokenTransfer(from, to, tokenId);
    }

        //Block Approvals
     function _approve(address to, uint256 tokenId)
        internal
        virtual
        override(ERC721)
    {
        revert("NonApprovableERC721Token: non-approvable");
    }

        //Block ApproveAll
     function setApprovalForAll(address operator, bool _approved)
        public
        virtual
        override(ERC721)
    {
        revert("NonApprovableERC721Token: non-approvable");
    }
}
