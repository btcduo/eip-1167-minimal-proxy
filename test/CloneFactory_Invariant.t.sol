// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {BaseCloneFactory} from "../src/BaseCloneFactory.sol";
import {VaultFactory} from "../src/VaultFactory.sol";
import {Implementation} from "../src/Implementation.sol";

/// @title Invariant tests for EIP-1167 clone vaults
/// @notice Uses a Handler to fuzz sequences of create/deposit/withdraw across multiple users
/// @dev Goal: ensure factory bookkeeping and clone state remain consistent under arbitrary call order
/// @dev Stateful fuzzer actions
/// - createVault(user): creates a new clone owned by user
/// - deposit(user, amt, idx): deposits into one of user's vaults(bounded)
/// - withdraw(user, amt, idx): withdraws from one of user's vaults(bounded)
contract Handler is Test {
    VaultFactory factory;

    constructor(VaultFactory f) {
        factory = f;
    }

    function createVault(address user) external {
        vm.assume(user != address(0));
        vm.startPrank(user);
        factory.create();
        vm.stopPrank();
    }

    function deposit(address user, uint96 amt, uint256 idx) external {
        vm.assume(user != address(0));
        address[] memory vs = factory.getUserVaults(user);
        if (vs.length == 0) return;

        idx = bound(idx, 0, vs.length - 1);
        amt = uint96(bound(amt, 1, 5 ether));

        vm.deal(user, amt);
        vm.startPrank(user);
        Implementation(vs[idx]).deposit{value: amt}();
        vm.stopPrank();
    }

    function withdraw(address user, uint96 amt, uint256 idx) external {
        vm.assume(user != address(0));
        address[] memory vs = factory.getUserVaults(user);
        if (vs.length == 0) return;
        idx = bound(idx, 0, vs.length - 1);

        Implementation clone = Implementation(vs[idx]);
        uint256 bal = clone.balance();
        if (bal == 0) return;
        amt = uint96(bound(amt, 1, uint96(bal)));
        vm.startPrank(user);
        clone.withdraw(amt);
        vm.stopPrank();
    }
}

contract CloneFactory_Invariant is StdInvariant, Test {
    VaultFactory factory;
    Implementation impl;
    Handler handler;

    function setUp() public {
        impl = new Implementation();
        factory = new VaultFactory(address(impl));
        handler = new Handler(factory);

        targetContract(address(handler));
    }

    /// @dev Ledger must not exceed real ETH held by the clone (prevents "phantom balance")
    function invariant_ledgerNeverExceedsRealETH() public {
        address[3] memory users = [makeAddr("U0"), makeAddr("U1"), makeAddr("U2")];
        for (uint256 i; i < users.length; i++) {
            address[] memory vs = factory.getUserVaults(users[i]);
            for (uint256 j; j < vs.length; j++) {
                Implementation clone = Implementation(vs[j]);
                assertLe(clone.balance(), vs[j].balance);
            }
        }
    }

    /// @dev Owner is immutable after initialize (no unauthorized ownership change)
    function invariant_ownerNeverChange() public {
        address[3] memory users = [makeAddr("U0"), makeAddr("U1"), makeAddr("U2")];
        for (uint256 i; i < users.length; i++) {
            address[] memory vs = factory.getUserVaults(users[i]);
            for (uint256 j; j < vs.length; j++) {
                Implementation clone = Implementation(vs[j]);
                assertEq(clone.owner(), users[i]);
            }
        }
    }

    /// @dev Factory should only record deployed clones (address must contain code)
    function invariant_vaultListAreDeployedContracts() public {
        address[3] memory users = [makeAddr("U0"), makeAddr("U1"), makeAddr("U2")];
        for (uint256 i; i < users.length; i++) {
            address[] memory vs = factory.getUserVaults(users[i]);
            for (uint256 j; j < vs.length; j++) {
                assertGt(vs[j].code.length, 0);
            }
        }
    }
}
