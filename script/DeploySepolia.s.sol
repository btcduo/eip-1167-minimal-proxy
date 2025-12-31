// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {VaultFactory} from "../src/VaultFactory.sol";
import {Implementation} from "../src/Implementation.sol";

contract DeploySepolia is Script {
    function run() external returns (address impl, address factory) {
        uint256 pk = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(pk);

        Implementation _impl = new Implementation();

        VaultFactory _factory = new VaultFactory(address(_impl));

        vm.stopBroadcast();

        impl = address(_impl);
        factory = address(_factory);

        console2.log("Implementation:", impl);
        console2.log("Factory:", factory);
    }
}
