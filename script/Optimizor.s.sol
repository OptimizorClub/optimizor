// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";

import "src/Optimizor.sol";
import "src/PurityChecker.sol";
import "src/challenges/SqrtChallenge.sol";

contract OptimizorDeploy is Script {
    function run() external {
        vm.startBroadcast();

        PurityChecker purity = new PurityChecker();
        Optimizor opt = new Optimizor(purity);
        SqrtChallenge sqrtChl = new SqrtChallenge();
        opt.addChallenge(4, sqrtChl);

        vm.stopBroadcast();
    }
}
