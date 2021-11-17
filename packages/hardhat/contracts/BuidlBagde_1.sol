pragma solidity ^0.8.0;
// // SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BuidlBagde_1 is ERC721URIStorage, AccessControl, Ownable {
    bytes32 public constant ADMINS_ROLE = keccak256("ADMIN");

    uint256 public tokenCounter = 1;
    string public tokenURI;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    event Minted(address recipient, uint256 tokenCounter);

    constructor(string memory _baseURI, address[] memory admin) ERC721 ("BuidlGuidl Bagde 1", "BG1") {
        tokenURI = _baseURI;

        transferOwnership(0x34aA3F359A9D614239015126635CE7732c18fDF3);

        for (uint256 i = 0; i < admin.length; ++i) {
            _setupRole(DEFAULT_ADMIN_ROLE, admin[i]);
        }

        _setRoleAdmin(ADMINS_ROLE, DEFAULT_ADMIN_ROLE);
    }

    function mint(address recipient) public returns (uint256) {
        require(hasRole(ADMINS_ROLE, msg.sender), "admin only function");

        _mint(recipient, tokenCounter);

        _setTokenURI(tokenCounter, tokenURI);

        tokenCounter = tokenCounter + 1;

            emit Minted(recipient, tokenCounter);

        return tokenCounter;
    }

    function addAdmins(address[] memory admins) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "DEFAULT_ADMIN only function");

        for (uint256 i = 0; i < admins.length; ++i) {
            grantRole(ADMINS_ROLE, admins[i]);
        }
    }

    function updateURI(string memory newURI) public onlyOwner {
        
        tokenURI = newURI;

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

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}
