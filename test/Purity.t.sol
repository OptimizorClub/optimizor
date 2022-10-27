// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import {BaseTest} from "test/BaseTest.sol";

contract PurityTest is BaseTest {
    function testCheapSumPurity() public {
        assertTrue(purity.check(address(cheapSum)));
    }

    function testExpSumPurity() public {
        assertTrue(purity.check(address(expSum)));
    }

    function testCheapSqrtPurity() public {
        assertTrue(purity.check(address(cheapSqrt)));
    }

    function testExpSqrtPurity() public {
        assertTrue(purity.check(address(expSqrt)));
    }
}
