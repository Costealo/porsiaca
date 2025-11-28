class DatabaseItem {
  final int? id;
  String name;
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
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'unit': unit,
    };
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
