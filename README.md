# Stacks Lending Protocol

A decentralized lending protocol built on the Stacks blockchain that enables users to deposit STX tokens as collateral, borrow against their collateral, and participate in liquidations.

## Features

- Deposit STX tokens as collateral
- Borrow STX against deposited collateral
- Repay loans with interest
- Withdraw collateral
- Liquidation mechanism for under-collateralized positions
- Protocol parameter management
- Real-time position tracking

## Key Parameters

- Minimum Collateral Ratio: 150%
- Liquidation Threshold: 130%
- Protocol Fee: 1%
- Maximum Collateral Ratio: 500%
- Minimum Collateral Ratio: 110%
- Maximum Protocol Fee: 10%

## Functions

### User Functions

- `deposit()`: Deposit STX tokens as collateral
- `borrow(amount)`: Borrow STX against collateral
- `repay(amount)`: Repay borrowed STX
- `withdraw(amount)`: Withdraw collateral
- `liquidate(user)`: Liquidate under-collateralized positions

### Admin Functions

- `set-minimum-collateral-ratio(new-ratio)`
- `set-liquidation-threshold(new-threshold)`
- `set-protocol-fee(new-fee)`

### Read-Only Functions

- `get-user-position(user)`
- `get-protocol-stats()`

## Security Features

- Parameter bounds validation
- Self-liquidation prevention
- Collateral ratio enforcement
- Safe arithmetic operations
- Access control for admin functions

## Installation

```bash
# Clone the repository
git clone https://github.com/dominic-alt/lending-protocol.git

# Deploy using Clarinet
clarinet deploy
```

## Testing

```bash
clarinet test
```

## License

MIT License - See LICENSE file for details
