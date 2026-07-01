/// Represents a Course as returned/consumed by the JSONPlaceholder API.
///
/// JSONPlaceholder's `/posts` resource is used to simulate course records:
///   - `title` -> course title
///   - `body`  -> course description
///   - `id`    -> course id
///   - `userId`-> owning "instructor" id (defaults to 1)
///
/// Docs: https://jsonplaceholder.typicode.com/guide
class CourseModel {
  final int? id;
  final int userId;
  final String title;
  final String description;

  const CourseModel({
    this.id,
    this.userId = 1,
    required this.title,
    required this.description,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] == null
          ? null
          : (json['id'] is int
              ? json['id'] as int
              : int.tryParse(json['id'].toString())),
      userId: json['userId'] is int ? json['userId'] as int : 1,
      title: (json['title'] ?? '').toString(),
      description: (json['body'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'title': title,
      'body': description,
    };
  }

  CourseModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
  }) {
    return CourseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }
}
