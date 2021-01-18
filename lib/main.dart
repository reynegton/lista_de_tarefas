import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _toDoList = [];
  final _todoController = TextEditingController();
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  void _addToDo() {
    setState(() {
      Map<String, dynamic> newTodo = Map();
      newTodo["title"] = _todoController.text;
      newTodo["ok"] = false;
      _todoController.text = '';
      _toDoList.add(newTodo);
      _saveData();
    });
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _readData().then((data) {
        _toDoList = json.decode(data);
      });
    });
  }

  Widget buildItem(context, index) {
    return Dismissible(
      key: Key(
        DateTime.now().millisecondsSinceEpoch.toString(),
      ),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);

          _saveData();

          final snack = SnackBar(
            duration: Duration(seconds: 2),
            content: Text('Tarefa ${_lastRemoved['title']} removida.'),
            action: SnackBarAction(
              label: 'Desfazer',
              onPressed: () {
                setState(() {
                  _toDoList.insert(_lastRemovedPos, _lastRemoved);
                  _saveData();
                });
              },
            ),
          );
          Scaffold.of(context).showSnackBar(snack);
        });
      },
      child: CheckboxListTile(
        activeColor: Colors.teal,
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]['ok'],
        secondary: CircleAvatar(
          backgroundColor: Colors.teal,

          child: Icon(_toDoList[index]['ok'] ? Icons.check : Icons.error),
        ),
        onChanged: (check) {
          setState(() {
            _toDoList[index]['ok'] = check;
            _saveData();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de tarefas.'),
        backgroundColor: Colors.teal[400],
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _todoController,
                    decoration: InputDecoration(
                      labelText: "Nova Tarefa",
                      labelStyle: TextStyle(color: Colors.teal),
                    ),
                  ),
                ),
                RaisedButton(
                  color: Colors.teal,
                  child: Text('Add'),
                  textColor: Colors.white,
                  onPressed: _addToDo,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsetsDirectional.only(top: 10),
                itemCount: _toDoList.length,
                itemBuilder: buildItem),
          )
        ],
      ),
    );
  }
}
