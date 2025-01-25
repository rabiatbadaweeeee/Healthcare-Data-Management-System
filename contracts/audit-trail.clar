;; Audit Trail Contract

(define-map audit-logs
  uint
  { patient-id: uint, action: (string-ascii 20), performer: principal, timestamp: uint }
)

(define-data-var audit-log-nonce uint u0)

(define-public (log-action (patient-id uint) (action (string-ascii 20)))
  (let
    ((new-id (+ (var-get audit-log-nonce) u1)))
    (map-set audit-logs new-id
      { patient-id: patient-id, action: action, performer: tx-sender, timestamp: block-height }
    )
    (var-set audit-log-nonce new-id)
    (ok new-id)
  )
)

(define-read-only (get-audit-log (log-id uint))
  (map-get? audit-logs log-id)
)

(define-read-only (get-patient-audit-logs (patient-id uint))
  (filter audit-logs (lambda (log) (is-eq (get patient-id log) patient-id)))
)

