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

## Relevant contract addresses:

1. Optimizor: [0x66DE7D67CcfDD92b4E5759Ed9dD2d7cE3C9154a9](https://etherscan.io/address/0x66DE7D67CcfDD92b4E5759Ed9dD2d7cE3C9154a9)
2. Purity Checker: [0x5C71fcd090948dCC5E8A1a01ad8Fa26313422022](https://etherscan.io/address/0x5C71fcd090948dCC5E8A1a01ad8Fa26313422022)
3. SQRT Challenge: [0x2747096ff9e0fce877cd168dcd5de16040a4ab85](https://etherscan.io/address/0x2747096ff9e0fce877cd168dcd5de16040a4ab85)