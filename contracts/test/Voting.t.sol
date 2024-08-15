// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import "../lib/forge-std/src/Test.sol";
import "../src/Voting.sol";
import "../../circuits/contract/plonk_vk.sol";

contract VotingTest is Test {
    Voting public voteContract;
    UltraVerifier public verifier;

    bytes32[] proof;
    bytes32[] emptyProof;

    uint256 deadline = block.timestamp + 10000000;

    bytes32 merkleRoot;
    bytes32 nullifierHash;

    function readInputs() internal view returns (string memory) {
        string memory inputDir = string.concat(vm.projectRoot(), "/data/input");

        return vm.readFile(string.concat(inputDir, ".json"));
    }

    function setUp() public {
        string memory inputs = readInputs();

        merkleRoot = bytes32(vm.parseJson(inputs, ".merkleRoot"));
        nullifierHash = bytes32(vm.parseJson(inputs, ".nullifierHash"));

        verifier = new UltraVerifier();
        voteContract = new Voting(merkleRoot, address(verifier));
        voteContract.propose("First proposal", deadline);

        string memory proofFilePath = "./circuits/proofs/foundry_voting.proof";
        string memory proofData = vm.readLine(proofFilePath);

        proof = abi.decode(vm.parseBytes(proofData), (bytes32[]));
        // emptyProof = abi.decode(vm.parseBytes(proofData), (bytes32[]));
    }

    function test_validVote() public {
        voteContract.castVote(proof, 0, 1, nullifierHash);
    }

    function test_invalidProof() public {
        vm.expectRevert();
        voteContract.castVote(emptyProof, 0, 1, nullifierHash); // passing an empty proof
    }

    function test_doubleVoting() public {
        voteContract.castVote(proof, 0, 1, nullifierHash);

        vm.expectRevert("Proof has been already submitted");
        voteContract.castVote(proof, 0, 1, nullifierHash);
    }

    function test_changedVote() public {
        vm.expectRevert();

        voteContract.castVote(proof, 0, 0, nullifierHash); // attempting to vote against after a vote for
    }
}
