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

    func stake(amount: Uint256) -> (success: felt) {
    }

    func withdraw(amount: Uint256) -> (success: felt) {
    }

    func claimReward() -> (success: felt) {
    }

    func exit() -> (success: felt) {
    }
}
