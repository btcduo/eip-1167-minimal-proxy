// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {BaseCloneFactory} from "../src/BaseCloneFactory.sol";
import {VaultFactory} from "../src/VaultFactory.sol";
import {Implementation} from "../src/Implementation.sol";
import {Receiver} from "../src/mocks/Receiver.sol";

/// @title Revert-path tests for Clone/Vault factories
/// @notice Covers expected failures for factory deployment + clone usage
/// @dev Focus:
/// - factory revert branches
/// - clone access contol + input validation
/// - transfer failure branch via Receiver that rejects ether
contract CloneFactory_Revert is Test {
    VaultFactory factory;
    Implementation impl;
    Receiver user2;
    address user;

    function setUp() public {
        impl = new Implementation();
        factory = new VaultFactory(address(impl));
        user = makeAddr("USER");
        user2 = new Receiver();
        vm.deal(user, 2 ether);
        vm.deal(address(user2), 2 ether);
    }

    /// @dev Helper: deploy clone as '_user' (owner is set in init inside factory)
    function _deploy(address _user) internal returns (Implementation clone) {
        vm.startPrank(_user);
        clone = Implementation(factory.create());
        vm.stopPrank();
    }

    function testRevert_Factory_AlreadyDeployed() public {
        bytes memory data = abi.encodeCall(Implementation.initialize, (user));
        vm.startPrank(user);
        factory.create();
        uint256 nonce = factory.nonces(user);
        vm.expectRevert(BaseCloneFactory.AlreadyDeployed.selector);
        factory.createWithRevert(nonce, data);
        vm.stopPrank();
    }

    function testRevert_Factory_InitFailed() public {
        bytes memory data = abi.encodeCall(Implementation.initRevert, ());
        vm.startPrank(user);
        uint256 nonce = 0;
        vm.expectRevert(BaseCloneFactory.InitFailed.selector);
        factory.createWithRevert(nonce, data);
        vm.stopPrank();
    }

    function testRevert_Clone_NotOwner() public {
        Implementation c = _deploy(user);
        vm.startPrank(address(user2));
        vm.expectRevert(Implementation.NotOwner.selector);
        c.deposit();
        vm.stopPrank();
    }

    function testRevert_Clone_ZeroValue() public {
        Implementation c = _deploy(user);
        vm.startPrank(user);
        vm.expectRevert(Implementation.ZeroValue.selector);
        c.deposit();
        vm.stopPrank();
    }

    function testRevert_Clone_InsufficientBalance() public {
        Implementation c = _deploy(user);
        vm.startPrank(user);
        c.deposit{value: 1 ether}();
        vm.expectRevert(Implementation.InsufficientBalance.selector);
        c.withdraw(1 ether + 1);
        vm.stopPrank();
    }

    function testRevert_Clone_TransferFailed() public {
        Implementation c = _deploy(address(user2));
        vm.startPrank(address(user2));
        c.deposit{value: 1 ether}();
        vm.expectRevert(Implementation.TransferFailed.selector);
        c.withdraw(1 ether);
        vm.stopPrank();
    }
}
