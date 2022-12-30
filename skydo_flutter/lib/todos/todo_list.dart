import 'package:flutter/material.dart';
import 'package:skydo_flutter/LoginPage.dart';
import 'package:skydo_flutter/api_service.dart';
import 'package:skydo_flutter/todos/create_todo.dart';
import 'package:skydo_flutter/todos/todo_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TodoListPaage extends StatefulWidget {
  static String routeName = '/todos';
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPaage> {
  List<TodoItem> _todos = [];
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();
    loadTodos();
  }

  void loadTodos({
    bool withArchived = false,
  }) async {
    final todos = await ApiService.getTodos(
      withArchive: withArchived,
    );
    setState(() {
      _todos = todos!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          // Refresh with archived todos
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              loadTodos(withArchived: true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: () async {
              await Navigator.pushNamed(context, LoginPage.routeName);
              setState(() {
                loadTodos();
              });
            },
          ),
        ],
      ),
      body: _buildTodos(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, CreateTodoPage.routeName);
          setState(() {
            loadTodos();
          });
        },
        tooltip: 'Add Todo',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodos() {
    return RefreshIndicator(
        onRefresh: () async {
          loadTodos(withArchived: true);
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _todos.length * 2,
          itemBuilder: (context, i) {
            if (i.isOdd) return const Divider();

            final index = i ~/ 2;
            if (index >= _todos.length) {
              return Text('No more todos');
            }
            return _buildRow(_todos[index]);
          },
        ));
  }

  Widget _buildRow(TodoItem todo) {
    return Slidable(
        endActionPane: _buildActionPane(todo),
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateTodoPage(todo: todo),
              ),
            ).then((value) {
              setState(() {
                loadTodos();
              });
            });
          },
          tileColor: !todo.isActive ? Colors.grey.withOpacity(0.5) : null,
          leading: Icon(
            todo.completed ? Icons.check_box : Icons.check_box_outline_blank,
            color: todo.completed ? Colors.green : null,
          ),
          title: Text(
            todo.title,
            style: _biggerFont,
          ),
        ));
  }

  ActionPane _buildActionPane(TodoItem todo) {
    return ActionPane(
      motion: const ScrollMotion(),
      children: [
        SlidableAction(
          // icon:  Icons.check_box,
          icon:
              todo.completed ? Icons.check_box : Icons.check_box_outline_blank,
          backgroundColor: todo.completed ? Colors.green : Colors.blue,
          label: todo.completed ? 'Reopen' : 'Mark as completed',
          // Function(BuildContext)? onPressed
          onPressed: (context) async {
            await ApiService.toggleCompleted(todo.id, !todo.completed);
            setState(() {
              loadTodos();
            });
          },
        ),
        SlidableAction(
          // icon: Icons.archive,
          icon: todo.isActive ? Icons.archive : Icons.unarchive,
          backgroundColor: todo.isActive ? Colors.orange : Colors.blue,
          label: todo.isActive ? 'Archive' : 'Unarchive',
          onPressed: (context) async {
            await ApiService.toggleActive(todo.id, !todo.isActive);
            setState(() {
              loadTodos();
            });
          },
        ),
      ],
    );
  }
}
