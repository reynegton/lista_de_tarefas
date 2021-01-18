import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import '../src/localfile.dart';


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
      saveData(_toDoList);
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      readData().then((data) {
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

          saveData(_toDoList);

          final snack = SnackBar(
            duration: Duration(seconds: 2),
            content: Text('Tarefa ${_lastRemoved['title']} removida.'),
            action: SnackBarAction(
              label: 'Desfazer',
              onPressed: () {
                setState(() {
                  _toDoList.insert(_lastRemovedPos, _lastRemoved);
                  saveData(_toDoList);
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
            saveData(_toDoList);
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