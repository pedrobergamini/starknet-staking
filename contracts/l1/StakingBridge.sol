// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { IStarkNetCore } from "./interfaces/IStarkNetCore.sol";
import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract StakingBridge {
    using SafeERC20 for IERC20;

    /// @dev StarkNet Core address
    IStarkNetCore public starknet;
    /// @dev Staking token address
    IERC20 public stakingToken;
    /// @dev Reward token address
    IERC20 public rewardToken;
    /// @dev L2 staking address
    uint256 public staking;

    // TODO: calculate correct cairo fn selectors
    /// @dev `stake_l1` cairo function selector
    uint256 public constant STAKE_L1_SELECTOR = 1;
    /// @dev `withdraw_l1` cairo function selector
    uint256 public constant WITHDRAW_L1_SELECTOR = 2;
    /// @dev `exit_l1` cairo function selector
    uint256 public constant EXIT_L1_SELECTOR = 3;

    event LogStake(address user, uint256 amount);
    event LogInitiateWithdrawal(address user, uint256 amount);
    event LogInitiateExit(address user);

    modifier onlyStarknet() {
        require(msg.sender == address(starknet), "StakingBridge: caller not starknet");
        _;
    }

    constructor(
        IStarkNetCore _starknet,
        IERC20 _stakingToken,
        IERC20 _rewardToken,
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
    function stake(uint256 _amount) external {
        require(_amount > 0, "StakingBridge: amount 0");

        uint256[] memory payload = new uint256[](3);
        payload[0] = uint256(uint160(msg.sender));
        payload[1] = _amount & (1 << (128 - 1));
        payload[2] = _amount >> 128;

        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);
        starknet.sendMessageToL2(staking, STAKE_L1_SELECTOR, payload);

        emit LogStake(msg.sender, _amount);
    }

    function initiateWithdrawal(uint256 amount) external {
        require(_amount > 0, "StakingBridge: amount 0");

        uint256[] memory payload = new uint256[](3);
        payload[0] = uint256(uint160(msg.sender));
        payload[1] = _amount & (1 << (128 - 1));
        payload[2] = _amount >> 128;

        starknet.sendMessageToL2(staking, WITHDRAW_L1_SELECTOR, payload);

        emit LogInitiateWithdrawal(msg.sender, _amount);
    }

    function initiateExit() external {
        uint256 memory payload = new uint256[](1);
        payload[0] = uint256(uint160(msg.sender));

        starknet.sendMessageToL2(staking, EXIT_L1_SELECTOR, payload);

        emit LogInitiateExit(msg.sender);
    }

    function executeWithdrawal() external onlyStarknet {}
}
