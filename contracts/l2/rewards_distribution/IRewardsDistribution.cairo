# SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IRewardsDistribution:
    #
    # View functions
    #

    func authority() -> (authority : felt):
    end

    func distributions(index : felt) -> (destination : felt, amount : Uint256):
    end

    func distributionsLength() -> (length : felt):
    end

    #
    # External functions
    #
    func distributeRewards(amount : Uint256) -> (success : felt):
    end
end
