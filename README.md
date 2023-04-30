# YearnYield

YearnYield is a Foundry project that integrates with Yearn Vaults using VaultAPI interfaces and leverages their yield strategies. It allows users to deposit tokens into a vault and withdraw them after a specified deadline, while earning interest from the vault's strategy. A portion of the interest is sent to a treasury address as a fee.

## Installation

To install the project, you need to have [Foundry](https://foundrydao.com/) installed and configured on your machine. Then, clone this repository and run `foundry build` in the project directory.

## Usage

To use the project, you need to deploy the `YearnYield` contract with the following parameters:

- `_stakingToken`: The address of the ERC20 token that users can deposit and withdraw.
- `_yieldVault`: The address of the Yearn Vault that implements the VaultAPI interface and has the same underlying token as `_stakingToken`.
- `_treasury`: The address of the treasury that receives a 10% fee from the interest earned by the vault.

After deploying the contract, users can interact with it using the following functions:

- `deposit(uint256 amount, uint256 deadline)`: Allows a user to deposit `amount` of tokens into the vault and set a `deadline` (in seconds) for withdrawal. The user must approve the contract to spend their tokens before calling this function. The function returns the number of shares that the user receives from the vault.
- `withdraw()`: Allows a user to withdraw their tokens and interest after the deadline has passed. The function transfers 90% of the interest and the original deposit to the user, and 10% of the interest to the treasury. The function also burns the user's shares from the vault.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
