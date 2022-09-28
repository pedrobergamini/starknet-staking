import { expect } from "chai";
import { ethers, starknet } from "hardhat";

import config from "../../hardhat.config";
import {
  DEFAULT_TIMEOUT,
  MAX_UINT256_ETHERS,
  MAX_UINT256_STARKNET,
  ONE_DAY,
  ONE_MILLION,
  SEVEN_DAYS,
  fromUint256,
  toUint256,
} from "../utils";

const {
  utils: { parseEther },
} = ethers;

const networkUrl = "http://localhost:8545";

describe("StakingRewards", async function () {
  this.timeout(DEFAULT_TIMEOUT);

  before(async function () {
    const nowUnix = Math.floor(new Date().getTime() / 1000);
    await starknet.devnet.setTime(nowUnix);
    const [l1Admin, l1Alice, l1Bob] = await ethers.getSigners();
    const l2Admin = await starknet.deployAccount("OpenZeppelin");
    const l2Alice = await starknet.deployAccount("OpenZeppelin");
    const l2Bob = await starknet.deployAccount("OpenZeppelin");

    this.l1Signers = {
      admin: l1Admin,
      alice: l1Alice,
      bob: l1Bob,
    };
    this.l2Signers = {
      admin: l2Admin,
      alice: l2Alice,
      bob: l2Bob,
    };
    this.StakingBridge = await ethers.getContractFactory("StakingBridge");
    this.L1ERC20 = await ethers.getContractFactory("ERC20Mock");
    this.L2ERC20 = await starknet.getContractFactory("contracts/l2/openzeppelin/token/erc20/presets/ERC20");
    this.RewardsDistribution = await starknet.getContractFactory(
      "contracts/l2/rewards_distribution/RewardsDistribution",
    );
    this.StakingRewards = await starknet.getContractFactory("contracts/l2/staking/StakingRewards");
    // this.starknetMessagingAddress = (await starknet.devnet.loadL1MessagingContract(networkUrl)).address;
  });
  beforeEach(async function () {
    this.l1StakingToken = await this.L1ERC20.deploy("Staking Token", "STK", parseEther(ONE_MILLION.toString()));
    this.l1RewardToken = await this.L1ERC20.deploy("Reward Token", "RWD", parseEther(ONE_MILLION.toString()));
    this.l2StakingToken = await this.L2ERC20.deploy({
      name: starknet.shortStringToBigInt("Staking Token"),
      symbol: starknet.shortStringToBigInt("STK"),
      decimals: BigInt(18),
      initial_supply: toUint256(parseEther(ONE_MILLION).mul(100)),
      recipient: BigInt(this.l2Signers.admin.address),
    });
    this.l2RewardToken = await this.L2ERC20.deploy({
      name: starknet.shortStringToBigInt("Reward Token"),
      symbol: starknet.shortStringToBigInt("RWD"),
      decimals: BigInt(18),
      initial_supply: toUint256(parseEther(ONE_MILLION).mul(100)),
      recipient: BigInt(this.l2Signers.admin.address),
    });
    this.stakingRewards = await this.StakingRewards.deploy({
      rewards_distribution: BigInt(this.l2Signers.admin.starknetContract.address),
      reward_token: BigInt(this.l2RewardToken.address),
      staking_token: BigInt(this.l2StakingToken.address),
      initial_rewards_duration: BigInt(SEVEN_DAYS),
      owner: BigInt(this.l2Signers.admin.address),
    });
    console.log(await this.stakingRewards.call("lastTimeRewardApplicable"));
    this.stakingBridge = await this.StakingBridge.deploy(
      this.l1Signers.admin.address,
      this.l1StakingToken.address,
      this.l1RewardToken.address,
      BigInt(this.stakingRewards.address),
    );

    await this.l2Signers.admin.invoke(this.l2StakingToken, "transfer", {
      recipient: BigInt(this.l2Signers.alice.starknetContract.address),
      amount: toUint256(parseEther(ONE_MILLION)),
    });
    await this.l2Signers.admin.invoke(this.l2StakingToken, "transfer", {
      recipient: BigInt(this.l2Signers.bob.starknetContract.address),
      amount: toUint256(parseEther(ONE_MILLION)),
    });
    await this.l2Signers.admin.invoke(this.l2StakingToken, "approve", {
      spender: BigInt(this.stakingRewards.address),
      amount: MAX_UINT256_STARKNET,
    });
    await this.l2Signers.alice.invoke(this.l2StakingToken, "approve", {
      spender: BigInt(this.stakingRewards.address),
      amount: MAX_UINT256_STARKNET,
    });
    await this.l2Signers.bob.invoke(this.l2StakingToken, "approve", {
      spender: BigInt(this.stakingRewards.address),
      amount: MAX_UINT256_STARKNET,
    });
  });
  it("should update the user balance", async function () {
    // stake 100 tokens
    console.log(await this.stakingRewards.call("lastTimeRewardApplicable"));
    const amountToStake = parseEther("100");
    await this.l2Signers.alice.invoke(this.stakingRewards, "stakeL2", {
      amount: toUint256(amountToStake),
    });
    // balance must increase by 100
    const { balance } = await this.stakingRewards.call("balanceOf", {
      account: BigInt(this.l2Signers.alice.address),
    });

    expect(fromUint256(balance)).to.be.equal(amountToStake);
  });
  it("should update rewards correctly", async function () {
    // allocate 1 million tokens for rewards
    await this.l2Signers.admin.invoke(this.l2RewardToken, "transfer", {
      recipient: BigInt(this.stakingRewards.address),
      amount: toUint256(parseEther("100")),
    });
    await this.l2Signers.admin.invoke(this.stakingRewards, "notifyRewardAmount", {
      reward: toUint256(parseEther("100")),
    });
    console.log(await this.stakingRewards.call("lastTimeRewardApplicable"));

    const amountToStake = parseEther("50");
    // users stake
    await this.l2Signers.alice.invoke(this.stakingRewards, "stakeL2", {
      amount: toUint256(amountToStake),
    });
    await this.l2Signers.bob.invoke(this.stakingRewards, "stakeL2", {
      amount: toUint256(amountToStake),
    });
    // increase 7 days
    console.log(await this.stakingRewards.call("getRewardForDuration"));
    console.log(await this.stakingRewards.call("periodFinish"));
    console.log(await this.stakingRewards.call("rewardRate"));
    console.log(await this.stakingRewards.call("rewardsDuration"));
    console.log(await this.stakingRewards.call("rewardPerToken"));
    console.log(await this.stakingRewards.call("lastTimeRewardApplicable"));
    console.log("------------------------");
    await starknet.devnet.increaseTime(SEVEN_DAYS);
    console.log(await this.stakingRewards.call("getRewardForDuration"));
    console.log(await this.stakingRewards.call("periodFinish"));
    console.log(await this.stakingRewards.call("rewardRate"));
    console.log(await this.stakingRewards.call("rewardsDuration"));
    console.log(await this.stakingRewards.call("rewardPerToken"));
    console.log(await this.stakingRewards.call("lastTimeRewardApplicable"));

    // each must receive half of rewards for the period
    const expectedRewardsForEach = parseEther(ONE_MILLION).div(2);

    console.log("------------------------");
    // await this.l2Signers.bob.invoke(this.stakingRewards, "stakeL2", {
    //   amount: toUint256(ethers.BigNumber.from(1)),
    // });
    await starknet.devnet.createBlock();
    console.log(await this.stakingRewards.call("getRewardForDuration"));
    console.log(await this.stakingRewards.call("periodFinish"));
    console.log(await this.stakingRewards.call("rewardRate"));
    console.log(await this.stakingRewards.call("rewardsDuration"));
    console.log(await this.stakingRewards.call("rewardPerToken"));
    console.log(await this.stakingRewards.call("lastTimeRewardApplicable"));
    const { reward: aliceReward } = await this.stakingRewards.call("earned", {
      account: BigInt(this.l2Signers.alice.address),
    });
    const { reward: bobReward } = await this.stakingRewards.call("earned", {
      account: BigInt(this.l2Signers.bob.address),
    });
    console.log(aliceReward, fromUint256(aliceReward));
    console.log(bobReward, fromUint256(bobReward));
    // await starknet.devnet.createBlock();

    // const { reward: aliceReward } = await this.stakingRewards.call("earned", {
    //   account: BigInt(this.l2Signers.alice.address),
    // });
    // const { reward: bobReward } = await this.stakingRewards.call("earned", {
    //   account: BigInt(this.l2Signers.bob.address),
    // });
    // // each must receive half of rewards for the period
    // const expectedRewardsForEach = parseEther(ONE_MILLION).div(2);

    // console.log(aliceReward, fromUint256(aliceReward));
    // console.log(bobReward, fromUint256(bobReward));

    // expect(fromUint256(aliceReward)).to.be.equal(expectedRewardsForEach);
    // expect(fromUint256(bobReward)).to.be.equal(expectedRewardsForEach);
  });
});
