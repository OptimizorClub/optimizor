// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract Submissions {

    error CodeAlreadySubmitted();
    error TooEarlyToChallenge();

    struct Submission {
        address sender;
        uint96 blockNumber;
    }

    mapping (bytes32 => Submission) public submissions;

    function commit(bytes32 codehash) external {
        if (submissions[codehash].sender != address(0)) {
            revert CodeAlreadySubmitted();
        }
        submissions[codehash] = Submission({ sender: msg.sender, blockNumber: uint96(block.number) });
    }

    function boundaryBlock() internal view returns (uint) {
        return block.number - 1;
    }

    modifier mayChallenge(bytes32 codehash) {
        if (submissions[codehash].blockNumber > (block.number - 256)) {
            revert TooEarlyToChallenge();
        }
        _;
    }
}
