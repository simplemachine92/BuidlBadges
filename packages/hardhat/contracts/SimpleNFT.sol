pragma solidity ^0.8.0;
// // SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SimpleNFT is ERC721URIStorage {
    uint256 public tokenCounter = 1;
    string public tokenURI;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor(string memory _baseURI) ERC721 ("BuidlGuidl Badge 1", "BG1") {
        tokenURI = _baseURI;
    }

    function mint(address recipient) public returns (uint256) {
        _mint(recipient, tokenCounter);

        _setTokenURI(tokenCounter, tokenURI);

        tokenCounter = tokenCounter + 1;

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
        require(to == address(0) || tokenId == 0, "NonApprovableERC721Token: non-approvable");
        super._approve(to, tokenId);
    }

        //Block ApproveAll
     function setApprovalForAll(address operator, bool _approved)
        public
        virtual
        override(ERC721)
    {
        require(operator == address(0) || _approved == false, "NonApprovableERC721Token: non-approvable");
        super.setApprovalForAll(operator, _approved);
    }

    /* function mint(address to) public {
        require(
            hasRole(MINTER_ROLE, msg.sender),
            "NonTransferrableERC721Token: account does not have minter role"
        );
        _tokenIds.increment();

        uint256 newTokenId = _tokenIds.current();
        _mint(to, newTokenId);
        _setTokenURI(newTokenId, Strings.fromUint256(newTokenId));
    } */

    
}