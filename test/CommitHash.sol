// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

function computeKey(address sender, bytes32 codehash, uint salt) pure returns (bytes32) {
    return keccak256(abi.encode(sender, codehash, salt));
}