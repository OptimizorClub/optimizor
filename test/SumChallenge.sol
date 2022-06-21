// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

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

	function svg(uint tokenId) external view returns (bytes memory art) {
		art = "<rect width='300' height='100' style='fill:rgb(0,0,255);stroke-width:3;stroke:rgb(0,0,0)' />";
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
