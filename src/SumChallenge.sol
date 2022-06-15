// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./Challenge.sol";

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
}
