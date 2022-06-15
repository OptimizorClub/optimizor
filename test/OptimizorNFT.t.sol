// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/OptimizorNFT.sol";
import "../src/SumChallenge.sol";

uint constant SUM_ID = 0;
uint constant NON_USED_ID = type(uint).max;

contract OptimizorTest is Test {
	Optimizor opt;
	IChallenge sum = new SumChallenge();

    function setUp() public {
		opt = new Optimizor();
	}

	function testAddSumChallenge() public {
		addSumChallenge();
	}

	function addSumChallenge() internal {
		opt.addChallenge(SUM_ID, sum);
	}

	function testDupAddSumChallenge() public {
		addSumChallenge();

		vm.expectRevert(abi.encodeWithSignature("ChallengeExists(uint256)", uint(0)));
		addSumChallenge();
	}

	function testAddChallengeNonAdmin() public {
		// TODO
	}

	function testAddExistingChallengeNonAdmin() public {
		// TODO
	}

	function testNonExistentChallenge() public {
		vm.roll(block.number + 512);
		vm.expectRevert(abi.encodeWithSignature("ChallengeNotFound(uint256)", type(uint).max));
		opt.challenge(NON_USED_ID, bytes32(0), address(0), address(0));
    }

	function testCheapSum() public {
		addSumChallenge();
		runCheapSum();
	}

	function runCheapSum() internal {
		CheapSum ch = new CheapSum();
		opt.commit(address(ch).codehash);

		vm.roll(block.number + 512);

		opt.challenge(SUM_ID, address(ch).codehash, address(ch), address(this));
		(,, address o,) = opt.challenges(SUM_ID);
		assertEq(o, address(this));
    }

	/*
	function testExpensiveSum() public {
		addSumChallenge();
		runExpensiveSum();
	}

	function runExpensiveSum() internal {
		ExpensiveSum exp = new ExpensiveSum();
		opt.challenge(SUM_ID, address(exp));
		(,, address o) = opt.challenges(SUM_ID);
		assertEq(o, address(exp));
    }

    function testCheapExpensiveSum() public {
		addSumChallenge();
		runExpensiveSum();
		runCheapSum();
    }
	*/
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
