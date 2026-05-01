import '../models/user.dart';
import '../models/session.dart';

/// Dummy data provider — contains all hardcoded data for the app.
/// When backend is ready, replace DummyAuthService/DummySessionService
/// with real API implementations.
class DummyData {
  DummyData._();

  static final User defaultUser = User(
    id: 'u-001',
    fullName: 'রাহি আহমেদ',
    phoneNumber: '01712345678',
    classLevel: 'HSC',
    pointsBalance: 85,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  );

  static final List<Session> sessions = [
    Session(
      id: 's-001',
      userId: 'u-001',
      title: 'Structure and Functions of Blood Cells',
      status: 'complete',
      detectedSubject: 'Biology',
      filePageCount: 3,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      completedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Session(
      id: 's-002',
      userId: 'u-001',
      title: 'নিউটনের গতিসূত্র',
      status: 'complete',
      detectedSubject: 'Physics',
      filePageCount: 4,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      completedAt: DateTime.now().subtract(const Duration(days: 1, hours: 23)),
    ),
    Session(
      id: 's-003',
      userId: 'u-001',
      title: 'জৈব যৌগের নামকরণ',
      status: 'complete',
      detectedSubject: 'Chemistry',
      filePageCount: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      completedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Session(
      id: 's-004',
      userId: 'u-001',
      title: 'সমাকলন — Calculus',
      status: 'partial',
      detectedSubject: 'Mathematics',
      filePageCount: 5,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  /// Full Biology study package from gemini_output.txt
  static Map<String, dynamic> get studyPackageJson => {
    "session_title": "Structure and Functions of Blood Cells",
    "detected_subject": "Biology",
    "class_level_hint": "HSC",
    "key_points": {
      "what_to_learn": [
        "Structure of Hemoglobin including globin chains and heme groups.",
        "Primary and secondary functions of RBC (gas transport, buffer, viscosity).",
        "Production of Bilirubin and Biliverdin from RBC breakdown.",
        "Distinction between Leukocytosis, Leukopenia, and Leukemia.",
        "Normal ratio of RBC to WBC (600:1).",
        "Classification of WBCs into Granulocytes and Agranulocytes."
      ],
      "quick_summary": "This document outlines the essential characteristics and functions of red and white blood cells in human physiology. RBCs are specialized for oxygen transport and maintaining blood homeostasis through buffering and viscosity regulation. WBCs act as the body's mobile defense unit, categorized by their structural appearance and nuclear shape. Clinical conditions like Leukemia are defined based on abnormal fluctuations in leukocyte counts, highlighting the importance of the 600:1 RBC to WBC ratio.",
      "shortcut_techniques": [
        "Use the mnemonic 'R-600, W-1' to remember the standard RBC to WBC ratio of 600:1.",
        "Remember 'G-BEN' for Granulocytes: Basophils, Eosinophils, and Neutrophils."
      ],
      "important_points_qa": [
        {
          "type": "mcq",
          "question": "What is the normal ratio of RBC to WBC in a healthy human body?",
          "options": {"A": "1:600", "B": "600:1", "C": "500:1", "D": "1:500"},
          "correct_option": "B",
          "correct_bool": null,
          "blank_answer": null,
          "left_items": null,
          "right_items": null,
          "correct_matches": null,
          "explanation": "In a healthy human, there are approximately 600 red blood cells for every 1 white blood cell."
        },
        {
          "type": "true_false",
          "question": "Mature White Blood Cells (WBC) contain hemoglobin just like Red Blood Cells.",
          "options": null,
          "correct_option": null,
          "correct_bool": false,
          "blank_answer": null,
          "left_items": null,
          "right_items": null,
          "correct_matches": null,
          "explanation": "WBCs are colorless because they do not contain hemoglobin; their primary role is defense, not gas transport."
        },
        {
          "type": "fill_in_the_blanks",
          "question": "The breakdown of RBCs produces a yellow pigment called ___.",
          "options": null,
          "correct_option": null,
          "correct_bool": null,
          "blank_options": ["Biliverdin", "Bilirubin", "Hemoglobin"],
          "blank_answer": "Bilirubin",
          "left_items": null,
          "right_items": null,
          "correct_matches": null,
          "explanation": "Bilirubin is the yellow pigment produced from the heme part of hemoglobin when old RBCs are destroyed."
        },
        {
          "type": "connecting_answer",
          "question": null,
          "options": null,
          "correct_option": null,
          "correct_bool": null,
          "blank_answer": null,
          "left_items": ["Leukocytosis", "Leukopenia", "Leukemia"],
          "right_items": ["Abnormal uncontrolled WBC increase", "WBC count higher than normal", "WBC count lower than normal"],
          "correct_matches": [
            {"left": "Leukocytosis", "right": "WBC count higher than normal"},
            {"left": "Leukopenia", "right": "WBC count lower than normal"},
            {"left": "Leukemia", "right": "Abnormal uncontrolled WBC increase"}
          ],
          "explanation": "Leukocytosis is a simple increase, Leukopenia is a decrease, and Leukemia is a cancerous increase of WBCs."
        },
        {
          "type": "mcq",
          "question": "Which substance on the RBC plasma membrane determines blood grouping?",
          "options": {"A": "Bilirubin", "B": "Heme", "C": "Antigen Protein", "D": "Nitric Oxide"},
          "correct_option": "C",
          "correct_bool": null,
          "blank_answer": null,
          "left_items": null,
          "right_items": null,
          "correct_matches": null,
          "explanation": "Antigen proteins attached to the plasma membrane of RBCs are responsible for determining blood group."
        }
      ],
      "easy_lessons": [
        {
          "concept": "RBC vs WBC Nucleus",
          "explanation": "সহজভাবে মনে রাখো: লোহিত রক্তকণিকা (RBC) পরিণত অবস্থায় নিউক্লিয়াস হারায়। কিন্তু শ্বেত রক্তকণিকা (WBC) সবসময় নিউক্লিয়াসযুক্ত থাকে।"
        },
        {
          "concept": "Granulocytes vs Agranulocytes",
          "explanation": "দানাদার (Granulocytes) মানে যাদের সাইটোপ্লাজমে দানা থাকে। অদানাদার (Agranulocytes) মানে যাদের সাইটোপ্লাজম স্বচ্ছ ও মসৃণ।"
        }
      ],
      "math_and_logic": null
    },
    "practice_examples": [
      {
        "question": "Describe the structure of a Hemoglobin molecule and its components.",
        "is_math": false,
        "steps": [
          "Step 1: Identify that Hemoglobin consists of four globin protein chains.",
          "Step 2: Explain that each chain is associated with one iron-containing Heme group.",
          "Step 3: State that the Heme group is responsible for the red color and oxygen binding."
        ],
        "answer": "Hemoglobin is a conjugate protein made of 4 polypeptide chains and 4 Heme groups.",
        "needs_diagram": true,
        "diagram_prompt": "A schematic diagram of a Hemoglobin molecule showing four intertwined polypeptide chains.",
        "diagram_reason": "A diagram helps visualize how the protein chains and heme groups are organized."
      },
      {
        "question": "List the types of Agranulocytes and their structural features.",
        "is_math": false,
        "steps": [
          "Step 1: Define Agranulocytes as WBCs with non-granular, clear cytoplasm.",
          "Step 2: Identify: Lymphocytes and Monocytes.",
          "Step 3: Describe nuclei: Lymphocytes have large round nuclei, Monocytes have kidney-shaped nuclei."
        ],
        "answer": "The two Agranulocytes are Lymphocytes and Monocytes.",
        "needs_diagram": false,
        "diagram_prompt": null,
        "diagram_reason": null
      },
      {
        "question": "If a patient has 3,000,000 RBCs in a sample, what is the expected number of WBCs?",
        "is_math": true,
        "steps": [
          "Step 1: Recall the standard RBC:WBC ratio is 600:1.",
          "Step 2: Set up: (Number of RBC) / 600 = Number of WBC.",
          "Step 3: Calculate 3,000,000 / 600.",
          "Step 4: Result."
        ],
        "answer": "5,000 WBCs per mm³.",
        "needs_diagram": false,
        "diagram_prompt": null,
        "diagram_reason": null
      },
      {
        "question": "Explain how RBCs act as a buffer in the blood.",
        "is_math": false,
        "steps": [
          "Step 1: Hemoglobin and other proteins in RBCs can bind to hydrogen ions.",
          "Step 2: By binding excess H+ ions, they prevent the blood from becoming too acidic.",
          "Step 3: This maintains the acid-base balance (pH) of the blood."
        ],
        "answer": "RBCs maintain pH balance by using hemoglobin as a buffer.",
        "needs_diagram": false,
        "diagram_prompt": null,
        "diagram_reason": null
      },
      {
        "question": "Compare Leukocytosis and Leukemia.",
        "is_math": false,
        "steps": [
          "Step 1: Leukocytosis is a temporary increase in WBCs due to infection.",
          "Step 2: Leukemia is a permanent, uncontrolled increase in abnormal WBCs.",
          "Step 3: Leukemia is life-threatening (cancer); Leukocytosis is an immune response."
        ],
        "answer": "Leukocytosis is healthy immune response; Leukemia is malignant blood cancer.",
        "needs_diagram": false,
        "diagram_prompt": null,
        "diagram_reason": null
      },
      {
        "question": "How does RBC influence the viscosity of blood?",
        "is_math": false,
        "steps": [
          "Step 1: RBC concentration determines blood density and thickness.",
          "Step 2: High RBC count increases viscosity; low RBC count decreases it.",
          "Step 3: Proper viscosity is essential for maintaining blood pressure and flow."
        ],
        "answer": "RBCs maintain blood viscosity ensuring efficient circulation.",
        "needs_diagram": false,
        "diagram_prompt": null,
        "diagram_reason": null
      },
      {
        "question": "State the origin and significance of Biliverdin.",
        "is_math": false,
        "steps": [
          "Step 1: Biliverdin is a green pigment from Heme group breakdown.",
          "Step 2: It is converted into Bilirubin or excreted through bile.",
          "Step 3: Its presence indicates normal recycling of blood components."
        ],
        "answer": "Biliverdin is a green pigment formed from Heme breakdown.",
        "needs_diagram": false,
        "diagram_prompt": null,
        "diagram_reason": null
      },
      {
        "question": "Discuss the role of Hydrogen Sulfide (H₂S) produced by RBCs.",
        "is_math": false,
        "steps": [
          "Step 1: RBCs produce H₂S gas as a signaling molecule.",
          "Step 2: H₂S signals the smooth muscles of blood vessels to contract or relax.",
          "Step 3: This regulates blood flow and vessel diameter."
        ],
        "answer": "RBCs produce H₂S which regulates blood vessel walls.",
        "needs_diagram": false,
        "diagram_prompt": null,
        "diagram_reason": null
      }
    ],
    "top_questions": [
      {
        "question_text": "Which part of the hemoglobin is responsible for the red color of blood?",
        "difficulty": "easy",
        "question_type": "mcq",
        "source": "HSC Board Exam",
        "options": {"A": "Globin protein", "B": "Plasma membrane", "C": "Heme group", "D": "Antigen"},
        "correct_option": "C",
        "selectable_points": null,
        "answer": null,
        "explanation": "The iron-containing heme group gives blood its red color."
      },
      {
        "question_text": "What are the two main types of pigments produced during RBC destruction?",
        "difficulty": "easy",
        "question_type": "short_answer",
        "source": "HSC Board Exam",
        "options": null,
        "correct_option": null,
        "selectable_points": null,
        "answer": "The two pigments are Bilirubin (yellow) and Biliverdin (green).",
        "explanation": "These pigments are metabolic byproducts of Heme breakdown."
      },
      {
        "question_text": "Explain why the RBC count increases in a baby's body.",
        "difficulty": "medium",
        "question_type": "short_answer",
        "source": "HSC Board Exam",
        "options": null,
        "correct_option": null,
        "selectable_points": null,
        "answer": "In infants, higher metabolic demand for oxygen necessitates higher RBC concentration.",
        "explanation": "Growth and high metabolic rates trigger increased erythropoiesis."
      },
      {
        "question_text": "Select the correct statements regarding White Blood Cells (WBC).",
        "difficulty": "medium",
        "question_type": "broad_answer",
        "source": "HSC Board Exam",
        "options": null,
        "correct_option": null,
        "selectable_points": [
          {"point": "WBCs contain hemoglobin.", "is_correct": false},
          {"point": "They are nucleated and irregular in shape.", "is_correct": true},
          {"point": "The average count is 7,500 per mm³.", "is_correct": true},
          {"point": "They are responsible for oxygen transport.", "is_correct": false},
          {"point": "They act as the body's mobile defense unit.", "is_correct": true}
        ],
        "answer": null,
        "explanation": "WBCs lack hemoglobin but have nuclei and perform vital immune functions."
      },
      {
        "question_text": "Analyze the consequences of a blood sample showing a WBC count of 150,000 per mm³.",
        "difficulty": "hard",
        "question_type": "creative",
        "source": "Medical Admission",
        "options": null,
        "correct_option": null,
        "selectable_points": null,
        "answer": "A count this high indicates Leukemia (blood cancer). This leads to severe anemia, immune failure, and death if untreated.",
        "explanation": "Massive WBC increases are characteristic of Leukemia."
      }
    ],
    "quick_test": [
      {
        "question": "What is the average lifespan of an RBC in humans?",
        "options": {"A": "10 days", "B": "60 days", "C": "120 days", "D": "200 days"},
        "correct_answer": "C",
        "explanation": "Red blood cells typically circulate for about 120 days."
      },
      {
        "question": "Which of these is NOT a granulocyte?",
        "options": {"A": "Neutrophil", "B": "Basophil", "C": "Lymphocyte", "D": "Eosinophil"},
        "correct_answer": "C",
        "explanation": "Lymphocytes and Monocytes are agranulocytes."
      },
      {
        "question": "The green pigment from heme breakdown is:",
        "options": {"A": "Bilirubin", "B": "Biliverdin", "C": "Hemocyanin", "D": "Chlorophyll"},
        "correct_answer": "B",
        "explanation": "Biliverdin is the green byproduct."
      },
      {
        "question": "WBCs are called 'Mobile Defense Units' because of:",
        "options": {"A": "Oxygen carrying", "B": "Phagocytosis", "C": "Hemoglobin content", "D": "Fixed position"},
        "correct_answer": "B",
        "explanation": "Phagocytosis allows them to engulf and kill pathogens."
      },
      {
        "question": "The average WBC count in a healthy adult is:",
        "options": {"A": "500-1,000", "B": "4,000-11,000", "C": "5 million", "D": "100,000"},
        "correct_answer": "B",
        "explanation": "The standard range is 4,000 to 11,000 cells per mm³."
      },
      {
        "question": "The ratio of RBC:WBC is approximately:",
        "options": {"A": "1:600", "B": "100:1", "C": "600:1", "D": "1:1"},
        "correct_answer": "C",
        "explanation": null
      },
      {
        "question": "Which cell type has a kidney-shaped nucleus?",
        "options": {"A": "Lymphocyte", "B": "Monocyte", "C": "Neutrophil", "D": "Eosinophil"},
        "correct_answer": "B",
        "explanation": "Monocytes have a distinct kidney-shaped nucleus."
      },
      {
        "question": "Leukocytosis typically occurs during:",
        "options": {"A": "Sleep", "B": "Infection", "C": "Starvation", "D": "Blood loss"},
        "correct_answer": "B",
        "explanation": "The body produces more WBCs to fight off pathogens during infection."
      }
    ]
  };
}
