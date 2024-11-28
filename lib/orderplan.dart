
//constructor and factory for order plans

class OrderPlan {
  final int? id;
  final String date;
  final double targetCost;
  final String selectedItems;

  OrderPlan({
    this.id,
    required this.date,
    required this.targetCost,
    required this.selectedItems,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'target_cost': targetCost,
      'selected_items': selectedItems,
    };
  }

  factory OrderPlan.fromMap(Map<String, dynamic> map) {
    return OrderPlan(
      id: map['id'],
      date: map['date'],
      targetCost: map['target_cost'],
      selectedItems: map['selected_items'],
    );
  }
}
