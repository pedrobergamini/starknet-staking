%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin

const ADMIN = 1;
const ALICE = 2;
const BOB = 3;
const ERC20_DECIMALS = 18;
const ERC20_INITIAL_SUPPLY = 100000000 * 10 ** 18;  // 100 million
const SEVEN_DAYS = 86400 * 7;

@view
func __setup__() {
    %{
        context.staking_token = deploy_contract("openzeppelin/token/erc20/presets/ERC20.cairo" [
            "Staking Token",
            "STK",
            ERC20_DECIMALS,
            Uint256(ERC20_INITIAL_SUPPLY, 0),
            ADMIN
        ]).contract_address
        context.reward_token = deploy_contract("openzeppelin/token/erc20/presets/ERC20.cairo", [
            "Reward Token",
            "RWD",
            ERC20_DECIMALS,
            UINT256(ERC20_INITIAL_SUPPLY, 0),
            ADMIN
        ]).contract_address
        context.staking_rewards = deploy_contract("contracts/l2/staking/StakingRewards.cairo", [
            ADMIN,
            context.reward_token,
            context.staking_token,
            SEVEN_DAYS,
            ADMIN

        ]).contract_address
        print(context.staking_token, context.reward_token, context.staking_rewards)
    %}

    @view
    func test_stake_l2() {
        assert 1 = 1;
    }
}
