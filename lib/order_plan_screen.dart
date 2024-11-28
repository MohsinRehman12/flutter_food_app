import 'package:flutter/material.dart';
import 'dbprovider.dart';
import 'food_item.dart';

class OrderPlanPage extends StatefulWidget {
  @override
  _OrderPlanPageState createState() => _OrderPlanPageState();
}

class _OrderPlanPageState extends State<OrderPlanPage> {
  final TextEditingController targetCostController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController newItemNameController = TextEditingController();
  final TextEditingController newItemCostController = TextEditingController();

  final List<FoodItem> selectedItems = [];
  final dbHelper = SQLiteDbProvider.db;
  List<FoodItem> allItems = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await dbHelper.getAllFoodItems();
    setState(() {
      allItems = items;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Order Plan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            //Input for date
            TextFormField(
              controller: dateController,
              decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
            ),
            SizedBox(height: 16),

            // Input for target cost
            TextFormField(
              controller: targetCostController,
              decoration: InputDecoration(labelText: 'Target Cost'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),


            SizedBox(height: 16),

            // Expanded(Scrollable) List of Food
            Expanded(
              child: ListView.builder(
                itemCount: allItems.length,
                itemBuilder: (context, index) {
                  final item = allItems[index];
                  return CheckboxListTile(
                    title: Text(item.name),
                    subtitle: Text('Cost: \$${item.cost.toString()}'),
                    value: selectedItems.contains(item),
                    onChanged: (bool? isSelected) {
                      setState(() {
                        if (isSelected == true) {
                          selectedItems.add(item);
                        } else {
                          selectedItems.remove(item);
                        }
                      });
                    },
                  );
                },
              ),
            ),

            //save button that compares target to final cost and if its inccorect it deletes it
            ElevatedButton(
              onPressed: () async {
                final targetCost = double.tryParse(targetCostController.text);
                final totalCost = selectedItems.fold(0.0, (sum, item) => sum + item.cost);

                if (targetCost != null && totalCost <= targetCost) {
                  final selectedItemIds = selectedItems.map((item) => item.id.toString()).join(',');

                  await dbHelper.saveOrderPlan(
                    dateController.text,
                    targetCost,
                    selectedItemIds,
                  );

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('order plan is saved')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Target cost exceeded/ Possible Error please meet requirements')),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
