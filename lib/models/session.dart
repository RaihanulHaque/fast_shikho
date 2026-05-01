class Session {
  final String id;
  final String userId;
  final String title;
  final String status; // pending, uploaded, processing, partial, complete, failed
  final String? detectedSubject;
  final int filePageCount;
  final DateTime createdAt;
  final DateTime? completedAt;

  Session({
    required this.id,
    required this.userId,
    required this.title,
    this.status = 'pending',
    this.detectedSubject,
    this.filePageCount = 0,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      status: json['status'] as String? ?? 'pending',
      detectedSubject: json['detected_subject'] as String?,
      filePageCount: json['file_page_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'status': status,
      'detected_subject': detectedSubject,
      'file_page_count': filePageCount,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  Session copyWith({
    String? title,
    String? status,
    String? detectedSubject,
    int? filePageCount,
    DateTime? completedAt,
  }) {
    return Session(
      id: id,
      userId: userId,
      title: title ?? this.title,
      status: status ?? this.status,
      detectedSubject: detectedSubject ?? this.detectedSubject,
      filePageCount: filePageCount ?? this.filePageCount,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  bool get isComplete => status == 'complete';
  bool get isFailed => status == 'failed';
  bool get isProcessing => status == 'processing' || status == 'partial';
}
