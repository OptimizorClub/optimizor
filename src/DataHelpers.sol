// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

function packTokenId(uint challengeId, uint32 level) pure returns (uint) {
    return (challengeId << 32) | level;
}

function unpackTokenId(uint256 tokenId) pure returns (uint256 challengeId, uint32 level) {
    challengeId = tokenId >> 32;
    level = uint32(tokenId);
}
