// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import {OptimizorNFT} from "src/OptimizorNFT.sol";
import {IPurityChecker} from "src/IPurityChecker.sol";
import {IAttribute} from "src/IAttribute.sol";
import {IChallenge} from "src/IChallenge.sol";

import {Owned} from "solmate/auth/Owned.sol";

contract OptimizorAdmin is OptimizorNFT, Owned {
    IPurityChecker public purityChecker;

    error ChallengeExists(uint256 challengeId);

    event PurityCheckerUpdated(IPurityChecker newPurityChecker);
    event ChallengeAdded(uint256 challengeId, IChallenge);

    constructor(IPurityChecker _purityChecker) Owned(msg.sender) {
        updatePurityChecker(_purityChecker);
    }

    /// @dev Purity checker may need to be updated when there are EVM changes.
    function updatePurityChecker(IPurityChecker _purityChecker) public onlyOwner {
        purityChecker = _purityChecker;

        emit PurityCheckerUpdated(_purityChecker);
    }

    function addAttribute(IAttribute attr) external onlyOwner {
        extraAttrs.push(attr);
    }

    function addChallenge(uint256 id, IChallenge chlAddr) external onlyOwner {
        ChallengeInfo storage chl = challenges[id];
        if (address(chl.target) != address(0)) {
            revert ChallengeExists(id);
        }

        chl.target = chlAddr;

        emit ChallengeAdded(id, chlAddr);
    }
}
