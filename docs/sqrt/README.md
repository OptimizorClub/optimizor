ID: 1

In the SQRT problem your contract is given an array of Fixed18 numbers, and it
must return the square root of each number with an error margin of 10^-5.
The challenge contract can be found at
[0x2747096ff9e0fce877cd168dcd5de16040a4ab85](https://etherscan.io/address/0x2747096ff9e0fce877cd168dcd5de16040a4ab85#code#F3#L1).

The interface that your solution contract must have can be represented by the
Solidity interface below. Function `sqrt` will be called by the challenge
contract when you make a challenge.

```solidity
interface ISqrt {
    function sqrt(Fixed18[INPUT_SIZE] calldata) external view returns (Fixed18[INPUT_SIZE] memory);
}
```

The Fixed18 library can be found in the deployed contract's source code or in
this directory.
