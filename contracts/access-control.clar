;; Access Control Contract

(define-map access-permissions
  { patient: principal, provider: principal }
  { granted: bool, expiration: uint }
)

(define-public (grant-access (provider principal) (expiration uint))
  (let
    ((patient tx-sender))
    (map-set access-permissions
      { patient: patient, provider: provider }
      { granted: true, expiration: expiration }
    )
    (ok true)
  )
)

(define-public (revoke-access (provider principal))
  (let
    ((patient tx-sender))
    (map-delete access-permissions { patient: patient, provider: provider })
    (ok true)
  )
)

(define-read-only (check-access (patient principal) (provider principal))
  (let
    ((permission (default-to { granted: false, expiration: u0 }
      (map-get? access-permissions { patient: patient, provider: provider }))))
    (and (get granted permission) (> (get expiration permission) block-height))
  )
)
