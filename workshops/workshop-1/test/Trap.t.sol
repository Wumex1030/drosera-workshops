// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/LargeTransferTrap.sol";

contract MockERC20 {
    mapping(address => uint256) public balances;

    function setBalance(address account, uint256 amount) external {
        balances[account] = amount;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}

contract LargeTransferTrapTest is Test {
    LargeTransferTrap trap;
    MockERC20 token;

    address constant TARGET = 0x0000000000000000000000000000000000000002;

    function setUp() public {
        token = new MockERC20();

        // Cheatcode: overwrite TOKEN slot in trap
        trap = new LargeTransferTrap();

        // Set initial balance
        token.setBalance(TARGET, 10_000_000 ether);
    }

    function testDetectsLargeTransferIncrease() public {
        bytes memory prevData = abi.encode(LargeTransferTrap.CollectOutput({balance: 10_000_000 ether}));
        bytes memory latestData = abi.encode(LargeTransferTrap.CollectOutput({balance: 11_500_000 ether}));

        bytes ;
        data[0] = latestData;
        data[1] = prevData;

        (bool should, bytes memory msgData) = trap.shouldRespond(data);

        assertTrue(should);
        assertEq(string(msgData), "Large transfer detected");
    }

    function testNoTriggerForSmallChange() public {
        bytes memory prevData = abi.encode(LargeTransferTrap.CollectOutput({balance: 10_000_000 ether}));
        bytes memory latestData = abi.encode(LargeTransferTrap.CollectOutput({balance: 10_100_000 ether}));

        bytes ;
        data[0] = latestData;
        data[1] = prevData;

        (bool should, ) = trap.shouldRespond(data);
        assertFalse(should);
    }
}
