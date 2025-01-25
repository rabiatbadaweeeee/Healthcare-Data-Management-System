;; Access Control Contract

(define-map access-permissions
  { patient-id: uint, provider: principal }
  { granted: bool, expiration: uint }
)

(define-public (grant-access (patient-id uint) (provider principal) (expiration uint))
  (let
    ((patient-address (unwrap! (contract-call? .patient-registry get-patient-id-by-address tx-sender) (err u404))))
    (asserts! (is-eq patient-address patient-id) (err u403))
    (map-set access-permissions
      { patient-id: patient-id, provider: provider }
      { granted: true, expiration: expiration }
    )
    (ok true)
  )
)

(define-public (revoke-access (patient-id uint) (provider principal))
  (let
    ((patient-address (unwrap! (contract-call? .patient-registry get-patient-id-by-address tx-sender) (err u404))))
    (asserts! (is-eq patient-address patient-id) (err u403))
    (map-delete access-permissions { patient-id: patient-id, provider: provider })
    (ok true)
  )
)

(define-read-only (check-access (patient-id uint) (provider principal))
  (let
    ((permission (default-to { granted: false, expiration: u0 }
      (map-get? access-permissions { patient-id: patient-id, provider: provider }))))
    (and (get granted permission) (> (get expiration permission) block-height))
  )
)

