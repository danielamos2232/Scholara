(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INSUFFICIENT_FUNDS (err u101))
(define-constant ERR_PROPOSAL_NOT_FOUND (err u102))
(define-constant ERR_PROPOSAL_EXPIRED (err u103))
(define-constant ERR_ALREADY_VOTED (err u104))
(define-constant ERR_INVALID_AMOUNT (err u105))
(define-constant ERR_PROPOSAL_NOT_ACTIVE (err u106))
(define-constant ERR_VOTING_PERIOD_ACTIVE (err u107))
(define-constant ERR_INSUFFICIENT_VOTES (err u108))

(define-data-var proposal-counter uint u0)
(define-data-var min-proposal-amount uint u1000000)
(define-data-var voting-period uint u1440)
(define-data-var min-votes-required uint u3)

(define-map proposals
  uint
  {
    student: principal,
    amount: uint,
    description: (string-ascii 500),
    created-at: uint,
    expires-at: uint,
    votes-for: uint,
    votes-against: uint,
    executed: bool,
    active: bool
  }
)

(define-map votes
  {proposal-id: uint, voter: principal}
  {vote: bool, amount: uint}
)

(define-map member-contributions
  principal
  uint
)

(define-map student-applications
  principal
  {
    name: (string-ascii 100),
    institution: (string-ascii 200),
    field-of-study: (string-ascii 100),
    gpa: uint,
    financial-need: (string-ascii 500),
    applied-at: uint
  }
)

;; (define-public (contribute)
;;   (let ((amount (stx-get-balance tx-sender)))
;;     (if (> amount u0)
;;       (begin
;;         (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
;;         (map-set member-contributions 
;;           tx-sender 
;;           (+ (default-to u0 (map-get? member-contributions tx-sender)) amount))
;;         (ok amount))
;;       (err ERR_INSUFFICIENT_FUNDS))))

(define-public (submit-application 
  (name (string-ascii 100))
  (institution (string-ascii 200))
  (field-of-study (string-ascii 100))
  (gpa uint)
  (financial-need (string-ascii 500)))
  (begin
    (map-set student-applications
      tx-sender
      {
        name: name,
        institution: institution,
        field-of-study: field-of-study,
        gpa: gpa,
        financial-need: financial-need,
        applied-at: stacks-block-height
      })
    (ok true)))

(define-public (create-proposal 
  (student principal)
  (amount uint)
  (description (string-ascii 500)))
  (let ((proposal-id (+ (var-get proposal-counter) u1))
        (current-height stacks-block-height)
        (expires-at (+ current-height (var-get voting-period))))
    (asserts! (>= amount (var-get min-proposal-amount)) ERR_INVALID_AMOUNT)
    (asserts! (>= (stx-get-balance (as-contract tx-sender)) amount) ERR_INSUFFICIENT_FUNDS)
    (map-set proposals
      proposal-id
      {
        student: student,
        amount: amount,
        description: description,
        created-at: current-height,
        expires-at: expires-at,
        votes-for: u0,
        votes-against: u0,
        executed: false,
        active: true
      })
    (var-set proposal-counter proposal-id)
    (ok proposal-id)))

(define-public (vote-on-proposal (proposal-id uint) (vote-for bool))
  (let ((proposal (unwrap! (map-get? proposals proposal-id) ERR_PROPOSAL_NOT_FOUND))
        (voter-contribution (default-to u0 (map-get? member-contributions tx-sender)))
        (current-height stacks-block-height))
    (asserts! (get active proposal) ERR_PROPOSAL_NOT_ACTIVE)
    (asserts! (<= current-height (get expires-at proposal)) ERR_PROPOSAL_EXPIRED)
    (asserts! (> voter-contribution u0) ERR_NOT_AUTHORIZED)
    (asserts! (is-none (map-get? votes {proposal-id: proposal-id, voter: tx-sender})) ERR_ALREADY_VOTED)
    
    (map-set votes
      {proposal-id: proposal-id, voter: tx-sender}
      {vote: vote-for, amount: voter-contribution})
    
    (map-set proposals
      proposal-id
      (merge proposal
        {
          votes-for: (if vote-for (+ (get votes-for proposal) voter-contribution) (get votes-for proposal)),
          votes-against: (if vote-for (get votes-against proposal) (+ (get votes-against proposal) voter-contribution))
        }))
    (ok true)))
(define-public (execute-proposal (proposal-id uint))
  (let ((proposal (unwrap! (map-get? proposals proposal-id) ERR_PROPOSAL_NOT_FOUND))
        (current-height stacks-block-height))
    (asserts! (get active proposal) ERR_PROPOSAL_NOT_ACTIVE)
    (asserts! (> current-height (get expires-at proposal)) ERR_VOTING_PERIOD_ACTIVE)
    (asserts! (not (get executed proposal)) ERR_NOT_AUTHORIZED)
    (asserts! (> (get votes-for proposal) (get votes-against proposal)) ERR_INSUFFICIENT_VOTES)
    (asserts! (>= (+ (get votes-for proposal) (get votes-against proposal)) (var-get min-votes-required)) ERR_INSUFFICIENT_VOTES)
    
    (try! (as-contract (stx-transfer? (get amount proposal) tx-sender (get student proposal))))
    
    (map-set proposals
      proposal-id
      (merge proposal {executed: true, active: false}))
    (ok true)))

(define-public (cancel-proposal (proposal-id uint))
  (let ((proposal (unwrap! (map-get? proposals proposal-id) ERR_PROPOSAL_NOT_FOUND)))
    (asserts! (or (is-eq tx-sender CONTRACT_OWNER) (is-eq tx-sender (get student proposal))) ERR_NOT_AUTHORIZED)
    (asserts! (get active proposal) ERR_PROPOSAL_NOT_ACTIVE)
    (asserts! (not (get executed proposal)) ERR_NOT_AUTHORIZED)
    
    (map-set proposals
      proposal-id
      (merge proposal {active: false}))
    (ok true)))

(define-public (update-voting-period (new-period uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (var-set voting-period new-period)
    (ok true)))

(define-public (update-min-proposal-amount (new-amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (var-set min-proposal-amount new-amount)
    (ok true)))

(define-public (update-min-votes-required (new-min uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (var-set min-votes-required new-min)
    (ok true)))

(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals proposal-id))

(define-read-only (get-vote (proposal-id uint) (voter principal))
  (map-get? votes {proposal-id: proposal-id, voter: voter}))

(define-read-only (get-member-contribution (member principal))
  (default-to u0 (map-get? member-contributions member)))

(define-read-only (get-student-application (student principal))
  (map-get? student-applications student))

(define-read-only (get-contract-balance)
  (stx-get-balance (as-contract tx-sender)))

(define-read-only (get-proposal-counter)
  (var-get proposal-counter))

(define-read-only (get-voting-period)
  (var-get voting-period))

(define-read-only (get-min-proposal-amount)
  (var-get min-proposal-amount))

(define-read-only (get-min-votes-required)
  (var-get min-votes-required))

(define-read-only (get-proposal-status (proposal-id uint))
  (match (map-get? proposals proposal-id)
    proposal
    (let ((current-height stacks-block-height)
          (total-votes (+ (get votes-for proposal) (get votes-against proposal))))
      (ok {
        id: proposal-id,
        active: (get active proposal),
        executed: (get executed proposal),
        expired: (> current-height (get expires-at proposal)),
        winning: (> (get votes-for proposal) (get votes-against proposal)),
        sufficient-votes: (>= total-votes (var-get min-votes-required)),
        time-remaining: (if (> (get expires-at proposal) current-height)
                         (- (get expires-at proposal) current-height)
                         u0)
      }))
    ERR_PROPOSAL_NOT_FOUND))