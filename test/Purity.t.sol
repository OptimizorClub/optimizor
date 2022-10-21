// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.15;

import "./BaseTest.sol";

import "../src/PurityChecker.sol";
import "./SolidityMetadata.sol";

import "puretea/Puretea.sol";

contract PurityTest is BaseTest {
    uint256 constant acceptedOpcodesMask = 0x600800000000000000000000ffffffffffffffff0fdf01ff67ff00013fff0fff;

    function testCheapSqrtPurity() public {
        assertTrue(
            Puretea.check(
                address(cheapSqrt).code,
                acceptedOpcodesMask
            )
        );
    }
}
