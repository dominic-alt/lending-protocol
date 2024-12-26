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

;; Data Variables
(define-data-var minimum-collateral-ratio uint u150) ;; 150% collateralization ratio
(define-data-var liquidation-threshold uint u130) ;; 130% triggers liquidation
(define-data-var protocol-fee uint u1) ;; 1% fee
(define-data-var total-deposits uint u0)
(define-data-var total-borrows uint u0)

;; Data Maps
(define-map loans
    { loan-id: uint }
    {
        borrower: principal,
        collateral-amount: uint,
        borrowed-amount: uint,
        interest-rate: uint,
        start-height: uint,
        last-interest-update: uint,
        active: bool
    }
)

(define-map user-positions
    { user: principal }
    {
        total-collateral: uint,
        total-borrowed: uint,
        loan-count: uint
    }
)

;; Private Functions
(define-private (calculate-interest (principal uint) (rate uint) (blocks uint))
    (let (
        (interest-per-block (/ (* principal rate) u10000))
        (total-interest (* interest-per-block blocks))
    )
    total-interest)
)

(define-private (get-collateral-ratio (collateral uint) (debt uint))
    (if (is-eq debt u0)
        u0
        (/ (* collateral u100) debt)
    )
)

(define-private (update-user-position (user principal) (collateral-change int) (borrow-change int))
    (let (
        (current-position (default-to
            { total-collateral: u0, total-borrowed: u0, loan-count: u0 }
            (map-get? user-positions { user: user })))
    )
    (map-set user-positions
        { user: user }
        {
            total-collateral: (+ (get total-collateral current-position) collateral-change),
            total-borrowed: (+ (get total-borrowed current-position) borrow-change),
            loan-count: (get loan-count current-position)
        }
    ))
)