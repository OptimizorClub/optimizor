// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.14;

import "./ChallengeIDs.sol";
import "./SumChallenge.sol";

import "../src/OptimizorNFT.sol";

import "forge-std/Test.sol";

contract BaseTest is Test {
	Optimizor opt;
	IChallenge sum;

	ISum cheapSum;
	ISum expSum;

    function setUp() public {
		opt = new Optimizor();
		sum = new SumChallenge();

		cheapSum = new CheapSum();
		expSum = new ExpensiveSum();
	}

	function addSumChallenge() internal {
		opt.addChallenge(SUM_ID, sum);
	}

	function advancePeriod() internal {
		vm.roll(block.number + 256);
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
