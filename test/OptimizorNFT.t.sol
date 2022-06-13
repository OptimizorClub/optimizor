// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.13;

import "./ChallengeIDs.sol";

import "../src/OptimizorNFT.sol";
import "../src/SumChallenge.sol";
import "../src/SqrtChallenge.sol";

import "forge-std/Test.sol";

contract OptimizorTest is Test {
	Optimizor opt;
	Challenge sum = new SumChallenge();
	Challenge sqrt = new SqrtChallenge();

    function setUp() public {
		opt = new Optimizor();
	}

	function testAddSumChallenge() public {
		addSumChallenge();
	}

	function addSumChallenge() internal {
		opt.addChallenge(SUM_ID, sum);
	}

	function addSqrtChallenge() internal {
		opt.addChallenge(SQRT_ID, sqrt);
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
		vm.expectRevert(abi.encodeWithSignature("NoChallenge(uint256)", type(uint).max));
		opt.optimize(NON_USED_ID, address(0));
    }

	function testCheapSqrt() public {
		addSqrtChallenge();
		runCheapSqrt();
	}

	function runCheapSqrt() internal {
		CheapSqrt ch = new CheapSqrt();
		opt.optimize(SQRT_ID, address(ch));
		(,, address o) = opt.challenges(SQRT_ID);
		assertEq(o, address(ch));
    }

	function testCheapSum() public {
		addSumChallenge();
		runCheapSum();
	}

	function runCheapSum() internal {
		CheapSum ch = new CheapSum();
		opt.optimize(SUM_ID, address(ch));
		(,, address o) = opt.challenges(SUM_ID);
		assertEq(o, address(ch));
    }

	function testExpensiveSum() public {
		addSumChallenge();
		runExpensiveSum();
	}

	function runExpensiveSum() internal {
		ExpensiveSum exp = new ExpensiveSum();
		opt.optimize(SUM_ID, address(exp));
		(,, address o) = opt.challenges(SUM_ID);
		assertEq(o, address(exp));
    }

    function testCheapExpensiveSum() public {
		addSumChallenge();
		runExpensiveSum();
		runCheapSum();
    }
}

contract CheapSqrt is ISqrt {
	function sqrt(uint64[INPUT_SIZE] calldata inputs) external pure returns (uint64[INPUT_SIZE] memory outputs) {
		for (uint i = 0; i < inputs.length; ++i)
			outputs[i] = sqrt_one(inputs[i]);
	}

	function sqrt_one(uint64 input) internal pure returns (uint64 output) {
		uint l = 0;
		uint r = input - 1;
		while (l < r) {
			uint m = (l + r) / 2;
			if ((m * m) <= input && ((m + 1) * (m + 1)) > input)
				return uint64(m);
			if (m * m < input)
				l = m;
			else
				r = m;
		}
		revert("wrong algorithm");
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
