// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {BaseTest} from "test/BaseTest.sol";
import {PurityChecker} from "src/PurityChecker.sol";

contract PurityCheckerManagementTest is BaseTest {
    // We need to redefine the event here because the compiler won't
    // let us reuse the one from OptimizorAdmin.
    event PurityCheckerUpdated(PurityChecker newPurityChecker);

    function testNewPurityChecker() public {
        PurityChecker newChecker = new PurityChecker();

        vm.expectEmit(true, false, false, false);
        emit PurityCheckerUpdated(newChecker);

        opt.updatePurityChecker(newChecker);

        assertEq(address(newChecker), address(opt.purityChecker()));
    }
}
