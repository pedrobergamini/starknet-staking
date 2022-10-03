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
    ONE_MILLION,
    ERC20_DECIMALS,
    ERC20_INITIAL_SUPPLY,
    SEVEN_DAYS,
    MAX_UINT256_FELT,
)

@external
func __setup__{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    local staking_token;
    local reward_token;
    local staking_rewards;

    %{
        context.staking_token = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc20/presets/ERC20.cairo",
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
        ids.staking_token = context.staking_token
        ids.reward_token = context.reward_token
        ids.staking_rewards = context.staking_rewards
        stop_prank = start_prank(ids.ADMIN, context.staking_token)
    %}
    IERC20.transfer(
        contract_address=staking_token, recipient=ALICE, amount=Uint256(ONE_MILLION, 0)
    );
    IERC20.transfer(contract_address=staking_token, recipient=BOB, amount=Uint256(ONE_MILLION, 0));
    IERC20.approve(
        contract_address=staking_token,
        spender=staking_rewards,
        amount=Uint256(MAX_UINT256_FELT, MAX_UINT256_FELT),
    );
    %{ stop_prank() %}
    %{ stop_prank = start_prank(ids.ALICE, context.staking_token) %}
    IERC20.approve(
        contract_address=staking_token,
        spender=staking_rewards,
        amount=Uint256(MAX_UINT256_FELT, MAX_UINT256_FELT),
    );
    %{ stop_prank() %}
    %{ stop_prank = start_prank(ids.BOB, context.staking_token) %}
    IERC20.approve(
        contract_address=staking_token,
        spender=staking_rewards,
        amount=Uint256(MAX_UINT256_FELT, MAX_UINT256_FELT),
    );
    %{ stop_prank() %}

    return ();
}

@external
func test_balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    local staking_rewards;
    %{ ids.staking_rewards = context.staking_rewards %}
    %{ stop_prank = start_prank(ids.ALICE, context.staking_rewards) %}
    let (success) = IStakingRewards.stakeL2(
        contract_address=staking_rewards, amount=Uint256(ONE_MILLION, 0)
    );
    assert success = TRUE;
    let (alice_balance) = IStakingRewards.balanceOf(
        contract_address=staking_rewards, account=ALICE
    );
    assert_uint256_eq(alice_balance, Uint256(ONE_MILLION, 0));
    %{ stop_prank() %}

    return ();
}

@external
func test_earned{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    local staking_rewards;
    local stake_value: Uint256 = Uint256(1000 * 10 ** 18, 0);
    %{ ids.staking_rewards = context.staking_rewards %}
    test_utils.distributeRewards();
    %{ stop_prank = start_prank(ids.ALICE, context.staking_rewards) %}
    IStakingRewards.stakeL2(contract_address=staking_rewards, amount=stake_value);
    %{ stop_prank() %}
    %{ stop_prank = start_prank(ids.BOB, context.staking_rewards) %}
    IStakingRewards.stakeL2(contract_address=staking_rewards, amount=stake_value);
    let (block_timestamp) = get_block_timestamp();
    %{ stop_warp = warp(ids.block_timestamp + ids.SEVEN_DAYS, ids.staking_rewards) %}
    let (new_block_timestamp) = get_block_timestamp();
    %{ stop_prank() %}
    %{ stop_prank = start_prank(ids.ALICE, context.staking_rewards) %}
    IStakingRewards.stakeL2(contract_address=staking_rewards, amount=Uint256(500, 0));
    let (alice_reward) = IStakingRewards.earned(contract_address=staking_rewards, account=ALICE);
    let (bob_reward) = IStakingRewards.earned(contract_address=staking_rewards, account=BOB);
    let (expected_rewards, _) = SafeUint256.div_rem(Uint256(ONE_MILLION, 0), Uint256(2, 0));
    let (alice_reward_parsed) = test_utils.uint256_divide_and_ceil(alice_reward);
    let (bob_reward_parsed) = test_utils.uint256_divide_and_ceil(bob_reward);
    let (expected_rewards_parsed) = test_utils.uint256_divide_and_ceil(expected_rewards);

    assert_uint256_eq(alice_reward_parsed, expected_rewards_parsed);
    assert_uint256_eq(bob_reward_parsed, expected_rewards_parsed);
    %{ stop_prank() %}

    return ();
}

@external
func test_getRewardForDuration{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    local staking_rewards;
    %{ ids.staking_rewards = context.staking_rewards %}
    test_utils.distributeRewards();
    let (reward_for_duration) = IStakingRewards.getRewardForDuration(
        contract_address=staking_rewards
    );
    let (reward_for_duration_parsed) = test_utils.uint256_divide_and_ceil(reward_for_duration);
    let (expected_value_parsed) = test_utils.uint256_divide_and_ceil(Uint256(ONE_MILLION, 0));

    assert_uint256_eq(reward_for_duration_parsed, expected_value_parsed);

    return ();
}

@external
func test_lastTimeRewardApplicable{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    ) {
    alloc_locals;
    local staking_rewards;
    test_utils.distributeRewards();
    let (block_timestamp) = get_block_timestamp();
    %{
        ids.staking_rewards = context.staking_rewards
        stop_warp = warp(ids.block_timestamp + 1000, ids.staking_rewards)
    %}
    let (first_res) = IStakingRewards.lastTimeRewardApplicable(contract_address=staking_rewards);
    let (block_timestamp) = get_block_timestamp();
    %{
        stop_warp()
        stop_warp = warp(ids.block_timestamp + ids.SEVEN_DAYS + 100, ids.staking_rewards)
    %}
    let (second_res) = IStakingRewards.lastTimeRewardApplicable(contract_address=staking_rewards);

    assert first_res = 1000;
    assert second_res = SEVEN_DAYS;

    return ();
}

@external
func test_rewardPerToken{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    local staking_rewards;
    local stake_value: Uint256 = Uint256(1000 * 10 ** 18, 0);
    %{ ids.staking_rewards = context.staking_rewards %}
    test_utils.distributeRewards();
    %{ stop_prank = start_prank(ids.ALICE, context.staking_rewards) %}
    IStakingRewards.stakeL2(contract_address=staking_rewards, amount=stake_value);
    %{ stop_prank() %}
    %{ stop_prank = start_prank(ids.BOB, context.staking_rewards) %}
    IStakingRewards.stakeL2(contract_address=staking_rewards, amount=stake_value);
    let (block_timestamp) = get_block_timestamp();
    %{ stop_warp = warp(ids.block_timestamp + ids.SEVEN_DAYS, ids.staking_rewards) %}
    let (reward_per_token) = IStakingRewards.rewardPerToken(contract_address=staking_rewards);
    let (reward_per_token_parsed) = test_utils.uint256_divide_and_ceil(reward_per_token);
    let expected_reward_per_token = ONE_MILLION / (stake_value.low * 2);

    assert reward_per_token_parsed.low = expected_reward_per_token;

    return ();
}

@external
func test_setRewardsDuration{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    local staking_rewards;
    local duration = SEVEN_DAYS / 7;
    %{
        ids.staking_rewards = context.staking_rewards
        stop_prank = start_prank(ids.ADMIN, context.staking_rewards)
        expect_revert(error_message="StakingRewards: Previous rewards period must finish")
    %}
    IStakingRewards.setRewardsDuration(contract_address=staking_rewards, duration=duration);
    %{ expect_revert(error_message="StakingRewards: invalid duration") %}
    IStakingRewards.setRewardsDuration(
        contract_address=staking_rewards, duration=MAX_UINT256_FELT + 1
    );
    %{
        stop_prank()
        stop_prank = start_prank(ids.ALICE, context.staking_rewards)
        expect_revert(error_message="Ownable: caller is not the owner")
    %}
    IStakingRewards.setRewardsDuration(
        contract_address=staking_rewards, duration=MAX_UINT256_FELT + 1
    );

    return ();
}

@external
func test_recoverERC20{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    local mocked_token;
    local staking_rewards;
    local token_amount: Uint256 = Uint256(ONE_MILLION, 0);
    %{
        ids.mocked_token = deploy_contract("lib/cairo_contracts/src/openzeppelin/token/erc20/presets/ERC20.cairo",
            {
                "name": "Mocked Token",
                "symbol": "MTKN",
                "decimals": ids.ERC20_DECIMALS,
                "initial_supply": ids.ERC20_INITIAL_SUPPLY,
                "recipient": ids.ADMIN
            }
        ).contract_address
        ids.staking_rewards = context.staking_rewards
        stop_prank = start_prank(ids.ADMIN, ids.mocked_token)
    %}
    IERC20.transfer(contract_address=mocked_token, recipient=staking_rewards, amount=token_amount);
    let (initial_balance) = IERC20.balanceOf(contract_address=mocked_token, account=ADMIN);
    %{
        expect_events({"name": "LogRecoverERC20", "token": ids.mocked_token, "amount": ids.token_amount})
        stop_prank()
        stop_prank = start_prank(ids.ADMIN, ids.staking_rewards)
    %}
    IStakingRewards.recoverERC20(
        contract_address=staking_rewards, token=mocked_token, amount=token_amount
    );
    let (final_balance) = IERC20.balanceOf(contract_address=mocked_token, account=ADMIN);
    let (recovered_amount) = SafeUint256.sub_lt(final_balance, initial_balance);
    %{
        stop_prank()
        stop_prank = start_prank(ids.ALICE, context.staking_rewards)
        expect_revert(error_message="Ownable: caller is not the owner")
    %}
    IStakingRewards.recoverERC20(
        contract_address=staking_rewards, token=mocked_token, amount=token_amount
    );

    assert_uint256_eq(recovered_amount, token_amount);

    return ();
}

@external
func test_stakeL2{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    local staking_rewards;
    local stake_value: Uint256 = Uint256(1000 * 10 ** 18, 0);
    %{
        ids.staking_rewards = context.staking_rewards
        stop_prank = start_prank(ids.ALICE, context.staking_rewards)
    %}
    %{ expect_events({"name": "LogStake", "user": ids.ALICE, "amount": ids.stake_value, "staked_from_l1": 0}) %}
    let (success) = IStakingRewards.stakeL2(contract_address=staking_rewards, amount=stake_value);
    assert success = TRUE;
    %{ stop_prank() %}
    test_utils.distributeRewards();
    %{ expect_revert(error_message="StakingRewards: cannot stake 0") %}
    IStakingRewards.stakeL2(contract_address=staking_rewards, amount=Uint256(0, 0));

    %{
        stop_prank = start_prank(ids.BOB, context.staking_rewards)
        expect_events({"name": "LogStake", "user": ids.BOB, "amount": ids.stake_value, "staked_from_l1": 0})
    %}
    let (success) = IStakingRewards.stakeL2(contract_address=staking_rewards, amount=stake_value);
    let (total_supply) = IStakingRewards.totalSupply(contract_address=staking_rewards);
    let (balance) = IStakingRewards.balanceOf(contract_address=staking_rewards, account=BOB);
    let (expected_total_supply) = SafeUint256.mul(stake_value, Uint256(2, 0));

    assert success = TRUE;
    assert_uint256_eq(total_supply, expected_total_supply);
    assert_uint256_eq(balance, stake_value);

    return ();
}

@external
func test_withdrawL2{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    local staking_rewards;
    local alice_stake_value: Uint256 = Uint256(2000 * 10 ** 18, 0);
    local bob_stake_value: Uint256 = Uint256(1000 * 10 ** 18, 0);
    %{ ids.staking_rewards = context.staking_rewards %}
    test_utils.distributeRewards();

    %{ stop_prank = start_prank(ids.BOB, context.staking_rewards) %}
    IStakingRewards.stakeL2(contract_address=staking_rewards, amount=bob_stake_value);
    %{ expect_events({"name": "LogWithdraw", "user": ids.BOB, "amount": ids.bob_stake_value, "withdrawn_to_l1": 0}) %}
    let (success) = IStakingRewards.withdrawL2(
        contract_address=staking_rewards, amount=bob_stake_value
    );
    assert success = TRUE;
    %{
        stop_prank()
        stop_prank = start_prank(ids.ALICE, context.staking_rewards)
    %}
    IStakingRewards.stakeL2(contract_address=staking_rewards, amount=alice_stake_value);
    %{ expect_events({"name": "LogWithdraw", "user": ids.ALICE, "amount": ids.bob_stake_value, "withdrawn_to_l1": 0}) %}
    let (success) = IStakingRewards.withdrawL2(
        contract_address=staking_rewards, amount=bob_stake_value
    );
    assert success = TRUE;

    %{ expect_revert(error_message="StakingRewards: cannot withdraw 0") %}

    let (success) = IStakingRewards.withdrawL2(
        contract_address=staking_rewards, amount=Uint256(0, 0)
    );
    let (total_supply) = IStakingRewards.totalSupply(contract_address=staking_rewards);
    let (alice_balance) = IStakingRewards.balanceOf(
        contract_address=staking_rewards, account=ALICE
    );
    let (bob_balance) = IStakingRewards.balanceOf(contract_address=staking_rewards, account=BOB);
    let expected_total_supply = Uint256(1000 * 10 ** 18, 0);
    let expected_alice_balance = Uint256(1000 * 10 ** 18, 0);
    let expected_bob_balance = Uint256(0, 0);

    assert success = TRUE;
    assert_uint256_eq(total_supply, expected_total_supply);
    assert_uint256_eq(alice_balance, expected_alice_balance);
    assert_uint256_eq(bob_balance, expected_bob_balance);

    return ();
}

// @view
// func test_claimRewards

// @view
// func test_exitL2
