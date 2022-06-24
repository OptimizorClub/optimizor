// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../src/Challenge.sol";

import {Fixed18} from "./Fixed18.sol";

//uint constant INPUT_SIZE = 100;
uint constant INPUT_SIZE = 3;

// Expecting around 5 decimal place of precision
Fixed18 constant EPSILON = Fixed18.wrap(0.0001 * 10**18);

interface ISqrt {
    function sqrt(Fixed18[INPUT_SIZE] calldata) external view returns (Fixed18[INPUT_SIZE] memory);
}

function random_fixed18(uint256 seed) view returns (Fixed18) {
    return Fixed18.wrap(uint256(random_uint64(seed)));
}

function random_uint64(uint256 seed) view returns (uint64) {
    return uint64(uint256(keccak256(abi.encodePacked(tx.origin, block.timestamp, seed))));
}

contract SqrtChallenge is IChallenge {

    error DoesNotSatisfyTolerance(uint input, uint output);

    function run(address target, uint seed) external view override returns (uint) {
        // Generate inputs.
        Fixed18[INPUT_SIZE] memory inputs;
        unchecked {
            for (uint i = 0; i < INPUT_SIZE; ++i) {
                inputs[i] = random_fixed18(seed);
                // TODO should the inputs be uniform?
                // TODO Maybe use a Linear Congruential Generator?
                seed = Fixed18.unwrap(inputs[i]);
            }
        }

        uint preGas = gasleft();
        Fixed18[INPUT_SIZE] memory outputs = ISqrt(target).sqrt(inputs);
        uint usedGas;
        unchecked { usedGas = preGas - gasleft(); }

        verify(inputs, outputs);

        return usedGas;
    }

    // Reverts if invalid
    function verify(Fixed18[INPUT_SIZE] memory inputs, Fixed18[INPUT_SIZE] memory outputs) internal pure {
        unchecked {
            for (uint i = 0; i < INPUT_SIZE; ++i) {
                verify(inputs[i], outputs[i]);
            }
        }
    }

    // Reverts if invalid
    function verify(Fixed18 input, Fixed18 output) internal pure {
        // Checks
        //       | output * output - input |
        //       --------------------------  < EPSILON
        //       |        output           |
        if(
            !output
            .mul(output)
            .distance(input)
            .div(output)
            .lt(EPSILON)
        ) {
            revert DoesNotSatisfyTolerance(Fixed18.unwrap(input), Fixed18.unwrap(output));
        }
    }

    function name() external override view returns (string memory) {
        return "SQRT";
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

/// Returns the midpoint avoiding phantom overflow
function mid(uint a, uint b) pure returns (uint) {
    unchecked {
        return (a & b) + (a ^ b) / 2;
    }
}

contract CheapSqrt is ISqrt {
    function sqrt(Fixed18[INPUT_SIZE] calldata inputs) external pure returns (Fixed18[INPUT_SIZE] memory outputs) {
        for (uint i = 0; i < inputs.length; ++i) {
            outputs[i] = sqrt_one(inputs[i]);
        }
    }

    function sqrt_one(Fixed18 input) internal pure returns (Fixed18 output) {
        uint l = 0;
        uint uInput = Fixed18.unwrap(input);
        uint r = uInput - 1;
        while (l < r) {
            uint m = mid(l, r);
            uint mPlus1 = m + 1;
            if ((m * m <= uInput) && (mPlus1 * mPlus1 > uInput))
                return Fixed18.wrap(m * 10**9);
            if (m * m < uInput)
                l = m;
            else
                r = m;
        }
        revert("wrong algorithm");
    }
}

contract ExpensiveSqrt is ISqrt {
    function sqrt(Fixed18[INPUT_SIZE] calldata inputs) external pure returns (Fixed18[INPUT_SIZE] memory outputs) {
        for (uint i = 0; i < inputs.length; ++i) {
            outputs[i] = sqrt_one(inputs[i]);
            outputs[i] = sqrt_one(inputs[i]);
            outputs[i] = sqrt_one(inputs[i]);
        }
    }

    function sqrt_one(Fixed18 input) internal pure returns (Fixed18 output) {
        uint l = 0;
        uint uInput = Fixed18.unwrap(input);
        uint r = uInput - 1;
        while (l < r) {
            uint m = mid(l, r);
            uint mPlus1 = m + 1;
            if ((m * m <= uInput) && (mPlus1 * mPlus1 > uInput))
                return Fixed18.wrap(m * 10**9);
            if (m * m < uInput)
                l = m;
            else
                r = m;
        }
        revert("wrong algorithm");
    }
}
