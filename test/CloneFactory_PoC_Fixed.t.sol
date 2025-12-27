// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {BaseCloneFactory} from "../src/BaseCloneFactory.sol";
import {VaultFactory} from "../src/VaultFactory.sol";
import {Implementation} from "../src/Implementation.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/// @title Regression tests for clone template initialization hardening
/// @notice Ensures the implementaion (logic template) cannot be initialized after fix
/// @dev Fix: Call OZ Initializable._disableInitializers() in the templates' constructor
/// Expectation: Call initialize() on the template MUST revert with InvalidInitialization
contract CloneFactory_PoC_Fixed is Test {
    VaultFactory factory;
    Implementation impl;
    address attacker;

    function setUp() public {
        impl = new Implementation();
        factory = new VaultFactory(address(impl));
        attacker = makeAddr("ATTACKER");
        vm.deal(attacker, 2 ether);
    }

    /// @notice Initialization on the template MUST revert after hardening
    /// @dev Implementation's constructor contains _disableInitializers(), preventing anyone from setting owner in the template context
    function test_Implementation_Init_Reverts_AfterFix() public {
        vm.startPrank(attacker);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        impl.initialize(attacker);
        vm.stopPrank();
    }

    /// @notice Guaranteens the hardening does not break the intended clone initialization flow
    function test_Init_ViaFactory_WorkOut_AfterFix() public {
        vm.startPrank(attacker);
        Implementation clone = Implementation(factory.create());
        assertEq(clone.owner(), attacker);
        vm.stopPrank();
    }
}
