// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, assert_uint256_eq
from starkware.cairo.common.bool import TRUE
from starkware.starknet.common.syscalls import get_block_timestamp
from openzeppelin.token.erc20.IERC20 import IERC20
from openzeppelin.security.safemath.library import SafeUint256
from contracts.l2.staking.IStakingRewards import IStakingRewards
from utils import (
    test_utils,
    ADMIN,
    ALICE,
    BOB,
    AUTHORITY,
    ONE_MILLION,
    ERC20_DECIMALS,
    ERC20_INITIAL_SUPPLY,
    SEVEN_DAYS,
    MAX_UINT256_FELT,
)

@external
func __setup__{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    local rewards_distribution;
    local reward_token;
    local staking_rewards;

    %{
        context.rewards_distribution = deploy_contract("contracts/l2/rewards_distribution/RewardsDistribution.cairo",
            {
              "authority": ids.AUTHORITY,
              "owner": ids.ADMIN
            }
        ).contract_address
        context.staking_token = deploy_contract("lib/cairo_contracts/src/openzeppelin/token/erc20/presets/ERC20.cairo",
            {
                "name": "Staking Token",
                "symbol": "STK",
                "decimals": ids.ERC20_DECIMALS,
                "initial_supply": ids.ERC20_INITIAL_SUPPLY,
                "recipient": ids.ADMIN
            }
        ).contract_address
        context.reward_token = deploy_contract("lib/cairo_contracts/src/openzeppelin/token/erc20/presets/ERC20.cairo",
            {
                "name": "Reward Token",
                "symbol": "RWD",
                "decimals": ids.ERC20_DECIMALS,
                "initial_supply": ids.ERC20_INITIAL_SUPPLY,
                "recipient": ids.ADMIN
            }
        ).contract_address
        context.staking_rewards = deploy_contract("contracts/l2/staking/StakingRewards.cairo",
            {
                "rewards_distribution": ids.ADMIN,
                "reward_token": context.reward_token,
                "staking_token": context.staking_token,
                "initial_rewards_duration": ids.SEVEN_DAYS,
                "owner": ids.ADMIN
            }
        ).contract_address
        ids.rewards_distribution = context.rewards_distribution
        ids.reward_token = context.reward_token
        ids.staking_rewards = context.staking_rewards
        stop_prank = start_prank(ids.ADMIN, context.staking_token)
    %}

    return ();
}
