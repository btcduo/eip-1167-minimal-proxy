// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {BaseCloneFactory} from "./BaseCloneFactory.sol";
// Interfaces
import {ILogic} from "./interfaces/ILogic.sol";

/// @title VaultFactory
/// @notice Deploys and tracks per-user vault clones
/// @dev Design goals:
/// - Deterministic vault addressses via CREATE2
/// - One vault per (user, nonce) pair
/// - Stateless clone logic with explicit initializer call
contract VaultFactory is BaseCloneFactory {
    /// @notice List of all vaults created by a user
    /// @dev Used only for indexing / off-chain descovery
    mapping(address => address[]) public userVaults;

    /// @notice Per-user nonce for deterministic vault deployment
    /// @dev Incremented before deployment to avoid salt reuse
    mapping(address => uint256) public nonces;

    /// @notice Emitted after deployment has performed to preserve diagnosability
    /// @param _user Vault owner & initializer
    /// @param _clone Deployed vault address
    /// @param _salt CREATE2 salt used for deployment
    /// @param _initData Initialization calldata
    event Clone(address indexed _user, address indexed _clone, bytes32 _salt, bytes _initData);

    constructor(address _impl) BaseCloneFactory(_impl) {}

    /// @notice Deploy a new vault clone for the caller
    /// @dev Flow:
    /// - Increment user nonce
    /// - Derive CREARE2 salt from (user, nonce)
    /// - Build initialization calldata
    /// - Deploy clone via BaseCloneFactory
    /// - Track vault in userVaults
    /// @dev Reverts:
    /// - Clone already exists at predicted address
    /// - Initialization call failed
    function create() external returns (address clone) {
        uint256 _nonce = nonces[msg.sender] + 1;
        nonces[msg.sender] = _nonce;
        bytes32 salt = _salt(msg.sender, _nonce);
        bytes memory initData = _initData(msg.sender);
        clone = _deployClone(salt, initData);
        userVaults[msg.sender].push(clone);

        emit Clone(msg.sender, clone, salt, initData);
    }

    function createWithRevert(uint256 _nonce, bytes memory initData) external {
        bytes32 salt = _salt(msg.sender, _nonce);
        _deployClone(salt, initData);
    }

    /// @dev Derives deterministic salt
    /// @param _user Vault owner & initializer
    /// @param _nonce Per-user incrementing nonce
    /// @return salt keccak256(_user, _nonce)
    /// Security: uses abi.enocde to avoid collision
    function _salt(address _user, uint256 _nonce) private pure returns (bytes32) {
        return keccak256(abi.encode(_user, _nonce));
    }

    /// @dev Builds initialization calldata for vault clone
    /// @param _user Vault owner & initializer
    /// Security: initialize() MUST be protected against re-initialization
    function _initData(address _user) private pure returns (bytes memory) {
        return abi.encodeCall(ILogic.initialize, (_user));
    }

    /// @notice Predict the next vault address for _user
    /// @dev Uses incremented current nonce
    /// @param _user Vault owner & initializer
    /// @return predicted Deterministic vault address
    function predictVaultAddr(address _user) external view returns (address predicted) {
        uint256 nonce_ = nonces[_user] + 1;
        bytes32 salt = _salt(_user, nonce_);
        predicted = _predict(salt);
    }

    function getUserVaults(address _user) external view returns (address[] memory) {
        return userVaults[_user];
    }
}
