// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

function packTokenId(uint challengeId, uint32 level) pure returns (uint) {
    return (challengeId << 32) | level;
}

function unpackTokenId(uint256 tokenId) pure returns (uint256 challengeId, uint32 level) {
    challengeId = tokenId >> 32;
    level = uint32(tokenId);
}

function packExtraDetail(address recipient, uint32 gasUsed) pure returns (uint) {
    return (uint(uint160(recipient)) << 32) | gasUsed;
}

function unpackExtraDetail(uint256 detail) pure returns (address recipient, uint32 gasUsed) {
    recipient = address(uint160(detail >> 32));
    gasUsed = uint32(detail);
}
