const hre = require("hardhat");

async function main() {
  const Buddy = await hre.ethers.getContractFactory("BuddyWalletRegistry");
  const buddy = await Buddy.deploy();
  console.log("Deploying Buddy Wallet Registry...");

  await buddy.deployed();

  console.log(`Buddy Wallet Registry deployed to ${buddy.address}`);
  // 0xe841F1319Ed45B6d3C26D05cEA498828db8FDd57
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
