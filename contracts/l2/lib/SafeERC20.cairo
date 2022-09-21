// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE
from contracts.l2.lib.interfaces.IERC20 import IERC20

namespace SafeERC20 {
    func safe_transfer_from{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        token: felt, sender: felt, recipient: felt, amount: Uint256
    ) {
        with_attr error_message("SafeERC20: ERC20 transferFrom failed") {
            let (success) = IERC20.transferFrom(
                contract_address=token, sender=sender, recipient=recipient, amount=amount
            );
            assert success = TRUE;
        }

        return ();
    }

    func safe_transfer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        token: felt, recipient: felt, amount: Uint256
    ) {
        with_attr error_message("SafeERC20: ERC20 transfer failed") {
            let (success) = IERC20.transfer(
                contract_address=token, recipient=recipient, amount=amount
            );
            assert success = TRUE;
        }

        return ();
    }
}
