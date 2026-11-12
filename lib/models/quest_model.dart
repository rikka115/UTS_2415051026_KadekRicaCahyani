class QuestModel {
  final String? id;
  final String title;
  final String description;
  final int expReward;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? deadline; // Parameter deadline

  QuestModel({
    this.id,
    required this.title,
    required this.description,
    required this.expReward,
    this.isCompleted = false,
    this.createdAt,
    this.deadline,
  });

  factory QuestModel.fromJson(Map<String, dynamic> json) {
    return QuestModel(
      id: json['id']?.toString(),
      title: json['title'] as String? ?? 'Untitled Quest',
      description: json['description'] as String? ?? '',
      expReward: (json['exp_reward'] as num?)?.toInt() ?? 10,
      isCompleted: json['is_completed'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'exp_reward': expReward,
      'is_completed': isCompleted,
    };
    if (id != null) data['id'] = id;
    if (deadline != null) data['deadline'] = deadline!.toIso8601String();
    return data;
  }

  QuestModel copyWith({
    String? id,
    String? title,
    String? description,
    int? expReward,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? deadline,
  }) {
    return QuestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      expReward: expReward ?? this.expReward,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
    );
  }
}