// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ExampleExternalContract is ReentrancyGuard {

  //ik that Ownable by OZ exists... im just messing around
  address public constant nowonder = 
    0xb010ca9Be09C382A9f31b79493bb232bCC319f01;

  bool public completed;
  bool public epicness;

  modifier isOwner() {
        require(msg.sender == nowonder, "You aren't nowonder!");
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }

  function complete() public payable {
    completed = true;
  }

  function ownerOverride() public isOwner {
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
          require(sent, "Failed to send Ether");
      }

  function bamboozled() public payable {
    require(msg.value == .420 ether, "Please enter a .Weed number!1!1"); 
      epicness = true;
      (bool sent, ) = nowonder.call{value: msg.value}("");
      require(sent, "BOGGED");
  }
}