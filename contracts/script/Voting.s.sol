// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import "../lib/forge-std/src/Script.sol";
import "../src/Voting.sol";
import "../../circuits/contract/plonk_vk.sol";

contract DeploymentScript is Script {
    function readInputs() internal view returns (string memory) {
        string memory inputDir = string.concat(vm.projectRoot(), "/data/input");

        return vm.readFile(string.concat(inputDir, ".json"));
    }

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Instantiate the UltraVerifier contract
        UltraVerifier verifier = new UltraVerifier();

        // Read and parse the input file
        string memory inputs = readInputs();

        // Parse the merkleRoot from the JSON inputs
        bytes32 merkleRoot = bytes32(vm.parseJson(inputs, ".merkleRoot"));

        // Deploy the Voting contract with the parsed merkleRoot and verifier address
        Voting voting = new Voting(merkleRoot, address(verifier));

        vm.stopBroadcast();
    }
}
