pragma solidity ^0.8.0;
// // SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract 1155 is ERC1155, Ownable, AccessControl {
    bytes32 public constant ADMINS_ROLE = keccak256("ADMIN");

    uint256 public constant GOLD = 0;
    uint256 public constant SILVER = 1;
    uint256 public constant THORS_HAMMER = 2;
    uint256 public constant SWORD = 3;
    uint256 public constant SHIELD = 4;

    constructor(address[] memory admin) ERC1155("https://game.example/api/item/{id}.json") {
        _mint(msg.sender, GOLD, 10**18, "");
        _mint(msg.sender, SILVER, 10**27, "");
        _mint(msg.sender, THORS_HAMMER, 1, "");
        _mint(msg.sender, SWORD, 10**9, "");
        _mint(msg.sender, SHIELD, 10**9, "");

        transferOwnership(0x34aA3F359A9D614239015126635CE7732c18fDF3);

        for (uint256 i = 0; i < admin.length; ++i) {
            _setupRole(DEFAULT_ADMIN_ROLE, admin[i]);
        }

        _setRoleAdmin(ADMINS_ROLE, DEFAULT_ADMIN_ROLE);
        
    }

    function addAdmins(address[] memory admins) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "DEFAULT_ADMIN only function");

        for (uint256 i = 0; i < admins.length; ++i) {
            grantRole(ADMINS_ROLE, admins[i]);
        }
    }

    //Block Transfers
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal
        virtual
        override(ERC1155)
    {
        require(from == address(0) || to == address(0), "NonTransferrableERC1155Token: non transferrable");
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

        //Block ApproveAll
     function setApprovalForAll(address operator, bool _approved)
        public
        virtual
        override(ERC1155)
    {
        revert("NonApprovableERC1155Token: non-approvable");
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}