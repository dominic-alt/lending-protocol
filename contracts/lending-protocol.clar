;; Lending Protocol Smart Contract
;; 
;; This smart contract implements a decentralized lending protocol on the Stacks blockchain. 
;; Users can deposit STX tokens as collateral, borrow against their collateral, repay loans, 
;; and withdraw their collateral. The contract also supports liquidation of under-collateralized 
;; positions and provides administrative functions for managing protocol parameters.

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-COLLATERAL (err u101))
(define-constant ERR-INVALID-AMOUNT (err u102))
(define-constant ERR-LOAN-NOT-FOUND (err u103))
(define-constant ERR-LOAN-ACTIVE (err u104))
(define-constant ERR-INSUFFICIENT-BALANCE (err u105))
(define-constant ERR-LIQUIDATION-FAILED (err u106))