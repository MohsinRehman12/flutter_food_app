import 'package:flutter/material.dart';
import 'dbprovider.dart';
import 'edit_order_plan_page.dart';
import 'orderplan.dart';

class QueryPage extends StatefulWidget {
  @override
  _QueryPageState createState() => _QueryPageState();
}

class _QueryPageState extends State<QueryPage> {
  final TextEditingController dateController = TextEditingController();
  final dbHelper = SQLiteDbProvider.db;
  OrderPlan? orderPlan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Plans From Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input for date in query
            TextFormField(
              controller: dateController,
              decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
            ),
            SizedBox(height: 16),

            // Query button that uses db commands to get the orderplan by date
            ElevatedButton(
              onPressed: () async {
                final plans = await dbHelper.getOrderPlanByDate(dateController.text);
                if (plans.isNotEmpty) {
                  setState(() {
                    orderPlan = OrderPlan.fromMap(plans.first);
                  });
                } else {
                  setState(() {
                    orderPlan = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No order plan found.')),
                  );
                }
              },
              child: Text('Query Order Plan'),
            ),




            SizedBox(height: 16),
            // Display Order Plan
            if (orderPlan != null) ...[
              Text('Date: ${orderPlan!.date}'),
              Text('Target Cost: \$${orderPlan!.targetCost.toString()}'),
              ElevatedButton(
                onPressed: () async {
                  final success = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditOrderPlanPage(orderPlan: orderPlan!),
                    ),
                  );

                  if (success == true) {
                    // Reload the updated order plan
                    final updatedPlans = await dbHelper.getOrderPlanByDate(orderPlan!.date);
                    setState(() {
                      if (updatedPlans.isNotEmpty) {
                        orderPlan = OrderPlan.fromMap(updatedPlans.first);
                      }
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Order Plan Updated!')),
                    );
                  }
                },
                child: Text('Edit Order Plan'),
              ),

              // Button to delete query function
              ElevatedButton(
                onPressed: () async {
                  await dbHelper.deleteOrderPlan(orderPlan!.id!);
                  setState(() {
                    orderPlan = null;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Order Plan Deleted!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text('Delete Order Plan'),
              ),

            ] else
              Text('No order plan found for the given date.'),
          ],
        ),
      ),
    );
  }
}
