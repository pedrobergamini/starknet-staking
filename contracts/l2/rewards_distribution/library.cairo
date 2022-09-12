// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.uint256 import Uint256, assert_uint256_lt
from contracts.l2.rewards_distribution.IRewardsDistribution import Distribution

//
// Events
//
@event
func LogAddRewardDistribution(distribution: Distribution) {
}

@event
func LogEditRewardDistribution(index: felt, new_distribution: Distribution) {
}

@event
func LogRemoveRewardDistribution(index: felt) {
}

//
// Storage
//
@storage_var
func RewardsDistribution_distributions(index: felt) -> (distribution: Distribution) {
}

@storage_var
func RewardsDistribution_distributions_len() -> (res: felt) {
}

namespace RewardsDistribution {
    //
    // Public functions
    //

    //
    // View public functions
    //
    func distributions{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        index: felt
    ) -> (distribution: Distribution) {
        let (distribution) = RewardsDistribution_distributions.read(index);

        return (distribution,);
    }

    func distributions_len{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        ) -> felt {
        let (res) = RewardsDistribution_distributions_len.read();

        return res;
    }

    func add_reward_distribution{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        distribution: Distribution
    ) {
        with_attr error_message("RewardsDistribution: invalid destination or amount") {
            assert_not_zero(distribution.destination);
            assert_uint256_lt(Uint256(0, 0), distribution.amount);
        }
        let next_distribution_index = distributions_len();
        RewardsDistribution_distributions_len.write((next_distribution_index + 1));
        RewardsDistribution_distributions.write(next_distribution_index, distribution);
        LogAddRewardDistribution.emit(distribution);

        return ();
    }
}
