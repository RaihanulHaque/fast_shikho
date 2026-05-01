class QuickTestMCQ {
  final String question;
  final Map<String, String> options;
  final String correctAnswer;
  final String? explanation;

  QuickTestMCQ({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  factory QuickTestMCQ.fromJson(Map<String, dynamic> json) {
    return QuickTestMCQ(
      question: json['question'] as String,
      options: Map<String, String>.from(json['options'] as Map),
      correctAnswer: json['correct_answer'] as String,
      explanation: json['explanation'] as String?,
    );
  }
}
