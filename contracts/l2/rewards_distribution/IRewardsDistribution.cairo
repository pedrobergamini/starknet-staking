// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.uint256 import Uint256

struct Distribution {
    destination: felt,
    amount: Uint256,
}

@contract_interface
namespace IRewardsDistribution {
    //
    // View functions
    //

    func distributions(index: felt) -> (distribution: Distribution) {
    }

    func distributionsLength() -> (length: felt) {
    }

    //
    // External functions
    //
    func addRewardDistribution(distribution: Distribution) {
    }

    func editRewardDistribution(index: felt, distribution: Distribution) {
    }

    func removeRewardDistribution(index: felt) {
    }

    func distributeRewards(amount: Uint256) -> (success: felt) {
    }
}
