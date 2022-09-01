# SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_mul
from contracts.l2.openzeppelin.security.safemath.library import SafeUint256

#
# Constants
#

# @dev Base rewards calculation multiplier, used for divisions
const BASE_MULTIPLIER = 10 ** 18

@storage_var
func StakingRewards_reward_token() -> (token : felt):
end

@storage_var
func StakingRewards_staking_token() -> (token : felt):
end

@storage_var
func StakingRewards_reward_per_token() -> (reward_per_token : Uint256):
end

@storage_var
func StakingRewards_reward_rate() -> (reward_rate : Uint256):
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
    func balance_of{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        account : felt
    ) -> (balance : Uint256):
        let (balance : Uint256) = StakingRewards_balances.read(account)
        return (balance)
    end

    func reward_per_token{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        reward : Uint256
    ):
        return (Uint256(1, 0))
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
end
