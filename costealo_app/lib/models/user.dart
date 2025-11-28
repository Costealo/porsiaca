class User {
  final String id;
  final String email;
  final String name;
  final String organization;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.organization,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      organization: json['organization'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'organization': organization,
    };
  }
}
