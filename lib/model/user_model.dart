class UserModel {
  final String? id;
  final String fullName;
  final String email;
  final String password;
  final int role;

  const UserModel(
    {this.id,
      required this.fullName,
      required this.email,
      required this.password,
      required this.role
    }
  );

  toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'role': role
    };
  }
}
