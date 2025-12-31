// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {stdJson} from "forge-std/StdJson.sol";

import {VaultFactory} from "../src/VaultFactory.sol";
import {Implementation} from "../src/Implementation.sol";

contract InteractSepolia is Script {
    using stdJson for string;

    function run() external {
        require(block.chainid == 11155111, "wrong chain (not sepolia)");

        uint256 pk = vm.envUint("PRIVATE_KEY");
        address user = vm.addr(pk);

        // Load deployed addresses
        string memory json = vm.readFile("deployments/sepolia.v0.1.1-fix.json");
        address factoryAddr = json.readAddress(".contracts.factory.address");

        VaultFactory factory = VaultFactory(factoryAddr);

        // Amount controls
        uint256 depositAmt = vm.envOr("DEPOSIT_WEI", uint256(0.01 ether));
        uint256 withdrawAmt = vm.envOr("WITHDRAW_WEI", uint256(0.005 ether));

        console2.log("=== Sepolia Interact ===");
        console2.log("user:", user);
        console2.log("factory:", factoryAddr);
        console2.log("nonce(before):", factory.nonces(user));

        address predicted = factory.predictVaultAddr(user);
        console2.log("predicted(next vault):", predicted);

        vm.startBroadcast(pk);

        // Deploy + init in ONE tx
        address vault = factory.create();
        console2.log("created vault:", vault);

        // Deterministic check (should match)
        require(vault == predicted, "vault != predicted");

        // Interact with the clone (same interface as Implementation)
        Implementation v = Implementation(vault);

        console2.log("vault.owner():", v.owner());
        console2.log("vault.balance(before):", v.balance());

        // deposit
        v.deposit{value: depositAmt}();
        console2.log("deposit wei:", depositAmt);
        console2.log("vault.balance(after deposit):", v.balance());

        // withdraw
        v.withdraw(withdrawAmt);
        console2.log("withdraw wei:", withdrawAmt);
        console2.log("vault.balance(after withdraw):", v.balance());

        vm.stopBroadcast();

        console2.log("nonce(after):", factory.nonces(user));

        address[] memory vaults = factory.getUserVaults(user);
        console2.log("userVaults.length:", vaults.length);
        if (vaults.length > 0) {
            console2.log("userVaults[last]:", vaults[vaults.length - 1]);
        }
        console2.log("=== done ===");
    }
}
