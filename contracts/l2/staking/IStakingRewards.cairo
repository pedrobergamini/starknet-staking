# SPDX-License-Identifier: MIT

%lang starknet

@contract_interface
namespace IStakingRewards:
    #
    # View functions
    #
    func balanceOf(account : felt) -> (balance : felt):
    end

    func earned(account : felt) -> (reward : felt):
    end

    func getRewardForDuration() -> (reward : felt):
    end

    func lastTimeRewardApplicable() -> (timestamp : felt):
    end

    func rewardPerToken() -> (reward_per_token : felt):
    end

    func rewardsDistribution() -> (contract_address : felt):
    end

    func rewardToken() -> (token : felt):
    end

    func totalSupply() -> (total_supply : felt):
    end

    #
    # External functions
    #

    func exit() -> (success : felt):
    end

    func claimReward() -> (success : felt):
    end

    func stake(amount : felt) -> (success : felt):
    end

    func withdraw(amount : felt) -> (success : felt):
    end
end
