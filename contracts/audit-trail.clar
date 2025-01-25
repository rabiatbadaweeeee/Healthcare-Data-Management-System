;; Audit Trail Contract

(define-map audit-logs
  { log-id: uint, patient: principal }
  { action: (string-ascii 20), performer: principal, timestamp: uint }
)

(define-data-var audit-log-nonce uint u0)

(define-public (log-action (patient principal) (action (string-ascii 20)))
  (let
    ((new-id (+ (var-get audit-log-nonce) u1)))
    (map-set audit-logs
      { log-id: new-id, patient: patient }
      { action: action, performer: tx-sender, timestamp: block-height }
    )
    (var-set audit-log-nonce new-id)
    (ok new-id)
  )
)

(define-read-only (get-audit-log (log-id uint))
  (map-get? audit-logs { log-id: log-id, patient: tx-sender })
)

(define-read-only (get-last-audit-log-id)
  (ok (var-get audit-log-nonce))
)

