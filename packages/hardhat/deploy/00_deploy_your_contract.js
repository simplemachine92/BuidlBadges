// deploy/00_deploy_your_contract.js

const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  //! prod GTC address
  /* let GTC = { address: "0xDe30da39c46104798bB5aA3fe8B9e0e1F348163F" };

  // deploy mock token contract ~ if not on mainnet
  if (chainId !== "1") {
    // deploy mock GTC
    GTC = await deploy("GTC", {
      from: deployer,
      //front-end address vvvvvvvvvvvvvvv replace with args: [admins[0]], for deploy
      args: ["0xb010ca9Be09C382A9f31b79493bb232bCC319f01"], 
      log: true,
    });
  }

  const GTC2 = await ethers.getContract("GTC"); */

  NFT = await deploy("SimpleNFT", {
    from: deployer,
    args: ['bobsson', '0xb010ca9Be09C382A9f31b79493bb232bCC319f01', '200'],
    log: true,
    });

    const SimpleNFT = await ethers.getContract("SimpleNFT");

  // deploy Staking Contract ~ any network
  if (chainId !== "1") {
  await deploy("StakingGTC", {
    from: deployer,
    args: [NFT.address, '360'],
    log: true,
  });
} else {
  await deploy("StakingGTC", {
    from: deployer,
    args: ['0xDe30da39c46104798bB5aA3fe8B9e0e1F348163F'],
    log: true,
  });
}}

/*   // Getting a previously deployed contract
  const StakeGTCContract = await ethers.getContract("StakingGTC", deployer);

  // log the GTC and StreamFactory addresses
  console.log({
    GTC: GTC.address,
    streamFactory: StakeGTCContract.address,
  });

  // make sure were not on the local chain...
  if (chainId !== "31337") {
    // verigy the staking contract
    await run("verify:verify", {
      address: StakeGTCContract.address,
      contract: "contracts/StakingGTC.sol:StakingGTC",
      constructorArguments: [GTC.address],
    });
  }
}; */

module.exports.tags = ["StakingGTC", "SimpleNFT"];
