class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String role;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed property for full name
  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        firstName: json['firstName']?.toString() ?? '',
        lastName: json['lastName']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString(),
        isEmailVerified: json['isEmailVerified'] == true,
        isPhoneVerified: json['isPhoneVerified'] == true,
        role: json['role']?.toString() ?? 'user',
        status: json['status']?.toString() ?? 'pending',
        createdAt: json['createdAt'] != null 
            ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null 
            ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
    } catch (e) {
      throw FormatException('Failed to parse User from JSON: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'role': role,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final User? user;
  final Map<String, dynamic>? errors;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
    this.errors,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    try {
      return AuthResponse(
        success: json['success'] == true,
        message: json['message']?.toString() ?? 'Unknown error occurred',
        token: json['token']?.toString(),
        user: json['user'] != null ? User.fromJson(json['user']) : null,
        errors: json['errors'] is Map<String, dynamic> ? json['errors'] : null,
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Failed to parse response: $e',
      );
    }
  }

  // Helper method to get formatted error message
  String get errorMessage {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.values.first.toString();
    }
    return message;
  }
}