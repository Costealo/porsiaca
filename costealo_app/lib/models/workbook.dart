class WorkbookItem {
  final int? id;
  String name;
  double quantity;
  String unit;
  double additionalCost;
  double calculatedCost;

  WorkbookItem({
    this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.additionalCost = 0,
    this.calculatedCost = 0,
  });

  factory WorkbookItem.fromJson(Map<String, dynamic> json) {
    return WorkbookItem(
      id: json['id'],
      name: json['name'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      additionalCost: (json['additionalCost'] ?? 0).toDouble(),
      calculatedCost: (json['calculatedCost'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'additionalCost': additionalCost,
      'calculatedCost': calculatedCost,
    };
  }
}

class Workbook {
  final int? id;
  String name;
  double productionUnits;
  double sellingPrice;
  double profitMargin;
  String status; // Draft, Published
  String? bob;
  List<WorkbookItem> items;
  DateTime createdAt;

  Workbook({
    this.id,
    required this.name,
    this.productionUnits = 1,
    this.sellingPrice = 0,
    this.profitMargin = 20,
    this.status = 'Draft',
    this.bob,
    this.items = const [],
    required this.createdAt,
  });

  factory Workbook.fromJson(Map<String, dynamic> json) {
    return Workbook(
      id: json['id'],
      name: json['name'] ?? '',
      productionUnits: (json['productionUnits'] ?? 1).toDouble(),
      sellingPrice: (json['sellingPrice'] ?? 0).toDouble(),
      profitMargin: (json['profitMargin'] ?? 20).toDouble(),
      status: json['status'] ?? 'Draft',
      bob: json['bob'],
      items: (json['items'] as List?)?.map((i) => WorkbookItem.fromJson(i)).toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
