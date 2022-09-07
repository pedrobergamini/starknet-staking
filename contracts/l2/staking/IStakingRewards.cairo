# SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IStakingRewards:
    #
    # View functions
    #
    func balanceOf(account : felt) -> (balance : Uint256):
    end

    func earned(account : felt) -> (reward : Uint256):
    end

    func getRewardForDuration() -> (reward : Uint256):
    end

    func lastTimeRewardApplicable() -> (timestamp : felt):
    end

    func rewardPerToken() -> (reward_per_token : Uint256):
    end

    func rewardsDistribution() -> (contract_address : felt):
    end

    func stakingToken() -> (token : felt):
    end

    func rewardToken() -> (token : felt):
    end

    func totalSupply() -> (total_supply : Uint256):
    end

    #
    # External functions
    #
    func setRewardsDuration(duration : felt):
    end

    func setRewardsDistribution(rewards_distribution : felt):
    end

    func recoverERC20(token : felt, amount : Uint256):
    end

    func notifyRewardAmount(reward : Uint256):
    end

    func stake(amount : Uint256) -> (success : felt):
    end

    func withdraw(amount : Uint256) -> (success : felt):
    end

    func claimReward() -> (success : felt):
    end

    func exit() -> (success : felt):
    end
end
