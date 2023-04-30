// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

import "forge-std/Test.sol";
import "../src/YearnYield.sol";
import "../src/MockERC20.sol";

contract YearnYieldTest is Test {
    // Define the mock contracts
    MockERC20 stakingToken;
    MockVaultAPI yieldVault;
    address treasury;

    // Define the contract under test
    YearnYield yieldContract;

    // Define some constants
    uint256 constant AMOUNT = 100 ether;
    uint256 constant DEADLINE = block.timestamp + 1 days;
    uint256 constant SHARES = 50 ether;
    uint256 constant YIELD = 120 ether;

    // Set up the mock contracts and the contract under test
    function setUp() public {
        stakingToken = new MockERC20();
        yieldVault = new MockVaultAPI(stakingToken);
        treasury = address(1); // Replace with an actual treasury address
        yieldContract = new YearnYield(
            address(stakingToken),
            address(yieldVault),
            treasury
        );
    }

    // Test the deposit function
    function testDeposit() public {
        // Mint some tokens to the caller
        stakingToken.mint(msg.sender, AMOUNT);

        // Approve the transfer to the contract
        stakingToken.approve(address(yieldContract), AMOUNT);

        // Call the deposit function
        yieldContract.deposit(AMOUNT, DEADLINE);

        // Check the balances and shares
        assertEq(
            stakingToken.balanceOf(address(yieldContract)),
            AMOUNT,
            "Wrong balance of contract"
        );
        assertEq(
            yieldVault.balanceOf(address(yieldContract)),
            SHARES,
            "Wrong shares of contract"
        );
        assertEq(
            stakingToken.balanceOf(msg.sender),
            0,
            "Wrong balance of caller"
        );
        assertEq(yieldVault.balanceOf(msg.sender), 0, "Wrong shares of caller");

        // Check the user info
        (
            uint256 deadline,
            uint256 depositedAmount,
            uint256 depositedShares
        ) = yieldContract.userInfo(msg.sender);
        assertEq(deadline, DEADLINE, "Wrong deadline");
        assertEq(depositedAmount, AMOUNT, "Wrong deposited amount");
        assertEq(depositedShares, SHARES, "Wrong deposited shares");
    }

    // Test the withdraw function
    function testWithdraw() public {
        // Set up the deposit scenario
        testDeposit();

        // Set up the yield scenario
        yieldVault.setTotalSupply(SHARES);
        yieldVault.setTotalAssets(YIELD);

        // Fast forward to after the deadline
        hevm.warp(DEADLINE + 1 hours);

        // Call the withdraw function
        yieldContract.withdraw();

        // Check the balances and shares
        assertEq(
            stakingToken.balanceOf(address(yieldContract)),
            0,
            "Wrong balance of contract"
        );
        assertEq(
            yieldVault.balanceOf(address(yieldContract)),
            0,
            "Wrong shares of contract"
        );
        assertEq(
            stakingToken.balanceOf(msg.sender),
            (YIELD * 90) / 100 + AMOUNT,
            "Wrong balance of caller"
        );
        assertEq(yieldVault.balanceOf(msg.sender), 0, "Wrong shares of caller");
        assertEq(
            stakingToken.balanceOf(treasury),
            (YIELD * 10) / 100,
            "Wrong balance of treasury"
        );

        // Check the user info
        (
            uint256 deadline,
            uint256 depositedAmount,
            uint256 depositedShares
        ) = yieldContract.userInfo(msg.sender);
        assertEq(deadline, 0, "Wrong deadline");
        assertEq(depositedAmount, 0, "Wrong deposited amount");
        assertEq(depositedShares, 0, "Wrong deposited shares");
    }
}
