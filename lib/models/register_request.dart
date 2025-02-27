class RegisterRequest {
  final String email;
  final String username;
  final String password;
  final String phoneNumber;
  final String country;
  final String birthDate;

  RegisterRequest({
    required this.email,
    required this.username,
    required this.password,
    required this.phoneNumber,
    required this.country,
    required this.birthDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'password': password,
      'phoneNumber': phoneNumber,
      'country': country,
      'birthDate': birthDate,
    };
  }
} 