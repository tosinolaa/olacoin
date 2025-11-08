(define-constant OWNER tx-sender)

(define-data-var token-name (string-ascii 32) "OLACOIN")
(define-data-var token-symbol (string-ascii 10) "OLA")
(define-data-var token-decimals uint u6)
(define-data-var total-supply uint u0)

(define-map balances {owner: principal} {balance: uint})

(define-read-only (get-name)
  (ok (var-get token-name))
)

(define-read-only (get-symbol)
  (ok (var-get token-symbol))
)

(define-read-only (get-decimals)
  (ok (var-get token-decimals))
)

(define-read-only (get-total-supply)
  (ok (var-get total-supply))
)

(define-read-only (get-balance (who principal))
  (ok (get-balance-of who))
)

(define-private (get-balance-of (who principal))
  (match (map-get? balances {owner: who})
    data (get balance data)
    u0)
)

(define-private (credit (who principal) (amount uint))
  (let (
        (current (get-balance-of who))
        (new (+ current amount))
       )
    (map-set balances {owner: who} {balance: new})
    (ok new)
  )
)

(define-private (debit (who principal) (amount uint))
  (let ((current (get-balance-of who)))
    (if (>= current amount)
        (let ((new (- current amount)))
          (if (is-eq new u0)
              (begin (map-delete balances {owner: who}) (ok u0))
              (begin (map-set balances {owner: who} {balance: new}) (ok new))))
        (err u1) ; insufficient-balance
    )
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (if (is-eq tx-sender sender)
      (match (debit sender amount)
        debited
          (match (credit recipient amount)
            credited (ok true)
            err (err u4)) ; credit-failed
        err (err u1)) ; insufficient-balance
      (err u3) ; unauthorized-sender
  )
)

(define-public (mint (recipient principal) (amount uint))
  (if (is-eq tx-sender OWNER)
      (begin
        (var-set total-supply (+ (var-get total-supply) amount))
        (match (credit recipient amount)
          _ (ok true)
          err (err u4))
      )
      (err u2) ; not-owner
  )
)

(define-public (burn (holder principal) (amount uint))
  (if (is-eq tx-sender OWNER)
      (match (debit holder amount)
        _ (begin
            (var-set total-supply (- (var-get total-supply) amount))
            (ok true))
        err (err u1)
      )
      (err u2)
  )
)

; Error codes:
; u1: insufficient-balance
; u2: not-owner
; u3: unauthorized-sender
; u4: credit-failed
