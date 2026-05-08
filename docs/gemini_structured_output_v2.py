"""
Shikho — Gemini Structured Output v2
Updated schema: KeyPoints rework, ImportantPointQA types, TopQuestion rework.

Pipeline — 2 Gemini API calls per session:
  Call 1 (gemini-3-flash-preview)   — structured JSON study package;
                                       Gemini flags diagram worthiness inline on
                                       practice problems 0 and 1.
  Call 2 (gemini-2.5-flash-image)   — batch image generation for flagged problems.
                                       Skipped entirely if neither problem is flagged.
"""

import os
import json
from typing import List, Optional, Literal, Annotated, Union
from dataclasses import dataclass, field

from google import genai
from google.genai import types
from pydantic import BaseModel, Field
from dotenv import load_dotenv

load_dotenv()


# ─────────────────────────────────────────────────────────────────────────────
# Shared building blocks
# ─────────────────────────────────────────────────────────────────────────────

class MCQOptions(BaseModel):
    A: str
    B: str
    C: str
    D: str


# ─────────────────────────────────────────────────────────────────────────────
# KEY POINTS — updated models
# ─────────────────────────────────────────────────────────────────────────────

class EasyLesson(BaseModel):
    concept: str = Field(description="The concept being simplified.")
    explanation: str = Field(
        description="Plain-language explanation in simple Bangla or English. "
                    "Avoid jargon. Aim for a Class 9 reading level."
    )


class MathExample(BaseModel):
    formula: str = Field(description="The formula or mathematical rule.")
    worked_example: str = Field(
        description="Step-by-step worked example demonstrating the formula."
    )


class MatchPair(BaseModel):
    left: str = Field(description="Left column item.")
    right: str = Field(description="Matching right column item.")


class ImportantPointQA(BaseModel):
    """
    One interactive QA item. 'type' determines which fields are populated.

    mcq              → question, options, correct_option, explanation
    true_false        → question, correct_bool, explanation
    fill_in_the_blanks→ question (contains '___' placeholder), blank_answer, explanation
    connecting_answer → left_items, right_items (shuffled), correct_matches, explanation
    """
    type: Literal["mcq", "true_false", "fill_in_the_blanks", "connecting_answer", "short_answer"] = Field(
        description=(
            "Discriminator for question format. "
            "mcq: 4-option multiple choice. "
            "true_false: statement student marks true or false. "
            "fill_in_the_blanks: sentence with '___' the student fills. "
            "connecting_answer: match 2-3 left items to 2-3 right items. "
            "short_answer: a ক/খ-style short question requiring a 2–4 sentence answer."
        )
    )
    question: Optional[str] = Field(
        default=None,
        description=(
            "Question or statement text. "
            "Required for: mcq, true_false. "
            "For fill_in_the_blanks: the sentence containing '___' as the blank. "
            "Null for: connecting_answer."
        )
    )
    # MCQ-specific
    options: Optional[MCQOptions] = Field(
        default=None,
        description="4 options A–D. Required for mcq. Null for all other types."
    )
    correct_option: Optional[Literal["A", "B", "C", "D"]] = Field(
        default=None,
        description="Correct option key. Required for mcq. Null for all other types."
    )
    # True/False-specific
    correct_bool: Optional[bool] = Field(
        default=None,
        description="True or False. Required for true_false. Null for all other types."
    )
    # Fill-in-the-blank-specific
    blank_options: Optional[List[str]] = Field(
        default=None,
        description=(
            "3 or 4 short answer options shown to the student. One must equal blank_answer exactly. "
            "The rest are plausible distractors. The number is up to the model (3 or 4). "
            "Required for fill_in_the_blanks. Null otherwise."
        )
    )
    blank_answer: Optional[str] = Field(
        default=None,
        description=(
            "The exact word or phrase that fills the blank. Must match one of blank_options exactly. "
            "Required for fill_in_the_blanks. Null otherwise."
        )
    )
    ka_kha_answer: Optional[str] = Field(
        default=None,
        description=(
            "Model answer for short_answer (ক/খ) type questions. "
            "2–4 sentences in the document's language. "
            "Required for short_answer. Null for all other types."
        )
    )
    # Connecting answer-specific
    left_items: Optional[List[str]] = Field(
        default=None,
        description="Left column items (2–3 strings). Required for connecting_answer. Null otherwise."
    )
    right_items: Optional[List[str]] = Field(
        default=None,
        description=(
            "Right column items (2–3 strings) in SHUFFLED order — not matching left order. "
            "Required for connecting_answer. Null otherwise."
        )
    )
    correct_matches: Optional[List[MatchPair]] = Field(
        default=None,
        description=(
            "Correct left→right pairings. Each MatchPair has 'left' and 'right' strings. "
            "Required for connecting_answer. Null otherwise."
        )
    )
    # Shared
    explanation: str = Field(
        description="Short explanation of why the correct answer is correct. Always required."
    )


class KeyPoints(BaseModel):
    what_to_learn: List[str] = Field(
        description=(
            "Concise list of topics and concepts essential for exam preparation from this document. "
            "Each item is one concrete skill, concept, or formula the student must master for the exam. "
            "Highlight areas that require extra attention or are frequently tested. "
            "3–8 items."
        )
    )
    quick_summary: str = Field(
        description=(
            "A single cohesive paragraph summarising the entire document. "
            "Cover all major topics, key relationships, and core conclusions. "
            "3–5 sentences. No bullet points — flowing prose only."
        )
    )
    shortcut_techniques: List[str] = Field(
        description=(
            "1–3 quick tips or tricks to solve problems faster, memorise formulas, "
            "or recall key facts during an exam. "
            "Each item is one actionable technique (e.g. 'Use SOHCAHTOA mnemonic for trig ratios'). "
            "If no genuine shortcuts exist for this topic, return 1 general study tip."
        )
    )
    common_mistakes: List[str] = Field(
        default=[],
        description=(
            "2–4 common mistakes students make on this topic in exams. "
            "Each item is one specific error or misconception to avoid. "
            "Return an empty list if no significant pitfalls exist."
        )
    )
    important_points_qa: List[ImportantPointQA] = Field(
        description=(
            "10-12 interactive QA items covering the most critical facts and concepts. "
            "Include at least 2 of each type: mcq, true_false, fill_in_the_blanks, connecting_answer. "
            "Total must be between 10 and 12. "
            "Questions must reinforce key concepts — not trivial recall."
        ),
    )
    easy_lessons: List[EasyLesson] = Field(
        description=(
            "Simplified explanations of hard or abstract concepts. "
            "Include only concepts that genuinely need simplification."
        )
    )
    math_and_logic: Optional[List[MathExample]] = Field(
        default=None,
        description=(
            "Formulas with step-by-step worked examples. "
            "Set to null for non-quantitative subjects (Biology, Bangla, English, History). "
            "Include for Physics, Chemistry, Mathematics, Higher Math, ICT."
        )
    )


# ─────────────────────────────────────────────────────────────────────────────
# PRACTICE EXAMPLES
# ─────────────────────────────────────────────────────────────────────────────

class PracticeExample(BaseModel):
    question: str = Field(
        description="The problem statement. Derived from or inspired by the uploaded document."
    )
    is_math: bool = Field(
        description=(
            "True if this is a math/numeric problem where the student writes a calculated answer. "
            "False for definition, explanation, or essay-type problems."
        )
    )
    steps: List[str] = Field(
        description="Ordered solution steps. Each step is a complete sentence "
                    "starting with 'Step N:'. Minimum 2 steps, maximum 8."
    )
    answer: str = Field(
        description="The final answer, clearly stated. Include units where applicable."
    )
    answer_choices: Optional[List[str]] = Field(
        default=None,
        description=(
            "3 or 4 short answer options shown as MCQ buttons to the student. "
            "One option must match or clearly represent the correct `answer`. "
            "Others are plausible distractors at a similar level of detail. "
            "For math/numeric: include values with units (e.g. '50 m/s', '100 N'). "
            "For concepts: include short phrases of 5–10 words max. "
            "Include for ALL problems. Null only when no meaningful distractors exist."
        )
    )
    # Diagram flags — only evaluated for problems at index 0 and 1.
    needs_diagram: bool = Field(
        default=False,
        description=(
            "Set true ONLY for problems at index 0 and 1, and ONLY when the problem "
            "involves a spatial or visual concept: vectors, free-body diagrams, electric circuits, "
            "chemical apparatus, biological structures, geometric constructions, ray/wave diagrams. "
            "Always false for index 2–7. Always false for pure arithmetic or definition recall."
        ),
    )
    diagram_prompt: Optional[str] = Field(
        default=None,
        description=(
            "Required when needs_diagram is true. Detailed image generation prompt. "
            "Describe what to draw, labels, arrows, colors, spatial layout. "
            "Style: clean 2D educational schematic, high school textbook quality, English labels. "
            "Null when needs_diagram is false."
        ),
    )
    diagram_reason: Optional[str] = Field(
        default=None,
        description=(
            "Required when needs_diagram is true. One sentence: why a diagram helps "
            "the student understand this specific problem. Null when needs_diagram is false."
        ),
    )


# ─────────────────────────────────────────────────────────────────────────────
# TOP QUESTIONS — updated with types, source, answers
# ─────────────────────────────────────────────────────────────────────────────

class SelectablePoint(BaseModel):
    point: str = Field(description="A point that may or may not be needed to answer the question.")
    is_correct: bool = Field(
        description="True if this point is actually needed/correct for the answer. False if it is a distractor."
    )


class TopQuestion(BaseModel):
    question_text: str = Field(
        description="The exam question text."
    )
    difficulty: Literal["easy", "medium", "hard"] = Field(
        description="Difficulty calibrated against SSC/HSC/Admission exam standards."
    )
    question_type: Literal["short_answer", "creative", "mcq", "broad_answer"] = Field(
        description=(
            "short_answer: 1–3 sentence factual recall. "
            "creative: analysis, comparison, application — HSC style. "
            "mcq: 4-option multiple choice with options and correct answer. "
            "broad_answer: student selects which of 4–6 provided points are needed to answer."
        )
    )
    source: str = Field(
        description=(
            "Exam this question is from or modelled after. "
            "Calibrate source based on class_level_hint: SSC → SSC board exams, HSC → HSC board exams (may include admission-level questions for hard difficulty), Admission → university admission exams (It contains different difficulty levels)."
            "Format examples: 'SSC', 'HSC', 'Admission'"
        )
    )
    # MCQ-specific
    options: Optional[MCQOptions] = Field(
        default=None,
        description="4 options A–D. Required for mcq. Null for all other types."
    )
    correct_option: Optional[Literal["A", "B", "C", "D"]] = Field(
        default=None,
        description="Correct option. Required for mcq. Null for all other types."
    )
    # broad_answer-specific
    selectable_points: Optional[List[SelectablePoint]] = Field(
        default=None,
        description=(
            "4–6 points total (mix of correct and distractor). "
            "Student selects which points are needed to answer the question. "
            "Required for broad_answer. Null for all other types."
        )
    )
    # short_answer and creative answer
    answer: Optional[str] = Field(
        default=None,
        description=(
            "Model answer text. Required for short_answer and creative. "
            "Null for mcq (use correct_option) and broad_answer (use selectable_points)."
        )
    )
    explanation: str = Field(
        description="Short explanation of the answer or solution approach. Always required."
    )


# ─────────────────────────────────────────────────────────────────────────────
# QUICK TEST MCQ — unchanged
# ─────────────────────────────────────────────────────────────────────────────

class QuickTestMCQ(BaseModel):
    question: str = Field(description="The MCQ question stem.")
    options: MCQOptions
    correct_answer: Literal["A", "B", "C", "D"]
    explanation: Optional[str] = Field(
        default=None,
        description="Brief explanation of why the correct answer is right. "
                    "Include only when reasoning is non-obvious."
    )


# ─────────────────────────────────────────────────────────────────────────────
# ROOT — StudyPackage
# ─────────────────────────────────────────────────────────────────────────────

class StudyPackage(BaseModel):
    session_title: str = Field(
        description="Auto-generated session title. Max 6 words. "
                    "Specific and descriptive (e.g. 'Newton's Laws of Motion')."
    )
    detected_subject: str = Field(
        description="Subject inferred from document content. "
                    "One of: Physics, Chemistry, Biology, Mathematics, Higher Math, "
                    "Bangla, English, ICT, Agricultural Science, or 'General'."
    )
    class_level_hint: Literal["SSC", "HSC", "Admission", "Unknown"] = Field(
        description="Inferred class level. SSC=Class 9–10, HSC=Class 11–12, Admission=university prep."
    )
    key_points: KeyPoints
    practice_examples: List[PracticeExample] = Field(
        description="Exactly 8 practice problems. Progress easy → hard.",
        min_length=8,
        max_length=8,
    )
    top_questions: List[TopQuestion] = Field(
        description=(
            "10 to 18 predicted exam questions sorted easy → medium → hard. "
            "Generate at least 10 and no more than 18. "
            "Mix all question_type values. Source questions from the appropriate exam board "
            "based on class_level_hint."
        ),
    )
    quick_test: List[QuickTestMCQ] = Field(
        description="About 8–16 MCQs for the Quick Test module. The length should be either 8 or 12 or 16 — no odd numbers. All questions must have 4 plausible options with correct answers distributed across A/B/C/D.",
    )


# ─────────────────────────────────────────────────────────────────────────────
# Diagram pipeline types
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class DiagramRequest:
    problem_index: int
    diagram_prompt: str
    reason: str


@dataclass
class DiagramResult:
    problem_index: int
    image_path: Optional[str]
    status: str   # "generated" | "failed"
    reason: str


# ─────────────────────────────────────────────────────────────────────────────
# System prompt
# ─────────────────────────────────────────────────────────────────────────────

def build_system_prompt(class_level: Literal["SSC", "HSC", "Admission"]) -> str:
    """
    Build the Gemini system prompt with the user's registered class level injected.
    This prevents Gemini from misidentifying the level from document content alone.
    """
    level_context = {
        "SSC": (
            "The student is in Class 9 or 10 (SSC level). "
            "Calibrate all content, difficulty, and question sources to SSC board exams "
            "(Dhaka, Rajshahi, Chittagong, Sylhet, etc.). "
            "Do not generate HSC or admission-level content."
        ),
        "HSC": (
            "The student is in Class 11 or 12 (HSC level). "
            "Calibrate all content, difficulty, and question sources to HSC board exams. "
            "Hard questions may draw from university admission exams."
        ),
        "Admission": (
            "The student is preparing for university admission exams (HSC passed). "
            "Calibrate all content, difficulty, and question sources to university admission exams "
            "(DU, BUET, CUET, medical, etc.). Assume strong foundational knowledge."
        ),
    }

    return f"""
You are an expert exam preparation assistant for Bangladeshi secondary and higher secondary students (SSC, HSC, and University Admission levels).

Analyze the uploaded document (handwritten notes or PDF pages) and generate a structured study package. The student is preparing for an upcoming exam.

## Student Level (Confirmed — do not override)

{level_context[class_level]}

Set class_level_hint in your response to "{class_level}". Do not infer a different level from the document.

## Rules

### 1. Subject detection
Infer subject from content only — do not ask. Use curriculum context (Newton's Laws → Physics, organic compounds → Chemistry, Liberation War → History).
Do NOT infer class_level from content — it is already confirmed above.

### 2. Key Points

**what_to_learn** — 3–8 items. Focus on what to study for the exam. Highlight frequently tested areas and concepts needing extra attention.

**quick_summary** — Single flowing paragraph (3–5 sentences). Cover all major topics and key relationships from the document. No bullet points.

**shortcut_techniques** — 1–3 practical exam tricks: mnemonics, shortcut formulas, pattern recognition tips. If no genuine shortcuts exist, give 1 general memory tip.

**important_points_qa** — 5–7 interactive QA items. Rules:
- At minimum 1 item of each type: mcq, true_false, fill_in_the_blanks, connecting_answer.
- MCQ: 4 plausible options, one correct. Distribute correct answers across A/B/C/D.
- True/False: test a commonly misunderstood concept.
- Fill in blank: use '___' in the question text exactly once. Provide exactly 3 blank_options (one equals blank_answer, two are plausible distractors).
- Connecting answer: 2–3 left items, 2–3 right items in SHUFFLED order, correct_matches lists correct pairs.
- Short answer (ক/খ): a concise exam-style question. Populate question and ka_kha_answer. All other fields null.
- All items include explanation.

**common_mistakes** — 2–4 specific errors students make in exams. If none, return empty list.

**easy_lessons** — Simplify only genuinely hard concepts. Skip trivial ones.

**math_and_logic** — Null for Biology, Bangla, English, History. Include for Physics, Chemistry, Math, Higher Math, ICT.

### 3. Practice Examples — EXACTLY 8 problems
- Derive from document content.
- Progress: simple recall (1–3) → application (4–6) → analysis (7–8).
- Set is_math=true for numeric/calculation problems, false for definition/essay problems.
- Each problem: minimum 2 numbered steps.
- Math/science: numeric answers with units. Humanities: full model answers.
- **answer_choices**: Always include 3 or 4 options. One must represent the correct answer. For math: numeric values with units. For concepts: short phrases (≤10 words). Distractors must be plausible — not obviously wrong.

**Diagram flags — problems at index 0 and 1 only:**
- Worthy: vectors with direction, free-body diagrams, electric circuits, chemical apparatus, biological structures, geometric constructions, ray diagrams, labeled graphs.
- Not worthy: pure arithmetic, definition recall, essay-type.
- If worthy → needs_diagram=true, detailed diagram_prompt, diagram_reason.
- Problems index 2–7: always needs_diagram=false, diagram_prompt=null, diagram_reason=null.

### 4. Top Questions — 10 to 18 questions
- Source from relevant exam board based on class_level_hint:
  - SSC → SSC board exams (Dhaka, Rajshahi, Chittagong, etc.)
  - HSC → HSC board exams; hard difficulty may include admission-level questions
  - Admission → university admission exams (DU, BUET, CUET, medical, etc.)
- Sort strictly: easy → medium → hard.
- Mix all question_type values (short_answer, creative, mcq, broad_answer).
- MCQ: populate options + correct_option. answer=null.
- broad_answer: 4–6 selectable_points (mix correct=true and distractor correct=false). answer=null.
- short_answer / creative: populate answer text. options=null, selectable_points=null.
- All types: include explanation.

### 5. Quick Test — EXACTLY 8 MCQs
- All 4 options plausible.
- Correct answers distributed across A/B/C/D.
- Include explanation when reasoning is non-obvious.

### 6. General rules
- Session title: max 6 words, specific.
- Accuracy: students use this for real exams. Correct any errors in the document.
- Language: match document language. Bangla doc → Bangla explanations; technical terms in English.
- Respond ONLY with valid JSON matching the schema. No markdown, no prose outside JSON.
"""


# ─────────────────────────────────────────────────────────────────────────────
# Call 1: Structured study package
# ─────────────────────────────────────────────────────────────────────────────

def generate_study_package(
    image_paths: list[str],
    class_level: Literal["SSC", "HSC", "Admission"],
) -> StudyPackage:
    """
    Send document images to Gemini → validated StudyPackage.
    Diagram flags for problems 0 and 1 set inline — no extra call.

    Uses response_schema=StudyPackage (Pydantic class) — SDK handles schema
    conversion internally. Gemini supports $defs/$ref natively; do NOT
    pre-process the schema (nullable/inline expansion breaks the API).

    Args:
        image_paths: Local JPG/PNG paths. Max 6. Caller converts PDF to images first.
        class_level: User's registered class level (SSC / HSC / Admission).
                     Injected into the system prompt so Gemini never misidentifies it.

    Returns:
        Validated StudyPackage.

    Raises:
        ValueError: Malformed JSON or schema validation failure.
    """
    if not image_paths:
        raise ValueError("At least one image path required.")
    if len(image_paths) > 6:
        raise ValueError(f"Max 6 images per session. Got {len(image_paths)}.")

    client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

    parts: list = [build_system_prompt(class_level)]
    for path in image_paths:
        with open(path, "rb") as f:
            image_bytes = f.read()
        mime = "image/jpeg" if path.lower().endswith((".jpg", ".jpeg")) else "image/png"
        parts.append(types.Part.from_bytes(data=image_bytes, mime_type=mime))

    response = client.models.generate_content(
        model="gemini-3-flash-preview",
        contents=parts,
        config={
            "response_mime_type": "application/json",
            "response_schema": StudyPackage,
        },
    )

    # response.parsed uses the SDK's own deserialization (handles Unicode/Bengali
    # text safely). Falls back to manual parse if SDK doesn't populate it.
    if response.parsed is not None:
        return response.parsed
    return StudyPackage.model_validate_json(response.text)


def extract_diagram_requests(package: StudyPackage) -> List[DiagramRequest]:
    """Read diagram flags from practice_examples[0] and [1]. No API call."""
    requests: List[DiagramRequest] = []
    for idx in (0, 1):
        prob = package.practice_examples[idx]
        if prob.needs_diagram and prob.diagram_prompt and prob.diagram_reason:
            requests.append(DiagramRequest(
                problem_index=idx,
                diagram_prompt=prob.diagram_prompt,
                reason=prob.diagram_reason,
            ))
    return requests


# ─────────────────────────────────────────────────────────────────────────────
# Call 2: Batch diagram generation
# ─────────────────────────────────────────────────────────────────────────────

def generate_practice_diagrams(
    diagram_requests: List[DiagramRequest],
    output_dir: str = ".",
) -> List[DiagramResult]:
    """
    Generate educational diagrams via individual gemini-2.5-flash-image calls.
    Up to 2 requests (problems 0 and 1). Each is a separate generate_content call.

    Args:
        diagram_requests: From extract_diagram_requests(). Empty list → no-op.
        output_dir: Directory to save generated PNG files.

    Returns:
        List of DiagramResult. Check .status == "generated" before using .image_path.
    """
    if not diagram_requests:
        return []

    client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

    results: List[DiagramResult] = []
    for req in diagram_requests:
        print(f"  Generating diagram for problem {req.problem_index + 1}...")
        try:
            response = client.models.generate_content(
                model="gemini-2.5-flash-image",
                contents=[{"parts": [{"text": req.diagram_prompt}]}],
                config={"response_modalities": ["IMAGE"]},
            )

            image_path = None
            for part in response.parts:
                if part.inline_data:
                    image_path = os.path.join(output_dir, f"practice_diagram_{req.problem_index + 1}.png")
                    part.as_image().save(image_path)
                    break

            results.append(DiagramResult(
                problem_index=req.problem_index,
                image_path=image_path,
                status="generated" if image_path else "failed",
                reason=req.reason,
            ))
        except Exception as e:
            print(f"  Diagram generation failed for problem {req.problem_index + 1}: {e}")
            results.append(DiagramResult(
                problem_index=req.problem_index, image_path=None, status="failed", reason=req.reason
            ))

    return results


# ─────────────────────────────────────────────────────────────────────────────
# Orchestrator
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class SessionResult:
    package: StudyPackage
    diagram_results: List[DiagramResult] = field(default_factory=list)

    def diagram_for(self, problem_index: int) -> Optional[str]:
        """Return local image path for a problem index, or None."""
        for d in self.diagram_results:
            if d.problem_index == problem_index and d.status == "generated":
                return d.image_path
        return None


def run_session_pipeline(
    image_paths: list[str],
    class_level: Literal["SSC", "HSC", "Admission"],
    output_dir: str = ".",
) -> SessionResult:
    """
    Full Shikho session pipeline.

    Call 1 — generate_study_package(): structured output + inline diagram flags.
    Call 2 — generate_practice_diagrams(): individual images, only if flags are set.

    Args:
        image_paths: Document image paths (JPG/PNG, max 6).
        class_level: User's registered class level (SSC / HSC / Admission).
                     Passed to Gemini to ensure correct exam board and difficulty.
        output_dir: Directory for generated diagram PNGs.

    Returns:
        SessionResult with study package and diagram results.
    """
    print("\n[1/2] Generating study package...")
    package = generate_study_package(image_paths, class_level)
    print(f"      '{package.session_title}' — {package.detected_subject}, {package.class_level_hint}")

    diagram_requests = extract_diagram_requests(package)

    if not diagram_requests:
        print("      No diagram flags set. Skipping image generation.")
        return SessionResult(package=package)

    worthy = [r.problem_index + 1 for r in diagram_requests]
    print(f"      Diagram flag set on problem(s): {worthy}")
    for req in diagram_requests:
        print(f"        Problem {req.problem_index + 1}: {req.reason}")

    print(f"\n[2/2] Generating {len(diagram_requests)} diagram(s) via batch API...")
    diagram_results = generate_practice_diagrams(diagram_requests, output_dir=output_dir)

    for result in diagram_results:
        print(f"      Problem {result.problem_index + 1} → {result.image_path or 'FAILED'}")

    return SessionResult(package=package, diagram_results=diagram_results)


# ─────────────────────────────────────────────────────────────────────────────
# Entrypoint
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    import sys

    if len(sys.argv) < 3 or sys.argv[1] not in ("SSC", "HSC", "Admission"):
        print("Usage: python gemini_structured_output_v2.py <SSC|HSC|Admission> <image1.jpg> [image2.jpg ...]")
        print("\nStudyPackage JSON Schema:")
        print(json.dumps(StudyPackage.model_json_schema(), indent=2))
        sys.exit(0)

    class_level_arg: Literal["SSC", "HSC", "Admission"] = sys.argv[1]  # type: ignore[assignment]
    result = run_session_pipeline(sys.argv[2:], class_level=class_level_arg, output_dir=".")
    pkg = result.package

    print(f"\n{'─' * 50}")
    print(f"Session Title      : {pkg.session_title}")
    print(f"Subject            : {pkg.detected_subject}")
    print(f"Class Level        : {pkg.class_level_hint}")
    print(f"Quick Summary      : {pkg.key_points.quick_summary[:80]}...")
    print(f"What to Learn      : {len(pkg.key_points.what_to_learn)} items")
    print(f"Shortcut Techniques: {len(pkg.key_points.shortcut_techniques)} tips")
    print(f"Important QA items : {len(pkg.key_points.important_points_qa)}")
    for qa in pkg.key_points.important_points_qa:
        print(f"  [{qa.type}] {(qa.question or '')[:60]}")
    print(f"Practice Problems  : {len(pkg.practice_examples)}")
    print(f"  Problem 1 diagram: {result.diagram_for(0) or 'none'}")
    print(f"  Problem 2 diagram: {result.diagram_for(1) or 'none'}")
    print(f"Top Questions      : {len(pkg.top_questions)}")
    for q in pkg.top_questions:
        print(f"  [{q.difficulty}][{q.question_type}] {q.source} — {q.question_text[:50]}")
    print(f"Quick Test MCQs    : {len(pkg.quick_test)}")
    print(f"\nFull JSON:\n{pkg.model_dump_json(indent=2)}")
