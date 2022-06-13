// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Challenge.sol";

import {Fixed18} from "./Fixed18.sol";

uint constant INPUT_SIZE = 100;
//uint constant INPUT_SIZE = 1;

// Expecting around 5 decimal place of precision
Fixed18 constant EPSILON = Fixed18.wrap(0.00001 * 10**18);

interface ISqrt {
	function sqrt(Fixed18[INPUT_SIZE] calldata) external view returns (Fixed18[INPUT_SIZE] memory);
}

function random_fixed18(uint256 seed) view returns (Fixed18) {
    return Fixed18.wrap(random_uint256(seed));
}

function random_uint256(uint256 seed) view returns (uint256) {
    return uint256(keccak256(abi.encodePacked(tx.origin, block.timestamp, seed)));
}

contract SqrtChallenge is Challenge {

    error DoesNotSatisfyTolerance();

	function run(address target, uint seed) external view override returns (bool, uint) {
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

        // TODO should we skip the boolean?
		return (true, usedGas);
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
        //       | input * input - output |
        //       --------------------------  < EPSILON
        //       |        input           |
        if(
           !input
           .mul(input)
           .distance(output)
           .div(input)
           .lt(EPSILON)
        )
            revert DoesNotSatisfyTolerance();

    }


}
