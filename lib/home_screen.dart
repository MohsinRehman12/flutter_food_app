import 'package:flutter/material.dart';
import 'package:flutter_food_app/query_page.dart';
import 'dbprovider.dart';
import 'food_item.dart';
import 'order_plan_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dbHelper = SQLiteDbProvider.db;
  late Future<List<FoodItem>> _foodItemsFuture;

  @override
  void initState() {
    super.initState();
    _refreshFoodItems();
  }

  //get the 20 items of food
  void _refreshFoodItems() {
    setState(() {
      _foodItemsFuture = dbHelper.getAllFoodItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Ordering App'),
      ),
      body: FutureBuilder<List<FoodItem>>(
        future: _foodItemsFuture,
        builder: (context, snapshot) {
           if (snapshot.hasError) {

            return Center(child: Text('Error: ${snapshot.error}'));

          }
           else if (!snapshot.hasData || snapshot.data!.isEmpty) {

            return Center(child: Text('No food items listed were found in the DB.'));

          }
           else {
            final items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index].name),
                  subtitle: Text('Cost: \$${items[index].cost.toString()}'),
                );
              },
            );
          }
        },
      ),

      // button column that contains the button to redirect to query page and order plan page
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [

          FloatingActionButton(
            child: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderPlanPage()),
              );
            },
            heroTag: 'addPlan',
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            child: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QueryPage()),
              );
            },
            heroTag: 'queryPlan',
          ),
        ],
      ),
    );
  }
}
