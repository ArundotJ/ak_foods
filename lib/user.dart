final class User {
  final String userID;
  final String password;
  final String contactNumber, emailID, userType, name, joiningDate;
  final String active;

  User(this.userID, this.password, this.contactNumber, this.emailID,
      this.userType, this.name, this.joiningDate, this.active);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        json['UserID'],
        json['Password'],
        json['ContactNo'],
        json['EmailID'],
        json['UserType'],
        json['Name'],
        json['JoiningDate'],
        json['Active']);
  }
}
