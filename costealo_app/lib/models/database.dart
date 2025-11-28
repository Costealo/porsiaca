class DatabaseItem {
  final int? id;
  String name; // Mapped to 'product' in JSON
  double price;
  String unit;
  double? quantity; // For workbook usage

  DatabaseItem({
    this.id,
    required this.name,
    required this.price,
    required this.unit,
    this.quantity,
  });

  factory DatabaseItem.fromJson(Map<String, dynamic> json) {
    return DatabaseItem(
      id: json['id'],
      name: json['product'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'product': name,
      'price': price,
      'unit': unit,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}

class PriceDatabase {
  final int? id;
  final String name;
  final int itemCount;
  final DateTime createdAt;
  final String? bob;
  final String? sourceUrl;

  PriceDatabase({
    this.id,
    required this.name,
    this.itemCount = 0,
    required this.createdAt,
    this.bob,
    this.sourceUrl,
  });

  factory PriceDatabase.fromJson(Map<String, dynamic> json) {
    return PriceDatabase(
      id: json['id'],
      name: json['name'] ?? '',
      itemCount: json['itemCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      bob: json['bob'],
      sourceUrl: json['sourceUrl'],
    );
  }
}
