// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE
from contracts.l2.openzeppelin.access.ownable.library import Ownable
from contracts.l2.staking.library import StakingRewards

// @notice StakingRewards constructor
@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner: felt, rewards_distribution: felt, reward_token: felt, staking_token: felt
) {
    Ownable.initializer(owner);
    StakingRewards.initializer(rewards_distribution, reward_token, staking_token);

    return ();
}

//
// View functions
//

@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(account: felt) -> (
    balance: Uint256
) {
    let (balance: Uint256) = StakingRewards.balance_of(account);

    return (balance,);
}

@view
func earned{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(account: felt) -> (
    reward: Uint256
) {
    let (reward: Uint256) = StakingRewards.earned(account);

    return (reward,);
}

@view
func getRewardForDuration{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    reward: Uint256
) {
    let (reward: Uint256) = StakingRewards.get_reward_for_duration();

    return (reward,);
}

@view
func lastTimeRewardApplicable{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    ) -> (timestamp: felt) {
    let (timestamp) = StakingRewards.last_time_reward_applicable();

    return (timestamp,);
}

@view
func rewardPerToken{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    reward_per_token: Uint256
) {
    let (reward_per_token: Uint256) = StakingRewards.reward_per_token();

    return (reward_per_token,);
}

@view
func rewardsDistribution{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    contract_address: felt
) {
    let (rewards_distribution) = StakingRewards.rewards_distribution();

    return (rewards_distribution,);
}

@view
func stakingToken{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    token: felt
) {
    let (staking_token) = StakingRewards.staking_token();

    return (staking_token,);
}

@view
func rewardToken{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    token: felt
) {
    let (reward_token) = StakingRewards.reward_token();

    return (reward_token,);
}

@view
func stakingBridgeL1{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    res: felt
) {
    let staking_bridge_l1_address = StakingRewards.staking_bridge_l1();

    return (staking_bridge_l1_address,);
}

@view
func totalSupply{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    total_supply: Uint256
) {
    let (total_supply: Uint256) = StakingRewards.total_supply();

    return (total_supply,);
}

//
// External functions
//

@external
func setRewardsDuration{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    duration: felt
) {
    Ownable.assert_only_owner();
    StakingRewards.set_rewards_duration(duration);

    return ();
}

@external
func setRewardsDistribution{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    rewards_distribution: felt
) {
    Ownable.assert_only_owner();
    StakingRewards.set_rewards_distribution(rewards_distribution);

    return ();
}

@external
func recoverERC20{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token: felt, amount: Uint256
) {
    Ownable.assert_only_owner();
    let (owner) = Ownable.owner();
    StakingRewards.recover_erc20(token, owner, amount);

    return ();
}

@external
func notifyRewardAmount{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    reward: Uint256
) {
    StakingRewards.notify_reward_amount(reward);

    return ();
}

@external
func stake{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(amount: Uint256) -> (
    success: felt
) {
    StakingRewards.stake(amount);

    return (TRUE,);
}

@external
func withdraw{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(amount: Uint256) -> (
    success: felt
) {
    StakingRewards.withdraw(amount);

    return (TRUE,);
}

@external
func claimReward{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    success: felt
) {
    StakingRewards.claim_rewards();

    return (TRUE,);
}

@external
func exit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (success: felt) {
    StakingRewards.exit();

    return (TRUE,);
}
