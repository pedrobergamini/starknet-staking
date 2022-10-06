import { expect } from "chai";
import { ethers } from "hardhat";

import { toUint256 } from "../utils";

const {
  utils: { parseEther },
  constants: { MaxUint256 },
  BigNumber,
} = ethers;
const ONE_MILLION = 1000000;
const DEFAULT_TIMEOUT = 300000;
const TOKEN_UNIT = BigInt(10 ** 18);
const MOCK_STAKING_L2_ADDRESS = 999;
const STAKE_AMOUNT = parseEther("1000");
const STARKNET_STAKE_L1_SELECTOR = "0x310825e0f3725d80b141f53c613cfea59901b2fb68ab710e53c39da41c26ca2";
const WITHDRAW_MESSAGE = 1;
const CLAIM_REWARD_MESSAGE = 2;

describe("StakingBridge", async function () {
  this.timeout(DEFAULT_TIMEOUT);

  before(async function () {
    const [l1Admin, l1Alice, l1Bob] = await ethers.getSigners();

    this.signers = {
      admin: l1Admin,
      alice: l1Alice,
      bob: l1Bob,
    };
    this.StakingBridge = await ethers.getContractFactory("StakingBridge");
    this.ERC20 = await ethers.getContractFactory("ERC20Mock");
    this.StarknetMessaging = await ethers.getContractFactory("StarknetMessagingMock");
  });
  beforeEach(async function () {
    this.stakingToken = await this.ERC20.deploy("Staking Token", "STK", parseEther(ONE_MILLION.toString()));
    this.rewardToken = await this.ERC20.deploy("Reward Token", "RWD", parseEther(ONE_MILLION.toString()));
    this.starknetMessaging = await this.StarknetMessaging.deploy();
    this.stakingBridge = await this.StakingBridge.deploy(
      this.starknetMessaging.address,
      this.stakingToken.address,
      this.rewardToken.address,
      MOCK_STAKING_L2_ADDRESS,
    );

    await this.stakingToken.connect(this.signers.admin).transfer(this.signers.alice.address, parseEther("100000"));
    await this.stakingToken.connect(this.signers.admin).transfer(this.signers.bob.address, parseEther("100000"));

    await this.stakingToken.connect(this.signers.alice).approve(this.stakingBridge.address, MaxUint256);
    await this.stakingToken.connect(this.signers.bob).approve(this.stakingBridge.address, MaxUint256);
  });
  it("should stake tokens to L2", async function () {
    const stakeTx = await this.stakingBridge.connect(this.signers.alice).stake(STAKE_AMOUNT);
    await expect(stakeTx).to.emit(this.stakingBridge, "LogStake").withArgs(this.signers.alice.address, STAKE_AMOUNT);
    const uint256StakeAmount = toUint256(STAKE_AMOUNT);

    await this.starknetMessaging.mockConsumeMessageToL2(
      BigNumber.from(this.stakingBridge.address),
      BigNumber.from(MOCK_STAKING_L2_ADDRESS),
      BigNumber.from(STARKNET_STAKE_L1_SELECTOR),
      [
        BigNumber.from(this.signers.alice.address),
        BigNumber.from(uint256StakeAmount.low),
        BigNumber.from(uint256StakeAmount.high),
      ],
      BigNumber.from("0"),
    );
  });
  it("shouldn't allow staking 0", async function () {
    const stakeTx = this.stakingBridge.connect(this.signers.alice).stake(0);
    await expect(stakeTx).to.be.revertedWith("StakingBridge: amount 0");
  });
  it("should withdraw tokens from L2", async function () {
    await this.stakingToken.connect(this.signers.admin).transfer(this.stakingBridge.address, STAKE_AMOUNT);
    const uint256WithdrawAmount = toUint256(STAKE_AMOUNT);
    const payload = [
      BigNumber.from(WITHDRAW_MESSAGE),
      BigNumber.from(this.signers.bob.address),
      BigNumber.from(uint256WithdrawAmount.low),
      BigNumber.from(uint256WithdrawAmount.high),
    ];
    await this.starknetMessaging.mockSendMessageFromL2(
      BigNumber.from(MOCK_STAKING_L2_ADDRESS),
      BigNumber.from(this.stakingBridge.address),
      payload,
    );

    const withdrawTx = await this.stakingBridge.connect(this.signers.bob).withdraw(STAKE_AMOUNT);
    await expect(withdrawTx)
      .to.emit(this.stakingBridge, "LogWithdraw")
      .withArgs(this.signers.bob.address, STAKE_AMOUNT);
  });
  it("should revert on invalid withdrawal", async function () {
    await this.stakingToken.connect(this.signers.admin).transfer(this.stakingBridge.address, STAKE_AMOUNT);
    const uint256WithdrawAmount = toUint256(STAKE_AMOUNT);
    const payload = [
      BigNumber.from(WITHDRAW_MESSAGE),
      BigNumber.from(this.signers.bob.address),
      BigNumber.from(uint256WithdrawAmount.low),
      BigNumber.from(uint256WithdrawAmount.high),
    ];
    await this.starknetMessaging.mockSendMessageFromL2(
      BigNumber.from(MOCK_STAKING_L2_ADDRESS),
      BigNumber.from(this.stakingBridge.address),
      payload,
    );

    const withdrawTx = this.stakingBridge.connect(this.signers.bob).withdraw(STAKE_AMOUNT.add(10));
    await expect(withdrawTx).to.be.reverted;
  });
  it("should claim reward from l2 and mint reward tokens", async function () {
    const uint256RewardAmount = toUint256(STAKE_AMOUNT);
    const payload = [
      BigNumber.from(CLAIM_REWARD_MESSAGE),
      BigNumber.from(this.signers.alice.address),
      BigNumber.from(uint256RewardAmount.low),
      BigNumber.from(uint256RewardAmount.high),
    ];
    await this.starknetMessaging.mockSendMessageFromL2(
      BigNumber.from(MOCK_STAKING_L2_ADDRESS),
      BigNumber.from(this.stakingBridge.address),
      payload,
    );

    const claimRewardTx = await this.stakingBridge.connect(this.signers.alice).claimReward(STAKE_AMOUNT);
    const rewardTokenBalance = await this.rewardToken.balanceOf(this.signers.alice.address);
    await expect(claimRewardTx)
      .to.emit(this.stakingBridge, "LogClaimReward")
      .withArgs(this.signers.alice.address, STAKE_AMOUNT);
    expect(rewardTokenBalance).to.be.equal(STAKE_AMOUNT);
  });
  it("should revert on invalid claim reward", async function () {
    const uint256RewardAmount = toUint256(STAKE_AMOUNT);
    const payload = [
      BigNumber.from(CLAIM_REWARD_MESSAGE),
      BigNumber.from(this.signers.alice.address),
      BigNumber.from(uint256RewardAmount.low),
      BigNumber.from(uint256RewardAmount.high),
    ];
    await this.starknetMessaging.mockSendMessageFromL2(
      BigNumber.from(MOCK_STAKING_L2_ADDRESS),
      BigNumber.from(this.stakingBridge.address),
      payload,
    );

    const claimRewardTx = this.stakingBridge.connect(this.signers.alice).claimReward(STAKE_AMOUNT.add(10));

    await expect(claimRewardTx).to.be.reverted;
  });
});
