class IngredientModel {
  final String name;
  final double amount;
  final String unit;
  final String? imageUrl;

  IngredientModel({
    required this.name,
    required this.amount,
    required this.unit,
    this.imageUrl,
  });

  factory IngredientModel.fromMap(Map<String, dynamic> map) {
    return IngredientModel(
      name: map['name'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
      'imageUrl': imageUrl,
    };
  }

  double scaledAmount(int currentServings, int baseServings) {
    if (baseServings <= 0) return amount;
    return (amount * currentServings) / baseServings;
  }

  String formattedAmount(int currentServings, int baseServings) {
    final val = scaledAmount(currentServings, baseServings);
    if (val == val.roundToDouble()) {
      return val.toInt().toString();
    }
    // Clean up floating point precision issues (e.g., 0.33, 1.5)
    return val.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  }
}
