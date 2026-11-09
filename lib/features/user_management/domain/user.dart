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
    this.phone = '',
    this.avatarUri = '',
  });

  final String email;
  final String firstName;
  final String lastName;

  /// Role stored by the API ("farmer" or "merchant").
  final String role;
  final String token;
  final String phone;

  /// Local file path of the profile photo, kept on this device like Kotlin `avatarUri`.
  final String avatarUri;

  String get displayName => [firstName, lastName].where((p) => p.isNotEmpty).join(' ');

  User copyWith({String? email, String? phone, String? avatarUri}) => User(
    email: email ?? this.email,
    firstName: firstName,
    lastName: lastName,
    role: role,
    token: token,
    phone: phone ?? this.phone,
    avatarUri: avatarUri ?? this.avatarUri,
  );

  Map<String, dynamic> toJson() => {
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'role': role,
    'token': token,
    'phone': phone,
    'avatarUri': avatarUri,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    email: json['email'] as String? ?? '',
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    role: json['role'] as String? ?? '',
    token: json['token'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    avatarUri: json['avatarUri'] as String? ?? '',
  );
}
