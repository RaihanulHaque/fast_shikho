# Shikho — AI Study Companion

**Software Requirements Specification**

*Confidential · Internal*

Eleventh-hour exam prep for Bangladeshi science students (SSC · HSC · Admission)

| | |
|---|---|
| **Version** | 2.0 |
| **Stack** | Django · Flutter · S3 · Gemini Flash |
| **Audience** | Class 9–12 + Admission |
| **Scope** | MVP · Phase 1 |

---

## Section 1: Product Overview

A session-based, document-driven AI study tool. Students upload handwritten notes or PDFs and receive a structured, AI-generated study package — no typing, no searching.

| | | |
|---|---|---|
| **4** | Feature modules per session | Key Points, Practice Examples, Top Questions, Quick Test |
| **6** | Max pages per upload | |
| **2** | Gemini API calls per session | 1 text (always) + 1 batch image (conditional) |

### Core Value Proposition

Students upload notes at 11 PM and within seconds receive key points, practice problems, predicted exam questions, and a quick self-test — all derived exclusively from their own material. Zero friction, zero text entry, no pre-seeded question banks.

### What Shikho Is

- Document-driven, session-scoped AI study assistant
- Structured JSON output from Gemini Flash
- Adaptive output — missing sections omitted, not blank
- Progress tracking via Quick Test scores
- Points-based reward system for active problem-solving
- Offline-friendly session history

### What Shikho Is Not

- Not a general Q&A chatbot
- Not a live tutoring service
- Not a pre-curated question bank
- No free-text input from user (upload only)
- No real-time multi-session concurrency (MVP)

### Supported Subjects *(AI-detected, not predefined)*

Gemini infers subject from the document and tailors output accordingly. Expected subjects: Physics, Chemistry, Biology, Mathematics, Bangla, English, ICT, Higher Math, Agricultural Science.

> **Class level is not inferred** — it is read from the user's registered profile (`class_level` field) and injected directly into the Gemini system prompt. This ensures exam board, difficulty, and question sources always match the student's actual level regardless of document content.

---

## Section 2: Users & Authentication

Student-only platform. No teacher or admin-facing interface in MVP. Authentication is OTP-based via Bangladeshi phone numbers.

### Registration Fields

| Field | Type | Notes | Required |
|-------|------|-------|----------|
| `full_name` | String | Display name, min 2 chars | Yes |
| `phone_number` | BD Mobile (01X) | Used for OTP. Unique per account. | Yes |
| `class_level` | Enum | SSC / HSC / Admission | Yes |
| `password` | String | Min 8 chars, hashed (bcrypt/argon2) | Yes |
| `otp_code` | 6-digit | Sent to phone, expires in 5 min | Yes |

### OTP Flow

1. **Request OTP** — User enters phone number → backend sends 6-digit OTP via SMS gateway
2. **Verify OTP** — OTP validated, expires in 5 min, max 3 attempts before lockout
3. **Complete Profile** — On successful OTP: set name, class, password. JWT issued.
4. **Login** — Phone + password → JWT access token (7d) + refresh token (30d)

### Auth Tokens

| Token | Type | Expiry | Storage |
|-------|------|--------|---------|
| Access | JWT (RS256) | 7 days | flutter_secure_storage |
| Refresh | Opaque (hashed in DB) | 30 days | flutter_secure_storage |

### Class Levels

- **SSC** — Class 9 & 10
- **HSC** — Class 11 & 12
- **Admission** — University entrance prep

> `class_level` is editable from profile settings. It influences UI labels and future personalization but does not gate Gemini content in MVP.

---

## Section 3: Session Model

A session is the core unit of the product. One session = one document upload = one AI-generated study package. Sessions persist indefinitely and are browsable like chat history.

### Session Lifecycle

1. **Session Created** — User taps "+ New Session" → session created with status `pending`. Temporary session ID issued immediately.
2. **Document Upload** — User uploads JPG/PNG images or PDF (max 6 pages). File sent to S3. Backend validates page count.
3. **AI Processing (Text)** — Backend sends images to Gemini (text call). Status becomes `processing`.
4. **Partial Result Ready** — Gemini text response parsed and stored. Key Points, Top Questions, and Quick Test are immediately available. Status → `partial`. App is notified — Flutter renders tabs 1, 3, and 4. Practice tab shows a loading state.
5. **Diagram Queue** — Backend enqueues image generation task (Celery). Up to 2 diagram prompts (from practice problems 0 and 1) are submitted as individual `generate_content` calls, run concurrently via thread pool.
6. **Practice Ready** — Diagrams generated and uploaded to S3. URLs injected into `practice_examples`. Status → `complete`. App is notified — Flutter renders the Practice tab with full content including diagrams.
7. **User Views Results** — All 4 tabs available. Quick Test scores written back on submission.

### Upload Constraints

- Max 6 pages or images per session — enforced client-side and server-side.
- Accepted formats: JPG, PNG, PDF — PDF converted to images server-side before sending to Gemini.
- No per-day upload caps in MVP. Each session is independent.

### Session History

- Home screen, sorted by `created_at` descending
- Each row: auto-generated title, date, status badge
- **Rename:** Long-press or swipe to reveal rename option
- **Delete:** Swipe-to-delete with confirm dialog. Removes session + S3 file.
- Title generated by Gemini in the first API response (not a second call)

### Session Status States

| Status | Meaning | UI |
|--------|---------|-----|
| `pending` | Created, awaiting upload | Empty state placeholder |
| `uploaded` | File received, queued | Spinner / "Analyzing..." |
| `processing` | Gemini text call in flight | Animated progress indicator |
| `partial` | Text data ready; diagram generation queued | Tabs 1, 3, 4 visible. Practice tab shows loading skeleton. |
| `complete` | All data ready including diagrams | All 4 tabs fully visible |
| `failed` | Gemini error or timeout | Error state + retry button |

> **Note:** If no practice problems are flagged for diagrams, status skips `partial` and goes directly from `processing` → `complete`.

---

## Section 4: Feature Modules

Four tab-based modules rendered from the AI JSON response. Each module is adaptive — content varies by subject.

---

### Module 1 — Key Points *(Adaptive sub-sections)*

Gemini returns only the sub-sections relevant to the subject. Flutter renders only what is returned.

| Sub-section | Field name | Description | Subjects |
|-------------|-----------|-------------|---------|
| What to Learn | `what_to_learn` | Concise list of topics and concepts essential for exam prep. Highlights frequently tested areas. 3–8 items. | All |
| Quick Summary | `quick_summary` | **Single flowing paragraph** (3–5 sentences) summarising the entire document. Not a list. | All |
| Shortcut Techniques | `shortcut_techniques` | 1–3 quick exam tricks: mnemonics, shortcut formulas, pattern-recognition tips. | All |
| Important Points QA | `important_points_qa` | 5–7 interactive QA items (see format below). Min 1 of each QA type. | All |
| Easy Lessons | `easy_lessons` | Simplified plain-language explanations of hard concepts only. | All |
| Math & Logic | `math_and_logic` | Formulas with step-by-step worked examples. **Null for non-math subjects.** | Physics, Chemistry, Math, Higher Math, ICT |

> **Removed from v1:** `quick_summaries` (was a list of objects) and `exam_prep_notes` — both replaced by the fields above.

#### Important Points QA Format

Each item in `important_points_qa` has a `type` field that determines its structure. Flutter must switch rendering based on `type`.

| `type` | Fields present | UI |
|--------|---------------|-----|
| `mcq` | `question`, `options` (A/B/C/D), `correct_option`, `explanation` | 4-choice radio buttons |
| `true_false` | `question`, `correct_bool` (boolean), `explanation` | True / False toggle |
| `fill_in_the_blanks` | `question` (contains `___`), `blank_answer`, `explanation` | Text input with blank |
| `connecting_answer` | `left_items` (list), `right_items` (shuffled list), `correct_matches` (list of `{left, right}` pairs), `explanation` | Drag-and-match UI |

All types include `explanation`. Fields for other types are `null`.

---

### Module 2 — Practice Examples *(8 problems)*

Step-by-step solved problems derived from the uploaded document.

- 8 problems generated per session
- First 4 shown by default; "Show more" reveals remaining 4
- Each problem: question → step-by-step solution → final answer
- Expandable step explanation (collapsible accordion)

#### Math vs Non-Math Behaviour

Each problem has an `is_math` boolean set by Gemini.

| `is_math` | Student interaction |
|-----------|-------------------|
| `true` | Student can **write their own answer** before revealing the solution. Write-answer input shown. |
| `false` | No write-answer input. Student taps "View Answer" to reveal solution directly. |

Both types support "View Answer" (reveals steps + final answer). Math problems additionally allow the student to attempt before viewing.

#### Points Unlock

Answers, solving steps, and diagrams in Practice Examples are locked by default. Students unlock them using **reward points** (see Section 4 — Points System).

- Attempting a math problem before viewing answer = earns points
- Spending points = reveals answer + steps for any problem

#### Diagram Generation (problems 1 and 2 only)

Gemini evaluates whether each of the first two problems benefits from a visual diagram. If so, it sets a flag and writes an image generation prompt inline in the JSON response. The backend then submits those prompts to the batch image API (`gemini-2.5-flash-image`) as a second API call. Generated images are stored in S3 and returned alongside the problem.

Diagram-worthy problems: vector diagrams, free-body diagrams, electric circuits, chemical apparatus, biological structures, geometric constructions, ray diagrams, labeled graphs. Pure calculation or text-based problems are not flagged.

---

### Module 3 — Top Questions *(AI-predicted exam questions)*

AI-predicted exam questions sourced from relevant board exams, ranked by difficulty.

- 10–18 questions per session (no hard cap enforced in schema — count driven by Gemini)
- Sorted: easy → medium → hard
- Each question has a `source` field indicating the exam it is from or modelled after (e.g. `"SSC Dhaka Board 2022"`, `"DU Admission 2023"`)
- Source selection is driven by `class_level_hint`:
  - `SSC` → SSC board exams
  - `HSC` → HSC board exams (hard questions may include admission-level)
  - `Admission` → university admission exams (DU, BUET, CUET, medical)
- All questions include `answer` or structured answer fields + `explanation`

#### Question Types

| `question_type` | Description | Answer structure |
|----------------|-------------|-----------------|
| `short_answer` | 1–3 sentence factual recall | `answer`: string paragraph |
| `creative` | Analysis, comparison, application — HSC style | `answer`: string paragraph |
| `mcq` | 4-option multiple choice | `options` (A/B/C/D), `correct_option` |
| `broad_answer` | Student selects which of 4–6 points are needed to answer | `selectable_points`: list of `{point, is_correct}` |

All types include `explanation`.

#### Points Unlock

Top Question answers are locked by default. Students spend reward points to reveal the answer and explanation (see Section 4 — Points System).

---

### Module 4 — Quick Test *(Score tracked)*

MCQ self-assessment derived from the document.

- 8 MCQs per session
- First 4 shown; "Load more" reveals next 4
- Each MCQ: `question`, `options` (A–D), `correct_answer`, optional `explanation`
- Correct answer hidden until submission
- Score (X/8) saved to DB with timestamp
- Multiple attempts allowed; all scores stored for progress graph

---

### Points System *(Reward & Unlock)*

Points incentivise active problem-solving. This is a **product/frontend feature** — Gemini output is unchanged. No points fields in the AI JSON.

#### Earning Points

| Action | Points earned |
|--------|--------------|
| Attempting a math practice problem before viewing answer | +10 pts |
| Completing Quick Test | +5 pts |
| Uploading a new session | +2 pts |

#### Spending Points

| Unlock | Cost |
|--------|------|
| View answer + steps for one practice problem | 5 pts |
| View answer for one top question | 3 pts |
| View diagram for one practice problem | 2 pts |

> **Backend note:** Point balances and transactions stored in `user_points` and `point_transactions` tables (see Section 6). All unlock checks happen server-side — never trust the client. Deduct points atomically with the unlock event.

---

## Section 5: AI Pipeline

Two Gemini API calls per session. Structured JSON output. The second call (image generation) only fires when Gemini flags one or both of the first two practice problems as diagram-worthy. The two calls are decoupled — Call 1 result is returned to the app immediately while Call 2 runs in the background.

### Models

| Model | Role |
|-------|------|
| `gemini-3-flash-preview` | Call 1 — full study package (text) |
| `gemini-2.5-flash-image` | Call 2 — individual diagram generation (conditional, up to 2 calls) |

### Call 1 — Study Package

Single `generate_content` call with document images attached via `types.Part.from_bytes()`. Returns structured JSON validated against the Pydantic schema.

**Schema passed as:** `response_schema=StudyPackage` (Pydantic class directly — SDK handles conversion). Do **not** pass a manually constructed JSON schema dict; Gemini rejects asymmetric `minItems/maxItems` constraints on complex object arrays.

**Class level is injected into the system prompt** — the user's registered `class_level` (SSC / HSC / Admission) is passed explicitly and Gemini is instructed not to override it. This prevents misidentification when document content looks more advanced or basic than the student's actual level (e.g. an SSC student with dense notes being classified as HSC). Gemini still infers the subject from document content — only the class level is fixed.

**Gemini also decides diagram worthiness inline** — no separate call needed. For practice problems 0 and 1, it sets `needs_diagram`, `diagram_prompt`, and `diagram_reason` as part of the same JSON response.

Once Call 1 completes, the backend immediately persists and exposes key_points, top_questions, and quick_test. Session status moves to `partial` and the app is notified.

### Call 2 — Individual Diagram Generation (Background Queue)

Only executed if at least one of problems 0/1 has `needs_diagram=true`. Each flagged problem triggers a separate `generate_content` call to `gemini-2.5-flash-image`. Up to 2 calls are run concurrently via a thread pool (Celery worker). Generated images are uploaded to S3 and their URLs are injected into `practice_examples` in the DB. Session status moves to `complete` and the app is notified.

**Why not batch API:** Individual `generate_content` calls are used instead of the Gemini batch API. The batch API introduces polling overhead (job queue on Gemini's side) with unpredictable latency. Direct calls with a thread pool achieve equivalent concurrency with lower and more predictable latency for 1–2 images.

**Decoupling rationale:** By the time the user finishes reading Key Points and Top Questions (~30–60 seconds), the diagram generation is expected to be complete. The Practice tab loading skeleton covers this window without the user perceiving a wait.

### API Response Schema

```json
{
  "session_title": "Red Blood Cells and Haemoglobin",
  "detected_subject": "Biology",
  "class_level_hint": "HSC",

  "key_points": {
    "what_to_learn": [
      "Structure and components of haemoglobin",
      "Functions of RBCs in oxygen transport"
    ],
    "quick_summary": "Red blood cells are biconcave, anucleate cells whose primary role is oxygen transport via haemoglobin. Haemoglobin contains four globin chains each bound to a haem group carrying one Fe²⁺ ion. Each RBC lives approximately 120 days before being broken down in the spleen.",
    "shortcut_techniques": [
      "Remember haemoglobin structure: 4 chains × 1 haem × 1 Fe²⁺ = 4 O₂ carried per molecule",
      "Biconcave = large surface area + no nucleus = more room for haemoglobin"
    ],
    "important_points_qa": [
      {
        "type": "mcq",
        "question": "How many oxygen molecules can one haemoglobin molecule carry?",
        "options": { "A": "2", "B": "4", "C": "6", "D": "8" },
        "correct_option": "B",
        "correct_bool": null,
        "blank_answer": null,
        "left_items": null,
        "right_items": null,
        "correct_matches": null,
        "explanation": "Each of the 4 haem groups binds one O₂, giving 4 per haemoglobin molecule."
      },
      {
        "type": "true_false",
        "question": "Red blood cells contain a nucleus in mature form.",
        "options": null,
        "correct_option": null,
        "correct_bool": false,
        "blank_answer": null,
        "left_items": null,
        "right_items": null,
        "correct_matches": null,
        "explanation": "Mature RBCs eject their nucleus during development to maximise haemoglobin space."
      },
      {
        "type": "fill_in_the_blanks",
        "question": "The lifespan of a red blood cell is approximately ___ days.",
        "options": null,
        "correct_option": null,
        "correct_bool": null,
        "blank_answer": "120",
        "left_items": null,
        "right_items": null,
        "correct_matches": null,
        "explanation": "After ~120 days, worn-out RBCs are phagocytosed mainly in the spleen."
      },
      {
        "type": "connecting_answer",
        "question": null,
        "options": null,
        "correct_option": null,
        "correct_bool": null,
        "blank_answer": null,
        "left_items": ["Haemoglobin", "Biconcave shape", "No nucleus"],
        "right_items": ["More haemoglobin capacity", "Large surface area", "Carries oxygen"],
        "correct_matches": [
          { "left": "Haemoglobin", "right": "Carries oxygen" },
          { "left": "Biconcave shape", "right": "Large surface area" },
          { "left": "No nucleus", "right": "More haemoglobin capacity" }
        ],
        "explanation": "Each structural feature of RBCs directly supports their oxygen-transport function."
      }
    ],
    "easy_lessons": [
      {
        "concept": "Why is haemoglobin red?",
        "explanation": "The iron (Fe²⁺) in the haem group reflects red light. When iron binds oxygen it turns bright red; without oxygen it is dark red-purple."
      }
    ],
    "math_and_logic": null
  },

  "practice_examples": [
    {
      "question": "A patient has 5 million RBCs per mm³. If each haemoglobin carries 4 O₂ molecules and each RBC contains 280 million haemoglobin, how many O₂ molecules does 1 mm³ of blood carry?",
      "is_math": true,
      "steps": [
        "Step 1: O₂ per RBC = 280,000,000 haemoglobin × 4 O₂ = 1,120,000,000 O₂",
        "Step 2: Total O₂ = 5,000,000 RBCs × 1,120,000,000 = 5.6 × 10¹⁵ O₂ molecules"
      ],
      "answer": "5.6 × 10¹⁵ oxygen molecules per mm³",
      "needs_diagram": false,
      "diagram_prompt": null,
      "diagram_reason": null
    },
    {
      "question": "Describe the biconcave shape of RBCs and explain its advantage.",
      "is_math": false,
      "steps": [
        "Step 1: RBCs are disc-shaped with a depressed centre (biconcave) and no nucleus.",
        "Step 2: This increases surface-area-to-volume ratio, speeding up O₂/CO₂ diffusion.",
        "Step 3: Absence of nucleus leaves more cytoplasm space for haemoglobin."
      ],
      "answer": "Biconcave shape maximises diffusion surface and haemoglobin capacity.",
      "needs_diagram": true,
      "diagram_prompt": "Draw a labelled diagram of a biconcave red blood cell. Show: top view (circular with central depression), side view (hourglass cross-section), labels for cell membrane, haemoglobin-filled cytoplasm, absent nucleus. Clean 2D educational style, white background, English labels.",
      "diagram_reason": "The biconcave shape is spatial and difficult to convey without a visual cross-section."
    }
  ],

  "top_questions": [
    {
      "question_text": "What is the role of iron in haemoglobin?",
      "difficulty": "easy",
      "question_type": "short_answer",
      "source": "SSC Dhaka Board 2022",
      "options": null,
      "correct_option": null,
      "selectable_points": null,
      "answer": "Iron (Fe²⁺) in the haem group binds reversibly to oxygen, enabling haemoglobin to pick up oxygen in the lungs and release it in tissues.",
      "explanation": "The Fe²⁺ ion is the actual oxygen-binding site; without it haemoglobin cannot carry O₂."
    },
    {
      "question_text": "Which of the following correctly describes the lifespan of a red blood cell?",
      "difficulty": "easy",
      "question_type": "mcq",
      "source": "SSC Rajshahi Board 2021",
      "options": { "A": "30 days", "B": "60 days", "C": "90 days", "D": "120 days" },
      "correct_option": "D",
      "selectable_points": null,
      "answer": null,
      "explanation": "RBCs survive approximately 120 days before being removed by the spleen and liver."
    },
    {
      "question_text": "Explain how the structure of red blood cells is adapted to their function in oxygen transport.",
      "difficulty": "hard",
      "question_type": "broad_answer",
      "source": "HSC Dhaka Board 2023",
      "options": null,
      "correct_option": null,
      "selectable_points": [
        { "point": "Biconcave shape increases surface area for faster gas diffusion.", "is_correct": true },
        { "point": "Absence of nucleus provides more space for haemoglobin.", "is_correct": true },
        { "point": "Haemoglobin contains Fe²⁺ which binds O₂ reversibly.", "is_correct": true },
        { "point": "RBCs are produced in yellow bone marrow.", "is_correct": false },
        { "point": "Flexible membrane allows passage through narrow capillaries.", "is_correct": true }
      ],
      "answer": null,
      "explanation": "Four structural features directly enable oxygen transport: shape, nucleus absence, haemoglobin content, and membrane flexibility."
    }
  ],

  "quick_test": [
    {
      "question": "What gives haemoglobin its red colour?",
      "options": { "A": "Globin protein", "B": "Fe²⁺ in haem group", "C": "CO₂ binding", "D": "Cell membrane" },
      "correct_answer": "B",
      "explanation": "The iron ion in the haem group absorbs and reflects red wavelengths."
    }
  ]
}
```

> **Backend responsibility:** After receiving Gemini's response, Django parses and validates the JSON. Null `key_points` sub-sections are stripped before sending to Flutter. Flutter never receives null fields — only fields that exist. Diagram image S3 URLs are injected into the `practice_examples` before sending to Flutter.

### Error Handling

| Error | Handling |
|-------|---------|
| Malformed JSON from Gemini (text call) | Retry once with stricter prompt. If second attempt fails → `failed` status. |
| Timeout >30s on text call | Return 202 immediately; process via Celery. App polls status every 3s. |
| Gemini quota exceeded | Queue session. Show "Your study pack is being prepared." |
| Unreadable document | Best-effort response. If `key_points` entirely empty → `failed`. |
| Diagram generation failed (one or both) | Session still marked `complete`. Affected practice problems rendered without diagram. No retry in MVP. |
| Diagram generation timeout | Same as failure — session marked `complete`, practice shown without diagram image. |

---

## Section 6: Data Schema

PostgreSQL via Django ORM. S3 for file storage. Redis for task queuing (Celery).

### users

| Field | Type | Notes |
|-------|------|-------|
| id | UUID PK | Auto-generated |
| full_name | VARCHAR(100) | |
| phone_number | VARCHAR(14) | Unique, BD format |
| password_hash | VARCHAR | bcrypt / argon2 |
| class_level | ENUM | SSC / HSC / Admission |
| is_verified | BOOLEAN | OTP verified flag |
| created_at | TIMESTAMP | Auto |

### otp_codes

| Field | Type | Notes |
|-------|------|-------|
| id | UUID PK | |
| phone_number | VARCHAR(14) | |
| code | VARCHAR(6) | Hashed |
| expires_at | TIMESTAMP | +5 min from creation |
| attempt_count | INT | Max 3 |
| is_used | BOOLEAN | One-time use |

### sessions

| Field | Type | Notes |
|-------|------|-------|
| id | UUID PK | Shared with Flutter |
| user_id | UUID FK | → users |
| title | VARCHAR(80) | AI-generated, editable |
| status | ENUM | pending/uploaded/processing/complete/failed |
| detected_subject | VARCHAR(60) | Gemini-detected |
| file_url | TEXT | S3 presigned URL |
| file_page_count | INT | 1–6 |
| created_at | TIMESTAMP | |
| completed_at | TIMESTAMP | Nullable |

### session_content

| Field | Type | Notes |
|-------|------|-------|
| id | UUID PK | |
| session_id | UUID FK | 1-to-1 with sessions |
| key_points | JSONB | Filtered, nulls stripped |
| practice_examples | JSONB | Array of 8; diagram S3 URLs injected; `is_math` flag included |
| top_questions | JSONB | Array of 10–18; includes answers, selectable_points, source |
| quick_test | JSONB | Array of 8 MCQs |
| raw_gemini_response | JSONB | Full Gemini JSON, for debugging |

### test_results

| Field | Type | Notes |
|-------|------|-------|
| id | UUID PK | |
| session_id | UUID FK | → sessions |
| user_id | UUID FK | → users |
| score | INT | 0–8 |
| answers | JSONB | User's selected answers |
| taken_at | TIMESTAMP | Auto |

### user_points

| Field | Type | Notes |
|-------|------|-------|
| id | UUID PK | |
| user_id | UUID FK | → users. Unique (1-to-1) |
| balance | INT | Current point balance. Never goes below 0. |
| updated_at | TIMESTAMP | Auto |

### point_transactions

| Field | Type | Notes |
|-------|------|-------|
| id | UUID PK | |
| user_id | UUID FK | → users |
| session_id | UUID FK | → sessions. Nullable (some actions are session-scoped) |
| action | VARCHAR(60) | e.g. `practice_attempt`, `quick_test_complete`, `unlock_practice_answer` |
| delta | INT | Positive = earned, negative = spent |
| balance_after | INT | Snapshot of balance after this transaction |
| created_at | TIMESTAMP | Auto |

### content_unlocks

| Field | Type | Notes |
|-------|------|-------|
| id | UUID PK | |
| user_id | UUID FK | → users |
| session_id | UUID FK | → sessions |
| unlock_type | ENUM | `practice_answer` / `top_question_answer` / `practice_diagram` |
| item_index | INT | Index of the unlocked item (0-based) |
| unlocked_at | TIMESTAMP | Auto |

> **Backend note:** Before sending `session_content` to Flutter, mask locked fields based on `content_unlocks` for that user+session. Never send locked answers to client — check server-side every request.

### refresh_tokens

| Field | Type | Notes |
|-------|------|-------|
| id | UUID PK | |
| user_id | UUID FK | → users |
| token_hash | VARCHAR | Hashed, one-time use |
| expires_at | TIMESTAMP | 30d from creation |
| revoked | BOOLEAN | For logout |

---

## Section 7: API Design

RESTful. JSON responses. JWT auth on all protected endpoints.

Base URL: `https://api.shikho.app/v1`

### Authentication

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST | `/auth/request-otp` | Send OTP to phone | Public |
| POST | `/auth/verify-otp` | Verify OTP, complete registration | Public |
| POST | `/auth/login` | Phone + password → JWT | Public |
| POST | `/auth/refresh` | Refresh access token | Refresh Token |
| POST | `/auth/logout` | Revoke refresh token | JWT |

### Sessions

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST | `/sessions` | Create new session | JWT |
| POST | `/sessions/{id}/upload` | Upload file. Triggers AI pipeline. | JWT |
| GET | `/sessions` | List user sessions (paginated) | JWT |
| GET | `/sessions/{id}` | Session metadata + status | JWT |
| GET | `/sessions/{id}/content` | AI content available at current status. Returns key_points, top_questions, quick_test when `partial`; adds practice_examples when `complete`. Applies unlock masking. | JWT |
| PATCH | `/sessions/{id}` | Update title | JWT |
| DELETE | `/sessions/{id}` | Delete session + S3 file | JWT |

#### Two-Phase Content Delivery

The `/sessions/{id}/content` endpoint returns whatever is available at the time of the request:

| Session status | Fields returned |
|----------------|----------------|
| `partial` | `session_title`, `detected_subject`, `class_level_hint`, `key_points`, `top_questions`, `quick_test` |
| `complete` | All of the above + `practice_examples` (with diagram S3 URLs injected where applicable) |

Flutter polls `/sessions/{id}` every 3 seconds while status is `partial` (or listens for push notification). Once status becomes `complete`, it calls `/sessions/{id}/content` again to fetch `practice_examples` and render the Practice tab.

### Test & Progress

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST | `/sessions/{id}/test-result` | Submit Quick Test score + answers | JWT |
| GET | `/sessions/{id}/test-results` | All test attempts for a session | JWT |
| GET | `/users/me/progress` | Aggregate test scores across sessions | JWT |
| PATCH | `/users/me` | Update profile (name, class_level) | JWT |

### Points & Unlocks

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| GET | `/users/me/points` | Current balance + recent transactions | JWT |
| POST | `/sessions/{id}/unlock` | Spend points to unlock an item. Body: `{unlock_type, item_index}` | JWT |
| POST | `/sessions/{id}/practice-attempt` | Record that student attempted a math problem. Awards points. Body: `{item_index}` | JWT |

---

## Section 8: Non-Functional Requirements

### Performance Targets

| Operation | Target |
|-----------|--------|
| Upload acknowledge | < 2s (202 async) |
| Gemini text response | < 15s for 6-page doc |
| Batch image job | < 60s (async, polled) |
| Session list load | < 500ms (paginated, cached) |
| Content fetch | < 300ms (pre-stored, no re-gen) |
| App cold start | < 2s on mid-range Android |

### Security

- All traffic over HTTPS / TLS 1.3
- JWT signed with RS256
- S3 files in private bucket, accessed via presigned URLs (TTL: 1h)
- OTP rate-limited: max 3 requests per phone per 15 minutes
- API rate limiting: 60 req/min per user (DRF throttling)
- No PII in application logs
- Locked content never sent to client — masking happens server-side before response

### Scalability

- **Celery + Redis:** AI processing decoupled from HTTP request cycle
- **Stateless Django:** Horizontal scaling behind load balancer
- **PostgreSQL:** Read replicas for session list queries
- **S3:** Files never served through Django
- **Gemini quota:** Per-user session cap (max 20/day in MVP)

### Offline Behavior

- Session history cached locally (Hive or SQLite)
- Session content cached post-load — accessible offline
- Quick Test answers saved locally before sync
- Upload requires active connection — clear error if offline

### File Processing Pipeline

**Phase 1 — Text (synchronous within Celery task)**

| Step | Tool | Notes |
|------|------|-------|
| 1. Receive upload | Django REST Framework | Multipart form, max 20MB |
| 2. Validate file type | python-magic | Check actual MIME, not extension |
| 3. Count pages | PyPDF2 / Pillow | Reject if >6 pages |
| 4. Store original | boto3 → S3 | Private bucket, user-scoped path |
| 5. Convert PDF to images | pdf2image / Poppler | 72–150 DPI, JPG output |
| 6. Queue AI task | Celery | Pass session_id + image paths |
| 7. Call Gemini (text) | google-genai SDK | Images via `types.Part.from_bytes()`. Schema via `response_schema=StudyPackage`. |
| 8. Parse + store partial JSON | Django ORM | Persist key_points, top_questions, quick_test. Status → `partial`. Notify app. |

**Phase 2 — Diagrams (background, concurrent within same Celery task)**

| Step | Tool | Notes |
|------|------|-------|
| 9. Check diagram flags | — | Inspect `needs_diagram` on practice_examples[0] and [1] |
| 10. Generate diagrams concurrently | google-genai SDK + ThreadPoolExecutor | Up to 2 individual `generate_content` calls to `gemini-2.5-flash-image`, run in parallel |
| 11. Store diagrams | boto3 → S3 | Upload PNGs; inject S3 URLs into `practice_examples` in DB |
| 12. Mark complete | Django ORM | Persist full `practice_examples`. Status → `complete`. Notify app. |

---

## Section 9: Risks & Mitigations

### High

| Risk | Mitigation |
|------|-----------|
| Gemini hallucinations in exam questions | Prompt engineering with explicit accuracy instruction; future human spot-check pipeline |
| Gemini schema non-compliance | Use `response_schema=StudyPackage` (Pydantic class). Do not use asymmetric `minItems/maxItems` on complex object arrays — Gemini rejects those. |
| Unreadable handwritten notes | Image quality check before sending; advise users on scan quality |

### Medium

| Risk | Mitigation |
|------|-----------|
| Gemini API cost overrun | Per-user daily session cap (20/day MVP); Flash Lite A/B testing; deduplicate same-document uploads |
| Batch image job failure | Session marked complete; affected problems shown without diagram; no retry in MVP |
| OTP delivery failure in BD | Integrate 2 SMS gateway providers (primary + fallback); retry with exponential backoff |
| Large file timeouts | Async Celery task with 60s timeout; client polls status every 3s; graceful failure message |
| Points balance race condition | Deduct points atomically (DB transaction + row lock). Never trust client-reported balance. |

### Low

| Risk | Mitigation |
|------|-----------|
| S3 presigned URL expiry mid-session | Flutter refreshes URL via `/sessions/{id}` before rendering if TTL near expiry |
| Copyright concerns with uploaded content | ToS: user-owned or personal notes only; no content redistributed |

### Out of Scope — MVP

- Text-based chat input
- Teacher / admin panel
- Social / sharing features
- Subscription / payment
- Push notifications (stretch goal)
- Collaborative sessions
- Web version
