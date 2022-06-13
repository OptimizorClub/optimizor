// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract Time {
	/// Currently in the challenge period.
	error InChallengePeriod();

	/// Currently not in the challenge period.
	error NotInChallengePeriod();

	error CodeAlreadySubmitted();

	error CodeNotSubmitted();

	error BlockHashNotFound();

	/// The genesis block we start counting from.
	//uint256 constant public startBlock = 14946000;
	uint256 immutable public startBlock;

	mapping (bytes32 => address) public codehashes;

	constructor() {
		startBlock = block.number;
	}

	/// The challenge is split into two periods:
	/// - commit, when new code can be submitted (this is the odd period)
	/// - challenge, when committed code can be competed with (this is the even period)
	///
	/// Code can be committed at last 256 blocks preceding
	/// the challenge period, and the challenge period is active
	/// for 256 blocks. 
	///
	function period() view public returns (uint256) {
		unchecked {
			return (block.number - startBlock) / 256;
		}
	}

	modifier inCommitPeriod {
		if ((period() % 2) != 0) {
			revert InChallengePeriod();
		}
		_;
	}

	modifier inChallengePeriod {
		if ((period() % 2) != 1) {
			revert NotInChallengePeriod();
		}
		_;
	}

	function commit(bytes32 codehash) inCommitPeriod external {
		if (codehashes[codehash] != address(0)) {
			revert CodeAlreadySubmitted();
		}
		codehashes[codehash] = msg.sender;
	}
}
