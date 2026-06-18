# Product Requirement Document (PRD)

## Module Focus: Peer Accountability & Guardian Engine (PAGE)

### 1. The Core Concept

A co-living management system built on mutual agreement, gamified accountability, and rotating administrative power. Instead of a permanent "parent" admin, roommates rotate the **Guardian** role automatically to enforce house rules, grade chores, and manage the **Housemate Score** system which directly impacts personal perks.

### 2. Functional Requirements

#### A. The House Agreement & Planning Phase

* **Task Value Calibration:** At the start of a cycle (weekly/monthly), the app triggers a "Planning Phase." Roommates must collectively agree on and assign fixed point values to tasks based on difficulty (e.g., Deep Cleaning Bathroom = 50 pts; Taking out Trash = 10 pts).
* **Privilege Threshold Configuration:** Roommates can toggle default privilege templates on/off and customize the **Housemate Score** thresholds required to unlock/lock them.

#### B. The Rotating Guardian System

* **Automated Rotation:** The Guardian role passes automatically and sequentially (e.g., Roommate A $\rightarrow$ Roommate B $\rightarrow$ Roommate C) at the end of every cycle.
* **Equality Constraint:** The rotation schedule is strictly fixed. The Housemate Score *cannot* alter the rotation order, ensuring equal burden-sharing.
* **The Guardian Dashboard:** The active Guardian receives a dedicated view to monitor active tasks, review submissions, and manage the house scoreboards.

#### C. Score & Task Lifecycle Logic

* **Fixed Point Penalties:** If a task is failed or rejected, the assigned point value of that task is automatically deducted from the assignee’s Housemate Score.
* **Review Verification Loop:** When a roommate marks a task "Done," it goes to the Guardian for review.
* **Approval:** Roommate receives the fixed task points. *Optional:* The Guardian can award a predefined **Bonus Point** modifier for exemplary work.
* **Rejection:** The Guardian **must** provide a mandatory text justification explaining why the task failed. The task reverts to "Active" status.

### 3. Core User Flow: The Peer Verification Loop

This flow outlines how the Guardian acts as the system buffer, preventing direct arguments between housemates.

```
[Roommate completes task & uploads proof]
                   │
                   ▼
       [Guardian Reviews Task]
                   │
         ┌─────────┴─────────┐
         ▼                   ▼
    [APPROVE]            [REJECT]
         │                   │
         │                   └──► *Mandatory:* Input Justification
         │                        (e.g., "Missed the recycling bin")
         │                   │
         │                   └──► Task returns to Active
         │                   │
         │                   └──► Deduct Fixed Points from Score
         │
         ├──► Add Fixed Points to Score
         │
         └──► Optional: Add Guardian Bonus (+5 pts)
                 │
                 ▼
[System updates Housemate Score -> Recalculates Privilege Tiers]

```

### 4. Privilege Tier Management (Feature Specs)

The system automatically manages real-world and digital perks based on the live Housemate Score matrix.

| Privilege Type | Example Perk (Customizable Templates) | Score Impact |
| --- | --- | --- |
| **Real-World Asset** | Master Parking Spot / Choice of Room Amenities | High Score Threshold |
| **In-App Power** | "Chore Pass" (Veto/Swap 1 chore this month) | Premium Tier Perk |
| **Social / House** | Exempt from next emergency house cleaning sweep | Mid-High Tier Perk |
| **Restriction** | Locked out of choosing preferred chore slots next cycle | Low Score Penalty |

## Module Focus: Onboarding & House Setup Flow

### 1. The House Initialization Sequence

The onboarding flow is divided into three distinct states: **Creation**, **The Ceremony (Drafting)**, and **Activation**.

```
[Roommate A Creates House] ──► [Generates Invite Link/QR] ──► [Roommates B & C Join]
                                                                     │
                                                                     ▼
[System Activates -> First Guardian Selected Randomly] ◄── [Everyone Hits "Accept"] ◄── [Async Collaborative Ceremony]

```

### 2. Functional Requirements

#### A. House Creation & Invitation

* **Host Generation:** Any single user can initiate a "New House" profile, defining basic details (e.g., Apartment Name).
* **Dynamic Invite Vector:** The host generates a unique invitation link or QR code.
* **Passive Lobby State:** Joining roommates enter a read-only "Lobby" until the host or another roommate officially triggers the Ceremony Phase.

#### B. The Async Ceremony Phase (Drafting State)

* **Democratic Editing:** Any roommate in the house can add, edit, or delete proposed chores, point values, and privilege configurations. Changes sync in real-time across all devices.
* **Unanimous Consensus Gate:** The house cannot go active until **100% of joined roommates** click the "Accept Rules" button.
* **Draft Mutability:** If a roommate edits a rule *after* another roommate has already clicked "Accept," all previous accepts are revoked, forcing everyone to review and accept the new changes.

#### C. Activation & The First Cycle

* **The Random Crown:** Upon the final "Accept" vote, the system automatically and randomly selects the first Guardian from the entire roster.
* **Cycle Lock:** The agreed-upon tasks and points are locked for the duration of that cycle (e.g., 1 week or 1 month).

#### D. The "Late Roommate" Protocol (Edge Case)

* **Mid-Cycle Integration:** If a new roommate joins via invite link while a cycle is already active, they are added to the roster immediately.
* **Rule Inheritance:** The late roommate must follow the existing rules, task point values, and privilege thresholds. They cannot trigger a new Ceremony Phase.
* **Rotation Queue:** They are appended to the *end* of the current automatic Guardian rotation queue and will participate in the next scheduled Ceremony Phase when the current cycle ends.

## Module Focus: Cycle Transition & Handover Ritual

### 1. Score & Privilege Dynamics

* **Lifetime Housemate Credit Score:** Scores do *not* reset to zero at the end of a cycle. They carry over continuously. A roommate's score is a rolling reflection of their historical reliability.
* **Real-Time Privilege State Machine:** The app constantly monitors the live Housemate Score. The moment a score crosses a predefined threshold (up or down), the corresponding privilege is instantly unlocked or locked, and a push notification is sent to the household (e.g., *"Roommate B's score dropped below 80. Master Parking Spot privilege is now LOCKED."*).

### 2. The Handover Ritual Flow

When a cycle reaches its time limit, the app halts standard operations and enters the **Handover Phase**.

```
[Cycle Timer Expires]
          │
          ▼
[App enters "Handover Phase"] ──► (Locks active chore creation)
          │
          ▼
[Step 1: Outgoing Guardian Closeout] ──► (Must approve/reject all pending submissions)
          │
          ▼
[Step 2: The Household Retrospective] ──► (App displays cycle stats: Most improved, MVP, Chore dodger)
          │
          ▼
[Step 3: New Ceremony Phase Triggered] ──► (Roommates discuss and adapt point values for next cycle)
          │
          ▼
[Everyone Hits "Accept"] ──► [Crown Passes to Next Scheduled Guardian & New Cycle Begins]

```

### 3. Functional Requirements

#### A. Phase Triggering & Locking

* **Hard Stop:** When the cycle duration ends, the app restricts the creation of new chores and pauses standard score tracking.
* **Pending Task Clean-up:** The outgoing Guardian is prompted to clear the queue. They must make a final approval or rejection decision on any tasks marked "Done" but not yet reviewed.

#### B. The Retrospective Screen

* **Data Visualization:** Once the queue is clear, the app generates a "Household Retro" summary screen visible to all.
* **Gamified Highlights:** It highlights trends from the cycle to facilitate the real-world discussion (e.g., Who gained the most points, who lost the most points, which chores were neglected the most).

#### C. Point Renegotiation & Token Passing

* **Transition to Ceremony:** From the Retro screen, the outgoing Guardian triggers the next "Ceremony Phase" (re-using the async collaborative setup code).
* **Point Calibration:** Roommates can adjust chore weights based on the retro (e.g., *"We realized deep cleaning the kitchen takes way too long; let's change it from 30 points to 50 points for the next cycle"*).
* **Unanimous Gate & Handover:** Once 100% of roommates hit "Accept" on the calibrated rules, the cycle officially rolls over. The system automatically transfers the Guardian status to the next sequential roommate in the queue.