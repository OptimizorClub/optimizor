// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../src/Challenge.sol";

interface ISum {
    error WrongSum(uint, uint, uint);

    function sum(uint, uint) external view returns (uint);
}

contract SumChallenge is IChallenge {
    function run(address opzor, uint seed) external view override returns (uint) {
        // Generate input.
        (uint x, uint y) = (random(seed), random(++seed));

        uint preGas = gasleft();
        uint s = ISum(opzor).sum(x, y);
        uint postGas = gasleft();

        verify(x, y, s);

        unchecked { return preGas - postGas; }
    }

    function verify(uint x, uint y, uint s) internal pure {
        unchecked {
            if (s != (x + y))
                revert ISum.WrongSum(x, y, s);
        }
    }

    function random(uint seed) internal view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, seed))) % 100;
    }

    function name() external override view returns (string memory) {
        return "SUM";
    }

    bytes32 constant p0 = 'points="115,145 153,145 153,183"';
    bytes32 constant p1 = 'points="115,145 153,183 126,210"';
    bytes31 constant p2 = 'points="115,145 126,210 88,217"';
    bytes30 constant p3 = 'points="115,145 88,217 52,204"';
    bytes30 constant p4 = 'points="115,145 52,204 26,176"';
    bytes30 constant p5 = 'points="115,145 26,176 14,139"';
    bytes30 constant p6 = 'points="115,145 14,139 16,101"';
    bytes29 constant p7 = 'points="115,145 16,101 31,66"';
    bytes28 constant p8 = 'points="115,145 31,66 58,38"';
    bytes28 constant p9 = 'points="115,145 58,38 91,20"';
    bytes29 constant p10 = 'points="115,145 91,20 129,13"';
    bytes30 constant p11 = 'points="115,145 129,13 167,17"';
    bytes30 constant p12 = 'points="115,145 167,17 203,31"';
    function svg(uint tokenId) external view returns (bytes memory art) {
        uint32 level = uint32(tokenId);
        art = abi.encodePacked(
            '<rect width="230" height="230" rx="18px" ry="18px" fill="rgba(0,0,0,0.1)" />',
            '<polygon ', p0, ' fill="none" stroke="white"/>',
            level > 1 ? abi.encodePacked('<polygon ', p1, ' fill="none" stroke="white"/>') : bytes(""),
            level > 2 ? abi.encodePacked('<polygon ', p2, ' fill="none" stroke="white"/>') : bytes(""),
            level > 3 ? abi.encodePacked('<polygon ', p3, ' fill="none" stroke="white"/>') : bytes(""),
            level > 4 ? abi.encodePacked('<polygon ', p4, ' fill="none" stroke="white"/>') : bytes(""),
            level > 5 ? abi.encodePacked('<polygon ', p5, ' fill="none" stroke="white"/>') : bytes(""),
            level > 6 ? abi.encodePacked('<polygon ', p6, ' fill="none" stroke="white"/>') : bytes(""),
            level > 7 ? abi.encodePacked('<polygon ', p7, ' fill="none" stroke="white"/>') : bytes(""),
            level > 8 ? abi.encodePacked('<polygon ', p8, ' fill="none" stroke="white"/>') : bytes(""),
            level > 9 ? abi.encodePacked('<polygon ', p9, ' fill="none" stroke="white"/>') : bytes(""),
            level > 10 ? abi.encodePacked('<polygon ', p10, ' fill="none" stroke="white"/>') : bytes(""),
            level > 11 ? abi.encodePacked('<polygon ', p11, ' fill="none" stroke="white"/>') : bytes(""),
            level > 12 ? abi.encodePacked('<polygon ', p12, ' fill="none" stroke="white"/>') : bytes("")
        );
    }
}

contract CheapSum is ISum {
    function sum(uint x, uint y) external pure returns (uint) {
        return x + y;
    }
}

contract ExpensiveSum is ISum {
    function sum(uint x, uint y) external pure returns (uint) {
        for (uint i = 0; i < y; ++i)
            ++x;
        return x;
    }
}
