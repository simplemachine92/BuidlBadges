pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IGTCPool is Initializable, ReentrancyGuard {
    // get pool balance
    function poolBalance(uint256 poolId) public returns(uint256) {

    // Creates Pool
    function createPool(address asset, uint256 amount) internal {

    // Returns true if the index has been marked claimed.
    function isClaimed(uint256 index) external view returns (bool);
    // Claim the given amount of the token to the given address. Reverts if the inputs are invalid.
    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external;
    // Initialize the Merkler contract with ETH
    function initializeEthMerkler(bytes32 _root, address _dropper, uint256 _days, string calldata _treefile) external payable;
    // Initialize the Merkler contract with ERC20s
    function initializeTokenMerkler(bytes32 _root, address _tokenAddress, uint256 _amount, address _dropper, uint256 _days, string calldata _treefile) external;
}

contract MerkleDeployer {

  address public implementation;

  event Deployed(address indexed _address, uint256 _type, address indexed _dropper, uint256 _deadline, address indexed _token, uint256 _amount, uint256 _decimals, string _symbol);

  constructor(address _implementation) {
    implementation = _implementation;
  }

  function deployEthMerkler(bytes32 _root, address _dropper, uint256 _deadline, string calldata _treefile) public payable returns (address) {

    // clone deterministically
    address deployment = Clones.cloneDeterministic(implementation, keccak256(abi.encodePacked("1", _root, _dropper, _treefile)));

    IMerkler(deployment).initializeEthMerkler{value: msg.value}(_root, _dropper, _deadline, _treefile);

    emit Deployed(deployment, 1, _dropper, _deadline, address(0), msg.value, 18, 'ETH');

    return deployment;

  }

  function deployTokenMerkler(bytes32 _root, address _tokenAddress, uint256 _amount, address _dropper, uint256 _deadline, string calldata _treefile) public returns (address) {

    // clone deterministically
    address deployment = Clones.clone(implementation);

    IERC721Metadata token = IERC721Metadata(_tokenAddress);
    //nft.transferFrom(msg.sender, address(this), _amount);
    //nft.approve(deployment, _amount);
    string memory _symbol = token.symbol();
    uint256 _decimals = 0;

    IMerkler(deployment).initializeTokenMerkler(_root, _tokenAddress, _amount, _dropper, _deadline, _treefile);

    emit Deployed(deployment, 2, _dropper, _deadline, _tokenAddress, _amount, _decimals, _symbol);

    return deployment;

  }
}
