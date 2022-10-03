// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, assert_uint256_eq
from starkware.cairo.common.bool import TRUE
from starkware.starknet.common.syscalls import get_block_timestamp
from openzeppelin.token.erc20.IERC20 import IERC20
from openzeppelin.security.safemath.library import SafeUint256
from contracts.l2.staking.IStakingRewards import IStakingRewards
from contracts.l2.rewards_distribution.IRewardsDistribution import (
    IRewardsDistribution,
    Distribution,
)
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
        context.rewards_distribution = deploy_contract("contracts/l2/rewards_distribution/RewardsDistribution.cairo",
            {
              "authority": ids.AUTHORITY,
              "owner": ids.ADMIN,
              "reward_token": context.reward_token
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

@external
func test_authority{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    tempvar rewards_distribution;
    %{ ids.rewards_distribution = context.rewards_distribution %}
    let (authority) = IRewardsDistribution.authority(contract_address=rewards_distribution);
    assert authority = AUTHORITY;

    return ();
}

@external
func test_rewardToken{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    tempvar rewards_distribution;
    tempvar reward_token;
    %{
        ids.rewards_distribution = context.rewards_distribution
        ids.reward_token = context.reward_token
    %}
    let (res) = IRewardsDistribution.rewardToken(contract_address=rewards_distribution);

    assert reward_token = res;

    return ();
}

@external
func test_setAuthority{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    tempvar rewards_distribution;
    %{
        ids.rewards_distribution = context.rewards_distribution
        stop_prank = start_prank(ids.ADMIN,context.rewards_distribution)
    %}
    IRewardsDistribution.setAuthority(contract_address=rewards_distribution, authority=ADMIN);
    let (authority) = IRewardsDistribution.authority(contract_address=rewards_distribution);

    assert authority = ADMIN;
    %{ stop_prank() %}

    return ();
}

@external
func test_setRewardToken{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    tempvar rewards_distribution;
    %{
        ids.rewards_distribution = context.rewards_distribution
        stop_prank = start_prank(ids.ADMIN,context.rewards_distribution)
    %}
    IRewardsDistribution.setRewardToken(contract_address=rewards_distribution, reward_token=ADMIN);
    let (reward_token) = IRewardsDistribution.rewardToken(contract_address=rewards_distribution);
    assert reward_token = ADMIN;
    %{ stop_prank() %}

    return ();
}

@external
func test_addRewardDistribution{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    local rewards_distribution;
    local staking_rewards;

    let distribution_amount: Uint256 = Uint256(ONE_MILLION, 0);
    let distribution: Distribution = Distribution(staking_rewards, distribution_amount);
    %{
        ids.rewards_distribution = context.rewards_distribution
        ids.staking_rewards = context.staking_rewards
        stop_prank = start_prank(ids.ALICE, context.rewards_distribution)
    %}
    %{ expect_revert(error_message="Ownable: caller is not the owner") %}
    IRewardsDistribution.addRewardDistribution(
        contract_address=rewards_distribution, distribution=distribution
    );

    %{
        stop_prank()
        stop_prank = start_prank(ids.ADMIN, context.rewards_distribution)
    %}
    let invalid_distribution: Distribution = Distribution(staking_rewards, Uint256(0, 0));
    %{ expect_revert(error_message="RewardsDistribution: invalid destination or amount") %}
    IRewardsDistribution.addRewardDistribution(
        contract_address=rewards_distribution, distribution=invalid_distribution
    );

    let (success) = IRewardsDistribution.addRewardDistribution(
        contract_address=rewards_distribution, distribution=distribution
    );

    assert success = TRUE;

    let (distribution_stored) = IRewardsDistribution.distributions(
        contract_address=rewards_distribution, index=0
    );
    let (distributions_len) = IRewardsDistribution.distributionsLength(
        contract_address=rewards_distribution
    );

    assert distribution_stored = distribution;
    assert distributions_len = 1;

    return ();
}

@external
func test_editRewardDistributon{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    local rewards_distribution;
    local staking_rewards;

    let distribution_amount: Uint256 = Uint256(ONE_MILLION, 0);
    let new_distribution_amount: Uint256 = Uint256(1000 * 10 ** 18, 0);
    let distribution: Distribution = Distribution(staking_rewards, distribution_amount);
    let new_distribution: Distribution = Distribution(staking_rewards, new_distribution_amount);
    %{
        ids.rewards_distribution = context.rewards_distribution
        ids.staking_rewards = context.staking_rewards
        stop_prank = start_prank(ids.ADMIN, context.rewards_distribution)
    %}
    let (success) = IRewardsDistribution.addRewardDistribution(
        contract_address=rewards_distribution, distribution=distribution
    );

    assert success = TRUE;
    %{
        stop_prank()
        stop_prank = start_prank(ids.ALICE, context.rewards_distribution)
        expect_revert(error_message="Ownable: caller is not the owner")
    %}
    IRewardsDistribution.editRewardDistribution(
        contract_address=rewards_distribution, index=0, distribution=new_distribution
    );
    %{
        stop_prank()
        stop_prank = start_prank(ids.ADMIN, context.rewards_distribution)
        expect_revert(error_message="RewardsDistribution: index out of bounds")
    %}
    IRewardsDistribution.editRewardDistribution(
        contract_address=rewards_distribution, index=1, distribution=new_distribution
    );
    %{ expect_revert(error_message="RewardsDistribution: invalid destination or amount") %}
    let invalid_distribution: Distribution = Distribution(staking_rewards, Uint256(0, 0));
    IRewardsDistribution.editRewardDistribution(
        contract_address=rewards_distribution, index=0, distribution=invalid_distribution
    );

    let (success) = IRewardsDistribution.editRewardDistribution(
        contract_address=rewards_distribution, index=0, distribution=new_distribution
    );
    let (distribution_stored) = IRewardsDistribution.distributions(
        contract_address=rewards_distribution, index=0
    );

    assert success = TRUE;
    assert distribution_stored = distribution;

    return ();
}
