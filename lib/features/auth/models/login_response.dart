class LoginResponse {
  final int id;
  final String name;
  final String lastName;
  final String token;
  final String role;

  LoginResponse({
    required this.id,
    required this.name,
    required this.lastName,
    required this.token,
    required this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      lastName: json['lastName'] ?? '',
      token: json['token'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastName': lastName,
      'token': token,
      'role': role,
    };
  }
}