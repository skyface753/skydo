import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:skydo_flutter/api_service.dart';
import 'package:skydo_flutter/todos/todo_model.dart';

class CreateTodoPage extends StatefulWidget {
  static String routeName = '/todos/create';

  TodoItem? todo;
  CreateTodoPage({Key? key, this.todo}) : super(key: key);

  @override
  _CreateTodoPageState createState() => _CreateTodoPageState();
}

class _CreateTodoPageState extends State<CreateTodoPage> {
  String? itemId;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  bool _completed = false;
  DateTime? _reminderDate;
  bool _withReminder = false;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      itemId = widget.todo!.id;
      _titleController.text = widget.todo!.title;
      _descController.text = widget.todo!.desc;
      _completed = widget.todo!.completed;
      if (widget.todo!.remindTime != null) {
        _withReminder = true;
        _reminderDate = widget.todo!.remindTime;
      }
      setState(() {});
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: itemId == null
            ? const Text('Create Todo')
            : Text('Edit Todo: ${itemId!}'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some Title';
                    }
                    return null;
                  },
                ),
                Container(height: 8.0),
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                Container(height: 8.0),
                itemId != null
                    ? Row(children: [
                        Text('Completed: '),
                        Switch(
                            value: _completed,
                            onChanged: (value) {
                              setState(() {
                                _completed = value;
                              });
                            }),
                      ])
                    : Container(),
                // Date and Time Picket
                Row(
                  children: [
                    Text('With Reminder: '),
                    Switch(
                        value: _withReminder,
                        onChanged: (value) {
                          setState(() {
                            _withReminder = value;
                            if (_withReminder && _reminderDate == null) {
                              _reminderDate = DateTime.now();
                            }
                          });
                        }),
                  ],
                ),
                _withReminder
                    ? Row(
                        children: [
                          Text('Reminder: '),
                          Text(_reminderDate == null
                              ? 'Not set'
                              : '${_reminderDate!.day}/${_reminderDate!.month}/${_reminderDate!.year} ${_reminderDate!.hour}:${_reminderDate!.minute}'),
                          ElevatedButton(
                              onPressed: () {
                                DatePicker.showDateTimePicker(context,
                                    showTitleActions: true,
                                    onChanged: (date) {}, onConfirm: (date) {
                                  setState(() {
                                    _reminderDate = date;
                                  });
                                },
                                    currentTime: DateTime.now(),
                                    locale: LocaleType.en);
                              },
                              child: const Text('Set'))
                        ],
                      )
                    : Container(),
                ElevatedButton(
                    child: Text(itemId == null ? 'Create' : 'Update'),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      if (itemId != null) {
                        if (await ApiService.updateTodo(
                            id: itemId!,
                            title: _titleController.text,
                            desc: _descController.text,
                            remindTime: _withReminder ? _reminderDate : null,
                            completed: _completed)) {
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Update failed'),
                            ),
                          );
                        }
                        return;
                      }
                      if (await ApiService.createTodo(
                          title: _titleController.text,
                          desc: _descController.text,
                          remindTime: _withReminder ? _reminderDate : null)) {
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Create failed'),
                          ),
                        );
                      }
                    })
              ],
            ),
          )),
    );
  }
}
