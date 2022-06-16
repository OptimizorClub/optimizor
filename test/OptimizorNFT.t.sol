// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.14;

import "./BaseTest.sol";
import "../src/OptimizorNFT.sol";
import "forge-std/Test.sol";

contract OptimizorTest is BaseTest {
	function testCheapSum() public {
		addSumChallenge();

		opt.commit(address(cheapSum).codehash);
		advancePeriod();
		advancePeriod();
		opt.challenge(SUM_ID, address(cheapSum).codehash, address(cheapSum), address(this));

		(,, address o,) = opt.challenges(SUM_ID);
		assertEq(o, address(this));
	}

	function testExpensiveSum() public {
		addSumChallenge();

		opt.commit(address(expSum).codehash);
		advancePeriod();
		advancePeriod();
		opt.challenge(SUM_ID, address(expSum).codehash, address(expSum), address(this));

		(,, address o,) = opt.challenges(SUM_ID);
		assertEq(o, address(this));
	}

    function testCheapExpensiveSum() public {
		addSumChallenge();

		opt.commit(address(cheapSum).codehash);
		opt.commit(address(expSum).codehash);

		advancePeriod();
		advancePeriod();

		opt.challenge(SUM_ID, address(expSum).codehash, address(expSum), address(this));
		(,, address o1,) = opt.challenges(SUM_ID);
		assertEq(o1, address(this));

		opt.challenge(SUM_ID, address(cheapSum).codehash, address(cheapSum), address(this));
		(,, address o2,) = opt.challenges(SUM_ID);
		assertEq(o2, address(this));
    }
}
