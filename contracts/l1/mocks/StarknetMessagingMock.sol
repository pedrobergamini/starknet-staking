// SPDX-License-Identifier: Apache-2.0.
// Retrieved from https://github.com/immutable/imx-starknet/blob/179dbb16cfa78e4412f484e76e7c7e6882437652/immutablex/ethereum/starknet/mocks/StarknetMessagingMock.sol
pragma solidity 0.8.15;

import "../starknet/core/StarknetMessaging.sol";

contract StarknetMessagingMock is StarknetMessaging {
    /**
      Mocks a message from L2 to L1.
    */
    function mockSendMessageFromL2(
        uint256 from_address,
        uint256 to_address,
        uint256[] calldata payload
    ) external {
        bytes32 msgHash = keccak256(abi.encodePacked(from_address, to_address, payload.length, payload));
        l2ToL1Messages()[msgHash] += 1;
    }

    /**
      Mocks consumption of a message from L1 to L2.
    */
    function mockConsumeMessageToL2(
        uint256 from_address,
        uint256 to_address,
        uint256 selector,
        uint256[] calldata payload,
        uint256 nonce
    ) external {
        bytes32 msgHash = keccak256(
            abi.encodePacked(from_address, to_address, nonce, selector, payload.length, payload)
        );

        require(l1ToL2Messages()[msgHash] > 0, "INVALID_MESSAGE_TO_CONSUME");
        l1ToL2Messages()[msgHash] -= 1;
    }
}
