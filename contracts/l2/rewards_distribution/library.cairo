// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero, assert_lt
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
func RewardsDistribution_authority() -> (authority_address: felt) {
}

@storage_var
func RewardsDistribution_reward_token() -> (reward_token_address: felt) {
}

@storage_var
func RewardsDistribution_distributions(index: felt) -> (distribution: Distribution) {
}

@storage_var
func RewardsDistribution_distributions_len() -> (res: felt) {
}

namespace RewardsDistribution {
    // @notice RewardsDistribution initializer
    func initializer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        authority_address: felt
    ) {
        with_attr error_message("RewardsDistribution: invalid initialization parameters") {
            assert_not_zero(authority_address);
        }
        RewardsDistribution_authority.write(authority_address);

        return ();
    }
    //
    // Public functions
    //

    //
    // View public functions
    //
    func authority{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> felt {
        let (authority_address) = RewardsDistribution_authority.read();

        return authority_address;
    }

    @external
    func reward_token{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> felt {
        let (reward_token_address) = RewardsDistribution_reward_token.read();

        return reward_token_address;
    }

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

    //
    // Mutative public functions
    //

    // @notice Set the address of the contract authorised to call distributeRewards()
    // @param _authority Address of the authorised calling contract.
    func set_authority{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        new_authority_address: felt
    ) {
        with_attr error_message("RewardsDistribution: invalid new authority address") {
            assert_not_zero(new_authority_address);
        }
        RewardsDistribution_authority.write(new_authority_address);

        return ();
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

    func edit_reward_distribution{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        index: felt, new_distribution: Distribution
    ) {
        let current_distributions_index = distributions_len();
        with_attr error_message("RewardsDistribution: index out of bounds") {
            assert_lt(index, current_distributions_index);
        }
        RewardsDistribution_distributions.write(index, new_distribution);
        LogEditRewardDistribution.emit(index, new_distribution);

        return ();
    }

    func distribute_rewards{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        amount: Uint256
    ) {
    }
}
