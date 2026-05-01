/// Represents one interactive QA item in Key Points.
class ImportantPointQA {
  final String type; // mcq, true_false, fill_in_the_blanks, connecting_answer
  final String? question;
  final Map<String, String>? options; // A, B, C, D
  final String? correctOption;
  final bool? correctBool;
  final List<String>? blankOptions;
  final String? blankAnswer;
  final List<String>? leftItems;
  final List<String>? rightItems;
  final List<MatchPair>? correctMatches;
  final String explanation;

  ImportantPointQA({
    required this.type,
    this.question,
    this.options,
    this.correctOption,
    this.correctBool,
    this.blankOptions,
    this.blankAnswer,
    this.leftItems,
    this.rightItems,
    this.correctMatches,
    required this.explanation,
  });

  factory ImportantPointQA.fromJson(Map<String, dynamic> json) {
    return ImportantPointQA(
      type: json['type'] as String,
      question: json['question'] as String?,
      options: json['options'] != null
          ? Map<String, String>.from(json['options'] as Map)
          : null,
      correctOption: json['correct_option'] as String?,
      correctBool: json['correct_bool'] as bool?,
      blankOptions: json['blank_options'] != null
          ? List<String>.from(json['blank_options'] as List)
          : null,
      blankAnswer: json['blank_answer'] as String?,
      leftItems: json['left_items'] != null
          ? List<String>.from(json['left_items'] as List)
          : null,
      rightItems: json['right_items'] != null
          ? List<String>.from(json['right_items'] as List)
          : null,
      correctMatches: json['correct_matches'] != null
          ? (json['correct_matches'] as List)
              .map((e) => MatchPair.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      explanation: json['explanation'] as String,
    );
  }
}

class MatchPair {
  final String left;
  final String right;

  MatchPair({required this.left, required this.right});

  factory MatchPair.fromJson(Map<String, dynamic> json) {
    return MatchPair(
      left: json['left'] as String,
      right: json['right'] as String,
    );
  }
}

class EasyLesson {
  final String concept;
  final String explanation;

  EasyLesson({required this.concept, required this.explanation});

  factory EasyLesson.fromJson(Map<String, dynamic> json) {
    return EasyLesson(
      concept: json['concept'] as String,
      explanation: json['explanation'] as String,
    );
  }
}

class MathExample {
  final String formula;
  final String workedExample;

  MathExample({required this.formula, required this.workedExample});

  factory MathExample.fromJson(Map<String, dynamic> json) {
    return MathExample(
      formula: json['formula'] as String,
      workedExample: json['worked_example'] as String,
    );
  }
}

class KeyPoints {
  final List<String> whatToLearn;
  final String quickSummary;
  final List<String> shortcutTechniques;
  final List<ImportantPointQA> importantPointsQa;
  final List<EasyLesson> easyLessons;
  final List<MathExample>? mathAndLogic;

  KeyPoints({
    required this.whatToLearn,
    required this.quickSummary,
    required this.shortcutTechniques,
    required this.importantPointsQa,
    required this.easyLessons,
    this.mathAndLogic,
  });

  factory KeyPoints.fromJson(Map<String, dynamic> json) {
    return KeyPoints(
      whatToLearn: List<String>.from(json['what_to_learn'] as List),
      quickSummary: json['quick_summary'] as String,
      shortcutTechniques:
          List<String>.from(json['shortcut_techniques'] as List),
      importantPointsQa: (json['important_points_qa'] as List)
          .map((e) => ImportantPointQA.fromJson(e as Map<String, dynamic>))
          .toList(),
      easyLessons: (json['easy_lessons'] as List)
          .map((e) => EasyLesson.fromJson(e as Map<String, dynamic>))
          .toList(),
      mathAndLogic: json['math_and_logic'] != null
          ? (json['math_and_logic'] as List)
              .map((e) => MathExample.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}
