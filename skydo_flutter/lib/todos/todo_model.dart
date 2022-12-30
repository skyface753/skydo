class TodoItem {
  String id;
  String title;
  String desc;
  bool completed;
  bool isActive;
  DateTime? remindTime;

  TodoItem({
    required this.id,
    required this.title,
    required this.desc,
    this.completed = false,
    this.isActive = true,
    this.remindTime,
  });
}
