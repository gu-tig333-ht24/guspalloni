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
