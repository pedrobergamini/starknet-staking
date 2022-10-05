// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero, assert_lt
from starkware.cairo.common.uint256 import (
    Uint256,
    assert_uint256_lt,
    assert_uint256_le,
    assert_uint256_eq,
)
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address
from openzeppelin.security.safemath.library import SafeUint256
from contracts.l2.lib.interfaces.IERC20 import IERC20
from contracts.l2.rewards_distribution.IRewardsDistribution import Distribution
from contracts.l2.lib.SafeERC20 import SafeERC20
from contracts.l2.staking.IStakingRewards import IStakingRewards

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
func LogDistributeRewards(amount: Uint256) {
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
    func initializer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        authority: felt, reward_token: felt
    ) {
        with_attr error_message("RewardsDistribution: invalid initialization parameters") {
            assert_not_zero(authority);
            assert_not_zero(reward_token);
        }
        RewardsDistribution_authority.write(authority);
        RewardsDistribution_reward_token.write(reward_token);

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
        let (distribution: Distribution) = RewardsDistribution_distributions.read(index);

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

    func set_authority{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        authority: felt
    ) {
        with_attr error_message("RewardsDistribution: invalid new authority address") {
            assert_not_zero(authority);
        }
        RewardsDistribution_authority.write(authority);

        return ();
    }

    func set_reward_token{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        reward_token: felt
    ) {
        with_attr error_message("RewardsDistribution: invalid new reward token") {
            assert_not_zero(reward_token);
        }
        RewardsDistribution_reward_token.write(reward_token);

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
        index: felt, distribution: Distribution
    ) {
        let current_distributions_index = distributions_len();
        with_attr error_message("RewardsDistribution: index out of bounds") {
            assert_lt(index, current_distributions_index);
        }
        with_attr error_message("RewardsDistribution: invalid destination or amount") {
            assert_not_zero(distribution.destination);
            assert_uint256_lt(Uint256(0, 0), distribution.amount);
        }
        RewardsDistribution_distributions.write(index, distribution);
        LogEditRewardDistribution.emit(index, distribution);

        return ();
    }

    func distribute_rewards{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        amount: Uint256
    ) {
        alloc_locals;
        with_attr error_message("RewardsDistribution: amount should be greater than 0") {
            assert_uint256_lt(Uint256(0, 0), amount);
        }
        let (caller) = get_caller_address();
        let authority_address = authority();
        with_attr error_message("RewardsDistribution: caller is not authorized") {
            assert caller = authority_address;
        }
        let reward_token_address = reward_token();
        with_attr error_message("RewardsDistribution: reward token not set") {
            assert_not_zero(reward_token_address);
        }
        let (contract_address) = get_contract_address();
        let (reward_token_balance: Uint256) = IERC20.balanceOf(
            contract_address=reward_token_address, account=contract_address
        );
        with_attr error_message("RewardsDistribution: not enough tokens to distribute") {
            assert_uint256_le(amount, reward_token_balance);
        }

        let res = distributions_len();
        let (amount_distributed: Uint256) = _loop_distribute_rewards(
            reward_token_address, res, Uint256(0, 0)
        );
        with_attr error_message(
                "RewardsDistribution: amount_distributed doesn't match provided amount") {
            assert_uint256_eq(amount_distributed, amount);
        }
        LogDistributeRewards.emit(amount);

        return ();
    }

    //
    // Internal functions
    //

    func _loop_distribute_rewards{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        reward_token: felt, distributions_len: felt, amount_distributed: Uint256
    ) -> (amount_distributed: Uint256) {
        if (distributions_len == 0) {
            return (amount_distributed,);
        }

        let (distribution: Distribution) = distributions((distributions_len - 1));
        SafeERC20.safe_transfer(reward_token, distribution.destination, distribution.amount);
        IStakingRewards.notifyRewardAmount(
            contract_address=distribution.destination, reward=distribution.amount
        );
        let (amount_distributed_updated: Uint256) = SafeUint256.add(
            amount_distributed, distribution.amount
        );

        let (total_amount_distributed: Uint256) = _loop_distribute_rewards(
            reward_token, (distributions_len - 1), amount_distributed_updated
        );

        return (total_amount_distributed,);
    }
}
