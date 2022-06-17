// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "../src/Challenge.sol";

uint8 constant SIZE = 4;

interface ISudoku {
	error WrongSolution();

	function solve(uint8[SIZE][SIZE] calldata board) external view returns (uint);
}

contract SudokuChallenge is IChallenge {
	function run(address opzor, uint seed) external view override returns (uint) {
		// Generate input.
		uint8[SIZE][SIZE] memory input;
		uint pMask = random(seed++);
		for (uint8 i = 0; i < SIZE; ++i)
			for (uint8 j = 0; j < SIZE; ++j) {
				uint b = uint(i) * SIZE + j;
				// 50% chance of blank or random number
				if (input & 1)
					input[i][j] = random(seed++) % SIZE + 1;
			}

		uint preGas = gasleft();
		uint s = ISudoku(opzor).solve(inputs);
		uint postGas = gasleft();

		verify(x, y, s);

		unchecked { return preGas - postGas; }
	}

	function verify(uint8[SIZE][SIZE] memory board) internal pure {
		for (uint8 i = 0; i < SIZE; ++i) {
			if (!verifyRow(board[0]) || !verifyCol(i, board))
				revert WrongSolution();
		}
	}

	function verifyCol(uint8 col, uint8[SIZE][SIZE] memory board) internal pure returns (bool) {
		uint16 v = 0;
		for (uint8 i = 0; i < SIZE; ++i) {
			v |= 1 << (board[i][col] - 1);
		}
		uint q = 2**SIZE - 1;
		return v == q;

	}

	function verifyRow(uint8[SIZE] memory row) internal pure returns (bool) {
		uint16 v = 0;
		for (uint8 i = 0; i < SIZE; ++i) {
			v |= 1 << (row[i] - 1);
		}
		uint q = 2**SIZE - 1;
		return v == q;
	}

	function random(uint seed) internal view returns (uint) {
		return uint(keccak256(abi.encodePacked(block.timestamp, seed))) % 100;
	}
}
