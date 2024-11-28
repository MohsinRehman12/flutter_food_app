import 'package:flutter/material.dart';
import 'dbprovider.dart';
import 'home_screen.dart'; // Ensure this file contains your HomeScreen implementation.

void main() async {

  WidgetsFlutterBinding.ensureInitialized();


  // Populate the database with 20 food items
  await SQLiteDbProvider.db.populateFoodItems();

  // Run the app
  runApp(MyApp());
}

// build the apps components and show the home screen
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering App',
      home: HomeScreen(),
    );
  }
}
