// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IChallenge} from "../src/IChallenge.sol";

interface ISum {
    error WrongSum(uint256, uint256, uint256);

    function sum(uint256, uint256) external view returns (uint256);
}

contract SumChallenge is IChallenge {
    function run(address opzor, uint256 seed) external view override returns (uint256) {
        // Generate input.
        (uint256 x, uint256 y) = (random(seed), random(++seed));

        uint256 preGas = gasleft();
        uint256 s = ISum(opzor).sum(x, y);
        uint256 postGas = gasleft();

        verify(x, y, s);

        unchecked {
            return preGas - postGas;
        }
    }

    function verify(uint256 x, uint256 y, uint256 s) internal pure {
        unchecked {
            if (s != (x + y)) {
                revert ISum.WrongSum(x, y, s);
            }
        }
    }

    function random(uint256 seed) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, seed))) % 100;
    }

    function name() external pure override returns (string memory) {
        return "SUM";
    }

    function description() external pure override returns (string memory) {
        return "";
    }

    function svg(uint256 /*tokenId*/ ) external pure returns (string memory) {
        return "";
    }
}

contract CheapSum is ISum {
    function sum(uint256 x, uint256 y) external pure returns (uint256) {
        return x + y;
    }
}

contract ExpensiveSum is ISum {
    function sum(uint256 x, uint256 y) external pure returns (uint256) {
        for (uint256 i = 0; i < y; ++i) {
            ++x;
        }
        return x;
    }
}
