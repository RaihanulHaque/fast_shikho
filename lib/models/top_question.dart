class SelectablePoint {
  final String point;
  final bool isCorrect;

  SelectablePoint({required this.point, required this.isCorrect});

  factory SelectablePoint.fromJson(Map<String, dynamic> json) {
    return SelectablePoint(
      point: json['point'] as String,
      isCorrect: json['is_correct'] as bool,
    );
  }
}

class TopQuestion {
  final String questionText;
  final String difficulty; // easy, medium, hard
  final String questionType; // short_answer, creative, mcq, broad_answer
  final String source;
  final Map<String, String>? options;
  final String? correctOption;
  final List<SelectablePoint>? selectablePoints;
  final String? answer;
  final String explanation;

  TopQuestion({
    required this.questionText,
    required this.difficulty,
    required this.questionType,
    required this.source,
    this.options,
    this.correctOption,
    this.selectablePoints,
    this.answer,
    required this.explanation,
  });

  factory TopQuestion.fromJson(Map<String, dynamic> json) {
    return TopQuestion(
      questionText: json['question_text'] as String,
      difficulty: json['difficulty'] as String,
      questionType: json['question_type'] as String,
      source: json['source'] as String,
      options: json['options'] != null
          ? Map<String, String>.from(json['options'] as Map)
          : null,
      correctOption: json['correct_option'] as String?,
      selectablePoints: json['selectable_points'] != null
          ? (json['selectable_points'] as List)
              .map((e) => SelectablePoint.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      answer: json['answer'] as String?,
      explanation: json['explanation'] as String,
    );
  }
}
