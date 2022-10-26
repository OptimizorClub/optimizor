// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "forge-std/Script.sol";
import "../src/Optimizor.sol";
import "../src/PurityChecker.sol";
import "../test/CommitHash.sol";
import "../test/SqrtChallengeSolutions.sol";

//address constant ME = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
address constant ME = 0x7D38256bAb82F2C8651d9968320b3Eaffd08a405;
uint constant SALT = 0;

contract OptimizorScript is Script {
    function run() external {
        vm.startBroadcast();

        PurityChecker purity = new PurityChecker();
        Optimizor opt = new Optimizor(purity);
        SqrtChallenge sqrtChl = new SqrtChallenge();
        ExpensiveSqrt expSqrt = new ExpensiveSqrt();
        CheapSqrt cheapSqrt = new CheapSqrt();

        opt.addChallenge(4, sqrtChl);

        opt.commit(computeKey(address(this), address(expSqrt).codehash, SALT));
        opt.commit(computeKey(address(this), address(cheapSqrt).codehash, SALT));

        opt.challenge(4, address(expSqrt), ME, SALT);
        opt.challenge(4, address(cheapSqrt), ME, SALT);

        vm.stopBroadcast();
    }
}
