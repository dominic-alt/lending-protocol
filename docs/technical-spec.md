# Technical Specification

## Contract Overview

The Stacks Lending Protocol is a decentralized lending platform implementing collateralized loans using STX tokens.

## Core Components

### Data Structures

1. **Loans Map**
   - Key: loan-id (uint)
   - Value: 
     - borrower: principal
     - collateral-amount: uint
     - borrowed-amount: uint
     - interest-rate: uint
     - start-height: uint
     - last-interest-update: uint
     - active: bool

2. **User Positions Map**
   - Key: user (principal)
   - Value:
     - total-collateral: uint
     - total-borrowed: uint
     - loan-count: uint

### Key Parameters

- Minimum Collateral Ratio: 150%
- Liquidation Threshold: 130%
- Protocol Fee: 1%
- Maximum bounds:
  - Collateral Ratio: 500%
  - Protocol Fee: 10%
- Minimum bounds:
  - Collateral Ratio: 110%

## Function Specifications

### deposit()
- Accepts STX tokens from user
- Updates total deposits
- Updates user position
- Returns amount deposited

### borrow(amount: uint)
- Validates collateral ratio
- Transfers STX to borrower
- Updates total borrows
- Updates user position
- Returns borrowed amount

### repay(amount: uint)
- Accepts STX repayment
- Updates total borrows
- Updates user position
- Returns repaid amount

### withdraw(amount: uint)
- Validates remaining collateral ratio
- Transfers STX to user
- Updates total deposits
- Updates user position
- Returns withdrawn amount

### liquidate(user: principal)
- Validates liquidation conditions
- Transfers collateral to liquidator
- Clears user position
- Updates protocol totals

## Security Considerations

1. **Access Control**
   - Admin functions restricted to contract owner
   - User operations validated against sender

2. **Parameter Validation**
   - All inputs bounds-checked
   - Ratio requirements enforced
   - Safe arithmetic operations

3. **Liquidation Safety**
   - Self-liquidation prevented
   - Minimum debt requirement
   - Position existence verification

4. **State Management**
   - Atomic operations
   - Safe position updates
   - Consistent total tracking