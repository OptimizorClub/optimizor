// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Challenge.sol";

error NoChallenge(uint);
error ChallengeExists(uint);
error NotCorrect();
error NotOptimizor(uint, uint, uint);

contract Optimizor {
	// TODO add events

	struct State {
		Challenge challenge;
		uint gasUsed;
		address optimizor;
	}

	// TODO challenge address to State/id map?

	// slot 0
	mapping (uint => State) public challenges;

	// slot 1
	address immutable admin;
	uint8 lock;
	uint128 salt;

	modifier onlyAdmin {
		require(msg.sender == admin);
		_;
	}

	modifier noReentrancy {
		require(lock == 1);
		lock = 2;
		_;
		lock = 1;
	}

	constructor() {
		admin = msg.sender;
		lock = 1;
	}

	function addChallenge(uint id, Challenge challenge) external onlyAdmin {
		State storage chl = challenges[id];
		if (address(chl.challenge) != address(0)) {
			revert ChallengeExists(id);
		}

		chl.challenge = challenge;
	}

	function optimize(uint id, address opzor) external noReentrancy {
		State storage chl = challenges[id];
		if (address(chl.challenge) == address(0)) {
			revert NoChallenge(id);
		}

		bool success;
		uint gas;
		unchecked {
			// It's fine if `salt` overflows because that's gonna take a while
			// and salt-based random number generation manipulation will be unlikely.
			// TODO should this call be `staticcall`?
			(success, gas) = chl.challenge.run(opzor, ++salt);
		}

		if (!success) {
			revert NotCorrect();
		}

		if (chl.gasUsed != 0 && (chl.gasUsed <= gas)) {
			revert NotOptimizor(id, chl.gasUsed, gas);
		}

		chl.gasUsed = gas;
		chl.optimizor = opzor;
	}
}
