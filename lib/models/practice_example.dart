class PracticeExample {
  final String question;
  final bool isMath;
  final List<String> steps;
  final String answer;
  final bool needsDiagram;
  final String? diagramPrompt;
  final String? diagramReason;
  final String? diagramUrl; // S3 URL injected by backend

  PracticeExample({
    required this.question,
    required this.isMath,
    required this.steps,
    required this.answer,
    this.needsDiagram = false,
    this.diagramPrompt,
    this.diagramReason,
    this.diagramUrl,
  });

  factory PracticeExample.fromJson(Map<String, dynamic> json) {
    return PracticeExample(
      question: json['question'] as String,
      isMath: json['is_math'] as bool,
      steps: List<String>.from(json['steps'] as List),
      answer: json['answer'] as String,
      needsDiagram: json['needs_diagram'] as bool? ?? false,
      diagramPrompt: json['diagram_prompt'] as String?,
      diagramReason: json['diagram_reason'] as String?,
      diagramUrl: json['diagram_url'] as String?,
    );
  }
}
