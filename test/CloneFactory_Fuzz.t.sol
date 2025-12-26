// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {BaseCloneFactory} from "../src/BaseCloneFactory.sol";
import {VaultFactory} from "../src/VaultFactory.sol";
import {Implementation} from "../src/Implementation.sol";

/// @title CloneFactory fuzz tests
/// @notice Fuzz tests covering deployment, initialization and vault accounting invariants
contract CloneFactory_Fuzz is Test {
    VaultFactory factory;
    Implementation impl;
    address user;

    function setUp() public {
        impl = new Implementation();
        factory = new VaultFactory(address(impl));
        user = makeAddr("USER");
    }

    /// @notice Depositing then withdrawing must preserve internal balance accounting
    /// @dev Ensures withdraw never underflows and matches deposited value
    function testFuzz_deposit_withdraw(uint96 dep, uint96 wd) public {
        dep = uint96(bound(dep, 1, 10 ether));
        wd = uint96(bound(wd, 0, dep));

        vm.deal(user, dep);

        vm.startPrank(user);
        Implementation clone = Implementation(factory.create());
        assertEq(clone.owner(), user);

        clone.deposit{value: dep}();
        assertEq(clone.balance(), dep);

        clone.withdraw(wd);
        assertEq(clone.balance(), dep - wd);
        vm.stopPrank();
    }
}
