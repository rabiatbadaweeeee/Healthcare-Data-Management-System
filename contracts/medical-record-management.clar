;; Medical Record Management Contract

(define-map medical-records
  { patient-id: uint, record-id: uint }
  { data-hash: (buff 32), timestamp: uint, provider: principal }
)

(define-map patient-record-list uint (list 100 uint))

(define-data-var record-id-nonce uint u0)

(define-public (add-medical-record (patient-id uint) (data-hash (buff 32)))
  (let
    ((new-id (+ (var-get record-id-nonce) u1))
     (record-list (default-to (list) (map-get? patient-record-list patient-id))))
    (asserts! (is-some (contract-call? .patient-registry get-patient-info patient-id)) (err u404))
    (map-set medical-records
      { patient-id: patient-id, record-id: new-id }
      { data-hash: data-hash, timestamp: block-height, provider: tx-sender }
    )
    (map-set patient-record-list patient-id
      (unwrap! (as-max-len? (append record-list new-id) u100) (err u500))
    )
    (var-set record-id-nonce new-id)
    (ok new-id)
  )
)

(define-read-only (get-medical-record (patient-id uint) (record-id uint))
  (map-get? medical-records { patient-id: patient-id, record-id: record-id })
)

(define-read-only (get-patient-records (patient-id uint))
  (map-get? patient-record-list patient-id)
)

