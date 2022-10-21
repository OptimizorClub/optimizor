pragma solidity ^0.8.15;

import "./OptimizorNFT.sol";

contract Optimizor is OptimizorNFT {
    constructor(IPurityChecker pureh) OptimizorNFT(pureh) {
    }

    function commit(bytes32 key) external {
        if (submissions[key].sender != address(0)) {
            revert CodeAlreadySubmitted();
        }
        submissions[key] = Submission({ sender: msg.sender, blockNumber: uint96(block.number) });
    }

    function challenge(
        uint256 id,
        address target,
        address recipient,
        uint salt
    ) external {
        Data storage chl = challenges[id];

        bytes32 codehash = target.codehash;
        bytes32 key = keccak256(abi.encode(msg.sender, codehash, salt));

        // Frontrunning cannot steal the submission, but can block
        // it for users at the expense of the frontrunner's gas.
        // We consider that a non-issue.
        if (submissions[key].blockNumber + EPOCH >= block.number) {
            revert TooEarlyToChallenge();
        }

        if (submissions[key].sender == address(0)) {
            revert CodeNotSubmitted();
        }


        if (address(chl.target) == address(0)) {
            revert ChallengeNotFound(id);
        }

        if (recipient == address(0)) {
            revert InvalidRecipient();
        }

        if (!purity.check(target)) {
           revert NotPure();
        }

        uint32 gas = uint32(chl.target.run(target, block.difficulty));

        uint winnerTokenId = packTokenId(id, chl.level);
        ExtraDetails storage prevDetails = extraDetails[winnerTokenId];

        if (prevDetails.gas != 0 && (prevDetails.gas <= gas)) {
            revert NotOptimizor();
        }

        unchecked {
            ++chl.level;
        }

        uint tokenId = packTokenId(id, chl.level);
        ERC721._mint(recipient, tokenId);
        extraDetails[tokenId] = ExtraDetails(target, recipient, gas);
    }
}
