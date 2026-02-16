class ItemModel {
  final String? id;
  final String title;
  final String description;
  final int createdAt;
  final int? updatedAt;

  ItemModel({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.updatedAt,
  });

  factory ItemModel.fromFirestore(String id, Map<String, dynamic> data) {
    return ItemModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt: data['createdAt'] ?? 0,
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}
