# SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IRewardsDistribution:
    func authority() -> (authority : felt):
    end

    func distributions(index : felt) -> (destination : felt, amount : Uint256):
    end

    func distributionsLength() -> (length : felt):
    end

    func distributeRewards(amount : Uint256) -> (success : felt):
    end
end
