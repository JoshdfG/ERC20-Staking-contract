import { ethers } from "hardhat";
// import '../contracts/';

async function main() {
  const [mySigner] = await ethers.getSigners();

  const stakingContractAddress = "0x00a421568CEB8b5c9F253BEA8410849146fE8e58";
  const stakingTokenAddress = "0xF9F75cAB668B5e1FA353093Ab37E8Ed6099C9871";
  const STAKINGCONTRACT = await ethers.getContractAt(
    "IStaking",
    stakingContractAddress
  );
  const STAKINGTOKEN = await ethers.getContractAt(
    "IERC20",
    stakingTokenAddress
  );

  const approve = await STAKINGTOKEN.approve(stakingContractAddress, 1000);
  await approve.wait();

  const stake = await STAKINGCONTRACT.stake(100);

  await stake.wait();

  console.log(
    `Stake successfully approved and deployed to ${stakingContractAddress}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
