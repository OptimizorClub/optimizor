// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

uint constant EPOCH = 256;

abstract contract Submissions {

    error CodeAlreadySubmitted();
    error TooEarlyToChallenge();

    struct Submission {
        address sender;
        uint96 blockNumber;
    }

    mapping (bytes32 => Submission) public submissions;

    function commit(bytes32 key) external {
        if (submissions[key].sender != address(0)) {
            revert CodeAlreadySubmitted();
        }
        submissions[key] = Submission({ sender: msg.sender, blockNumber: uint96(block.number) });
    }

    function boundaryBlock() internal view returns (uint) {
        return block.number - 1;
    }

    function checkChallengeTime(bytes32 key) internal view {
        if (submissions[key].blockNumber + EPOCH >= block.number) {
            revert TooEarlyToChallenge();
        }
    }
}
