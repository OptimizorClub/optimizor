# Challenger submission workflow

You can commit your contract as a challenger at any time.

```solidity
/// An interface for Optimizor for challenge operations
interface IOptimizor {
    function commit(bytes32 key) external;
    function challenge(uint256 id, address target, address recipient, uint salt) external;
}
```

In order to commit your contract, call function `commit(bytes32 key)` where
`key = keccak256(abi.encode(sender, codehash, salt))`, `sender` is the address
you intend to use when performing the challenge, `codehash` is the code hash of
your solution contract, and `salt` is any number of your choice.

The use of a secret information (`salt`) and allowing a separate `sender` is to prevent an external observer from easily finding your contract. We recommend using different accounts for `commit` and `challenge`, and also to pick a good and distinct salt for each commits. One can also delay the deployment of the actual solution contract to some time before the `challenge` call.

After waiting for at least 64 blocks, you can call the function `challenge(uint256 id, address target, address recipient, uint salt)` where
- `id` corresponds to the index for the challenge,
- `target` is the address of your solution contract,
- `recipient` is the address that should be the owner of the newly minted NFT,
- `salt` is the secret information used to generate input to `commit(...)`,
- the invariant `keccak256(abi.encode(msg.sender, target.codehash, salt)) == key` should be true, where `key` is the 32-byte hash that was committed before.

For specific information about a challenge, please check the directories here.

## Metadata Hash

When submitting a solution, your contract must be pure, that is, it cannot use
any opcode that mutates the state or that calls/creates another contract.  The
main Optimizor contract uses a
[Purity Checker](https://etherscan.io/address/0x5C71fcd090948dCC5E8A1a01ad8Fa26313422022)
to decide whether your solution is valid.  You should also use this contract to
test your solutions pre-deployment. The metadata hash which the Solidity and Vyper
compilers add to the bytecode may cause false positives in this verification.
Therefore it is recommended that you remove the metadata hash from your
solution's bytecode.

The latest release of the Vyper compiler has an option to remove the metadata hash.
Such option is available for Solidity only in the pre-release of the Solidity compiler.
You can use [this pre-release solc binary](https://github.com/OptimizorClub/optimizor/blob/main/bin/solc) in the meantime.
