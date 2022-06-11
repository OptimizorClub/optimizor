// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface Challenge {
	function run(address opzor, uint salt) external returns (bool, uint);
}
