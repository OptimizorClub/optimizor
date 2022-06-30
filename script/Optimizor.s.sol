// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "forge-std/Script.sol";
import "../src/OptimizorNFT.sol";
import "../test/SqrtChallenge.sol";

//address constant ME = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
address constant ME = 0x7D38256bAb82F2C8651d9968320b3Eaffd08a405;

contract OptimizorScript is Script {
	function run() external {
		vm.startBroadcast();

		Optimizor opt = new Optimizor();
		SqrtChallenge sqrtChl = new SqrtChallenge();
		ExpensiveSqrt expSqrt = new ExpensiveSqrt();
		CheapSqrt cheapSqrt = new CheapSqrt();

        opt.addChallenge(4, sqrtChl);

        opt.commit(address(expSqrt).codehash);
        opt.commit(address(cheapSqrt).codehash);

        opt.challenge(4, address(expSqrt).codehash, address(expSqrt), ME);
        opt.challenge(4, address(cheapSqrt).codehash, address(cheapSqrt), ME);

		vm.stopBroadcast();
	}
}
