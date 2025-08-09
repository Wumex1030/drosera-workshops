// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

/// @notice Minimal ERC20 interface for balanceOf checks
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

/// @notice Trap that detects when a monitored address sends or receives a large ERC20 transfer
contract LargeTransferTrap is ITrap {
    // Hardcoded values for Drosera deployment
    address public constant TOKEN = 0x0000000000000000000000000000000000000001; // Replace with ERC20 token address
    address public constant TARGET = 0x0000000000000000000000000000000000000002; // Replace with monitored address
    uint256 public constant TRANSFER_THRESHOLD = 1_000_000 ether; // Large transfer threshold

    struct CollectOutput {
        uint256 balance;
    }

    /// @notice Called by Drosera to collect latest state
    function collect() external view returns (bytes memory) {
        uint256 balance = IERC20(TOKEN).balanceOf(TARGET);
        return abi.encode(CollectOutput({balance: balance}));
    }

    /// @notice Called by Drosera to decide whether to trigger
    /// @param data Historical collect outputs, most recent first
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        require(data.length >= 2, "Need at least 2 data points");

        CollectOutput memory latest = abi.decode(data[0], (CollectOutput));
        CollectOutput memory previous = abi.decode(data[1], (CollectOutput));

        uint256 change = latest.balance > previous.balance
            ? latest.balance - previous.balance
            : previous.balance - latest.balance;

        if (change >= TRANSFER_THRESHOLD) {
            return (true, bytes("Large transfer detected"));
        }

        return (false, bytes(""));
    }
}
