import 'package:flutter/material.dart';

void main() {
  runApp(Myhome());
}

class Chores {
  String choreName;
  bool done;

  Chores(this.choreName, this.done);
}

List<Chores> choresList = [
  Chores("Write a book", false),
  Chores("Do Homework", false),
  Chores("Tidy Room", true),
  Chores("Watch Tv", false),
  Chores("Nap", false),
  Chores("Shop Groceries", false),
  Chores("Have fun", false),
  Chores("Meditate", false)
];

class Myhome extends StatelessWidget {
  const Myhome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        children: choresList
            .map((chore) =>
                buildChoreItem(context, chore.choreName, chore.done, chore))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newChore = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SecondScreen(),
            ),
          );
          if (newChore != null && newChore.isNotEmpty) {
            //Kollar om man lagt till en ny chore
            setState(() {
              choresList.add(Chores(
                  newChore, false)); //Lägger till ny chore till choresList
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildChoreItem(
      BuildContext context, String choreName, bool done, Chores chore) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            setState(() {
              chore.done = !chore.done;
            });
          },
          child: done
              ? Icon(Icons.check_box)
              : Icon(Icons.check_box_outline_blank),
        ),
        title: done
            ? Text(
                choreName,
                style: TextStyle(
                    decoration: TextDecoration.lineThrough, fontSize: 20),
              )
            : Text(
                choreName,
                style: TextStyle(fontSize: 20),
              ),
        trailing: GestureDetector(
          onTap: () {
            setState(() {
              choresList.remove(chore);
            });
          },
          child: (Icon(Icons.close)),
        ),
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  TextEditingController textInput = TextEditingController();
  String newTask = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TIG333 TODO"),
        centerTitle: true,
        backgroundColor: Colors.grey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "What are you going to do?",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              controller: textInput,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    newTask = textInput.text;
                  });
                  Navigator.pop(context, newTask);
                },
                child: Text(
                  "+ ADD",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
