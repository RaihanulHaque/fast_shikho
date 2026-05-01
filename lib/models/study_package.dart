import 'key_points.dart';
import 'practice_example.dart';
import 'top_question.dart';
import 'quick_test.dart';

class StudyPackage {
  final String sessionTitle;
  final String detectedSubject;
  final String classLevelHint;
  final KeyPoints keyPoints;
  final List<PracticeExample> practiceExamples;
  final List<TopQuestion> topQuestions;
  final List<QuickTestMCQ> quickTest;

  StudyPackage({
    required this.sessionTitle,
    required this.detectedSubject,
    required this.classLevelHint,
    required this.keyPoints,
    required this.practiceExamples,
    required this.topQuestions,
    required this.quickTest,
  });

  factory StudyPackage.fromJson(Map<String, dynamic> json) {
    return StudyPackage(
      sessionTitle: json['session_title'] as String,
      detectedSubject: json['detected_subject'] as String,
      classLevelHint: json['class_level_hint'] as String,
      keyPoints:
          KeyPoints.fromJson(json['key_points'] as Map<String, dynamic>),
      practiceExamples: (json['practice_examples'] as List)
          .map((e) => PracticeExample.fromJson(e as Map<String, dynamic>))
          .toList(),
      topQuestions: (json['top_questions'] as List)
          .map((e) => TopQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      quickTest: (json['quick_test'] as List)
          .map((e) => QuickTestMCQ.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
