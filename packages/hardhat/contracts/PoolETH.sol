pragma solidity 0.8.4;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


/// @title A title that should describe the contract/interface
/// @author jaxcoder && nowonder
/// @notice Creates Donation Pools that pools funds, purchases NFTs @ new floor, and burns them 🔥
/// @dev Explain to a developer any extra details
contract StakingGTC is Ownable, ReentrancyGuard {
  using SafeMath for uint256;
  using Counters for Counters.Counter;
  
    // vars
    Counters.Counter private _poolIds;
    bool public _isClosed;

  // structs
  struct PoolInfo {
    uint256 poolid;
    uint256 balance;
    uint256 time;
    uint256 deadline;
    uint floor;
  }

  // mappings
  mapping(uint256 => PoolInfo) public poolInfo;
  mapping(address => mapping(uint256 => PoolInfo)) public balanceInfo;
  //mapping(address => mapping(uint => PoolInfo)) public floorInfo;
  mapping(address => uint) public floor;
  //mapping(address => uint256) public userDonation;


  // events
  event Stake(address indexed user, uint256 amount, uint256 timestamp);
  event Unstake(address indexed user, uint256 amount,uint256 timestamp);
  event PoolCreated(uint256 poolId, address asset, address _nft, uint256 initialBalance, uint256 timestamp);

  constructor(address _nft, uint256 _totalSupply) {
    time = block.timestamp;
    deadline = time + 180;
    createPool(_nft, _totalSupply);
  }

  // create pool
  function createPool(address _nft, uint256 _totalSupply) public {

    _poolIds.increment();
    uint256 id = _poolIds.current();

    PoolInfo storage pool = poolInfo[id];
    pool.asset = asset;
    pool.balance = balance + msg.value;
    pool.poolid = _nft;
    pool.floor = pool.balance / nftSupply;

    emit PoolCreated(id, asset, _nft, amount, block.timestamp);

  }

    // donate/stake
  function stake(uint256 poolId) public {
    require(block.timestamp < deadline, "Donating closed");
    require(msg.value > 0, "value must be more than 0");

    PoolInfo storage pool = poolInfo[poolId];
    pool.balance = pool.balance.add(msg.value);
    balanceInfo[msg.sender][poolId].balance = balanceInfo[msg.sender][poolId].balance.add(msg.value);

    emit Stake(msg.sender, amount, block.timestamp);
  }

  function executeSale(
        IERC721Enumerable _nft,
        uint256 _id
    ) external {
        uint currentFloor = floor[address(_nft)];
        // updating the total supply to calculate the new floor
        uint updatedTotalSupply = _nft.totalSupply() - 1;
        // updating floor price by subtracting the current floor by the ratio of the sale amount and the new total supply
        require(floor[address(_nft)] > currentFloor / updatedTotalSupply, "RetroactiveFunding: sale cannot be made right now!");
        floor[address(_nft)] = floor[address(_nft)] - currentFloor / updatedTotalSupply; 
        (bool success, ) = msg.sender.call{value: currentFloor}("");
        require(success);
        // burn the nft's approval required
        _nft.safeTransferFrom(msg.sender, address(0), _id);
    }

    function poolFloor(uint256 poolId) public view returns(uint256) {
        PoolInfo storage pool = poolInfo[poolId];
        return pool.floor;
  }

  // get pool balance
  function poolBalance(uint256 poolId) public view returns(uint256) {
    PoolInfo storage pool = poolInfo[poolId];
    return pool.balance;
  }
  
}

  // initialize pool
  //function initializePool() public {
  //}

  //get pool nft floor