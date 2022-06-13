// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Challenge.sol";

uint constant INPUT_SIZE = 100;
//uint constant INPUT_SIZE = 1;

interface ISqrt {
	function sqrt(uint64[INPUT_SIZE] calldata) external view returns (uint64[INPUT_SIZE] memory);
}

contract SqrtChallenge is Challenge {
	function run(address target, uint seed) external view override returns (bool, uint) {
		// Generate inputs.
		uint64[INPUT_SIZE] memory inputs;
		unchecked {
			for (uint i = 0; i < INPUT_SIZE; ++i) {
				inputs[i] = random(seed);
				seed = inputs[i];
			}
		}

		uint preGas = gasleft();
		uint64[INPUT_SIZE] memory outputs = ISqrt(target).sqrt(inputs);
		uint usedGas;
		unchecked { usedGas = preGas - gasleft(); }

		return (verify(inputs, outputs), usedGas);
	}

	function verify(uint64[INPUT_SIZE] memory inputs, uint64[INPUT_SIZE] memory outputs) internal pure returns (bool) {
		unchecked {
			for (uint i = 0; i < INPUT_SIZE; ++i) {
				if (!verify_one(inputs[i], outputs[i]))
					return false;
			}
		}
		return true;
	}

	function verify_one(uint64 input, uint64 output) internal pure returns (bool) {
		uint output256 = uint(output);
		uint output256Plus1 = output256 + 1;

		unchecked {
			return
				(output256 * output256) <= input &&
				(output256Plus1 * output256Plus1) > input;
		}

	}

	function random(uint seed) internal view returns (uint64) {
		return uint64(uint256(keccak256(abi.encodePacked(tx.origin, block.timestamp, seed))));
	}
}
