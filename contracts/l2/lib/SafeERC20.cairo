# SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE
from contracts.l2.openzeppelin.token.erc20.IERC20 import IERC20

namespace SafeERC20:
    func safe_transfer_from{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        token : felt, sender : felt, recipient : felt, amount : Uint256
    ):
        with_attr error_message("ERC20 transfer failed"):
            let (success) = IERC20.transferFrom(contract_address=token, sender, recipient, amount)
            assert success = TRUE
        end
    end
end
