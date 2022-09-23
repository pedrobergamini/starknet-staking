import { expect } from "chai";
import { ethers, network, starknet } from "hardhat";

import config from "../../hardhat.config";

const {
  utils: { parseEther },
} = ethers;
const ONE_MILLION = 1000000;
const TOKEN_UNIT = BigInt(10 ** 18);
const networkUrl = config?.networks?.l1_testnet?.url as string;

describe("StakingBridge", async function () {
  this.timeout(120_000);
  before(async function () {
    const [l1Admin, l1Alice, l1Bob] = await ethers.getSigners();
    console.log(network.name, network.config.url);
    console.log(networkUrl);
    // this.starknetMessagingAddress = (
    //   await starknet.devnet.loadL1MessagingContract(network.config.url as string)
    // ).address;

    // const [l2Admin, l2Alice, l2Bob] = await Promise.all(new Array(3).map(() => starknet.deployAccount("OpenZeppelin")));
    // const l2Admin = await starknet.deployAccount("OpenZeppelin");
    // const l2Alice = await starknet.deployAccount("OpenZeppelin");
    // const l2Bob = await starknet.deployAccount("OpenZeppelin");

    // console.log(l2Admin.starknetContract.address);

    //   this.l1Signers = {
    //     admin: l1Admin,
    //     alice: l1Alice,
    //     bob: l1Bob,
    //   };
    // this.l2Signers = {
    //   admin: l2Admin,
    //   alice: l2Alice,
    //   bob: l2Bob,
    // };

    //   this.StakingBridge = await ethers.getContractFactory("StakingBridge");
    //   this.L1ERC20 = await ethers.getContractFactory("ERC20Mock");
    // this.L2ERC20 = await starknet.getContractFactory("contracts/l2/openzeppelin/token/erc20/presets/ERC20");
    //   this.RewardsDistribution = await starknet.getContractFactory(
    //     "contracts/l2/rewards_distribution/RewardsDistribution",
    //   );
    //   this.StakingRewards = await starknet.getContractFactory("contracts/l2/staking/StakingRewards");
    //   this.starknetMessagingAddress = (await starknet.devnet.loadL1MessagingContract(networkUrl)).address;
    // });

    // beforeEach(async function () {
    // this.l1StakingToken = await this.ERC20.deploy("Staking Token", "STK", parseEther(ONE_MILLION.toString()));
    //   this.l1RewardToken = await this.ERC20.deploy("Reward Token", "RWD", parseEther(ONE_MILLION.toString()));
    // this.l2StakingToken = await this.L2ERC20.deploy({
    //   name: BigInt(123),
    //   symbol: BigInt(1234),
    //   decimals: BigInt(18),
    //   initial_supply: { high: BigInt(0), low: BigInt(ONE_MILLION) * TOKEN_UNIT },
    //   recipient: BigInt(this.l2Signers.admin.address),
    // });
    //   this.rewardsDistribution = await this.RewardsDistribution.deploy({
    //     authority: BigInt(this.l2Signers.admin.address),
    //     owner: BigInt(this.l2Signers.admin.address),
    //   });
    //   this.stakingRewards = await this.StakingRewards.deploy({
    //     rewards_distribution: this.rewardsDistribution.address,
    //     reward_token: BigInt(this.l2RewardToken.address),
    //     staking_token: BigInt(this.l2StakingToken.address),
    //     owner: BigInt(this.l2Signers.admin.address),
    //   });
    //   this.stakingBridge = await this.StakingBridge.deploy(
    //     this.starknetMessagingAddress,
    //     this.stakingToken.address,
    //     this.rewardToken.address,
    //     BigInt(this.stakingRewards.address),
    //   );
  });
  it("should work", async function () {
    console.log("hi");
    const x = await starknet.devnet.loadL1MessagingContract("127.0.0.1:8545");
    console.log("yo");
  });
});
