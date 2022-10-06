import { BigNumber, ethers } from "ethers";
import { uint256 } from "starknet";

export function toUint256(value: BigNumber): uint256.Uint256 {
  return uint256.bnToUint256(value.toString());
}

export function fromUint256(value: uint256.Uint256): BigNumber {
  const parsedValue = uint256.uint256ToBN(value);

  return BigNumber.from(parsedValue.toString());
}

export const ONE_MILLION = 1000000;
export const DEFAULT_TIMEOUT = 300000;
export const TOKEN_UNIT = BigInt(10 ** 18);
export const MOCK_STAKING_L2_ADDRESS = 999;
export const STAKE_AMOUNT = ethers.utils.parseEther("1000");
export const STARKNET_STAKE_L1_SELECTOR = "0x310825e0f3725d80b141f53c613cfea59901b2fb68ab710e53c39da41c26ca2";
export const WITHDRAW_MESSAGE = 1;
export const CLAIM_REWARD_MESSAGE = 2;
