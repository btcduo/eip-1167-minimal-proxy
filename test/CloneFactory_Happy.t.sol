// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {BaseCloneFactory} from "../src/BaseCloneFactory.sol";
import {VaultFactory} from "../src/VaultFactory.sol";
import {Implementation} from "../src/Implementation.sol";

/// @title CloneFactory happy-path tests
/// @notice Validates the expected successful flow: deploy clone -> initialize -> deposit -> withdraw
/// @dev Asserts basic correctness of ownership and internal ETH accounting on the happy path
contract CloneFactory_Happy is Test {
    VaultFactory factory;
    Implementation impl;
    address user;

    function setUp() public {
        impl = new Implementation();
        factory = new VaultFactory(address(impl));
        user = makeAddr("USER");
        vm.deal(user, 2 ether);
    }

    /// @notice A user can create a clone, becomes the owner via initializer, then deposit and withdraw updates balance correctly
    /// @dev Asserts: clone.owner == user, clone.balance tracks deposits/withdrawals, and user receives withrawn ETH
    function test_clone_init_deposit_withdraw_OK() public {
        vm.startPrank(user);
        uint256 balBefore = user.balance;
        Implementation clone = Implementation(factory.create());
        assertEq(clone.owner(), user);
        clone.deposit{value: 2 ether}();
        assertEq(clone.balance(), 2 ether);
        clone.withdraw(1 ether);
        assertEq(clone.balance(), 1 ether);
        assertEq(user.balance, balBefore - 2 ether + 1 ether);
    }
}
