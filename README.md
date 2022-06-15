# Optimizoooor Gas Golfing NFTs

The `Optimizor` NFT collection rewards gas efficient people and machines by
minting new items whenever a cheaper solution is submitted for a certain
challenge.

See [the list]() of challenges, their ids and interfaces.

In order to try to beat a challenge, your contract must receive inputs and
return outputs in the form specified for that challenge. If your contract
spends less gas than the current leader, you receive a fresh NFT that
represents the top of the leader board for that challenge. The previous leader
keeps their NFT, but they lose the leader status.

The main NFT contract is always in one of three states: `Commit`, `Wait`, or
`Challenge`. Each state lasts 256 blocks. Challenger contracts can only be
committed during the first stage. The second stage makes it harder for
challengers to manipulate the pseudo-random input generation which relies on
the `blockhash` of the last block of the `wait` stage as seed. Finally,
in the third stage challengers can try to claim the lead.

If you are an optimizooor who wants to show your skills please see the
[docs](docs).