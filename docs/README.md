# Challenger submission workflow

You can commit your contract as a challenger at any time.

In order to commit your contract, call function `commit(bytes32 key)` where
`key = keccak256(abi.encode(sender, codehash, salt))`, `sender` is the address
you intend to use when performin the challenge, `codehash` is the code hash of
your solution contract, and `salt` is any number of your choice.  This will
(hopefully) make sure that you do not know the challenge inputs in advance, and
that only you can use your contract.

At least 256 blocks later, you can call function `challenge(uint256 id, address
target, address recipient, uint salt)` where `id` is the challenge id; `target`
is the address of your solution contract; `recipient` is the address that
should be the owner of the newly minted NFT, in case you become the leader; and
`salt` must be the same you passed when committing.
