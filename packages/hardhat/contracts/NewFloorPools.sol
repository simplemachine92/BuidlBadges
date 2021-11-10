pragma solidity 0.8.4;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


/// @title Floor Raising Pools!
/// @author jaxcoder && nowonder
/// @notice Creates Donation Pools, purchases NFTs @ new floor, and burns? them 🔥
/// @dev Explain to a developer any extra detailss

contract NewFloorPools is Ownable, ReentrancyGuard {
  using SafeMath for uint256;
  using Counters for Counters.Counter;

  uint256 public time;
  uint256 public deadline;
  IERC721 public token;
  
    // vars
    Counters.Counter private _poolIds;

  // structs
  struct PoolInfo {
    uint256 poolid;
    uint256 balance;
    uint256 supply;
    uint256 time;
    uint256 deadline;
    address asset;
    uint floor;
  }

  struct Token {
  uint id;
  address owner;
}

  // mappings
  mapping(uint256 => PoolInfo) public poolInfo;
  mapping(address => mapping(uint256 => PoolInfo)) public balanceInfo;
  //mapping(address => mapping(uint => PoolInfo)) public floorInfo;
  //mapping(address => uint) public floor;
  mapping(address => uint256) public userDonation;
  //mapping(address => mapping(uint256 => PoolInfo)) public userToken;


  // events
  event Donate(address indexed user, uint256 amount, uint256 timestamp);
  event PoolCreated(uint256 poolId, address _nft, uint256 initialBalance, uint256 timestamp);

  constructor(address _nft, uint256 _totalSupply) {
    time = block.timestamp;
    deadline = time + 180;
    createPool(_nft, _totalSupply);
  }

  // create pool
  function createPool(address _nft, uint256 _totalSupply) public payable {

    _poolIds.increment();
    uint256 id = _poolIds.current();

    PoolInfo storage pool = poolInfo[id];
    pool.asset = _nft;
    pool.balance = pool.balance + msg.value;
    pool.poolid = id;
    pool.supply = _totalSupply;
    pool.floor = pool.balance / _totalSupply;
    //pool.tokens = type[];

    emit PoolCreated(id, _nft, msg.value, block.timestamp);

  }

    // Maybe we allow users to lock their tokens, to determine ETH distribution instead of a total supply, we
    // have a user supply

   function locknft(uint256 poolId, uint256 _id, uint256 price) public {
    require(block.timestamp < deadline, "locking closed");
    PoolInfo storage pool = poolInfo[poolId];
    token = IERC721(pool.asset);

    token.transferFrom(msg.sender, address(this), _id);


    //userToken[msg.sender][poolId].tokens = userToken[msg.sender][poolId].balance.add(msg.value);
    
  } 

    // donate function accepts ETH for pool, raises floor price
  function donate(uint256 poolId) public payable {
    require(block.timestamp < deadline, "donating closed");
    require(msg.value > 0, "value must be more than 0");

    PoolInfo storage pool = poolInfo[poolId];
    pool.balance = pool.balance.add(msg.value);
    pool.floor = pool.balance / pool.supply;
    balanceInfo[msg.sender][poolId].balance = balanceInfo[msg.sender][poolId].balance.add(msg.value);

    emit Donate(msg.sender, msg.value, block.timestamp);
  }

  function executeSale(
        uint256 poolId,
        uint256 _id
    ) external {
      PoolInfo storage pool = poolInfo[poolId];
        uint currentFloor = pool.floor;
        token = IERC721(pool.asset);

        (bool success, ) = msg.sender.call{value: currentFloor}("");
        require(success);

        // transfer nft to this contract, approve needed ofc
        token.transferFrom(msg.sender, address(this), _id);
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
