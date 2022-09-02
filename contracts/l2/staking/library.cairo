# SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_eq
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.bool import TRUE
from starkware.starknet.common.syscalls import get_block_timestamp
from contracts.l2.openzeppelin.security.safemath.library import SafeUint256

#
# Constants
#

# @dev Base rewards calculation multiplier, used for divisions
const BASE_MULTIPLIER = 10 ** 18

#
# Storage
#
@storage_var
func StakingRewards_reward_token() -> (token : felt):
end

@storage_var
func StakingRewards_staking_token() -> (token : felt):
end

@storage_var
func StakingRewards_rewards_distribution() -> (contract_address : felt):
end

@storage_var
func StakingRewards_reward_per_token() -> (reward_per_token : Uint256):
end

@storage_var
func StakingRewards_reward_rate() -> (reward_rate : Uint256):
end

@storage_var
func StakingRewards_total_supply() -> (total_supply : Uint256):
end

@storage_var
func StakingRewards_rewards_duration() -> (duration : felt):
end

@storage_var
func StakingRewards_period_finish() -> (when : felt):
end

@storage_var
func StakingRewards_last_update_time() -> (last_update_time : felt):
end

@storage_var
func StakingRewards_rewards(account : felt) -> (reward : Uint256):
end

@storage_var
func StakingRewards_reward_per_token_paid(account : felt) -> (reward_per_token_paid : Uint256):
end

@storage_var
func StakingRewards_balances(account : felt) -> (balance : Uint256):
end

namespace StakingRewards:
    #
    # Public functions
    #

    func balance_of{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        account : felt
    ) -> (balance : Uint256):
        let (balance : Uint256) = StakingRewards_balances.read(account)
        return (balance)
    end

    func earned{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        account : felt
    ) -> (reward_earned : Uint256):
        alloc_locals
        # read storage values
        let (local account_balance : Uint256) = StakingRewards_balances.read(account)
        let (local current_reward_per_token : Uint256) = reward_per_token()
        let (local reward_per_token_paid : Uint256) = StakingRewards_reward_per_token_paid.read(
            account
        )
        let (local accumulated_rewards_stored : Uint256) = StakingRewards_rewards.read(account)

        # peform reward calculation
        let (local reward_per_token_delta : Uint256) = SafeUint256.sub_lt(
            current_reward_per_token, reward_per_token_paid
        )

        if reward_per_token_delta == 0:
            return (accumulated_rewards_stored)
        end

        let (accrued_rewards_normalized : Uint256, _) = SafeUint256.div_rem(
            reward_per_token_delta, BASE_MULTIPLIER
        )
        let (total_rewards : Uint256) = SafeUint256.add(
            accrued_rewards_normalized, accumulated_rewards_stored
        )

        return (total_rewards)
    end

    func get_reward_for_duration{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (reward : Uint256):
        let (reward_rate : Uint256) = StakingRewards_reward_rate.read()
        let (duration) = StakingRewards_rewards_duration.read()
        let (reward_for_duration : Uint256) = SafeUint256.mul(reward_rate, Uint256(duration, 0))

        return (reward_for_duration)
    end

    func last_time_reward_applicable{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }() -> (timestamp : felt):
        let (block_timestamp) = get_block_timestamp()
        let (period_finish) = StakingRewards_period_finish.read()
        let (is_period_finished) = is_le(period_finish, block_timestamp)

        if is_period_finished == TRUE:
            return (period_finish)
        end

        return (block_timestamp)
    end

    func reward_per_token{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        reward : Uint256
    ):
        alloc_locals
        let (local total_supply : Uint256) = StakingRewards_total_supply.read()
        let (local reward_per_token_stored : Uint256) = StakingRewards_reward_per_token.read()
        let (is_total_supply_zero) = uint256_eq(total_supply, Uint256(0, 0))

        if is_total_supply_zero == TRUE:
            return (reward_per_token_stored)
        end

        let (local last_applicable_timestamp) = last_time_reward_applicable()
        let (local last_update_time) = StakingRewards_last_update_time.read()
        let (local reward_rate : Uint256) = StakingRewards_reward_rate.read()

        let (time_delta : Uint256) = SafeUint256.sub_le(
            Uint256(last_applicable_timestamp, 0), Uint256(last_update_time, 0)
        )
        let (new_rewards_accumulated : Uint256) = SafeUint256.mul(time_delta, reward_rate)
        let (new_rewards_accumulated_denorm : Uint256) = SafeUint256.mul(
            new_rewards_accumulated, BASE_MULTIPLIER
        )
        let (new_rewards_accumulated_per_token : Uint256, _) = SafeUint256.div_rem(
            new_rewards_accumulated_denorm, total_supply
        )
        let (reward : Uint256) = SafeUint256.add(
            reward_per_token_stored, new_rewards_accumulated_per_token
        )

        return (reward)
    end

    func rewards_distribution{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (res : felt):
        let (res) = StakingRewards_rewards_distribution.read()

        return (res)
    end

    func reward_token{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        token : felt
    ):
        let (token) = StakingRewards_reward_token.read()

        return (token)
    end

    func total_supply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        res : Uint256
    ):
        let (res : Uint256) = StakingRewards_total_supply.read()

        return (res)
    end
end
