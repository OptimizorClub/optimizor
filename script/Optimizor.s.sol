// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "forge-std/Script.sol";
import "../src/OptimizorNFT.sol";
import "../test/SumChallenge.sol";

contract OptimizorScript is Script {
	function run() external {
		vm.startBroadcast();

		Optimizor opt = new Optimizor();
		SumChallenge sumChl = new SumChallenge();
		ExpensiveSum expSum = new ExpensiveSum();
		CheapSum cheapSum = new CheapSum();

		vm.stopBroadcast();
	}
}
