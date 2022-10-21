// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../src/challenges/SqrtChallenge.sol";

/// Returns the midpoint avoiding phantom overflow
function mid(uint a, uint b) pure returns (uint) {
    unchecked {
        return (a & b) + (a ^ b) / 2;
    }
}

abstract contract DefaultSqrt is ISqrt {
    function sqrt_one(Fixed18 input) internal pure returns (Fixed18 output) {
        uint l = 0;
        uint uInput = Fixed18.unwrap(input);
        uint r = uInput - 1;
        while (l < r) {
            uint m = mid(l, r);
            uint mPlus1 = m + 1;
            if ((m * m <= uInput) && (mPlus1 * mPlus1 > uInput))
                return Fixed18.wrap(m * 10**9);
            if (m * m < uInput)
                l = m;
            else
                r = m;
        }
        revert("wrong algorithm");
    }
}

contract CheapSqrt is DefaultSqrt {
    function sqrt(Fixed18[INPUT_SIZE] calldata inputs) external pure returns (Fixed18[INPUT_SIZE] memory outputs) {
        for (uint i = 0; i < inputs.length; ++i) {
            outputs[i] = sqrt_one(inputs[i]);
        }
    }
}

contract ExpensiveSqrt is DefaultSqrt {
    function sqrt(Fixed18[INPUT_SIZE] calldata inputs) external pure returns (Fixed18[INPUT_SIZE] memory outputs) {
        for (uint i = 0; i < inputs.length; ++i) {
            outputs[i] = sqrt_one(inputs[i]);
            outputs[i] = sqrt_one(inputs[i]);
        }
    }
}

contract ExpensiveSqrt2 is DefaultSqrt {
    function sqrt(Fixed18[INPUT_SIZE] calldata inputs) external pure returns (Fixed18[INPUT_SIZE] memory outputs) {
        for (uint i = 0; i < inputs.length; ++i) {
            outputs[i] = sqrt_one(inputs[i]);
            outputs[i] = sqrt_one(inputs[i]);
            outputs[i] = sqrt_one(inputs[i]);
        }
    }
}

contract ExpensiveSqrt3 is DefaultSqrt {
    function sqrt(Fixed18[INPUT_SIZE] calldata inputs) external pure returns (Fixed18[INPUT_SIZE] memory outputs) {
        for (uint i = 0; i < inputs.length; ++i) {
            outputs[i] = sqrt_one(inputs[i]);
            outputs[i] = sqrt_one(inputs[i]);
            outputs[i] = sqrt_one(inputs[i]);
            outputs[i] = sqrt_one(inputs[i]);
        }
    }
}
