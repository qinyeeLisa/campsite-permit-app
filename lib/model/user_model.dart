class UserModel {
  final int? userId;
  final String fullName;
  final String email;
  //storing password in db is not encouraged
  //Use Firebase Authentication for managing user accounts securely.
  //final String password;
  final int role;
  final DateTime? dateTimeCreated;
  final DateTime? dateTimeUpdated;

  const UserModel(
      {
      this.userId,
      required this.fullName,
      required this.email,
      //required this.password,
      required this.role,
      this.dateTimeCreated,
      this.dateTimeUpdated
      });
}
