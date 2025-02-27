class RegisterRequest {
  final String email;
  final String username;
  final String password;
  final String country;
  final String phoneNumber;
  final String birthDate;

  RegisterRequest({
    required this.email,
    required this.username,
    required this.password,
    required this.country,
    required this.phoneNumber,
    required this.birthDate,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'username': username,
    'password': password,
    'country': country,
    'phoneNumber': phoneNumber,
    'birthDate': birthDate,
  };
} 