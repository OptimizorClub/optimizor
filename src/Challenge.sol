// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IChallenge {
	function run(address target, uint seed) external view returns (uint);
	function svg(uint tokenId) external view returns (bytes memory);
}
