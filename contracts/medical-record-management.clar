;; Medical Record Management Contract

(define-map medical-records
  { patient: principal, record-id: uint }
  { data-hash: (buff 32), timestamp: uint, provider: principal }
)

(define-map patient-record-list principal (list 100 uint))

(define-data-var record-id-nonce uint u0)

(define-public (add-medical-record (data-hash (buff 32)))
  (let
    ((new-id (+ (var-get record-id-nonce) u1))
     (patient tx-sender)
     (record-list (default-to (list) (map-get? patient-record-list patient))))
    (map-set medical-records
      { patient: patient, record-id: new-id }
      { data-hash: data-hash, timestamp: block-height, provider: tx-sender }
    )
    (map-set patient-record-list patient
      (unwrap! (as-max-len? (append record-list new-id) u100) (err u500))
    )
    (var-set record-id-nonce new-id)
    (ok new-id)
  )
)

(define-read-only (get-medical-record (record-id uint))
  (map-get? medical-records { patient: tx-sender, record-id: record-id })
)

(define-read-only (get-patient-records)
  (map-get? patient-record-list tx-sender)
)
