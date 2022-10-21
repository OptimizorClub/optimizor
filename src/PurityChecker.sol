// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./IPurityChecker.sol";

import "puretea/Puretea.sol";

contract PurityChecker is IPurityChecker {
    uint256 constant acceptedOpcodesMask = 0x600800000000000000000000ffffffffffffffff0fdf01ff67ff00013fff0fff;

    function check(address account) external view returns (bool) {
        return Puretea.check(account.code, acceptedOpcodesMask);
    }
}
