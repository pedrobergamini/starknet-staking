// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IStakingRewards {
    //
    // View functions
    //
    func balanceOf(account: felt) -> (balance: Uint256) {
    }

    func earned(account: felt) -> (reward: Uint256) {
    }

    func getRewardForDuration() -> (reward: Uint256) {
    }

    func lastTimeRewardApplicable() -> (timestamp: felt) {
    }

    func rewardPerToken() -> (reward_per_token: Uint256) {
    }

    func rewardsDistribution() -> (contract_address: felt) {
    }

    func stakingToken() -> (token: felt) {
    }

    func rewardToken() -> (token: felt) {
    }

    func stakingBridgeL1() -> (res: felt) {
    }

    func totalSupply() -> (total_supply: Uint256) {
    }

    //
    // External functions
    //
    func setRewardsDuration(duration: felt) {
    }

    func setRewardsDistribution(rewards_distribution: felt) {
    }

    func recoverERC20(token: felt, amount: Uint256) {
    }

    func notifyRewardAmount(reward: Uint256) {
    }

    func stakeL2(amount: Uint256) -> (success: felt) {
    }

    func stakeL1(from_address: felt, l1_user: felt, amount: Uint256) {
    }

    func withdrawL2(amount: Uint256) -> (success: felt) {
    }

    func withdrawL1(from_address: felt, l1_user: felt, amount: Uint256) {
    }

    func claimReward() -> (success: felt) {
    }

    func claimRewardToL1() -> (success: felt) {
    }

    func exitL2() -> (success: felt) {
    }

    func exitL1(from_address: felt, l1_user: felt) {
    }
}
