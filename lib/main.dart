import 'package:flutter/material.dart';
import 'addChoreScreen.dart';
import 'package:provider/provider.dart';
import 'api.dart';

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
          //Navigerar till skärmen där en ny chore läggs till och väntar på svar
          final newChoreName = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddChoreScreen(), //Sidan där användaren lägger till en ny chore
            ),
          );

          if (newChoreName != null && newChoreName.isNotEmpty) {
            //Kollar så namnet på ny chore inte är tomt
            Chores newChore = Chores(
                "", newChoreName, false); //Skapar det nya chores-objektet
            await myState.apiAddChore(newChore).then(
                (addedChore) {}); // Lägger till det nya chore-objektet via API
          }
          myState.apiFetchChores(); //Uppdaterar chore-listan via API
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
            onTap: () {
              myState.toggleChoreStatus(
                  chore); //Funktionen som ändrar den lokala statusen för chore tille done/ej done
              myState.apiUpdateChore(
                  chore); //Uppdaterar status i API så att statusen även sparas på servern
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
