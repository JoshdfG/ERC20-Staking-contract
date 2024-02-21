import { ethers } from "hardhat";

async function main() {
  const stakingRewards = await ethers.deployContract("StakingRewards", [
    "0xF9F75cAB668B5e1FA353093Ab37E8Ed6099C9871",
    "0x8A42f6d41065F5DD0eD06B01B4D6A1FF081d7E16",
  ]);

  await stakingRewards.waitForDeployment();

  console.log(
    `StakingRewards contract contract deployed to ${stakingRewards.target}`
  );
}
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
