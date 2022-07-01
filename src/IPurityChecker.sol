// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IPurityChecker {
    function check(address account) external view returns (bool);
}
