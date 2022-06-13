// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./Challenge.sol";

interface ISum {
	error WrongSum(uint, uint, uint);

	function sum(uint, uint) external returns (uint);
}

contract SumChallenge is IChallenge {
	function run(address opzor, uint salt) external override returns (bool, uint) {
		// Generate input.
		(uint x, uint y) = (random(salt), random(++salt));

		uint preGas = gasleft();
		uint s = ISum(opzor).sum(x, y);
		uint postGas = gasleft();

		verify(x, y, s);

		unchecked { return (true, preGas - postGas); }
	}

	function verify(uint x, uint y, uint s) internal pure {
		unchecked {
			if (s != (x + y))
				revert ISum.WrongSum(x, y, s);
		}
	}

	function random(uint salt) internal view returns (uint) {
		return uint(keccak256(abi.encodePacked(block.timestamp, salt))) % 100;
	}
}
