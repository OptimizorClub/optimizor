// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IChallenge {
	function run(address target, uint seed) external returns (bool, uint);
}
