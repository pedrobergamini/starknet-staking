// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE
from starkware.starknet.common.syscalls import get_caller_address
from openzeppelin.access.ownable.library import Ownable
from contracts.l2.staking.library import StakingRewards

// @notice StakingRewards constructor
// @param rewards_distribution RewardsDistribution contract address
// @param reward_token ERC20 token used for staking rewards
// @param staking_token ERC20 token used for deposits/withdrawals
// @param initial_rewards_duration Initial value for the duration of rewards
// @param owner Privileged address with access to admin functions
@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    rewards_distribution: felt,
    reward_token: felt,
    staking_token: felt,
    initial_rewards_duration: felt,
    owner: felt,
) {
    Ownable.initializer(owner);
    StakingRewards.initializer(
        rewards_distribution, reward_token, staking_token, initial_rewards_duration
    );

    return ();
}

//
// View functions
//

// @notice Returns the staking balance of a given account
// @param account Address of a staking account
// @returns balance Amount of staked tokens
@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(account: felt) -> (
    balance: Uint256
) {
    let (balance: Uint256) = StakingRewards.balance_of(account);

    return (balance,);
}

// @notice Calculates amount of staking rewards earned
// @param account Address of a staking account
// @returns reward Amount of rewards accrued so far
@view
func earned{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(account: felt) -> (
    reward: Uint256
) {
    let (reward: Uint256) = StakingRewards.earned(account);

    return (reward,);
}

// @notice Returns the number of total reward tokens allocated for the current period duration
// @returns reward Total reward
@view
func getRewardForDuration{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    reward: Uint256
) {
    let (reward: Uint256) = StakingRewards.get_reward_for_duration();

    return (reward,);
}

// @notice Returns last timestamp applicable for rewards calculation
// @dev If reward  period has finished, it will return the timestamp of when it finished
// otherwise it will return the latest block_timestamp
// @returns timestamp Last timestamp applicable for rewards
@view
func lastTimeRewardApplicable{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    ) -> (timestamp: felt) {
    let (timestamp) = StakingRewards.last_time_reward_applicable();

    return (timestamp,);
}

// @notice Returns the latest amount of reward accumulated per token
// @returns reward_per_token Current stored value or most up to date reward per token
@view
func rewardPerToken{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    reward_per_token: Uint256
) {
    let (reward_per_token: Uint256) = StakingRewards.reward_per_token();

    return (reward_per_token,);
}

// @notice Returns the reward token address
// @return token ERC20 token contract address
@view
func rewardToken{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    token: felt
) {
    let reward_token = StakingRewards.reward_token();

    return (reward_token,);
}

// @notice Returns the staking token address
// @return token ERC20 token contract address
@view
func stakingToken{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    token: felt
) {
    let staking_token = StakingRewards.staking_token();

    return (staking_token,);
}

// @notice Returns when the current reward period finishes
// @return period_finish Timestamp of when the reward period finishes
@view
func periodFinish{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    period_finish: felt
) {
    let period_finish = StakingRewards.period_finish();

    return (period_finish,);
}

// @notice Returns the current reward per second value
// @returns reward_rate Current reward per second
@view
func rewardRate{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    reward_rate: Uint256
) {
    let (reward_rate) = StakingRewards.reward_rate();

    return (reward_rate,);
}
// @notice Returns the current duration for each reward period
// @returns reward_duration Stored reward duration in seconds
@view
func rewardsDuration{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    rewards_duration: felt
) {
    let rewards_duration = StakingRewards.rewards_duration();

    return (rewards_duration,);
}

// @notice Returns the L1 Staking Bridge address
// @returns res Stored staking bridge address in Ethereum's format
@view
func stakingBridgeL1{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    res: felt
) {
    let staking_bridge_l1_address = StakingRewards.staking_bridge_l1();

    return (staking_bridge_l1_address,);
}

// @notice Returns the reward distribution contract address
// @return contract_address Stored reward distribution contract address
@view
func rewardsDistribution{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    contract_address: felt
) {
    let rewards_distribution = StakingRewards.rewards_distribution();

    return (rewards_distribution,);
}

// @notice Returns the total amount of staked tokens
// @dev If a user sends tokens directly to the contract without using a stake function,
// this value won't be updated
// @returns total_supply Stored amount of tokens staked in the contract
@view
func totalSupply{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    total_supply: Uint256
) {
    let (total_supply: Uint256) = StakingRewards.total_supply();

    return (total_supply,);
}

//
// External functions
//

// @notice Updates the duration of a reward period
// @dev Only the owner is able to update this value
@external
func setRewardsDuration{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    duration: felt
) {
    Ownable.assert_only_owner();
    StakingRewards.set_rewards_duration(duration);

    return ();
}

// @notice Updates the rewards distribution contract address
// @dev Only the owner is able to update this value
@external
func setRewardsDistribution{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    rewards_distribution: felt
) {
    Ownable.assert_only_owner();
    StakingRewards.set_rewards_distribution(rewards_distribution);

    return ();
}

// @notice Recovers ERC20 tokens accidentally sent to this contract
// @dev Only the owner is able to update this value
// @dev Staked tokens cannot be withdrawn from the pool, even by the owner
// @dev Recovered tokens are sent to the owner address
// @param token ERC20 contract address
// @param amount Amount of tokens to be recovered
@external
func recoverERC20{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token: felt, amount: Uint256
) {
    Ownable.assert_only_owner();
    let (owner) = Ownable.owner();
    StakingRewards.recover_erc20(token, owner, amount);

    return ();
}

// @notice Used by the rewards distributions contract to notify the staking
// rewards contract of a new reward distribution
// @dev Only the rewards distribution contract can call this function
// @dev Reward related global state variables are update in this function in order
// to reflect the new distribution
// @param reward Amount of reward tokens being sent
@external
func notifyRewardAmount{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    reward: Uint256
) {
    StakingRewards.notify_reward_amount(reward);

    return ();
}

// @notice Stakes tokens from the caller's L2 wallet
// @dev Previous ERC20 approval to the staking rewards address is required
// @dev This function is used for staking tokens from a user that already has been
// onboarded to L2. Which means tokens can't be brought to L1 through the withdrawL1
// function
// @param amount Amount of tokens being staked
// @returns success Whether execution was successful or not
@external
func stakeL2{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(amount: Uint256) -> (
    success: felt
) {
    StakingRewards.stake_l2(amount);

    return (TRUE,);
}

// @notice Stakes tokens from a L1 message using the staking bridge
// @dev Users may opt to stake tokens directly from L1 and accumulate reward
// tokens in L2 to save gas, but when staking from L1 it's only possible to withdraw
// back to L1, which means withdrawL2 function won't be accessible
// @param from_address L1 contract which created the message
// @param l1_user Address of the L1 user calling the L1 contract
// @param amount Amount of tokens being staked
@l1_handler
func stakeL1{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    from_address: felt, l1_user: felt, amount: Uint256
) {
    StakingRewards.stake_l1(from_address, l1_user, amount);

    return ();
}

// @notice Withdraw staking tokens back to the L2 wallet address
// @dev Users that staked from l1 are not able to use this function
// @param amount Amount of tokens being withdrawn
// @returns success Whether execution was successful or not
@external
func withdrawL2{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    amount: Uint256
) -> (success: felt) {
    StakingRewards.withdraw_l2(amount);

    return (TRUE,);
}

// @notice Sends a message to the L1 staking bridge in order to allow the L1 user
// to withdraw an amount staked tokens
// @dev Tokens being withdrawn will be made available on the L1 staking bridge contract
// once L2 updates its state on L1
// @param amount Amount of tokens being withdrawn
// @returns success Whether execution was successful or not
@external
func withdrawL1{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    amount: Uint256
) -> (success: felt) {
    StakingRewards.withdraw_l1(amount);

    return (TRUE,);
}

// @notice Claims reward to L2 wallet address
// @dev Users are allowed to provide a L2 wallet address to receive the reward tokens,
// this way L1 users can stake from the staking bridge and claim rewards with low gas fees
// to a L2 wallet address
// @param recipient L2 wallet address receiving the reward tokens
// @returns success Whether execution was successful or not
@external
func claimRewardL2{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    recipient: felt
) -> (success: felt) {
    StakingRewards.claim_reward_l2(recipient);

    return (TRUE,);
}

// @notice Sends a message to the L1 staking bridge to unlock rewards straight to
// the L1 recipient address
// @param recipient L1 wallet address receiving the reward tokens
// @returns success Whether execution was successful or not
@external
func claimRewardL1{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    recipient: felt
) -> (success: felt) {
    StakingRewards.claim_reward_l1(recipient);

    return (TRUE,);
}

// @notice Claims all available rewards and unstakes to a L2 wallet
// @param reward_recipient L2 wallet address receiving the reward tokens
// @returns success Whether execution was successful or not
@external
func exitL2{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    reward_recipient: felt
) -> (success: felt) {
    StakingRewards.exit_l2(reward_recipient);

    return (TRUE,);
}

// @notice Sends a message to the L1 staking bridge to claim all available rewards
// and unstake to a L1 wallet
// @param reward_recipient L1 wallet address receiving the reward tokens
// @returns success Whether execution was successful or not
@external
func exitL1{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    reward_recipient: felt
) {
    StakingRewards.exit_l1(reward_recipient);

    return ();
}
