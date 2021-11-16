pragma solidity ^0.8.0;
// // SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract BuidlBadges is ERC1155, Ownable, AccessControl {
    bytes32 public constant ADMINS_ROLE = keccak256("ADMIN");

    uint256 public constant SIMPLE_NFT = 0;
    uint256 public constant STAKING = 1;
    uint256 public constant VENDOR = 2;
    uint256 public constant MULTI_SIG = 3;
    uint256 public constant ORACLES = 4;
    uint256 public constant EXCHANGE = 5;
    uint256 public constant BUYER_MINTS = 6;
    uint256 public constant STREAMS = 7;
    uint256 public constant DAMAGE_DEALER = 8;
    uint256 public constant COMMUNITY_HELPER = 9;

    event Minted(address recipient, uint256 tokenId);

    constructor(address[] memory admin) 
        ERC1155(
    "https://forgottenbots.mypinata.cloud/ipfs/QmRPv9HDrmQy2NDD1Q3HNeSFv1uy3F2DRqZpMkvEaXzNEN/{id}.json"
    ) 
    {

        transferOwnership(0x34aA3F359A9D614239015126635CE7732c18fDF3);

        for (uint256 i = 0; i < admin.length; ++i) {
            _setupRole(DEFAULT_ADMIN_ROLE, admin[i]);
        }

        _setRoleAdmin(ADMINS_ROLE, DEFAULT_ADMIN_ROLE);
        
    }

    function mint(
        address recipient,
        uint256 tokenId
        ) public {

        require(hasRole(ADMINS_ROLE, msg.sender), "admin only function");

        _mint(msg.sender, tokenId, 1, "");

            emit Minted(recipient, tokenId);

    }

    function reward(address recipient) public returns (uint256) {
        require(hasRole(ADMINS_ROLE, msg.sender), "admin only function");
        _mint(recipient, DAMAGE_DEALER, 10**9, "");
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
     function setApprovalForAll(
         address operator,
         bool _approved
    )
        public
        virtual
        override(ERC1155)
    {
        revert("NonApprovableERC1155Token: non-approvable");
    }

    function supportsInterface(
        bytes4 interfaceId
    ) 
    public
    view
    virtual
    override(ERC1155, AccessControl)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}