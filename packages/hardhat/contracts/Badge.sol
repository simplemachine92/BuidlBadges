pragma solidity ^0.8.0;
// // SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NonTransferrableERC721Token is ERC721URIStorage {
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
    
    //Make sure we can't transfer
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        virtual
        override(ERC721)
    {
        require(from == address(0) || to == address(0), "NonTransferrableERC721Token: non transferrable");
        super._beforeTokenTransfer(from, to, tokenId);
    }

    //Ensure no listing on Opensea by blocking Approve
    /* function _beforeApprove(address to, uint256 tokenId)
        internal
        virtual
        override(ERC721URIStorage, ERC721)
    {
        require(from == address(0) || to == address(0), "NonTransferrableERC721Token: non transferrable");
        super._beforeTokenTransfer(from, to, tokenId);
    }

    //setApprovalForAll(to, approved)
    function _beforeApproveAll(address to, bool approved)
        internal
        virtual
        override(ERC721URIStorage, ERC721)
    {
        require(from == address(0) || to == address(0), "NonTransferrableERC721Token: non transferrable");
        super._beforeTokenTransfer(from, to, tokenId);
    } */

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