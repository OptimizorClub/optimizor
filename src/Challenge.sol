// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IChallenge {
    function run(address target, uint seed) external view returns (uint);
    function svg(uint tokenId) external view returns (bytes memory);
    function name() external view returns (string memory);
    function description() external view returns (string memory);
}
