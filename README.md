# Optimizor Club Gas Golfing and NFT Collection

The `Optimizor Club` creates and publishes on-chain gas golfing challenges.
The NFT collection rewards gas efficient people and machines by
minting new items whenever a cheaper solution is submitted for a certain
challenge.

See [the list]() of challenges, their ids and interfaces.

In order to try to beat a challenge, your contract must receive inputs and
return outputs in the form specified for that challenge. If your contract
spends less gas than the current leader, you become the new leader.
As a reward you receive a fresh NFT that
represents the top of the leaderboard for that challenge. The previous leader
keeps their NFT, but they lose the leader status.

The inputs for the challenges are generated pseudo-randomly using `prevrandao`.
A challenger must first submit the hash of their solution contract. The
challenge itself can be performed after at least 64 blocks.

If you are an optimizooor who wants to show your skills please see the
[docs](docs).