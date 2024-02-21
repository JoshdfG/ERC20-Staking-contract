import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  // Deploy TokenA
  const Staking = await ethers.getContractFactory("zStake");
  const staking = await Staking.deploy(deployer);
  await staking.waitForDeployment();
  console.log(`Staking deployed at: ${staking.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
//0xF9F75cAB668B5e1FA353093Ab37E8Ed6099C9871
