import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  // Deploy TokenA
  const Rewards = await ethers.getContractFactory("Reward");
  const reward = await Rewards.deploy(deployer);
  await reward.waitForDeployment();
  console.log(`Rewards deployed at: ${reward.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
//0x8A42f6d41065F5DD0eD06B01B4D6A1FF081d7E16
