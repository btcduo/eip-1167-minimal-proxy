// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

/// @title BaseCloneFactory
/// @notice Base factory for deploying EIP-1167 minimal proxies.
/// @dev Child contracts should expose a typed external 'create()' that builds 'salt' and 'initData'.
abstract contract BaseCloneFactory {
    address public immutable implementation; // EIP-1167 template.

    error AlreadyDeployed();
    error InitFailed();

    constructor(address _impl) {
        implementation = _impl;
    }

    /// @notice Deploys a determinisitic clone and initializes it via a low-level-call.
    function _deployClone(bytes32 salt, bytes memory initData) internal returns (address clone) {
        clone = _predict(salt);
        if (_exists(clone)) {
            revert AlreadyDeployed();
        }
        clone = Clones.cloneDeterministic(implementation, salt);

        (bool ok,) = clone.call(initData);
        if (!ok) {
            revert InitFailed();
        }
    }

    function _predict(bytes32 salt) internal view returns (address predicted) {
        predicted = Clones.predictDeterministicAddress(implementation, salt, address(this));
    }

    /// @notice Return false can be deploy.
    function _exists(address clone) private view returns (bool) {
        return clone.code.length > 0;
    }
}
