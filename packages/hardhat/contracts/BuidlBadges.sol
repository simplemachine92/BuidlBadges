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
    "https://forgottenbots.mypinata.cloud/ipfs/QmZvQZiZrTm2ewQXDUw1GA5eaGv7xnpzPRtaRZznFBmpoQ/{id}.json"
    ) 
    {

        transferOwnership(0x34aA3F359A9D614239015126635CE7732c18fDF3);

        for (uint256 i = 0; i < admin.length; ++i) {
            _setupRole(DEFAULT_ADMIN_ROLE, admin[i]);
        }

        _setRoleAdmin(ADMINS_ROLE, DEFAULT_ADMIN_ROLE);
        
    }

    /**
     * @notice Mints the badge
     * @param tokenId identifies the badge to be minted (0-9 for now)
     */
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

    /**
     * @notice Allows original admins to add curators
     */
    function addAdmins(address[] memory admins) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "DEFAULT_ADMIN only function");

        for (uint256 i = 0; i < admins.length; ++i) {
            grantRole(ADMINS_ROLE, admins[i]);
        }
    }

    /**
   * @dev Contract uri
   */
    function uri() public view returns (string memory) {
        return
            "https://forgottenbots.mypinata.cloud/ipfs/QmTYr3kBhyySATmt9UEgKBPgpg7DGRFL4wef9AoSsDxNo2";
    }

    /**
     * @notice Block badge transfers
     */
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

    /**
     * @notice Block badge approvals, so they can't be listed on marketplaces.
     */
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

    /**
     * @notice Override interface to use AccessControl
     */
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