import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Lock", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployOneYearLockFixture() {
    let StakingRewards: any;
    let reward: any;
    let staking: any;
    let stakes: any;

    async function deployEtherAndERC20() {
      const [account1, account2] = await ethers.getSigners();

      const Reward = await ethers.getContractFactory("Reward");
      reward = await Reward.deploy(account1.address);

      const staking = await ethers.getContractFactory("zStake");
      stakes = await staking.deploy(account1.address);

      const Staked = await ethers.getContractFactory("StakingRewards");
      StakingRewards = await Staked.deploy(reward.target, account1.address);
      const amuntToDepost = 100;

      return { reward, StakingRewards, account1, account2, amuntToDepost };
    }

    describe("stake", function () {
      it("should be greater than 0", async function () {
        const amount = 0;
        const savings = ethers.getSigners();
        expect(savings).to.not.equal(amount);
      });

      // it("Should fail if the unlockTime is not in the future", async function () {

      // });
    });
  }
});
