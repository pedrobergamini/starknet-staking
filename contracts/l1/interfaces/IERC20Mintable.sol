// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20Mintable is IERC20 {
    /// @notice Mints given amount of tokens to an address
    /// @param to address receiving the tokens
    /// @param amount number of tokens to mint
    function mint(address to, uint256 amount) external;
}
