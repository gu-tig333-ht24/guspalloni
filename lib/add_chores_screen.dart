import 'package:flutter/material.dart';

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
