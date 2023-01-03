import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:skydo_flutter/todos/todo_model.dart';

String dbId = "63ada9616e452192e3e5";
String collId = "63ada9879e426f3b85f5";

class ApiService {
  static Client client = Client();
  static void init() {
    client
        .setEndpoint('https://appwrite.skyface.de/v1')
        .setProject('63ad9f6f86df3acb7d0a')
        .setSelfSigned(status: true);
  }

  static Future<bool> login(String email, String password) async {
    Account account = Account(client);
    try {
      models.Session response =
          await account.createEmailSession(email: email, password: password);
      print(response);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<List<TodoItem>?> getTodos({bool? withArchive}) async {
    init();
    Databases database = Databases(client);
    try {
      List<String> queries = [];
      if (withArchive != null && !withArchive) {
        queries.add(Query.equal('isActive', true));
      }
      models.DocumentList docs = await database.listDocuments(
          databaseId: dbId, collectionId: collId, queries: queries);

      List<TodoItem> todos = [];
      for (var item in docs.documents) {
        todos.add(TodoItem(
          id: item.$id,
          title: item.data['title'],
          desc: item.data['desc'],
          completed: item.data['completed'],
          isActive: item.data['isActive'],
          remindTime: item.data['remindTime'] != null
              ? DateTime.parse(item.data['remindTime'])
              : null,
          priority: item.data['priority'] != null
              ? todoPriorityFromString(item.data['priority'])
              : TodoPriority.without,
        ));
      }
      // Sort todos by remindTime
      todos.sort((a, b) {
        if (a.remindTime == null && b.remindTime == null) {
          return 0;
        } else if (a.remindTime == null) {
          return 1;
        } else if (b.remindTime == null) {
          return -1;
        } else {
          return a.remindTime!.compareTo(b.remindTime!);
        }
      });
      // Sort todos by completed
      todos.sort((a, b) {
        if (a.completed == b.completed) {
          return 0;
        } else if (a.completed) {
          return 1;
        } else {
          return -1;
        }
      });
      return todos;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<bool> createTodo({
    required String title,
    required String desc,
    DateTime? remindTime,
  }) async {
    init();
    if (title.isEmpty) {
      return false;
    }
    Databases database = Databases(client);
    try {
      models.Document doc = await database.createDocument(
          databaseId: dbId,
          collectionId: collId,
          documentId: ID.unique(),
          data: {
            'title': title,
            'desc': desc,
            'completed': false,
            'isActive': true,
            'remindTime': remindTime?.toIso8601String()
          });
      print(doc);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> updateTodo({
    required String id,
    required String title,
    required String desc,
    required bool completed,
    DateTime? remindTime,
    required TodoPriority pritority,
  }) async {
    if (title.isEmpty) {
      return false;
    }
    init();
    Databases database = Databases(client);
    try {
      models.Document doc = await database.updateDocument(
          databaseId: dbId,
          collectionId: collId,
          documentId: id,
          data: {
            'title': title,
            'desc': desc,
            'completed': completed,
            'remindTime': remindTime?.toIso8601String(),
            'priority': todoPriorityToString(pritority)
          });
      print(doc);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> toggleCompleted(String id, bool completed) async {
    init();
    Databases database = Databases(client);
    try {
      models.Document doc = await database.updateDocument(
          databaseId: dbId,
          collectionId: collId,
          documentId: id,
          data: {'completed': completed});
      print(doc);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> toggleActive(String id, bool isActive) async {
    init();
    Databases database = Databases(client);
    try {
      models.Document doc = await database.updateDocument(
          databaseId: dbId,
          collectionId: collId,
          documentId: id,
          data: {'isActive': isActive});
      print(doc);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> register(String email, String password) async {
    init();
    Account account = Account(client);
    try {
      models.Account acc = await account.create(
          email: email,
          password: password,
          name: email.split('@')[0],
          userId: ID.unique());
      print(acc);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future checkLogin() async {
    init();
    Account account = Account(client);
    try {
      models.Account acc = await account.get();
    } catch (e) {
      rethrow;
    }
  }
}
