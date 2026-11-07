/// Roles a Muyu user can work as. A person picks one after logging in.
enum UserRole {
  farmer('farmer'),
  merchant('merchant');

  const UserRole(this.value);

  final String value;

  static UserRole? tryParse(String? value) {
    for (final role in UserRole.values) {
      if (role.value == value) return role;
    }
    return null;
  }
}

class User {
  const User({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.token,
  });

  final String email;
  final String firstName;
  final String lastName;

  /// Role stored by the API ("farmer" or "merchant").
  final String role;
  final String token;

  String get displayName => [firstName, lastName].where((p) => p.isNotEmpty).join(' ');

  Map<String, dynamic> toJson() => {
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'role': role,
    'token': token,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    email: json['email'] as String? ?? '',
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    role: json['role'] as String? ?? '',
    token: json['token'] as String? ?? '',
  );
}
