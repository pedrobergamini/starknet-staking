import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";

import type { ERC20Mock } from "../src/types/contracts/l1/mocks";
import type { StarknetMessagingMock } from "../src/types/contracts/l1/mocks/StarknetMessagingMock";
import type { StakingBridge__factory } from "../src/types/factories/contracts/l1";
import type { ERC20Mock__factory, StarknetMessagingMock__factory } from "../src/types/factories/contracts/l1/mocks";

declare module "mocha" {
  export interface Context {
    signers: Signers;
    StakingBridge: StakingBridge__factory;
    ERC20: ERC20Mock__factory;
    StarknetMessaging: StarknetMessagingMock__factory;
    stakingToken: ERC20Mock;
    rewardToken: ERC20Mock;
    starknetMessaging: StarknetMessagingMock;
  }
}

export interface Signers {
  admin: SignerWithAddress;
  alice: SignerWithAddress;
  bob: SignerWithAddress;
}
