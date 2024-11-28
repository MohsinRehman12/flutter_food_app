import 'package:flutter/material.dart';
import 'dbprovider.dart';
import 'food_item.dart';
import 'orderplan.dart';

class EditOrderPlanPage extends StatefulWidget {
  final OrderPlan orderPlan;

  EditOrderPlanPage({required this.orderPlan});

  @override
  _EditOrderPlanPageState createState() => _EditOrderPlanPageState();
}

class _EditOrderPlanPageState extends State<EditOrderPlanPage> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController targetCostController = TextEditingController();

  final List<FoodItem> selectedItems = [];
  final dbHelper = SQLiteDbProvider.db;
  List<FoodItem> allItems = [];

  @override
  void initState() {
    super.initState();
    dateController.text = widget.orderPlan.date;
    targetCostController.text = widget.orderPlan.targetCost.toString();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await dbHelper.getAllFoodItems();
    final selectedIds = widget.orderPlan.selectedItems.split(',').map(int.parse).toList();
    final selected = items.where((item) => selectedIds.contains(item.id)).toList();

    setState(() {
      allItems = items;
      selectedItems.addAll(selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Order Plan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: dateController,
              decoration: InputDecoration(labelText: 'Enter Date (YYYY-MM-DD)'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: targetCostController,
              decoration: InputDecoration(labelText: 'Target Cost'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
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

            // button to submit update that checks if everything is valid in terms of cost not exceeded and inputs
            ElevatedButton(
              onPressed: () async {
                final targetCost = double.tryParse(targetCostController.text);
                final totalCost = selectedItems.fold(0.0, (sum, item) => sum + item.cost);

                if (targetCost == null || totalCost > targetCost) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Total cost exceeds target cost!')),
                  );
                  return;
                }

                final selectedItemIds = selectedItems.map((item) => item.id.toString()).join(',');

                await dbHelper.updateOrderPlan(
                  widget.orderPlan.id!,
                  dateController.text,
                  targetCost,
                  selectedItemIds,
                );

                Navigator.pop(context, true);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
