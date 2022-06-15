// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract Time {
	error NotInCommitPeriod();
	error NotInChallengePeriod();
	error CodeAlreadySubmitted();

	uint256 immutable public startBlock;
	mapping (bytes32 => address) public codehashes;

	enum Period { COMMIT, WAIT, CHALLENGE }

	constructor() {
		startBlock = block.number;
	}

	function commit(bytes32 codehash) inCommitPeriod external {
		if (codehashes[codehash] != address(0)) {
			revert CodeAlreadySubmitted();
		}
		codehashes[codehash] = msg.sender;
	}

	// 3 periods:
	// [0, 256) commit
	// [256, 512) wait
	// [512, 768) challenge
	function period() public view returns (Period) {
		unchecked {
			return Period(((block.number - startBlock) % 768) / 256);
		}
	}

	modifier inCommitPeriod {
		if (period() != Period.COMMIT) {
			revert NotInCommitPeriod();
		}
		_;
	}

	modifier inChallengePeriod {
		if (period() != Period.CHALLENGE) {
			revert NotInChallengePeriod();
		}
		_;
	}
}
