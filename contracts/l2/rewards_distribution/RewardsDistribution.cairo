// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE
from starkware.cairo.common.uint256 import Uint256
from openzeppelin.access.ownable.library import Ownable
from contracts.l2.rewards_distribution.library import RewardsDistribution
from contracts.l2.rewards_distribution.IRewardsDistribution import Distribution

// @notice RewardsDistribution constructor
@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    authority: felt, owner: felt, reward_token: felt
) {
    Ownable.initializer(owner);
    RewardsDistribution.initializer(authority, reward_token);

    return ();
}

@view
func authority{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    authority_address: felt
) {
    let authority_address = RewardsDistribution.authority();

    return (authority_address,);
}

@view
func rewardToken{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    reward_token_address: felt
) {
    let reward_token_address = RewardsDistribution.reward_token();

    return (reward_token_address,);
}

@view
func distributions{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    index: felt
) -> (distribution: Distribution) {
    let (distribution) = RewardsDistribution.distributions(index);

    return (distribution,);
}

@view
func distributionsLength{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    res: felt
) {
    let res = RewardsDistribution.distributions_len();

    return (res,);
}

@external
func addRewardDistribution{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    distribution: Distribution
) -> (success: felt) {
    Ownable.assert_only_owner();
    RewardsDistribution.add_reward_distribution(distribution);

    return (TRUE,);
}

@external
func editRewardDistribution{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    index: felt, new_distribution: Distribution
) -> (success: felt) {
    Ownable.assert_only_owner();
    RewardsDistribution.edit_reward_distribution(index, new_distribution);

    return (TRUE,);
}

@external
func distributeRewards{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    amount: Uint256
) -> (success: felt) {
    RewardsDistribution.distribute_rewards(amount);

    return (TRUE,);
}
