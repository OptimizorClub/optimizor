// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IChallenge} from "../src/IChallenge.sol";

interface ISum {
    error WrongSum(uint, uint, uint);

    function sum(uint, uint) external view returns (uint);
}

contract SumChallenge is IChallenge {
    function run(address opzor, uint seed) external view override returns (uint32) {
        // Generate input.
        (uint x, uint y) = (random(seed), random(++seed));

        uint preGas = gasleft();
        uint s = ISum(opzor).sum(x, y);
        uint postGas = gasleft();

        verify(x, y, s);

        unchecked { return uint32(preGas - postGas); }
    }

    function verify(uint x, uint y, uint s) internal pure {
        unchecked {
            if (s != (x + y))
                revert ISum.WrongSum(x, y, s);
        }
    }

    function random(uint seed) internal view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, seed))) % 100;
    }

    function name() external override pure returns (string memory) {
        return "SUM";
    }

    function description() external override pure returns (string memory) {
        return "";
    }

    function svg(uint /*tokenId*/) external pure returns (string memory) {
        return "";
    }
}

contract CheapSum is ISum {
    function sum(uint x, uint y) external pure returns (uint) {
        return x + y;
    }
}

contract ExpensiveSum is ISum {
    function sum(uint x, uint y) external pure returns (uint) {
        for (uint i = 0; i < y; ++i)
            ++x;
        return x;
    }
}
