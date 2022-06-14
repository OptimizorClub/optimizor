// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.15;

import "./BaseTest.sol";
import "../src/OptimizorNFT.sol";

contract OptimizorTest is BaseTest {
    function run() external returns (string memory) {
        setUp();
        testCheapExpensiveSum();
        return opt.tokenURI(2);
    }

    function testCheapSum() public {
        addSumChallenge();

        opt.commit(address(cheapSum).codehash);
        advancePeriod();
        advancePeriod();

        (,,, uint32 preLevel) = opt.challenges(SUM_ID);
        opt.challenge(SUM_ID, address(cheapSum).codehash, address(cheapSum), address(this));
        (,, address postOpt, uint32 postLevel) = opt.challenges(SUM_ID);

        assertEq(postOpt, address(this));
        assertEq(postLevel, preLevel + 1);

        uint tokenId = (SUM_ID << 32) | postLevel;
        assertEq(opt.ownerOf(tokenId), address(this));

        address[] memory leaders = opt.leaderboard(tokenId);
        assertEq(leaders.length, 1);
        assertEq(leaders[0], address(this));
    }

    function testExpensiveSum() public {
        addSumChallenge();

        opt.commit(address(expSum).codehash);
        advancePeriod();
        advancePeriod();

        (,,, uint32 preLevel) = opt.challenges(SUM_ID);
        opt.challenge(SUM_ID, address(expSum).codehash, address(expSum), address(this));
        (,, address postOpt, uint32 postLevel) = opt.challenges(SUM_ID);

        assertEq(postOpt, address(this));
        assertEq(postLevel, preLevel + 1);

        uint tokenId = (SUM_ID << 32) | postLevel;
        assertEq(opt.ownerOf(tokenId), address(this));

        address[] memory leaders = opt.leaderboard(tokenId);
        assertEq(leaders.length, 1);
        assertEq(leaders[0], address(this));
    }

    function testCheapExpensiveSum() public {
        addSumChallenge();

        address other = address(42);
        vm.prank(other);
        opt.commit(address(expSum).codehash);
        vm.stopPrank();

        opt.commit(address(cheapSum).codehash);

        advancePeriod();
        advancePeriod();

        (,,, uint32 preLevel) = opt.challenges(SUM_ID);

        vm.prank(other);
        opt.challenge(SUM_ID, address(expSum).codehash, address(expSum), other);
        vm.stopPrank();

        (,, address postOpt, uint32 postLevel) = opt.challenges(SUM_ID);
        assertEq(postOpt, other);
        assertEq(postLevel, preLevel + 1);

        uint tokenId = (SUM_ID << 32) | postLevel;
        assertEq(opt.ownerOf(tokenId), other);

        address[] memory leaders = opt.leaderboard(tokenId);
        assertEq(leaders.length, 1);
        assertEq(leaders[0], other);

        opt.challenge(SUM_ID, address(cheapSum).codehash, address(cheapSum), address(this));
        (,, address postOpt2, uint32 postLevel2) = opt.challenges(SUM_ID);
        assertEq(postOpt2, address(this));
        assertEq(postLevel2, postLevel + 1);

        uint tokenId2 = (SUM_ID << 32) | postLevel2;
        assertEq(opt.ownerOf(tokenId2), address(this));

        vm.prank(other);
        vm.expectRevert(abi.encodeWithSignature("NotOptimizor()"));
        opt.challenge(SUM_ID, address(expSum).codehash, address(expSum), other);
        vm.stopPrank();

        address[] memory leaders2 = opt.leaderboard(tokenId2);
        assertEq(leaders2.length, 2);
        assertEq(leaders2[0], other);
        assertEq(leaders2[1], address(this));
    }
}

/// Returns the midpoint avoiding phantom overflow
function mid(uint a, uint b) pure returns (uint) {
    unchecked {
		return (a & b) + (a ^ b) / 2;
    }
}

contract CheapSqrt {
    function sqrt(uint[INPUT_SIZE] calldata inputs) external returns (uint[INPUT_SIZE] memory outputs) {
		for (uint i = 0; i < inputs.length; ++i)
			outputs[i] = sqrt_one(inputs[i]);
	}

    function sqrt_one(uint input) internal returns (uint output) {
		uint l = 0;
		uint r = input - 1;
		while (l < r) {
            uint m = mid(l, r);
			emit BSEARCH(l, r, m);
			uint mPlus1 = m + 1;
            if ((m * m <= input) && (mPlus1 * mPlus1 > input))
				return m * 10**9;
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
