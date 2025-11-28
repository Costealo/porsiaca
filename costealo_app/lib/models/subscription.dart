class Subscription {
  final String planName;
  final int databaseLimit;
  final int databaseUsage;
  final int workbookLimit;
  final int workbookUsage;
  final DateTime? expiryDate;

  Subscription({
    required this.planName,
    required this.databaseLimit,
    required this.databaseUsage,
    required this.workbookLimit,
    required this.workbookUsage,
    this.expiryDate,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      planName: json['planName'] ?? 'Free',
      databaseLimit: json['databaseLimit'] ?? 5,
      databaseUsage: json['databaseUsage'] ?? 0,
      workbookLimit: json['workbookLimit'] ?? 10,
      workbookUsage: json['workbookUsage'] ?? 0,
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
    );
  }

  // Mock data for development
  factory Subscription.mock() {
    return Subscription(
      planName: 'Plan Gratuito',
      databaseLimit: 3,
      databaseUsage: 1,
      workbookLimit: 5,
      workbookUsage: 2,
      expiryDate: DateTime.now().add(const Duration(days: 30)),
    );
  }
}
