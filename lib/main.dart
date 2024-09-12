import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(" TIG333 To Do"),
          centerTitle: true,
          backgroundColor: Colors.grey,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(Icons.more_vert),
            ),
          ],
        ),
        body: ListView(
          children: [
            addToList("Write a book"),
            Divider(),
            addToList("Do Homework"),
            Divider(),
            addToList("Tidy Room"),
            Divider(),
            addToList("Watch TV"),
            Divider(),
            addToList("Nap"),
            Divider(),
            addToList("Shop groceries"),
            Divider(),
            addToList("Have fun"),
            Divider(),
            addToList("Meditate"),
            Divider(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  ListTile addToList(String text) {
    return ListTile(
      leading: Icon(Icons.check_box),
      title: Text(text),
      trailing: Icon(Icons.close),
    );
  }
}
