import 'package:flutter/material.dart';
import 'add_chores_screen.dart';
import 'package:provider/provider.dart';
import 'chores_api.dart';

void main() {
  MyState state =
      MyState(); // Skapar en instans av MyState som håller ordning på todo-listan och hanterar API-kommunikationen

  runApp(
    ChangeNotifierProvider(
      create: (context) =>
          state, //Ger instansen MyState till alla underliggande widgets
      child: Myhome(),
    ),
  );
}

class Myhome extends StatelessWidget {
  const Myhome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final myState = Provider.of<MyState>(
        context); // Hämtar instansen av MyStatt och lyssnar på förändringar så att UI kan uppdateras när förändirngar sker

    return Scaffold(
      appBar: AppBar(
        title: Text("Michael Scotts ToDo"),
        centerTitle: true,
        backgroundColor: Colors.grey,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                myState.filterChores();
              },
              child: Icon(Icons.sort),
            ),
          ),
        ],
      ),
      body: myState.loading //Kollar om data laddas från API
          ? Center(
              child: CircularProgressIndicator()) //Laddar det, visa en symbol
          : ListView(
              //Annars, visa chorelistan
              children: myState.choresList
                  .map((chore) => buildChoreItem(context,
                      chore)) //Skapar en widget för varje chore i listan
                  .toList(), //Gör listan av chores till en lista av widgets
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newChoreName = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddChoreScreen(),
            ),
          );

          if (newChoreName != null && newChoreName.isNotEmpty) {
            Chores newChore = Chores("", newChoreName, false);
            await myState.apiAddChore(newChore);
            await myState.apiFetchChores();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  //Widget för att bygga en Chore
  Widget buildChoreItem(BuildContext context, Chores chore) {
    final myState = Provider.of<MyState>(context); //Hämtar instansen av MyState
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
          leading: GestureDetector(
            onTap: () async {
              myState.toggleChoreStatus(chore);

              await myState.apiUpdateChore(chore);
              await myState.apiFetchChores();
            },
            child: chore.done
                ? Icon(Icons
                    .check_box) // Om chore är markerad, visa en markerad checkbox
                : Icon(Icons
                    .check_box_outline_blank), // Annars, visa en omarkerad checkbox
          ),
          title: Text(
            chore.choreName,
            style: TextStyle(
              fontSize: 20,
              decoration: chore.done
                  ? TextDecoration.lineThrough
                  : TextDecoration.none, //Är chore markerad stryks texten
            ),
          ),
          trailing: GestureDetector(
            onTap: () {
              myState.apiRemoveChore(
                  chore); //Funktion som tar bort chore från listan på servern
            },
            child: Icon(Icons.close), //Kryss för att ta bort en chore
          ),
        ),
      ),
    );
  }
}
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class Chores {
  String id;
  String choreName;
  bool done;

  Chores(this.id, this.choreName, this.done);

  //Skapar en Chores-instans från en JSON-representation
  factory Chores.fromJson(Map<String, dynamic> json) {
    return Chores(json["id"], json["title"], json["done"]);
  }

  //Konverterar Chores-instansen tillbaka till JSON
  Map<String, dynamic> toJson() {
    return {
      "title": choreName,
      "done": done,
    };
  }
}

class MyState extends ChangeNotifier {
  final List<Chores> _choresList = []; //Lagrar chores lokalt
  List<Chores> _filteredChoresList = []; // Lagrar filtrerade chores
  bool _isFiltered = false;

  String apiKey = "41e758f7-f727-4de8-9a6d-9200fbe45b2f";
  String ENDPOINT = "https://todoapp-api.apps.k8s.gu.se";

  bool _loading = false;
  get loading => _loading; //Getter för att hämta loadingstatus

  //Getter för att hämta listan över chores
  List<Chores> get choresList => _choresList;

  // Getter för att hämta den filtrerade listan
  List<Chores> get filteredChoresList => _filteredChoresList.isNotEmpty
      ? _filteredChoresList
      : _choresList; // Visa den filtrerade listan om den inte är tom, annars visa alla chores

  // Konstruktor för MyState, hämtar chores från API direkt när state skapas
  MyState() {
    apiFetchChores();
  }

//Sortera listan

  void filterChores() {
    if (_isFiltered) {
      _filteredChoresList.clear();
    } else {
      _filteredChoresList = _choresList.where((chore) => !chore.done).toList();
    }
    _isFiltered = !_isFiltered;
    notifyListeners();
  }

  //Makera en chore i UI som done/ej done
  void toggleChoreStatus(Chores chore) {
    chore.done = !chore.done;
    notifyListeners();
  }

  //Visar en laddningssymbol medan async körs
  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  //Hämtar API-listan över todos
  Future<void> apiFetchChores() async {
    setLoading(true);
    final response =
        await http.get(Uri.parse("$ENDPOINT/todos?key=$apiKey"), headers: {
      "Content-Type": "application/json",
    });

    if (response.statusCode == 200) {
      // Kontrollerar om API-anropet lyckades
      final List<dynamic> choresJson = jsonDecode(response.body);
      _choresList.clear(); //Rensar listan (lokala) innan den fylls med apidata
      _choresList.addAll(
        choresJson.map((json) => Chores.fromJson(json)).toList(),
      );
      notifyListeners();
    } else {
      print("Failed to fetch chores: ${response.statusCode}");
    }
    setLoading(false);
  }

  //Lägger till ny chore i api-listan
  Future<void> apiAddChore(Chores chore) async {
    setLoading(true);

    final response = await http.post(
      Uri.parse("$ENDPOINT/todos?key=$apiKey"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(chore.toJson()),
    );
    if (response.statusCode == 200) {
      // Kontrollerar om API-anropet lyckades
      print("Added ${chore.choreName}, successfully.");
      final List<dynamic> chores = jsonDecode(response.body);
      for (var item in chores) {
        print("Todo: ${item['title']}, Done: ${item['done']}");
      }
    } else {
      print("Failed to add chore: ${response.statusCode}");
    }
    setLoading(false);
  }

//Uppdaterar en chores status
  Future<void> apiUpdateChore(Chores chore) async {
    final response = await http.put(
      Uri.parse("$ENDPOINT/todos/${chore.id}?key=$apiKey"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(chore.toJson()),
    );
    if (response.statusCode == 200) {
      // Kontrollerar om API-anropet lyckades
      print("Updated ${chore.choreName}");
    } else {
      print("Failed to update chore: ${response.statusCode}");
    }
  }

// Tar bort en chore från api-listan
  Future<void> apiRemoveChore(Chores chore) async {
    setLoading(true);

    final response = await http.delete(
      Uri.parse("$ENDPOINT/todos/${chore.id}?key=$apiKey"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(chore.toJson()),
    );
    if (response.statusCode == 200) {
      // Kontrollerar om API-anropet lyckades
      print("Removed ${chore.choreName}");
      apiFetchChores();
    } else {
      print("Failed to remove chore: ${response.statusCode}");
    }
    setLoading(false);
  }
}

class AddChoreScreen extends StatelessWidget {
  AddChoreScreen({super.key});

  final TextEditingController textInput =
      TextEditingController(); //Controller för att hantera input

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add ToDo"),
        centerTitle: true,
        backgroundColor: Colors.grey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            TextField(
              //Textfältet där användaren skriver in ny chore
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
                  final newChore =
                      textInput.text; //Hämtar texten från textfältet
                  Navigator.pop(context,
                      newChore); //Stänger skärmen och skickar tillbaka newChore
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
