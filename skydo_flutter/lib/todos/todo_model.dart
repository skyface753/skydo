class TodoItem {
  String id;
  String title;
  String desc;
  bool completed;
  bool isActive;
  DateTime? remindTime;
  TodoPriority priority;

  TodoItem(
      {required this.id,
      required this.title,
      required this.desc,
      this.completed = false,
      this.isActive = true,
      this.remindTime,
      required this.priority});
}

enum TodoPriority {
  without,
  low,
  normal,
  high,
}

String todoPriorityToString(TodoPriority priority) {
  switch (priority) {
    case TodoPriority.without:
      return 'Without';
    case TodoPriority.low:
      return 'Low';
    case TodoPriority.normal:
      return 'Normal';
    case TodoPriority.high:
      return 'High';
    default:
      return 'Without';
  }
}

TodoPriority todoPriorityFromString(String priority) {
  switch (priority) {
    case 'Without':
      return TodoPriority.without;
    case 'Low':
      return TodoPriority.low;
    case 'Normal':
      return TodoPriority.normal;
    case 'High':
      return TodoPriority.high;
    default:
      return TodoPriority.without;
  }
}
