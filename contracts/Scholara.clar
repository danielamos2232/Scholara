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
(define-constant ERR_ACHIEVEMENT_NOT_FOUND (err u109))
(define-constant ERR_ACHIEVEMENT_ALREADY_CLAIMED (err u110))
(define-constant ERR_INSUFFICIENT_ACHIEVEMENT_TOKENS (err u111))
(define-constant ERR_INVALID_ACHIEVEMENT_TYPE (err u112))
(define-constant ERR_REWARD_NOT_AVAILABLE (err u113))
(define-constant ERR_INVALID_TIER_REQUIREMENTS (err u114))
(define-constant ERR_MENTOR_NOT_FOUND (err u115))
(define-constant ERR_MENTORSHIP_REQUEST_NOT_FOUND (err u116))
(define-constant ERR_MENTORSHIP_NOT_FOUND (err u117))
(define-constant ERR_ALREADY_MENTOR (err u118))
(define-constant ERR_NOT_QUALIFIED_MENTOR (err u119))
(define-constant ERR_MENTORSHIP_NOT_ACTIVE (err u120))
(define-constant ERR_INVALID_SESSION_DURATION (err u121))
(define-constant ERR_MENTORSHIP_ALREADY_EXISTS (err u122))
(define-constant ERR_INVALID_RATING_VALUE (err u123))

(define-data-var proposal-counter uint u0)
(define-data-var min-proposal-amount uint u1000000)
(define-data-var voting-period uint u1440)
(define-data-var min-votes-required uint u3)
(define-data-var achievement-counter uint u0)
(define-data-var reward-counter uint u0)
(define-data-var mentorship-request-counter uint u0)
(define-data-var mentorship-counter uint u0)

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

(define-map academic-achievements
  uint
  {
    student: principal,
    achievement-type: (string-ascii 50),
    title: (string-ascii 100),
    description: (string-ascii 300),
    token-reward: uint,
    tier-level: uint,
    requirements-met: (string-ascii 200),
    awarded-at: uint,
    verified: bool,
    verifier: (optional principal)
  }
)

(define-map student-achievement-tokens
  principal
  {
    total-tokens: uint,
    tokens-spent: uint,
    available-tokens: uint,
    bronze-achievements: uint,
    silver-achievements: uint,
    gold-achievements: uint,
    platinum-achievements: uint
  }
)

(define-map achievement-rewards
  uint
  {
    reward-type: (string-ascii 50),
    title: (string-ascii 100),
    description: (string-ascii 300),
    token-cost: uint,
    stx-reward: uint,
    reputation-boost: uint,
    tier-requirement: uint,
    max-redemptions: uint,
    current-redemptions: uint,
    active: bool,
    created-at: uint
  }
)

(define-map student-reward-claims
  {student: principal, reward-id: uint}
  {
    claimed: bool,
    claimed-at: uint,
    stx-received: uint,
    reputation-gained: uint
  }
)

(define-map achievement-types
  (string-ascii 50)
  {
    token-value: uint,
    tier-multiplier: uint,
    active: bool
  }
)

(define-map mentor-profiles
  principal
  {
    name: (string-ascii 100),
    expertise-areas: (string-ascii 300),
    experience-years: uint,
    education-background: (string-ascii 200),
    max-students: uint,
    current-students: uint,
    total-sessions: uint,
    average-rating: uint,
    total-ratings: uint,
    tokens-earned: uint,
    active: bool,
    registered-at: uint
  }
)

(define-map mentorship-requests
  uint
  {
    student: principal,
    subject-area: (string-ascii 100),
    description: (string-ascii 300),
    preferred-schedule: (string-ascii 100),
    duration-weeks: uint,
    status: (string-ascii 20),
    created-at: uint,
    matched-mentor: (optional principal)
  }
)

(define-map active-mentorships
  uint
  {
    mentor: principal,
    student: principal,
    subject-area: (string-ascii 100),
    start-date: uint,
    planned-duration: uint,
    sessions-completed: uint,
    total-hours: uint,
    student-progress: uint,
    mentor-notes: (string-ascii 500),
    status: (string-ascii 20),
    request-id: uint
  }
)

(define-map mentorship-sessions
  {mentorship-id: uint, session-number: uint}
  {
    date: uint,
    duration-minutes: uint,
    topics-covered: (string-ascii 200),
    student-progress-rating: uint,
    session-notes: (string-ascii 300),
    completed: bool
  }
)

(define-map mentor-feedback
  {mentorship-id: uint, reviewer: principal}
  {
    rating: uint,
    communication-score: uint,
    knowledge-score: uint,
    helpfulness-score: uint,
    feedback-text: (string-ascii 300),
    submitted-at: uint
  }
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

(define-public (setup-achievement-types)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (map-set achievement-types "gpa-excellence" {token-value: u100, tier-multiplier: u2, active: true})
    (map-set achievement-types "perfect-attendance" {token-value: u50, tier-multiplier: u1, active: true})
    (map-set achievement-types "research-publication" {token-value: u200, tier-multiplier: u3, active: true})
    (map-set achievement-types "community-service" {token-value: u75, tier-multiplier: u1, active: true})
    (map-set achievement-types "academic-improvement" {token-value: u80, tier-multiplier: u2, active: true})
    (map-set achievement-types "leadership-role" {token-value: u120, tier-multiplier: u2, active: true})
    (ok true)))

(define-public (create-achievement-reward
  (reward-type (string-ascii 50))
  (title (string-ascii 100))
  (description (string-ascii 300))
  (token-cost uint)
  (stx-reward uint)
  (reputation-boost uint)
  (tier-requirement uint)
  (max-redemptions uint))
  (let ((reward-id (+ (var-get reward-counter) u1)))
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (asserts! (> token-cost u0) ERR_INVALID_AMOUNT)
    (asserts! (<= tier-requirement u4) ERR_INVALID_TIER_REQUIREMENTS)
    (asserts! (> max-redemptions u0) ERR_INVALID_AMOUNT)
    
    (map-set achievement-rewards
      reward-id
      {
        reward-type: reward-type,
        title: title,
        description: description,
        token-cost: token-cost,
        stx-reward: stx-reward,
        reputation-boost: reputation-boost,
        tier-requirement: tier-requirement,
        max-redemptions: max-redemptions,
        current-redemptions: u0,
        active: true,
        created-at: stacks-block-height
      })
    (var-set reward-counter reward-id)
    (ok reward-id)))

(define-public (award-achievement
  (student principal)
  (achievement-type (string-ascii 50))
  (title (string-ascii 100))
  (description (string-ascii 300))
  (tier-level uint)
  (requirements-met (string-ascii 200)))
  (let ((achievement-id (+ (var-get achievement-counter) u1))
        (type-info (unwrap! (map-get? achievement-types achievement-type) ERR_INVALID_ACHIEVEMENT_TYPE))
        (base-tokens (get token-value type-info))
        (tier-multiplier (get tier-multiplier type-info))
        (token-reward (* base-tokens (+ u1 (* tier-level tier-multiplier))))
        (existing-tokens (default-to {total-tokens: u0, tokens-spent: u0, available-tokens: u0, bronze-achievements: u0, silver-achievements: u0, gold-achievements: u0, platinum-achievements: u0} 
                         (map-get? student-achievement-tokens student)))
        (verifier-contribution (default-to u0 (map-get? member-contributions tx-sender))))
    (asserts! (> verifier-contribution u500000) ERR_NOT_AUTHORIZED)
    (asserts! (get active type-info) ERR_INVALID_ACHIEVEMENT_TYPE)
    (asserts! (<= tier-level u4) ERR_INVALID_TIER_REQUIREMENTS)
    (asserts! (and (>= tier-level u1) (<= tier-level u4)) ERR_INVALID_TIER_REQUIREMENTS)
    
    (map-set academic-achievements
      achievement-id
      {
        student: student,
        achievement-type: achievement-type,
        title: title,
        description: description,
        token-reward: token-reward,
        tier-level: tier-level,
        requirements-met: requirements-met,
        awarded-at: stacks-block-height,
        verified: true,
        verifier: (some tx-sender)
      })
    
    (map-set student-achievement-tokens
      student
      {
        total-tokens: (+ (get total-tokens existing-tokens) token-reward),
        tokens-spent: (get tokens-spent existing-tokens),
        available-tokens: (+ (get available-tokens existing-tokens) token-reward),
        bronze-achievements: (+ (get bronze-achievements existing-tokens) (if (is-eq tier-level u1) u1 u0)),
        silver-achievements: (+ (get silver-achievements existing-tokens) (if (is-eq tier-level u2) u1 u0)),
        gold-achievements: (+ (get gold-achievements existing-tokens) (if (is-eq tier-level u3) u1 u0)),
        platinum-achievements: (+ (get platinum-achievements existing-tokens) (if (is-eq tier-level u4) u1 u0))
      })
    
    (var-set achievement-counter achievement-id)
    (ok achievement-id)))

(define-public (redeem-achievement-reward (reward-id uint))
  (let ((reward (unwrap! (map-get? achievement-rewards reward-id) ERR_REWARD_NOT_AVAILABLE))
        (student-tokens (unwrap! (map-get? student-achievement-tokens tx-sender) ERR_INSUFFICIENT_ACHIEVEMENT_TOKENS))
        (tier-requirement (get tier-requirement reward))
        (student-tier (calculate-student-tier tx-sender)))
    (asserts! (get active reward) ERR_REWARD_NOT_AVAILABLE)
    (asserts! (< (get current-redemptions reward) (get max-redemptions reward)) ERR_REWARD_NOT_AVAILABLE)
    (asserts! (>= (get available-tokens student-tokens) (get token-cost reward)) ERR_INSUFFICIENT_ACHIEVEMENT_TOKENS)
    (asserts! (>= student-tier tier-requirement) ERR_INVALID_TIER_REQUIREMENTS)
    (asserts! (is-none (map-get? student-reward-claims {student: tx-sender, reward-id: reward-id})) ERR_ACHIEVEMENT_ALREADY_CLAIMED)
    
    (let ((stx-reward (get stx-reward reward))
          (token-cost (get token-cost reward)))
      
      (and (> stx-reward u0)
           (unwrap! (as-contract (stx-transfer? stx-reward tx-sender tx-sender)) ERR_INSUFFICIENT_FUNDS))
      
      (map-set student-achievement-tokens
        tx-sender
        (merge student-tokens 
          {
            tokens-spent: (+ (get tokens-spent student-tokens) token-cost),
            available-tokens: (- (get available-tokens student-tokens) token-cost)
          }))
      
      (map-set student-reward-claims
        {student: tx-sender, reward-id: reward-id}
        {
          claimed: true,
          claimed-at: stacks-block-height,
          stx-received: stx-reward,
          reputation-gained: u0
        })
      
      (map-set achievement-rewards
        reward-id
        (merge reward {current-redemptions: (+ (get current-redemptions reward) u1)}))
      
      (ok true))))

(define-public (transfer-achievement-tokens (recipient principal) (amount uint))
  (let ((sender-tokens (unwrap! (map-get? student-achievement-tokens tx-sender) ERR_INSUFFICIENT_ACHIEVEMENT_TOKENS))
        (recipient-tokens (default-to {total-tokens: u0, tokens-spent: u0, available-tokens: u0, bronze-achievements: u0, silver-achievements: u0, gold-achievements: u0, platinum-achievements: u0} 
                          (map-get? student-achievement-tokens recipient))))
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (>= (get available-tokens sender-tokens) amount) ERR_INSUFFICIENT_ACHIEVEMENT_TOKENS)
    (asserts! (not (is-eq tx-sender recipient)) ERR_INVALID_AMOUNT)
    
    (map-set student-achievement-tokens
      tx-sender
      (merge sender-tokens {available-tokens: (- (get available-tokens sender-tokens) amount)}))
    
    (map-set student-achievement-tokens
      recipient
      (merge recipient-tokens 
        {
          total-tokens: (+ (get total-tokens recipient-tokens) amount),
          available-tokens: (+ (get available-tokens recipient-tokens) amount)
        }))
    (ok true)))

(define-private (calculate-student-tier (student principal))
  (let ((tokens (default-to {total-tokens: u0, tokens-spent: u0, available-tokens: u0, bronze-achievements: u0, silver-achievements: u0, gold-achievements: u0, platinum-achievements: u0} 
                 (map-get? student-achievement-tokens student))))
    (if (> (get platinum-achievements tokens) u0) u4
      (if (> (get gold-achievements tokens) u0) u3
        (if (> (get silver-achievements tokens) u0) u2
          (if (> (get bronze-achievements tokens) u0) u1 u0))))))

(define-read-only (get-achievement (achievement-id uint))
  (map-get? academic-achievements achievement-id))

(define-read-only (get-student-achievement-tokens (student principal))
  (map-get? student-achievement-tokens student))

(define-read-only (get-achievement-reward (reward-id uint))
  (map-get? achievement-rewards reward-id))

(define-read-only (get-student-reward-claim (student principal) (reward-id uint))
  (map-get? student-reward-claims {student: student, reward-id: reward-id}))

(define-read-only (get-achievement-type (type-name (string-ascii 50)))
  (map-get? achievement-types type-name))

(define-read-only (get-student-tier (student principal))
  (calculate-student-tier student))

(define-read-only (get-achievement-counter)
  (var-get achievement-counter))

(define-read-only (get-reward-counter)
  (var-get reward-counter))

(define-public (register-as-mentor
  (name (string-ascii 100))
  (expertise-areas (string-ascii 300))
  (experience-years uint)
  (education-background (string-ascii 200))
  (max-students uint))
  (let ((contributor-amount (default-to u0 (map-get? member-contributions tx-sender))))
    (asserts! (> contributor-amount u1000000) ERR_NOT_QUALIFIED_MENTOR)
    (asserts! (> max-students u0) ERR_INVALID_AMOUNT)
    (asserts! (is-none (map-get? mentor-profiles tx-sender)) ERR_ALREADY_MENTOR)
    
    (map-set mentor-profiles
      tx-sender
      {
        name: name,
        expertise-areas: expertise-areas,
        experience-years: experience-years,
        education-background: education-background,
        max-students: max-students,
        current-students: u0,
        total-sessions: u0,
        average-rating: u0,
        total-ratings: u0,
        tokens-earned: u0,
        active: true,
        registered-at: stacks-block-height
      })
    (ok true)))

(define-public (request-mentorship
  (subject-area (string-ascii 100))
  (description (string-ascii 300))
  (preferred-schedule (string-ascii 100))
  (duration-weeks uint))
  (let ((request-id (+ (var-get mentorship-request-counter) u1)))
    (asserts! (> duration-weeks u0) ERR_INVALID_AMOUNT)
    (asserts! (<= duration-weeks u52) ERR_INVALID_AMOUNT)
    (asserts! (is-some (map-get? student-applications tx-sender)) ERR_NOT_AUTHORIZED)
    
    (map-set mentorship-requests
      request-id
      {
        student: tx-sender,
        subject-area: subject-area,
        description: description,
        preferred-schedule: preferred-schedule,
        duration-weeks: duration-weeks,
        status: "pending",
        created-at: stacks-block-height,
        matched-mentor: none
      })
    (var-set mentorship-request-counter request-id)
    (ok request-id)))

(define-public (accept-mentorship-request (request-id uint))
  (let ((request (unwrap! (map-get? mentorship-requests request-id) ERR_MENTORSHIP_REQUEST_NOT_FOUND))
        (mentor-profile (unwrap! (map-get? mentor-profiles tx-sender) ERR_MENTOR_NOT_FOUND))
        (mentorship-id (+ (var-get mentorship-counter) u1)))
    (asserts! (get active mentor-profile) ERR_NOT_QUALIFIED_MENTOR)
    (asserts! (is-eq (get status request) "pending") ERR_MENTORSHIP_REQUEST_NOT_FOUND)
    (asserts! (< (get current-students mentor-profile) (get max-students mentor-profile)) ERR_NOT_QUALIFIED_MENTOR)
    
    (map-set mentorship-requests
      request-id
      (merge request {status: "matched", matched-mentor: (some tx-sender)}))
    
    (map-set active-mentorships
      mentorship-id
      {
        mentor: tx-sender,
        student: (get student request),
        subject-area: (get subject-area request),
        start-date: stacks-block-height,
        planned-duration: (get duration-weeks request),
        sessions-completed: u0,
        total-hours: u0,
        student-progress: u0,
        mentor-notes: "",
        status: "active",
        request-id: request-id
      })
    
    (map-set mentor-profiles
      tx-sender
      (merge mentor-profile {current-students: (+ (get current-students mentor-profile) u1)}))
    
    (var-set mentorship-counter mentorship-id)
    (ok mentorship-id)))

(define-public (log-mentorship-session
  (mentorship-id uint)
  (duration-minutes uint)
  (topics-covered (string-ascii 200))
  (student-progress-rating uint)
  (session-notes (string-ascii 300)))
  (let ((mentorship (unwrap! (map-get? active-mentorships mentorship-id) ERR_MENTORSHIP_NOT_FOUND))
        (mentor-profile (unwrap! (map-get? mentor-profiles tx-sender) ERR_MENTOR_NOT_FOUND))
        (session-number (+ (get sessions-completed mentorship) u1)))
    (asserts! (is-eq (get mentor mentorship) tx-sender) ERR_NOT_AUTHORIZED)
    (asserts! (is-eq (get status mentorship) "active") ERR_MENTORSHIP_NOT_ACTIVE)
    (asserts! (> duration-minutes u0) ERR_INVALID_SESSION_DURATION)
    (asserts! (<= duration-minutes u480) ERR_INVALID_SESSION_DURATION)
    (asserts! (<= student-progress-rating u10) ERR_INVALID_RATING_VALUE)
    
    (map-set mentorship-sessions
      {mentorship-id: mentorship-id, session-number: session-number}
      {
        date: stacks-block-height,
        duration-minutes: duration-minutes,
        topics-covered: topics-covered,
        student-progress-rating: student-progress-rating,
        session-notes: session-notes,
        completed: true
      })
    
    (map-set active-mentorships
      mentorship-id
      (merge mentorship 
        {
          sessions-completed: session-number,
          total-hours: (+ (get total-hours mentorship) (/ duration-minutes u60)),
          student-progress: (/ (+ (* (get student-progress mentorship) (get sessions-completed mentorship)) student-progress-rating) session-number)
        }))
    
    (map-set mentor-profiles
      tx-sender
      (merge mentor-profile {total-sessions: (+ (get total-sessions mentor-profile) u1)}))
    
    (ok session-number)))

(define-public (complete-mentorship
  (mentorship-id uint)
  (final-notes (string-ascii 500)))
  (let ((mentorship (unwrap! (map-get? active-mentorships mentorship-id) ERR_MENTORSHIP_NOT_FOUND))
        (mentor-profile (unwrap! (map-get? mentor-profiles (get mentor mentorship)) ERR_MENTOR_NOT_FOUND))
        (token-reward (* (get sessions-completed mentorship) u50)))
    (asserts! (or (is-eq tx-sender (get mentor mentorship)) (is-eq tx-sender (get student mentorship))) ERR_NOT_AUTHORIZED)
    (asserts! (is-eq (get status mentorship) "active") ERR_MENTORSHIP_NOT_ACTIVE)
    (asserts! (> (get sessions-completed mentorship) u0) ERR_INVALID_AMOUNT)
    
    (map-set active-mentorships
      mentorship-id
      (merge mentorship {status: "completed", mentor-notes: final-notes}))
    
    (map-set mentor-profiles
      (get mentor mentorship)
      (merge mentor-profile 
        {
          current-students: (- (get current-students mentor-profile) u1),
          tokens-earned: (+ (get tokens-earned mentor-profile) token-reward)
        }))
    
    (try! (as-contract (stx-transfer? token-reward tx-sender (get mentor mentorship))))
    (ok token-reward)))

(define-public (submit-mentor-feedback
  (mentorship-id uint)
  (rating uint)
  (communication-score uint)
  (knowledge-score uint)
  (helpfulness-score uint)
  (feedback-text (string-ascii 300)))
  (let ((mentorship (unwrap! (map-get? active-mentorships mentorship-id) ERR_MENTORSHIP_NOT_FOUND))
        (mentor-address (get mentor mentorship))
        (mentor-profile (unwrap! (map-get? mentor-profiles mentor-address) ERR_MENTOR_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get student mentorship)) ERR_NOT_AUTHORIZED)
    (asserts! (is-eq (get status mentorship) "completed") ERR_MENTORSHIP_NOT_ACTIVE)
    (asserts! (<= rating u10) ERR_INVALID_RATING_VALUE)
    (asserts! (<= communication-score u10) ERR_INVALID_RATING_VALUE)
    (asserts! (<= knowledge-score u10) ERR_INVALID_RATING_VALUE)
    (asserts! (<= helpfulness-score u10) ERR_INVALID_RATING_VALUE)
    (asserts! (is-none (map-get? mentor-feedback {mentorship-id: mentorship-id, reviewer: tx-sender})) ERR_ACHIEVEMENT_ALREADY_CLAIMED)
    
    (map-set mentor-feedback
      {mentorship-id: mentorship-id, reviewer: tx-sender}
      {
        rating: rating,
        communication-score: communication-score,
        knowledge-score: knowledge-score,
        helpfulness-score: helpfulness-score,
        feedback-text: feedback-text,
        submitted-at: stacks-block-height
      })
    
    (let ((new-total-ratings (+ (get total-ratings mentor-profile) u1))
          (current-total-score (* (get average-rating mentor-profile) (get total-ratings mentor-profile)))
          (new-total-score (+ current-total-score rating))
          (new-average (/ new-total-score new-total-ratings)))
      (map-set mentor-profiles
        mentor-address
        (merge mentor-profile 
          {
            total-ratings: new-total-ratings,
            average-rating: new-average
          })))
    (ok true)))

(define-read-only (get-mentor-profile (mentor principal))
  (map-get? mentor-profiles mentor))

(define-read-only (get-mentorship-request (request-id uint))
  (map-get? mentorship-requests request-id))

(define-read-only (get-active-mentorship (mentorship-id uint))
  (map-get? active-mentorships mentorship-id))

(define-read-only (get-mentorship-session (mentorship-id uint) (session-number uint))
  (map-get? mentorship-sessions {mentorship-id: mentorship-id, session-number: session-number}))

(define-read-only (get-mentor-feedback (mentorship-id uint) (reviewer principal))
  (map-get? mentor-feedback {mentorship-id: mentorship-id, reviewer: reviewer}))

(define-read-only (get-mentorship-request-counter)
  (var-get mentorship-request-counter))

(define-read-only (get-mentorship-counter)
  (var-get mentorship-counter))











