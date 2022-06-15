# Challenger submission workflow

You can commit your contract as a challenger during the `Commit` stage of the
main contract. You can check in what state the contract is by calling function
`period()`.

In order to commit your contract, call function `commit(bytes32 codehash)` with
the code hash of your contract. This will make sure that you (hopefully) do not
know the challenge inputs in advance, and that only you can use your contract.

When the main contract is in state `Challenge`, you can call function
`challenge(uint256 id, bytes32 codehash, address target, address recipient)`
where `id` is the challenge id; `codehash` is the codehash of your contract
that you have committed in the first stage; `target` is the address of your
contract; `recipient` is the address that should be the owner of the newly
minted NFT, in case you become the leader.

When the `Challenge` phase is done the whole cycle repeats and you can, for
example, commit new challenger contracts.
