// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from openzeppelin.token.erc20.IERC20 import IERC20
from contracts.l2.staking.IStakingRewards import IStakingRewards

const ADMIN = 1;
const ALICE = 2;
const BOB = 3;
const ONE_MILLION = 1000000 * 10 ** 18;  // one million tokens
const ERC20_DECIMALS = 18;
const ERC20_INITIAL_SUPPLY = 100000000 * 10 ** 18;  // 100 million
const SEVEN_DAYS = 86400 * 7;
const MAX_UINT256_FELT = 2 ** 128 - 1;

namespace test_utils {
    func uint256_divide_and_ceil{range_check_ptr}(value: Uint256) -> (parsed_value: Uint256) {
        tempvar parsed_value: Uint256;
        %{
            import math
            ids.parsed_value.low = math.ceil(ids.value.low / 10 ** 18)
            ids.parsed_value.high = math.ceil(ids.value.high / 10 ** 18)
        %}
        [range_check_ptr] = parsed_value.low;
        [range_check_ptr + 1] = parsed_value.high;
        let range_check_ptr = range_check_ptr + 2;

        return (parsed_value,);
    }
    func distributeRewards{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
        alloc_locals;
        local reward_token;
        local staking_rewards;
        %{
            ids.reward_token = context.reward_token
            ids.staking_rewards = context.staking_rewards
        %}
        %{ stop_prank = start_prank(ids.ADMIN, context.reward_token) %}
        IERC20.transfer(
            contract_address=reward_token, recipient=staking_rewards, amount=Uint256(ONE_MILLION, 0)
        );
        %{ stop_prank() %}
        %{ stop_prank = start_prank(ids.ADMIN, context.staking_rewards) %}
        IStakingRewards.notifyRewardAmount(
            contract_address=staking_rewards, reward=Uint256(ONE_MILLION, 0)
        );
        %{ stop_prank() %}

        return ();
    }
}
