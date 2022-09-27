import { BigNumber, ethers } from "ethers";
import { uint256 } from "starknet";

export function toUint256(value: BigNumber): uint256.Uint256 {
  return uint256.bnToUint256(value.toString());
}

export function fromUint256(value: uint256.Uint256): BigNumber {
  const parsedValue = uint256.uint256ToBN(value);

  return BigNumber.from(parsedValue.toString());
}

export const ONE_MILLION = "1000000";
export const DEFAULT_TIMEOUT = 120000;
export const MAX_UINT256_STARKNET = toUint256(ethers.constants.MaxUint256);
export const MAX_UINT256_ETHERS = ethers.constants.MaxUint256;
export const ONE_DAY = 86400;
export const SEVEN_DAYS = ONE_DAY * 7;
