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

;; Public Functions
(define-public (deposit)
    (let (
        (amount (stx-get-balance tx-sender))
    )
    (if (> amount u0)
        (begin
            (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
            (var-set total-deposits (+ (var-get total-deposits) amount))
            (update-user-position tx-sender amount 0)
            (ok amount)
        )
        ERR-INVALID-AMOUNT
    ))
)

(define-public (borrow (amount uint))
    (let (
        (user-pos (default-to
            { total-collateral: u0, total-borrowed: u0, loan-count: u0 }
            (map-get? user-positions { user: tx-sender })))
        (collateral (get total-collateral user-pos))
        (current-borrowed (get total-borrowed user-pos))
    )
    (if (and
            (> amount u0)
            (>= (get-collateral-ratio collateral (+ current-borrowed amount))
                (var-get minimum-collateral-ratio)))
        (begin
            (try! (as-contract (stx-transfer? amount (as-contract tx-sender) tx-sender)))
            (var-set total-borrows (+ (var-get total-borrows) amount))
            (update-user-position tx-sender 0 amount)
            (ok amount)
        )
        ERR-INSUFFICIENT-COLLATERAL
    ))
)

(define-public (repay (amount uint))
    (let (
        (user-pos (default-to
            { total-collateral: u0, total-borrowed: u0, loan-count: u0 }
            (map-get? user-positions { user: tx-sender })))
        (current-borrowed (get total-borrowed user-pos))
    )
    (if (<= amount current-borrowed)
        (begin
            (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
            (var-set total-borrows (- (var-get total-borrows) amount))
            (update-user-position tx-sender 0 (* -1 amount))
            (ok amount)
        )
        ERR-INVALID-AMOUNT
    ))
)

(define-public (withdraw (amount uint))
    (let (
        (user-pos (default-to
            { total-collateral: u0, total-borrowed: u0, loan-count: u0 }
            (map-get? user-positions { user: tx-sender })))
        (collateral (get total-collateral user-pos))
        (borrowed (get total-borrowed user-pos))
    )
    (if (and
            (<= amount collateral)
            (>= (get-collateral-ratio (- collateral amount) borrowed)
                (var-get minimum-collateral-ratio)))
        (begin
            (try! (as-contract (stx-transfer? amount (as-contract tx-sender) tx-sender)))
            (var-set total-deposits (- (var-get total-deposits) amount))
            (update-user-position tx-sender (* -1 amount) 0)
            (ok amount)
        )
        ERR-INSUFFICIENT-COLLATERAL
    ))
)

;; Liquidation Function
(define-public (liquidate (user principal))
    (let (
        (user-pos (default-to
            { total-collateral: u0, total-borrowed: u0, loan-count: u0 }
            (map-get? user-positions { user: user })))
        (collateral (get total-collateral user-pos))
        (borrowed (get total-borrowed user-pos))
        (ratio (get-collateral-ratio collateral borrowed))
    )
    (if (< ratio (var-get liquidation-threshold))
        (begin
            ;; Transfer collateral to liquidator with penalty
            (try! (as-contract (stx-transfer? collateral (as-contract tx-sender) tx-sender)))
            ;; Clear user position
            (map-delete user-positions { user: user })
            (var-set total-deposits (- (var-get total-deposits) collateral))
            (var-set total-borrows (- (var-get total-borrows) borrowed))
            (ok true)
        )
        ERR-LIQUIDATION-FAILED
    ))
)

;; Read-Only Functions
(define-read-only (get-user-position (user principal))
    (default-to
        { total-collateral: u0, total-borrowed: u0, loan-count: u0 }
        (map-get? user-positions { user: user })
    )
)

(define-read-only (get-protocol-stats)
    {
        total-deposits: (var-get total-deposits),
        total-borrows: (var-get total-borrows),
        minimum-collateral-ratio: (var-get minimum-collateral-ratio),
        liquidation-threshold: (var-get liquidation-threshold),
        protocol-fee: (var-get protocol-fee)
    }
)