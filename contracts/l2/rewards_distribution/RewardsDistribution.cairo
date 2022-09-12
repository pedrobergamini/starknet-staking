// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE
from contracts.l2.rewards_distribution.library import RewardsDistribution
from contracts.l2.rewards_distribution.IRewardsDistribution import Distribution

@external
func distributions{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    index: felt
) -> (distribution: Distribution) {
    let (distribution) = RewardsDistribution.distributions(index);

    return (distribution,);
}

@external
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
    RewardsDistribution.add_reward_distribution(distribution);

    return (TRUE,);
}
