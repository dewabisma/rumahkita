# rumahkita — Design Guidance & System Document

This document serves as the single source of truth for the visual identity, user experience design, and interface patterns for `rumahkita`. It translates a complex, decentralized peer-to-peer architecture into a warm, low-stress, and nurturing digital home ecosystem.

---

## 1. Brand Personality & Tone

* **The Persona (The Nurturing Companion):** The app behaves like a shared household pet. It is warm, comforting, and honest. It never scolds or assigns blame; it simply reflects the health of the home based on how well the roommates nurture it.
* **Visual Philosophy:** Soft, organic, and highly spacious. Avoid sharp corporate corners and clinical data dashboards. Utilize generous rounded corners (`border-radius: 16px` or higher) and fluid, relaxing layout transitions to lower user anxiety.
* **Micro-copy Tone:** Communal and collaborative.
* *Instead of:* "Task Overdue" $\rightarrow$ *Use:* "This chore needs a little love."
* *Instead of:* "Syncing Database" $\rightarrow$ *Use:* "Bringing everyone into harmony..."



---

## 2. Typography Hierarchy (Free Google Fonts)

To ensure the interface feels safe, clear, and distinct, `rumahkita` pairs two Google Fonts that balance a approachable aesthetic with reliable scannability.

### Heading Font: **Fredoka** (or **Quicksand**)

* **Style:** Rounded, organic terminals.
* **Usage:** Large titles, house naming screens, score callouts, and primary navigation headers.
* **Why:** Eliminates aggressive structural geometry, instantly signaling a friendly, gamified environment.

### Body Font: **Nunito**

* **Style:** Highly legible sans-serif with subtle rounding.
* **Usage:** Chore descriptions, justification notes, system log texts, and settings menus.
* **Why:** Inherits the soft aesthetic of the headers while maintaining exceptional clarity for rendering dense, replicated data tables.

---

## 3. Color Strategy & State Signifiers

`rumahkita` completely rejects anxiety-inducing, high-contrast alert colors (such as harsh neon reds or critical corporate blues). Instead, it maps system states to an earthy, comforting pastel palette that mirrors a changing natural ecosystem.

### The Palette Tokens

| Token Name | Hex/Color Style | System Meaning / Usage |
| --- | --- | --- |
| **Cozy Linen** | Warm Off-White / Pale Beige | Main application backgrounds; reduces eye strain. |
| **Sprout Green** | Soft Sage / Pastel Mint | Success, points earned, tasks approved, and cycle renewals. |
| **Sunny Butter** | Creamy Yellow / Soft Gold | Active/Open chores, items in drafting, and text diff changes. |
| **Drooping Leaf Brown** | Muted Terracotta / Autumn Brown | Replaces "Danger Red." Used for point deductions, rejections, or locked perks. |

### The Companion Pet Ecosystem

The color tokens tie directly into the emotional state of the household pet companion illustration on the main dashboard:

* **Thriving State:** When scores are high, the UI utilizes **Sprout Green** accents. The pet appears happy and energetic.
* **Rest State:** During planning or low-activity phases, the UI shifts to **Sunny Butter**. The pet is shown resting or napping contentedly.
* **Tired State:** When tasks are rejected or scores drop below key thresholds, accents shift to **Drooping Leaf Brown**. The pet looks slightly droopy or sleepy, sending a gentle, non-verbal cue that the house needs collective attention.

---

## 4. The Rotating Guardian UI

The weekly/monthly shift in administrative power must not make a roommate feel like a strict manager. The design treats the role as a temporary "helper duty".

### Visual Adjustments

* **The Companion’s Uniform:** When a user is the active Guardian, the dashboard pet gains a subtle accessory, such as a tiny inspector’s cap, a small satchel, or a helper badge.
* **The Passive Roster View:** For non-Guardian roommates, the dashboard shows the pet hanging out next to a small framed portrait of the current Guardian, keeping accountability clear without shifting the base UI.

### The Verification Loop Components

When reviewing completed chores, the Guardian is presented with playful, tactile interaction tools:

* **The Approval Button:** Styled as a watering can or fruit treat (triggering a **Sprout Green** animation).
* **The Rejection Button:** Shaped like a small pencil, which smoothly slides open a cozy, inline text container requiring mandatory justification notes.

---

## 5. Local-First & Connection UX Patterns

Because the app is built on a decentralized Tailscale network, offline states are entirely normal and expected, not treated as system errors.

### The "Solo House" Metaphor

* **Connected View:** The top header displays a minimalist garden patch or house. Small, soft circular avatars of online roommates are visible hanging out in the yard.
* **Isolated View (Offline):** The other roommates fade away. The pet is shown sitting peacefully on the porch alone with an inline message: *"Holding down the fort solo right now. Your updates are safe and tucked away, ready to share when the pack returns."*

### Replicated Data Markers

* **The Tucked-Away Seed:** When a change is made offline (e.g., scoring changes, claiming a chore, or casting a vote), a tiny icon of a closed chest or a sleeping seed appears next to the row.
* **The Unfurl:** As soon as the Tailscale mesh connects and the CRDT engine completes its merge, the seed quickly sprouts and fades away, indicating the data is safely uniform across the household.

---

## 6. The Ceremony Phase & Face-to-Face UX

The app acknowledges that real-world rule changes and point calibrations happen around a physical kitchen table or over text chats, not via complex remote workflows. The UI acts purely as a quiet, clear ledger.

* **The Silent Reset:** When a rule or point value is altered mid-ceremony, all unanimous checkmarks clear without loud pop-ups or alert sounds.
* **The Inline Delta:** The modified task card transitions to a soft **Sunny Butter yellow** backdrop, displaying a clean text-based difference marker directly on its face (e.g., *“Points updated: 30 $\rightarrow$ 50”*). This allows roommates looking at the screen together to instantly verify the change and re-tap "Accept".

---

## 7. Member Removal & Eviction UX

To respect the privacy, transparency, and gravity of a roommate leaving the household, the eviction and self-removal flows entirely strip away the "gamified pet" elements.

* **Strict Neutrality:** The process is treated strictly as a secure network action. There are no emotional graphics, waving animations, or conversational pet micro-copy.
* **The Audit Ledger:** The proposal progress, voting threshold metrics, and final disconnect events are rendered as clean, objective text logs within the historical ledger.
* **Terminal Execution:** Once a proposal transitions to `EXECUTED` and the Tailscale API key is invalidated, the node's record transitions smoothly to an inactive, grayed-out state on the historical roster—clean, respectful, and final.