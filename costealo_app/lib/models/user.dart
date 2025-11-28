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
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      organization: json['organization']?.toString() ?? '',
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
