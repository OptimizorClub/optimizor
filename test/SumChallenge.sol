// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../src/Challenge.sol";

interface ISum {
    error WrongSum(uint, uint, uint);

    function sum(uint, uint) external view returns (uint);
}

contract SumChallenge is IChallenge {
    function run(address opzor, uint seed) external view override returns (uint) {
        // Generate input.
        (uint x, uint y) = (random(seed), random(++seed));

        uint preGas = gasleft();
        uint s = ISum(opzor).sum(x, y);
        uint postGas = gasleft();

        verify(x, y, s);

        unchecked { return preGas - postGas; }
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

    function name() external override view returns (string memory) {
        return "SUM";
    }

    function svg(uint tokenId) external view returns (bytes memory art) {
        art = '<rect width="230" height="230" rx="18px" ry="18px" fill="rgba(0,0,0,0.1)" /><polygon points="115,145 153,145 153,183" fill="none" stroke="white"/><polygon points="115,145 153,183 126,210" fill="none" stroke="white"/><polygon points="115,145 126,210 88,217" fill="none" stroke="white"/><polygon points="115,145 88,217 52,204" fill="none" stroke="white"/><polygon points="115,145 52,204 26,176" fill="none" stroke="white"/><polygon points="115,145 26,176 14,139" fill="none" stroke="white"/><polygon points="115,145 14,139 16,101" fill="none" stroke="white"/><polygon points="115,145 16,101 31,66" fill="none" stroke="white"/><polygon points="115,145 31,66 58,38" fill="none" stroke="white"/><polygon points="115,145 58,38 91,20" fill="none" stroke="white"/><polygon points="115,145 91,20 129,13" fill="none" stroke="white"/><polygon points="115,145 129,13 167,17" fill="none" stroke="white"/><polygon points="115,145 167,17 203,31" fill="none" stroke="white"/>';
        /* art = '<rect width="230" height="240" style="fill:rgb(0,0,255);stroke-width:3;stroke:rgb(0,0,0)" />'; */
        //art = '<path d="M150 0 L75 200 L225 200 Z" />';
        //art = '<polygon points="100,10 40,198 190,78 10,78 160,198" style="fill:lime;stroke:purple;stroke-width:5;fill-rule:nonzero;" />';
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
