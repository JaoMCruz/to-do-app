
class Task {
  int id;
  String title;
  String status;
  String? description;

  Task({
    required this.id,
    required this.title,
    required this.status,
    required this.description
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      status: json['status'],
      description :json['description'],
    );
  }
}