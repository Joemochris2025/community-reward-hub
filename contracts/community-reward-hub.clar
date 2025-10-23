;; ------------------------------------------------------------
;; community-reward-hub.clar
;; Purpose: A decentralized reward distribution system for community contributors
;; Language: Clarity
;; Network: Stacks Blockchain
;; ------------------------------------------------------------

;; ------------------------------------------------------------
;; SECTION 1: DATA DEFINITIONS
;; ------------------------------------------------------------

(define-data-var admin principal tx-sender)
(define-data-var total-tasks uint u0)
(define-data-var reward-pool uint u0)

;; Each task has an ID, creator, reward amount, and completion status
(define-map tasks
  { id: uint }
  {
    title: (string-ascii 128),
    description: (string-ascii 512),
    reward: uint,
    assignee: principal,
    completed: bool
  }
)

;; Tracks users who have received rewards
(define-map user-rewards
  { user: principal }
  { total-earned: uint }
)

;; ------------------------------------------------------------
;; SECTION 2: CONSTANTS AND ERRORS
;; ------------------------------------------------------------

(define-constant ERR-NOT-ADMIN (err u401))
(define-constant ERR-TASK-NOT-FOUND (err u404))
(define-constant ERR-ALREADY-COMPLETED (err u405))
(define-constant ERR-NO-REWARD (err u406))

;; ------------------------------------------------------------
;; SECTION 3: ADMIN FUNCTIONS
;; ------------------------------------------------------------

;; 3.1 Add STX to the reward pool
(define-public (fund-reward-pool (amount uint))
  (begin
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set reward-pool (+ (var-get reward-pool) amount))
    (ok {funded: amount, total-pool: (var-get reward-pool)})
  )
)

;; 3.2 Create a new community task
(define-public (create-task (title (string-ascii 128)) (description (string-ascii 512)) (reward uint) (assignee principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-ADMIN)
    (let ((next-id (+ (var-get total-tasks) u1)))
      (map-set tasks { id: next-id }
        {
          title: title,
          description: description,
          reward: reward,
          assignee: assignee,
          completed: false
        })
      (var-set total-tasks next-id)
      ;; Emit event using print instead of emit-event
      (print {
        event: "task-created",
        id: next-id,
        creator: tx-sender,
        reward: reward
      })
      (ok {task-id: next-id, reward: reward})
    )
  )
)

;; ------------------------------------------------------------
;; SECTION 4: PUBLIC FUNCTIONS
;; ------------------------------------------------------------

;; 4.1 Mark a task as completed and send reward
(define-public (complete-task (task-id uint))
  (match (map-get? tasks { id: task-id })
    task
      (begin
        (asserts! (is-eq tx-sender (get assignee task)) ERR-ALREADY-COMPLETED)
        (asserts! (not (get completed task)) ERR-ALREADY-COMPLETED)
        (let ((reward (get reward task)))
          (asserts! (>= (var-get reward-pool) reward) ERR-NO-REWARD)
          ;; Transfer from contract to user
          (try! (as-contract (stx-transfer? reward tx-sender (get assignee task))))
          (map-set tasks { id: task-id }
            (merge task { completed: true }))
          (var-set reward-pool (- (var-get reward-pool) reward))
          (let ((previous (default-to u0 (get total-earned (map-get? user-rewards { user: tx-sender })))))
            (map-set user-rewards { user: tx-sender } { total-earned: (+ previous reward) }))
          ;; Emit events using print instead of emit-event
          (print {
            event: "task-completed",
            id: task-id,
            assignee: tx-sender,
            reward: reward
          })
          (print {
            event: "reward-distributed",
            assignee: tx-sender,
            amount: reward
          })
          (ok {task-id: task-id, reward: reward, status: "completed"})
        )
      )
    ERR-TASK-NOT-FOUND)
)

;; ------------------------------------------------------------
;; SECTION 5: READ-ONLY FUNCTIONS
;; ------------------------------------------------------------

;; 5.1 Get task details
(define-read-only (get-task (task-id uint))
  (match (map-get? tasks { id: task-id })
    task
      (ok {
        id: task-id,
        title: (get title task),
        description: (get description task),
        reward: (get reward task),
        assignee: (get assignee task),
        completed: (get completed task)
      })
    ERR-TASK-NOT-FOUND)
)

;; 5.2 Get user reward history
(define-read-only (get-user-rewards (user principal))
  (default-to u0 (get total-earned (map-get? user-rewards { user: user })))
)

;; 5.3 Get total available reward pool
(define-read-only (get-reward-pool)
  (ok (var-get reward-pool))
)

;; 5.4 Get total number of tasks created
(define-read-only (get-total-tasks)
  (ok (var-get total-tasks))
)
