class UserModel {
  int? userId;
  final String fullName;
  final String email;
  final int role;
  final DateTime? dateTimeCreated;
  final DateTime? dateTimeUpdated;

  UserModel(
  {
    this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    this.dateTimeCreated,
    this.dateTimeUpdated
  }); 
}
