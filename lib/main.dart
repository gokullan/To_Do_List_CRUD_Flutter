import 'dart:async';

import 'package:flutter/material.dart';

import 'expense.dart';
import 'db-manipulation.dart';

void main() async {
  // Avoid errors caused by flutter upgrade.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primaryColor: Colors.green,
        // colorSchemeSeed: Colors.deepPurpleAccent,
        // useMaterial3: true,
      ),
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  final DatabaseManipulation dbObj = DatabaseManipulation("expenses.db", 1);
  Home({Key? key}) : super(key: key);  // why no const?

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Expense Tracker"
        ),
        centerTitle: true,
      ),
      body: CrudUI(
        dbObj: dbObj,
      ),
    );
  }
}

class CrudUI extends StatefulWidget {
  final DatabaseManipulation dbObj;
  const CrudUI({Key? key, required this.dbObj}) : super(key: key);

  @override
  State<CrudUI> createState() => _CrudUIState();
}

class _CrudUIState extends State<CrudUI> {
  List<Expense> allExpenses = [];
  bool initialized = false;

  Future<Expense?> getExpense() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final _formKey = GlobalKey<FormState>();
        int id = -1;
        String item = "";
        double amount = 0.0;
        return AlertDialog(
          title: const Text("Enter Expense"),
          content: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "ID",
                  ),
                  onChanged: (text) => id = int.parse(text),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Item Name",
                  ),
                  onChanged: (text) => item = text,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Amount",
                  ),
                  onChanged: (text) => amount = double.parse(text),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context,
                      Expense(id: id, item: item, amount: amount, date: DateTime.now())
                  );
                },
                child: const Text("Save"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      return FutureBuilder(
        future: widget.dbObj.getExpenses(),
        builder: (BuildContext context, AsyncSnapshot<List<Expense>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }
          else if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError){
            initialized = true;
            allExpenses = snapshot.data as List<Expense>;
            return build(context);
          }
          return const Text("Error!");
        }
      );
    }
    else {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: allExpenses.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(allExpenses[index].item),
                  subtitle: Text(
                    '${allExpenses[index].amount} | ${allExpenses[index].date}',
                  ),
                );
              }
            ),
          ),
          TextButton(
            onPressed: () async {
              Expense? toInsert = await getExpense();
              toInsert != null ? widget.dbObj.insertExpense(toInsert) : print("Hi");
              setState(() {
                initialized = false;
                // allExpenses.add(toInsert);
              });
            },
            child: const Text("Add Item"),
          )
        ]
      );
    }
  }
}



