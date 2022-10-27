// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.15;

library HexString {
    /// Provided length is insufficient to store the value.
    error HexLengthInsufficient();

    bytes16 private constant ALPHABET = "0123456789abcdef";

    function toHexStringNoPrefix(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length);
        unchecked {
            for (uint256 i = buffer.length; i > 0; --i) {
                buffer[i - 1] = ALPHABET[value & 0xf];
                value >>= 4;
            }
        }
        if (value != 0) revert HexLengthInsufficient();
        return string(buffer);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        unchecked {
            for (uint256 i = 2 * length + 1; i > 1; --i) {
                buffer[i] = ALPHABET[value & 0xf];
                value >>= 4;
            }
        }
        if (value != 0) revert HexLengthInsufficient();
        return string(buffer);
    }
}
