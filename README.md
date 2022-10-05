# StarkNet Staking Rewards Template

# <img src="logo.png" alt="Cross-Domain Staking Rewards">

**WARNING: This repo hasn't been audited and still isn't fully covered with tests.**

## Overview

This repo is inspired on (Synthetix's Staking Rewards contract)[https://github.com/Synthetixio/synthetix/blob/develop/contracts/StakingRewards.sol], but designed for StarkNet and with extra features to introduce a Cross-Domain rewards earning mechanism. Multiple StakingRewards instances may be deployed and users can stake in order to earn reward tokens either directly in StarkNet, or without having to bridge liquidity to L2 by using the `StakingBridge` L1 contract. Using this design, developers are able to onboard L1 users and liquidity to L2 with less barriers compared to allowing only L2 tokens to be used in the system.

## Architecture

[]

## Contracts

**L1**

- `StakingBridge` Communicates with StarknetMessaging and handles L1 users interactions

**L2**

- `StakingRewards` Allows depositing the registered staking token in order to earn reward tokens at a certain rate
- `RewardsDistribution` Handles allocation of reward tokens in the StakingRewards deployed instances

### Contracts L1 <> L2 flow

### Staking

Developers are able to deploy multiple StakingRewards contracts in order to support a variety of staking tokens and incentivize users staking with an allocation of reward tokens. Staking tokens that a project may want to list can potentially be in a state where they still don't have a deployed contract in StarkNet yet, or users that own a lot of liquidity in some specific token may be more present in L1. The `StakingRewards` contract aims to solve this problem by allowing not only the regular way of staking tokens in the same domain, but also introduces the ability through the `StakingBridge` to directly stake tokens from L1, even if those don't have an L2 version yet, and claim rewards with much lower gas fees due to StarkNet's scalability potential.

This way, StakingRewards has two entrypoints:

- `stakeL1` L1 handler that receives a message from the StakingBridge which keeps tokens in L1
- `stakeL2` Standard stake function which transfers tokens from the caller's address

However, note that L1 users and L2 users flows are separated through the `stakeL1`, `stakeL2`, `withdrawL1` and `withdrawL2` functions in order to ensure full compatibility, although the system does not enforce or gives any benefit to different types of users.

### Claiming rewards

Both claim reward functions, `claimRewardL1` and `claimRewardL2`, can be used by both L1 and L2 users. Differently from stake and withdraw functions, rewards claiming function have been slightly redesign from Syntehtix's model in away that both users supported by the application design can claim the rewards directly to the preferred domain using any arbitrary recipient. This solves the potential issue of a user having different wallet addresses in L1 and L2 using different formats.
