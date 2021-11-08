// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ExampleExternalContract.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staker is ReentrancyGuard {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;
  using Counters for Counters.Counter;

  // vars
  Counters.Counter private _poolIds;

  // state
  address public gtcAddress;// 0xDe30da39c46104798bB5aA3fe8B9e0e1F348163F;

  // mappings
  mapping(uint256 => PoolInfo) public poolInfo;
  mapping(address => mapping(uint256 => PoolInfo)) public balanceInfo;
  mapping(address => uint) public floor;
  mapping(address => uint256) public userDonation;
  uint256 public time;
  uint256 public deadline;

    event Stake(address indexed user, uint256 amount, uint256 timestamp);
    event Unstake(address indexed user, uint256 amount,uint256 timestamp);
    event PoolCreated(uint256 poolId, IERC721Enumerable _nft, address asset, uint256 initialBalance, uint256 timestamp);

  constructor(address _gtcAddress, IERC721Enumerable _nft) {
    gtcAddress = _gtcAddress;
    time = block.timestamp;
    deadline = time + 180;
    createPool(gtcAddress, _nft, 10);
  }

  modifier notCompleted() {
        require(exampleExternalContract.completed() == false, "Staking Completed!");
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }

    modifier awaitDeadline() {
        require(block.timestamp >= deadline, "Cannot execute yet");
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }

  // get pool balance
  function poolBalance(uint256 poolId) public returns(uint256) {
    PoolInfo storage pool = poolInfo[poolId];
    return pool.balance;
  }

  // create pool
  function createPool(address asset, IERC721Enumerable _nft, uint256 amount) public {
    require(block.timestamp < deadline, "donating has ended");
    require(asset = gtcAddress, "not GTC");
    
    _poolIds.increment();
    uint256 id = _poolIds.current();

    PoolInfo storage pool = poolInfo[id];
    pool.asset = asset;
    pool.balance = amount;
    pool.poolid = id;
    pool.nft = _nft;

    balanceInfo[msg.sender][id].balance = balanceInfo[msg.sender][id].balance.add(amount);

    emit PoolCreated(id, asset, _nft, amount, block.timestamp);
  }

  // set floor price and start purchases
  function startPurchases() public {

    uint totalSupply = _nft.totalSupply();

       floor[address(_nft)] = floor[address(_nft)] + (amount / totalSupply);
       (bool success, ) = transferFrom(msg.sender, address(this), amount);
       require(success);
  }

  // initialize pool
  function initializePool() public {

  }


  // deposit/stake
  function stake(address asset, uint256 amount, uint256 poolId) public {
    PoolInfo storage pool = poolInfo[poolId];
    pool.balance = pool.balance.add(amount);

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
}

// OLD STAKING EXAMPLE FROM SPEEDRUN

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
    function stake() public payable notCompleted {
  
      // Cannot stake if deadline has been met
      require(block.timestamp < deadline, "Staking has ended");

      // Update balance
      balance[msg.sender] = balance[msg.sender] + msg.value;
        
          emit Stake(msg.sender, msg.value);
      
      // If balance > 1 eth, run our execute function
      if (address(this).balance >= threshold) {
        execute();

      }
    }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

    function execute() public {
      // Send ETH to external contract 

      require(address(this).balance >= threshold, "Not enough ETH staked");
            exampleExternalContract.complete{value: address(this).balance}();
    }

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
      function withdraw() public awaitDeadline {
        require(balance[msg.sender] != 0, "balance is zer0");
        require(block.timestamp >= deadline, "Cannot withdraw yet");
          (bool sent, ) = msg.sender.call{value: balance[msg.sender]}("");
          require(sent, "Failed to send Ether");
      }

      function ownerOverride() public isOwner {
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
          require(sent, "Failed to send Ether");
      }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
      function timeLeft() public view returns (uint256){
        if (block.timestamp >= deadline) {
          return 0;
        } else {
        return deadline - block.timestamp;
        }
    }
}