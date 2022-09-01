# SPDX-License-Identifier: MIT

%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

#
# Constants
#

# @dev Base rewards calculation multiplier, used for divisions
const BASE_MULTIPLIER = Uint256(10 ** 18, 0)

namespace StakingRewards:
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

    func StakingRewards_balance_of{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(account : felt) -> (balance : Uint256):
        let (balance) = balances.read(account)
        return (balance)
    end

    func StakingRewards_earned{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    end
end
