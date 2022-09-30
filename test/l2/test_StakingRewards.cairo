%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, assert_uint256_eq
from starkware.cairo.common.bool import TRUE
from openzeppelin.token.erc20.IERC20 import IERC20
from contracts.l2.staking.IStakingRewards import IStakingRewards

const ADMIN = 1;
const ALICE = 2;
const BOB = 3;
const ONE_MILLION = 1000000 * 10 ** 18;  // one million tokens
const ERC20_DECIMALS = 18;
const ERC20_INITIAL_SUPPLY = 100000000 * 10 ** 18;  // 100 million
const SEVEN_DAYS = 86400 * 7;
const MAX_UINT256 = 2 ** 128 - 1;

@view
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
        stop_prank_callable = start_prank(ids.ADMIN, context.staking_token)
    %}
    IERC20.transfer(
        contract_address=staking_token, recipient=ALICE, amount=Uint256(ONE_MILLION, 0)
    );
    IERC20.transfer(contract_address=staking_token, recipient=BOB, amount=Uint256(ONE_MILLION, 0));
    IERC20.approve(
        contract_address=staking_token,
        spender=staking_rewards,
        amount=Uint256(MAX_UINT256, MAX_UINT256),
    );
    %{ stop_prank_callable() %}
    %{ stop_prank_callable = start_prank(ids.ALICE, context.staking_token) %}
    IERC20.approve(
        contract_address=staking_token,
        spender=staking_rewards,
        amount=Uint256(MAX_UINT256, MAX_UINT256),
    );
    %{ stop_prank_callable() %}
    %{ stop_prank_callable = start_prank(ids.BOB, context.staking_token) %}
    IERC20.approve(
        contract_address=staking_token,
        spender=staking_rewards,
        amount=Uint256(MAX_UINT256, MAX_UINT256),
    );
    %{ stop_prank_callable() %}

    return ();
}

@view
func test_stakeL2{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    local staking_rewards;
    %{ ids.staking_rewards = context.staking_rewards %}
    %{ stop_prank_callable = start_prank(ids.ALICE, context.staking_rewards) %}
    let (success) = IStakingRewards.stakeL2(
        contract_address=staking_rewards, amount=Uint256(ONE_MILLION, 0)
    );
    assert success = TRUE;
    let (alice_balance) = IStakingRewards.balanceOf(
        contract_address=staking_rewards, account=ALICE
    );
    assert_uint256_eq(alice_balance, Uint256(ONE_MILLION, 0));
    %{ stop_prank_callable() %}

    return ();
}
