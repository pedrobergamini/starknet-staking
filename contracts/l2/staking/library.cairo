# SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_eq
from starkware.cairo.common.math_cmp import is_le, is_not_zero
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import (
    get_block_timestamp,
    get_caller_address,
    get_contract_address,
)
from contracts.l2.lib.SafeERC20 import SafeERC20
from contracts.l2.openzeppelin.security.safemath.library import SafeUint256

#
# Constants
#

# @dev Base rewards calculation multiplier, used for divisions
const BASE_MULTIPLIER = 10 ** 18

#
# Events
#
@event
func LogStake(user : felt, amount : Uint256):
end

@event
func LogWithdraw(user : felt, amount : Uint256):
end

@event
func LogClaimReward(user : felt, reward : Uint256):
end

@event
func LogRecoverERC20(token : felt, amount : Uint256):
end

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
        let (account_balance : Uint256) = StakingRewards_balances.read(account)
        let (current_reward_per_token : Uint256) = reward_per_token()
        let (reward_per_token_paid : Uint256) = StakingRewards_reward_per_token_paid.read(account)
        let (accumulated_rewards_stored : Uint256) = StakingRewards_rewards.read(account)

        let (reward_per_token_delta : Uint256) = SafeUint256.sub_lt(
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
        let (total_supply : Uint256) = StakingRewards_total_supply.read()
        let (reward_per_token_stored : Uint256) = StakingRewards_reward_per_token.read()
        let (is_total_supply_zero) = uint256_eq(total_supply, Uint256(0, 0))

        if is_total_supply_zero == TRUE:
            return (reward_per_token_stored)
        end

        let (last_applicable_timestamp) = last_time_reward_applicable()
        let (last_update_time) = StakingRewards_last_update_time.read()
        let (reward_rate : Uint256) = StakingRewards_reward_rate.read()

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

    func stake{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(amount : Uint256):
        alloc_locals
        let (caller) = get_caller_address()
        _update_reward(caller)
        with_attr error_message("Cannot stake 0"):
            let (is_zero) = uint256_eq(amount, Uint256(0, 0))
            assert is_zero = FALSE
        end

        let (current_total_supply : Uint256) = StakingRewards_total_supply.read()
        let (new_total_supply : Uint256) = SafeUint256.add(current_total_supply, amount)
        let (current_balance : Uint256) = StakingRewards_balances.read(caller)
        let (new_balance : Uint256) = SafeUint256.add(current_balance, amount)
        let (staking_token_address) = StakingRewards_staking_token.read()
        let (this_contract) = get_contract_address()

        StakingRewards_total_supply.write(new_total_supply)
        StakingRewards_balances.write(caller, new_balance)
        SafeERC20.safe_transfer_from(staking_token_address, caller, this_contract, amount)

        LogStake.emit(caller, amount)
    end

    #
    # Internal functions
    #
    func _update_reward{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        caller : felt
    ):
        alloc_locals
        let (is_valid_caller) = is_not_zero(caller)

        if is_valid_caller == TRUE:
            let (reward_per_token_stored : Uint256) = StakingRewards_reward_per_token.read()
            let (last_update_time) = last_time_reward_applicable()
            let (account_reward_earned : Uint256) = earned(caller)
            StakingRewards_rewards.write(caller, account_reward_earned)
            StakingRewards_reward_per_token_paid(caller, reward_per_token_stored)
            return ()
        end
        return ()
    end
end
