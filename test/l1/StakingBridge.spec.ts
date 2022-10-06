import { expect } from "chai";
import { ethers, network, starknet } from "hardhat";

const {
  utils: { parseEther },
} = ethers;
const ONE_MILLION = 1000000;
const DEFAULT_TIMEOUT = 300000;
const TOKEN_UNIT = BigInt(10 ** 18);
const MOCK_STAKING_L2_ADDRESS = 999;
const networkUrl = "http://127.0.0.1:8545";

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
  });
  it("should work", async function () {
    // const x = await starknet.devnet.loadL1MessagingContract(networkUrl);
    console.log("hi");
  });
});
