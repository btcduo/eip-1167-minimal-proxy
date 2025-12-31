// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Receiver {
    error Rejected();

    fallback() external payable {
        revert Rejected();
    }
}
