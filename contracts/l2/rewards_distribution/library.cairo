// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
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
        let distribution = RewardsDistribution_distributions.read(index);

        return (distribution);
    }

    func distributions_len{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> felt {
        let (res) = RewardsDistribution_distributions_len.read();

        return res;
    }
}
