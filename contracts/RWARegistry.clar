;; Contract: RWARegistry
;; Tokenized Real-World Asset Registry (compact, production-minded)

;; Constants & Errors
(define-constant contract-owner tx-sender)
(define-constant ERR-NOT-OWNER (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-REGISTERED (err u102))
(define-constant ERR-INVALID-VALUE (err u103))
(define-constant ERR-INVALID-METADATA (err u104))
(define-constant ERR-INVALID-ID (err u105))
(define-constant ERR-UNAUTHORIZED (err u106))

;; Storage
(define-data-var last-id uint u0)

(define-map assets uint 
  {
    owner: principal,
    metadata-hash: (buff 64),
    valuation: uint,
    active: bool
  })

;; --- Private functions
(define-private (validate-id (id uint))
  (and 
    (> id u0) 
    (<= id (var-get last-id))))

(define-private (validate-valuation (val uint))
  (> val u0))

(define-private (validate-metadata-hash (hash (buff 64)))
  (not (is-eq hash 0x)))  ;; Check if it's not an empty buffer

;; --- Register new asset
(define-public (register-asset (metadata-hash (buff 64)) (valuation uint))
  (begin
    (asserts! (validate-valuation valuation) ERR-INVALID-VALUE)
    (asserts! (validate-metadata-hash metadata-hash) ERR-INVALID-METADATA)
    (let 
      ((new-id (+ (var-get last-id) u1))
       (asset-data {
         owner: tx-sender,
         metadata-hash: metadata-hash,
         valuation: valuation,
         active: true
       }))
      (var-set last-id new-id)
      (map-set assets new-id asset-data)
      (ok new-id))))

;; --- Transfer ownership
(define-public (transfer-asset (id uint) (new-owner principal))
  (let ((asset (unwrap! (map-get? assets id) ERR-NOT-FOUND)))
    (begin
      (asserts! (validate-id id) ERR-INVALID-ID)
      (asserts! (is-eq tx-sender (get owner asset)) ERR-NOT-OWNER)
      (map-set assets 
        id
        (merge asset {owner: new-owner}))
      (ok true))))

;; --- Update valuation (only owner)
(define-public (update-valuation (id uint) (new-val uint))
  (let ((asset (unwrap! (map-get? assets id) ERR-NOT-FOUND)))
    (begin
      (asserts! (validate-id id) ERR-INVALID-ID)
      (asserts! (validate-valuation new-val) ERR-INVALID-VALUE)
      (asserts! (is-eq tx-sender (get owner asset)) ERR-NOT-OWNER)
      (map-set assets
        id
        (merge asset {valuation: new-val}))
      (ok true))))

;; --- Deactivate asset (burn-like, keeps history)
(define-public (deactivate-asset (id uint))
  (let ((asset (unwrap! (map-get? assets id) ERR-NOT-FOUND)))
    (begin
      (asserts! (validate-id id) ERR-INVALID-ID)
      (asserts! (is-eq tx-sender (get owner asset)) ERR-NOT-OWNER)
      (map-set assets
        id
        (merge asset {active: false}))
      (ok true))))

;; --- Read-only: get asset details
(define-read-only (get-asset (id uint))
  (map-get? assets id))
