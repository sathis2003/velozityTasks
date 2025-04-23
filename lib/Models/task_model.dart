class Task {
  final String id;
  final String title;
  final String description;
  final DateTime? deadline;
  bool isCompleted; // Make this mutable for toggle functionality

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.deadline,
    this.isCompleted = false,
  });

  // Empty/default task
  factory Task.empty() {
    return Task(
      id: '',
      title: '',
      description: '',
      deadline: null,
      isCompleted: false,
    );
  }

  // Create a copy with modified properties
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  // Deserialize from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
