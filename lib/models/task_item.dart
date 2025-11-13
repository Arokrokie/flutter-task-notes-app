class TaskItem {
  int? id;
  String title;
  String priority;
  String description;
  bool isCompleted;

  TaskItem({
    this.id,
    required this.title,
    required this.priority,
    required this.description,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      priority: json['priority'] as String? ?? 'Low',
      description: json['description'] as String? ?? '',
      isCompleted: (json['isCompleted'] == 1 || json['isCompleted'] == true),
    );
  }
}
