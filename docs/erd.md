## Tailscale P2P Network Flow

Instead of a centralized server, the house creator acts as the initial network gateway by generating an ephemeral/reusable Tailscale auth key.

```
[Roommate A: Creates House] ──► [Generates Tailscale Auth Key + House Metadata]
                                                    │
                                                    ▼
                                      [Encodes into Join QR Code]
                                                    │
                                                    ▼
[Roommates B & C: Scan QR] ──► [Device registers to Tailnet via Auth Key]
                                                    │
                                                    ▼
                       [Direct P2P Sync established over Tailscale Mesh]
                       [CRDT Engine merges local database replicas]

```

---

## Relational Schema to CRDT-Friendly Schema

In a pure CRDT/P2P system, standard auto-incrementing integer IDs ($1, 2, 3...$) will completely break your app because two offline devices will assign the same number to different chores.

### Critical Data Schema Adjustments

1. **Strict UUIDs / ULIDs:** Every single primary key *must* use globally unique identifiers generated on the device.
2. **State Vectors / LWW (Last-Write-Wins):** To handle your requirement where roommates can sort things out if a conflict happens, we will include a `last_modified_device_id` and a vector clock or millisecond timestamp on mutable fields.
3. **House Profiles vs. Network Profiles:** A user's profile is tied to their Tailscale machine identity, but they store a local `nickname` string specific to each house they populate.

Here is how your database entities morph into a distributed schema:

### Updated Distributed Entities

#### Table: `Local_User_Settings` (Device Specific)

*This table only exists on the local device and does not sync over the network.*

* `device_id` (PK, UUID) — Unique string identifying this phone.
* `tailscale_node_id` (Varchar) — The device’s identity on the tailnet.

#### Table: `Housemates_Sync` (CRDT Replicated)

Replaces the old `Users` and `House_Members` tables. This syncs across all peers.

* `member_id` (PK, UUID)
* `tailscale_user_id` (Varchar) — The immutable network identifier.
* `tailscale_node_key` (Varchar, Unique) — The unique identifier assigned by Tailscale to that specific physical device.
* `house_id` (UUID)
* `nickname` (Varchar) — The display name chosen for this specific house.
* `lifetime_score` (Integer) — CRDT PN-Counter (Positive-Negative Counter) so score additions/subtractions merge safely from different devices.
* `rotation_order_index` (Integer)
* `last_updated_timestamp` (BigInt)

#### Table: `Removal_Proposals_Sync` (CRDT Replicated, Append-Only)

Tracks the lifecycle of an eviction or a self-removal request. Part of the 4-stage removal process.

* `proposal_id` (PK, UUID)
* `house_id` (UUID)
* `target_member_id` (UUID) — The member being proposed for removal.
* `proposer_member_id` (UUID, Nullable) — The member initiating the vote (`Null` if it is a voluntary self-removal).
* `type` (Enum: `'eviction'`, `'self_removal'`)
* `status` (Enum: `'proposed'`, `'approved'`, `'ready_to_execute'`, `'executed'`, `'cancelled'`, `'rejected'`) — Handled via MV-CRDT (Multi-Value) or LWW to ensure phase transitions merge cleanly.
* `created_at` (BigInt) — Timestamp vector.
* `updated_at` (BigInt)

#### Table: `Proposal_Votes_Sync` (CRDT Replicated, Append-Only)

Tracks independent votes cast by roommates. Devices sync these rows over Tailscale; the app locally calculates whether the 50% majority threshold has been crossed.

* `vote_id` (PK, UUID)
* `proposal_id` (FK → `Removal_Proposals_Sync`)
* `voter_member_id` (FK → `Housemates_Sync`)
* `vote_cast` (Boolean) — `True` for Yes, `False` for No.
* `timestamp` (BigInt)
* **Unique constraint:** `(proposal_id, voter_member_id)` — Prevents a roommate from voting twice on the same proposal.

#### Table: `Cycles_Sync` (CRDT Replicated)

* `cycle_id` (PK, UUID)
* `house_id` (UUID)
* `active_guardian_member_id` (UUID)
* `status` (Enum: `'drafting'`, `'active'`, `'completed'`) — Handled via MV-CRDT (Multi-Value) or LWW to ensure the phase switches cleanly.
* `ceremony_signoffs` (JSON/Map) — A map of `member_id` $\rightarrow$ `Boolean` tracking who clicked "Accept". If someone modifies the rules, the local device clears this map and broadcasts the update.

#### Table: `Tasks_Sync` (CRDT Replicated)

Combines the catalog and instances into a flatter structure optimized for document/key-value sync or local SQLite with Yjs.

* `task_id` (PK, UUID)
* `cycle_id` (UUID)
* `title` (Varchar)
* `negotiated_points` (Integer)
* `status` (Enum: `'open'`, `'claimed'`, `'pending_review'`, `'approved'`, `'rejected'`)
* `claimed_by_member_ids` (Array/Set) — A CRDT Grow-Only Set. Multiple people can append their ID here to self-claim the task.

#### Table: `Audit_Log_Append_Only` (CRDT Replicated)

Because you want an accurate history of *why* and *when* tasks were rejected, this table is **strictly grow-only**. Devices never edit old rows; they only sync new logs.

* `log_id` (PK, UUID)
* `task_id` (UUID)
* `actor_member_id` (UUID)
* `action` (Varchar: e.g., `'claim'`, `'reject'`, `'approve'`)
* `justification_notes` (Text, Nullable)
* `timestamp` (BigInt)

---

### How Data Synchronization Works in Your App

Because you chose a **CRDT-driven local-first architecture**, the mathematical operation we defined earlier happens completely decentralized:

* **Score Changes:** When a task is approved or rejected, the local device calculates the split points based on the size of the `claimed_by_member_ids` set. It then registers a `+X` or `-X` operation on the `lifetime_score` PN-counter. When the devices reconnect via Tailscale, the counters add up identically across all devices.
* **The "Ceremony" Reset:** If a roommate changes a chore's point value while offline, the CRDT register updates the points and automatically empties the `ceremony_signoffs` map. When that syncs to other roommates, their screens will instantly update to show the new points and show that the "Accept" checkmark has been revoked.
