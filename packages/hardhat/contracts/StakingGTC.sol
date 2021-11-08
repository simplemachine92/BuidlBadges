pragma solidity 0.8.4;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./GTC.sol";


/// @title A title that should describe the contract/interface
/// @author jaxcoder && nowonder
/// @notice Creates Donation Pools to buy-back NFTs, and issues governance tokens for the NFT treasury.
/// @dev Explain to a developer any extra details
contract StakingGTC is Ownable, ReentrancyGuard {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;
  using Counters for Counters.Counter;

  uint256 public time;
  uint256 public deadline;
  //IERC721Enumerable address token;
  

    // vars
    Counters.Counter private _poolIds;
    bool public _isClosed;

  // state
  //address(mainnet) public gtcAddress;// 0xDe30da39c46104798bB5aA3fe8B9e0e1F348163F;

  // structs
  struct PoolInfo {
    uint256 poolid;
    address asset;
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

  constructor(address _gtcAddress, address _nft) {
    gtc = GTC(_gtcAddress);
    time = block.timestamp;
    deadline = time + 180;
    createPool(_gtcAddress, _nft, 10);
  }

  GTC gtc;

  // create pool
  function createPool(address asset, address _nft, uint256 amount) public {

    _poolIds.increment();
    uint256 id = _poolIds.current();

    PoolInfo storage pool = poolInfo[id];
    pool.asset = asset;
    pool.balance = amount;
    pool.poolid = id;
    //pool.nft = _nft;
    //pool.floor = amount / nftSupply;

    emit PoolCreated(id, asset, _nft, amount, block.timestamp);

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

  // initialize pool
  function initializePool() public {

  }


  // donate/stake
  function stake(uint256 amount, uint256 poolId) public {
    require(block.timestamp < deadline, "Donating closed");
    require(gtc.balanceOf(msg.sender) >= amount, "Not enough balance");

  (bool success) = gtc.transferFrom(msg.sender, address(this), amount);
        require(success, "Token transfer failed");

    PoolInfo storage pool = poolInfo[poolId];
    pool.balance = pool.balance.add(amount);
    balanceInfo[msg.sender][poolId].balance = balanceInfo[msg.sender][poolId].balance.add(amount);

    emit Stake(msg.sender, amount, block.timestamp);
  }


  // withdrawl/unstake
  function unstake(uint256 poolId) public {
    PoolInfo storage pool = poolInfo[poolId];
    uint256 balance = balanceInfo[msg.sender][poolId].balance;

    require(IERC20(pool.asset).balanceOf(address(this)) >= balance, "Cannot withdraw more that the contract holds ser");
    balanceInfo[msg.sender][poolId].balance = balanceInfo[msg.sender][poolId].balance.sub(balance);

    IERC20(pool.asset).transferFrom(address(this), msg.sender, balance);

    emit Unstake(msg.sender, balance, block.timestamp);
  }

  //get pool nft floor
  function poolFloor(uint256 poolId) public view returns(uint256) {
    
  }

  // get pool balance
  function poolBalance(uint256 poolId) public view returns(uint256) {
    PoolInfo storage pool = poolInfo[poolId];
    return pool.balance;
  }
  
}
