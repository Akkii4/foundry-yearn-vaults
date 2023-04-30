// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {VaultAPI} from "./VaultAPI.sol";

contract YearnYield {
    struct UserInfo {
        uint256 deadline;
        uint256 depositedAmount;
        uint256 depositedShares;
    }

    mapping(address => UserInfo) public userInfo;

    address immutable stakingToken;
    address immutable yieldVault;
    address immutable treasury;

    constructor(address _stakingToken, address _yieldVault, address _treasury) {
        require(_stakingToken != address(0), "Invalid staking token address");
        require(_yieldVault != address(0), "Invalid yield vault address");
        require(_treasury != address(0), "Invalid treasury address");

        stakingToken = _stakingToken;
        yieldVault = _yieldVault;
        treasury = _treasury;
    }

    function deposit(uint256 amount, uint256 deadline) external {
        require(amount > 0, "MyYieldChallenge: Amount must be greater than 0");
        require(
            deadline > block.timestamp,
            "MyYieldChallenge: Invalid deadline"
        );

        IERC20(stakingToken).transferFrom(msg.sender, address(this), amount);
        IERC20(stakingToken).approve(yieldVault, amount);
        uint256 shares = VaultAPI(yieldVault).deposit(amount);

        userInfo[msg.sender] = UserInfo(deadline, amount, shares);
    }

    function withdraw() external {
        UserInfo memory userChallenge = userInfo[msg.sender];
        require(
            userChallenge.depositedAmount > 0,
            "MyYieldChallenge: No deposited amount"
        );
        require(
            block.timestamp > userChallenge.deadline,
            "MyYieldChallenge: Deadline not met"
        );

        uint256 shares = userChallenge.depositedShares;
        userInfo[msg.sender].depositedAmount = 0;
        userInfo[msg.sender].depositedShares = 0;

        uint256 yieldAmount = VaultAPI(yieldVault).withdraw(shares);
        uint256 depositedAmount = userChallenge.depositedAmount;
        IERC20(stakingToken).transfer(
            msg.sender,
            ((yieldAmount * 90) / 100) + depositedAmount
        );
        IERC20(stakingToken).transfer(treasury, ((yieldAmount * 10) / 100));
    }
}
