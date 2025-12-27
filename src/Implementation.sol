// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/// @notice Minimal implementation contract used as the logic template for EIP-1167 clones.
/// @dev Purpose:
/// - Each clone has its own storage
/// - Call initialize() once per clone
contract Implementation is Initializable {
    /// @dev Demo-only ETH accounting, can deverge from address(this).balance such as forced ETH
    uint256 public balance;

    /// @dev Custom owner slot(EIP-1967-style) to avoid slot collision
    bytes32 internal constant OWNER_SLOT = bytes32(uint256(keccak256("vault.invariant.owner")) - 1);

    error NotOwner();
    error ZeroValue();
    error InsufficientBalance();
    error TransferFailed();

    /// @dev Fixed: adds _disableInitializers(), preventing user from initializing this context.
    constructor() {
        _disableInitializers();
    }

    /// @dev Owner-gated functions for demo(deposit/withdraw are restricted on purpose)
    modifier onlyOwner() {
        if (msg.sender != owner()) {
            revert NotOwner();
        }
        _;
    }

    /// @notice Initializes clone state(must be called once per clone)
    function initialize(address _owner) external initializer {
        _setOwner(_owner);
    }

    /// @notice Deposits ETH and updates internal ledger
    function deposit() external payable onlyOwner {
        if (msg.value == 0) {
            revert ZeroValue();
        }
        balance += msg.value;
    }

    /// @notice Withdraws ETH (Check-Effect-Interact)
    function withdraw(uint256 amount) external onlyOwner {
        if (amount > balance) {
            revert InsufficientBalance();
        }
        balance -= amount;
        (bool ok,) = msg.sender.call{value: amount}("");
        if (!ok) {
            revert TransferFailed();
        }
    }

    function getOwnerSlot() external pure returns (bytes32) {
        return OWNER_SLOT;
    }

    function owner() public view returns (address _owner) {
        bytes32 s = OWNER_SLOT;
        assembly {
            _owner := sload(s)
        }
    }

    function _setOwner(address _owner) internal {
        bytes32 s = OWNER_SLOT;
        assembly {
            sstore(s, _owner)
        }
    }

    /// @notice Only for test
    function initRevert() external pure {
        revert("FALSE");
    }
}
