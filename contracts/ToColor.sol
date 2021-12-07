// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

library ToColor {
    bytes16 internal constant ALPHABET = "0123456789abcdef";

    function toColor(bytes3 value, bytes3 randomNumber)
        internal
        pure
        returns (string memory)
    {
        bytes memory buffer = new bytes(6);
        for (uint256 i = 0; i < 3; i++) {
            buffer[i * 2 + 1] = ALPHABET[
                uint8(value[i] ^ randomNumber[i]) & 0xf
            ];
            buffer[i * 2] = ALPHABET[
                uint8((value[i] ^ randomNumber[i]) >> 4) & 0xf
            ];
        }
        return string(buffer);
    }
}
