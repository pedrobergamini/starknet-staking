import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import type { Account, StarknetContract, StarknetContractFactory } from "hardhat/types";

import type { StakingBridge } from "../src/types/contracts/l1";
import type { ERC20Mock } from "../src/types/contracts/l1/mocks";
import type { StakingBridge__factory } from "../src/types/factories/contracts/l1";
import type { ERC20Mock__factory } from "../src/types/factories/contracts/l1/mocks";

declare module "mocha" {
  export interface Context {
    l1Signers: L1Signers;
    l2Signers: L2Signers;
    StakingBridge: StakingBridge__factory;
    L1ERC20: ERC20Mock__factory;
    L2ERC20: StarknetContractFactory;
    RewardsDistribution: StarknetContractFactory;
    StakingRewards: StarknetContractFactory;
    stakingBridge: StakingBridge;
    l1StakingToken: ERC20Mock;
    l1RewardToken: ERC20Mock;
    l2StakingToken: StarknetContract;
    l2RewardToken: StarknetContract;
    rewardsDistribution: StarknetContract;
    stakingRewards: StarknetContract;
    starknetMessagingAddress: string;
  }
}

export interface L1Signers {
  admin: SignerWithAddress;
  alice: SignerWithAddress;
  bob: SignerWithAddress;
}

export interface L2Signers {
  admin: Account;
  alice: Account;
  bob: Account;
}
