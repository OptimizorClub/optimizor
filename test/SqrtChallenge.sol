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

    function description() external override view returns (string memory) {
        return "Spiral of Theodorus.";
    }

    function svg(uint tokenId) external view returns (bytes memory art) {
        uint32 level = uint32(tokenId);
        if (level == 0)
            return '<rect width="230" height="230" rx="18px" ry="18px" fill="rgba(0,0,0,0.1)" />';
        if (level == 1)
            return '<rect width="230" height="230" rx="18px" ry="18px" fill="rgba(0,0,0,0.1)" /><polygon points="115,115 144,115 144,144" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon>';
        if (level == 2)
            return '<rect width="230" height="230" rx="18px" ry="18px" fill="rgba(0,0,0,0.1)" /><polygon points="115,115 144,115 144,144" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 144,144 123,164" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon>';
        if (level == 3)
            return '<rect width="230" height="230" rx="18px" ry="18px" fill="rgba(0,0,0,0.1)" /><polygon points="115,115 144,115 144,144" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 144,144 123,164" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 123,164 95,169" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon>';
        if (level == 4)
            return '<rect width="230" height="230" rx="18px" ry="18px" fill="rgba(0,0,0,0.1)" /><polygon points="115,115 144,115 144,144" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 144,144 123,164" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 123,164 95,169" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 95,169 68,159" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon>';
        if (level == 5)
            return '<rect width="230" height="230" rx="18px" ry="18px" fill="rgba(0,0,0,0.1)" /><polygon points="115,115 144,115 144,144" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 144,144 123,164" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 123,164 95,169" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 95,169 68,159" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 68,159 48,138" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon>';
        if (level == 6)
            return '<rect width="230" height="230" rx="18px" ry="18px" fill="rgba(0,0,0,0.1)" /><polygon points="115,115 144,115 144,144" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 144,144 123,164" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 123,164 95,169" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 95,169 68,159" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 68,159 48,138" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 48,138 39,111" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon>';
        if (level == 7)
            return '<rect width="230" height="230" rx="18px" ry="18px" fill="rgba(0,0,0,0.1)" /><polygon points="115,115 144,115 144,144" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 144,144 123,164" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 123,164 95,169" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 95,169 68,159" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 68,159 48,138" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 48,138 39,111" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 39,111 41,82" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon>';
        if (level == 8)
            return '<rect width="230" height="230" rx="18px" ry="18px" fill="rgba(0,0,0,0.1)" /><polygon points="115,115 144,115 144,144" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 144,144 123,164" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 123,164 95,169" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 95,169 68,159" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 68,159 48,138" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 48,138 39,111" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 39,111 41,82" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 41,82 52,56" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon>';
        if (level == 9)
            return '<rect width="230" height="230" rx="18px" ry="18px" fill="rgba(0,0,0,0.1)" /><polygon points="115,115 144,115 144,144" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 144,144 123,164" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 123,164 95,169" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 95,169 68,159" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 68,159 48,138" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 48,138 39,111" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 39,111 41,82" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 41,82 52,56" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 52,56 72,35" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon>';
        if (level == 10)
            return '<rect width="230" height="230" rx="18px" ry="18px" fill="rgba(0,0,0,0.1)" /><polygon points="115,115 144,115 144,144" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 144,144 123,164" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 123,164 95,169" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 95,169 68,159" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 68,159 48,138" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 48,138 39,111" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 39,111 41,82" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 41,82 52,56" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 52,56 72,35" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 72,35 97,21" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon>';
        if (level == 11)
            return '<rect width="230" height="230" rx="18px" ry="18px" fill="rgba(0,0,0,0.1)" /><polygon points="115,115 144,115 144,144" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 144,144 123,164" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 123,164 95,169" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 95,169 68,159" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 68,159 48,138" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 48,138 39,111" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 39,111 41,82" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 41,82 52,56" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 52,56 72,35" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 72,35 97,21" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 97,21 126,16" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon>';
        if (level == 12)
            return '<rect width="230" height="230" rx="18px" ry="18px" fill="rgba(0,0,0,0.1)" /><polygon points="115,115 144,115 144,144" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 144,144 123,164" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 123,164 95,169" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 95,169 68,159" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 68,159 48,138" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 48,138 39,111" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 39,111 41,82" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 41,82 52,56" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 52,56 72,35" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 72,35 97,21" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 97,21 126,16" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 126,16 154,19" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon>';
        else
            return '<rect width="230" height="230" rx="18px" ry="18px" fill="rgba(0,0,0,0.1)" /><polygon points="115,115 144,115 144,144" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 144,144 123,164" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 123,164 95,169" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 95,169 68,159" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 68,159 48,138" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 48,138 39,111" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 39,111 41,82" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 41,82 52,56" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 52,56 72,35" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 72,35 97,21" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 97,21 126,16" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 126,16 154,19" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon><polygon points="115,115 154,19 181,30" fill="none" stroke="white"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 115 115" to="360 115 115" dur="10s" repeatCount="indefinite"/></polygon>';
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
