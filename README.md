# ZK Noir Anonymous Voting System
Anonymous Voting system developed with Noir, a DSL for ZK proofs.

## Overview
The zk-noir-voting system is designed to ensure privacy and security in voting processes using zero-knowledge proofs (ZKPs). It leverages the Noir DSL to create a ZK circuit that verifies votes without revealing any private information about the voter's choice or identity.

## Circuit Improvements Implemented

### 1. Commitment to the Vote
The circuit now includes a commitment to the vote using a Pedersen hash. This enhancement ensures that the actual vote remains hidden while allowing the system to verify that the commitment corresponds to a valid vote. The commitment is generated using the voter's choice (`vote_opening`) and a secret value (`secret`).

### 2. Range Proof for Vote Validity
To enforce that votes are within a valid range (e.g., `0` or `1` for binary choices), the circuit includes a range proof. This ensures that the vote is constrained to valid options without revealing the actual vote, further preserving voter privacy.

### 3. Improved Nullifier Calculation with a Random Salt
The nullifier, which prevents double voting, is now computed using a random salt in addition to the voter's secret and the proposal ID. This improvement ensures that each nullifier is unique, even if the same voter votes multiple times with the same secret and proposal ID. The salt adds an extra layer of security by making the nullifier unlinkable.

## Voting Contract
The `Voting` contract is central to this system, managing proposals, tracking votes, and ensuring the integrity of the voting process through the use of a Merkle tree and zero-knowledge proofs.

Key features include:
- **Proposal Management**: Allows the creation of proposals with a description and deadline.
- **Voting Mechanism**: Voters can cast votes on proposals, with votes being recorded as either "for" or "against".
- **Merkle Tree Verification**: Ensures that only authorized voters can participate by verifying their inclusion in a Merkle tree, preventing unauthorized voting.

### Fix for Second Preimage Attack Vulnerability
A crucial security enhancement in this contract is the prevention of second preimage attacks, which could potentially allow an adversary to find two different inputs that hash to the same value, undermining the security of the voting process.

#### How It Was Fixed:
- **Leaf Hash Encoding**: The contract now uses a specific encoding method for the leaf hashes in the Merkle tree. Instead of directly using the `nullifierHash`, the leaf hash is computed by hashing a concatenated encoding of the Merkle root, proposal ID, vote, and `nullifierHash`. This encoding is then used in the Merkle proof verification.
- **Merkle Proof Verification**: The encoded leaf hash is used as a public input in the zero-knowledge proof, ensuring that each leaf in the Merkle tree is unique and that second preimage attacks are mitigated.

By implementing this fix, the integrity of the Merkle tree and, by extension, the entire voting process is preserved, making it resistant to second preimage attacks and ensuring that each vote is counted securely and accurately.
