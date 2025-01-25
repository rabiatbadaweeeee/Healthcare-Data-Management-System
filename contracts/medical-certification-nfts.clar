;; Medical Certification NFTs Contract

(define-non-fungible-token medical-cert uint)

(define-map certification-info uint
  { name: (string-ascii 50), recipient: principal, issuer: principal, issue-date: uint, expiration-date: uint }
)

(define-data-var cert-id-nonce uint u0)

(define-public (issue-certification
    (recipient principal)
    (name (string-ascii 50))
    (expiration-date uint))
  (let
    ((new-id (+ (var-get cert-id-nonce) u1)))
    (try! (nft-mint? medical-cert new-id recipient))
    (map-set certification-info new-id
      { name: name, recipient: recipient, issuer: tx-sender, issue-date: block-height, expiration-date: expiration-date }
    )
    (var-set cert-id-nonce new-id)
    (ok new-id)
  )
)

(define-public (revoke-certification (cert-id uint))
  (let
    ((cert-info (unwrap! (map-get? certification-info cert-id) (err u404))))
    (asserts! (is-eq tx-sender (get issuer cert-info)) (err u403))
    (try! (nft-burn? medical-cert cert-id (get recipient cert-info)))
    (map-delete certification-info cert-id)
    (ok true)
  )
)

(define-read-only (get-certification-info (cert-id uint))
  (map-get? certification-info cert-id)
)

(define-read-only (is-certification-valid (cert-id uint))
  (let
    ((cert-info (unwrap! (map-get? certification-info cert-id) false)))
    (< block-height (get expiration-date cert-info))
  )
)
