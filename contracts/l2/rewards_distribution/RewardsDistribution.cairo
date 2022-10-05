// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE
from starkware.cairo.common.uint256 import Uint256
from openzeppelin.access.ownable.library import Ownable
from contracts.l2.rewards_distribution.library import RewardsDistribution
from contracts.l2.rewards_distribution.IRewardsDistribution import Distribution

// @notice RewardsDistribution constructor
// @param authority Address responsible to execute rewards distributions
// @param owner Address with privileged control over the contract
// @param reward_token Reward token address
@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    authority: felt, owner: felt, reward_token: felt
) {
    Ownable.initializer(owner);
    RewardsDistribution.initializer(authority, reward_token);

    return ();
}

// @notice Returns the authority address, responsible to handle rewards distributions
// @returns authority_address Stored authority address
@view
func authority{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    authority_address: felt
) {
    let authority_address = RewardsDistribution.authority();

    return (authority_address,);
}

// @notice Returns reward token address
// @returns reward_token_address Stored reward token address
@view
func rewardToken{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    reward_token_address: felt
) {
    let reward_token_address = RewardsDistribution.reward_token();

    return (reward_token_address,);
}

// @notice Returns distribution given its index position
// @returns distribution Stored distribution struct containing the destination and
// amount of reward
@view
func distributions{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    index: felt
) -> (distribution: Distribution) {
    let (distribution) = RewardsDistribution.distributions(index);

    return (distribution,);
}

// @notice Returns number of distributions added until now
// @returns res Length of distribution array
@view
func distributionsLength{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    res: felt
) {
    let res = RewardsDistribution.distributions_len();

    return (res,);
}

// @notice Set the address of the contract authorised to call distributeRewards()
// @param authority Address of the authorised calling contract
@external
func setAuthority{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    authority: felt
) {
    Ownable.assert_only_owner();
    RewardsDistribution.set_authority(authority);

    return ();
}

// @notice Set the address of the reward token
// @param reward_token Address of the reward token
@external
func setRewardToken{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    reward_token: felt
) {
    Ownable.assert_only_owner();
    RewardsDistribution.set_reward_token(reward_token);

    return ();
}

// @notice Stores a new distribution struct to the array of distributions
// Each distribution stored is going to be iterated in `distributeRewards()`,
// which is when the authority sends the reward tokens to StakingRewards and
// updates its state.
// @param distribution Distribution struct with destination and amount data
// @returns success Whether execution was successful or not
@external
func addRewardDistribution{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    distribution: Distribution
) -> (success: felt) {
    Ownable.assert_only_owner();
    RewardsDistribution.add_reward_distribution(distribution);

    return (TRUE,);
}

// @notice Edits the data of a previously stored distribution struct.
// @param index Array index of the stored distribution
// @param distribution Distribution struct with destination and amount data
// @returns success Whether execution was successful or not
@external
func editRewardDistribution{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    index: felt, distribution: Distribution
) -> (success: felt) {
    Ownable.assert_only_owner();
    RewardsDistribution.edit_reward_distribution(index, distribution);

    return (TRUE,);
}

// @notice Executes the distribution of rewards and cleans up the stored distributions
// @param amount Amount of tokens to be distributed, must match the sum of all distributions
// amount value
// @returns success Whether execution was successful or not
@external
func distributeRewards{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    amount: Uint256
) -> (success: felt) {
    RewardsDistribution.distribute_rewards(amount);

    return (TRUE,);
}
