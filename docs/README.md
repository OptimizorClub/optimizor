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

After waiting for at least 256 blocks, you can call the function `challenge(uint256 id, address target, address recipient, uint salt)` where
- `id` corresponds to the index for the challenge,
- `target` is the address of your solution contract,
- `recipient` is the address that should be the owner of the newly minted NFT,
- `salt` is the secret information used to generate input to `commit(...)`,
- the invariant `keccak256(abi.encode(msg.sender, target.codehash, salt)) == key` should be true, where `key` is the 32-byte hash that was committed before.
