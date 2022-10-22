pragma solidity ^0.8.15;

import {OptimizorAdmin, OptimizorNFT} from "./OptimizorAdmin.sol";
import {IPurityChecker} from "./IPurityChecker.sol";
import {packTokenId} from "./DataHelpers.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";

uint constant EPOCH = 256;

contract Optimizor is OptimizorAdmin {
    struct Submission {
        address sender;
        uint96 blockNumber;
    }

    mapping (bytes32 => Submission) public submissions;

    // Commit errors
    error CodeAlreadySubmitted();
    error TooEarlyToChallenge();

    // Challenge id errors
    error ChallengeNotFound(uint challengeId);

    // Input filtering
    error InvalidRecipient();
    error CodeNotSubmitted();
    error NotPure();

    // Sadness
    error NotOptimizor();

    constructor(IPurityChecker pureh) OptimizorAdmin(pureh) {
    }

    /// Commit a `key` derived using
    /// `keccak256(abi.encode(sender, codehash, salt))`
    /// where
    /// - `sender`: the `msg.sender` for the call to `challenge(...)`,
    /// - `target`: the address of your solution contract,
    /// - `salt`: `uint256` secret number.
    function commit(bytes32 key) external {
        if (submissions[key].sender != address(0)) {
            revert CodeAlreadySubmitted();
        }
        submissions[key] = Submission({ sender: msg.sender, blockNumber: uint96(block.number) });
    }

    /// After committing and waiting for at least 256 blocks, challenge can be
    /// called to claim an Optimizor Club NFT, if it beats the previous solution
    /// in terms of runtime gas.
    ///
    /// @param id The unique identifier for the challenge.
    /// @param target The address of your solution contract.
    /// @param recipient The address that receives the Optimizor Club NFT.
    /// @param salt The secret number used for deriving the committed key.
    function challenge(
        uint256 id,
        address target,
        address recipient,
        uint salt
    ) external {
        Data storage chl = challenges[id];

        bytes32 key = keccak256(abi.encode(msg.sender, target.codehash, salt));

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

        uint leaderTokenId = packTokenId(id, chl.level);
        uint leaderGas = extraDetails[leaderTokenId].gas;

        if ((leaderGas != 0) && (leaderGas <= gas)) {
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
