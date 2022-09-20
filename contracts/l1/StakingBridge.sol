// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { IStarkNetMessaging } from "./interfaces/IStarkNetMessaging.sol";
import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20Mintable } from "./interfaces/IERC20Mintable.sol";

contract StakingBridge {
    using SafeERC20 for IERC20;

    /// @dev StarkNet Messaging address
    IStarkNetMessaging public starknet;
    /// @dev Staking token address
    IERC20 public stakingToken;
    /// @dev Reward token address
    IERC20Mintable public rewardToken;
    /// @dev L2 staking address
    uint256 public staking;

    // TODO: calculate correct cairo fn selectors
    /// @dev `stake_l1` cairo function selector
    uint256 public constant STAKE_L1_SELECTOR = 1;
    /// @dev Starknet contract withdraw message
    uint256 public constant WITHDRAW_MESSAGE = 1;
    /// @dev Starknet contract claim reward message
    uint256 public constant CLAIM_REWARD_MESSAGE = 2;

    event LogStake(address user, uint256 amount);
    event LogWithdraw(address user, uint256 amount);
    event LogClaimReward(address user, uint256 amount);

    constructor(
        IStarkNetMessaging _starknet,
        IERC20 _stakingToken,
        IERC20Mintable _rewardToken,
        uint256 _staking
    ) {
        require(address(_starknet) != address(0), "StakingBridge: invalid _starknet");
        require(address(_stakingToken) != address(0), "StakingBridge: invalid _stakingToken");
        require(address(_rewardToken) != address(0), "StakingBridge: invalid _rewardToken");
        require(_staking != 0, "StakingBridge: invalid _staking");

        starknet = _starknet;
        stakingToken = _stakingToken;
        rewardToken = _rewardToken;
        staking = _staking;
    }

    /// @notice Stake tokens directly from L1 to L2
    /// @param _amount number of tokens to stake
    function stake(uint256 _amount) external returns (bool) {
        require(_amount > 0, "StakingBridge: amount 0");

        uint256[] memory payload = new uint256[](3);
        payload[0] = uint256(uint160(msg.sender));
        payload[1] = _amount & (1 << (128 - 1));
        payload[2] = _amount >> 128;

        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);
        starknet.sendMessageToL2(staking, STAKE_L1_SELECTOR, payload);

        emit LogStake(msg.sender, _amount);
        return true;
    }

    /// @notice Executes withdrawal initiated in L2
    /// @param _amount number of tokens being withdrawn
    function withdraw(uint256 _amount) external returns (bool) {
        _consumeMessage(WITHDRAW_MESSAGE, _amount);
        stakingToken.safeTransfer(msg.sender, _amount);

        emit LogWithdraw(msg.sender, _amount);
        return true;
    }

    /// @notice Claims reward accumulated in L2
    /// @dev Assumes this bridge has the permission to mint reward tokens
    /// @param _reward number of reward tokens accumulated in L2
    function claimReward(uint256 _reward) external returns (bool) {
        _consumeMessage(CLAIM_REWARD_MESSAGE, _reward);
        rewardToken.mint(msg.sender, _reward);

        emit LogClaimReward(msg.sender, _reward);
        return true;
    }

    /// @dev Consumes a given message from StarkNet's Messaging contract
    /// @param _message L2 message id
    /// @param _amount amount of tokens to withdraw/claim
    function _consumeMessage(uint256 _message, uint256 _amount) internal {
        uint256[] memory payload = new uint256[](4);
        payload[0] = _message;
        payload[1] = uint256(uint160(msg.sender));
        payload[2] = _amount & (1 << (128 - 1));
        payload[3] = _amount >> 128;

        starknet.consumeMessageFromL2(staking, payload);
    }
}
