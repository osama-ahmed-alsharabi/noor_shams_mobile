import 'package:equatable/equatable.dart';

class ProviderProfileModel extends Equatable {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String role;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProviderProfileModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProviderProfileModel.fromJson(Map<String, dynamic> json) {
    return ProviderProfileModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'مستخدم',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'provider',
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'avatar_url': avatarUrl,
    };
  }

  ProviderProfileModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
  }) {
    return ProviderProfileModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    role,
    avatarUrl,
    createdAt,
    updatedAt,
  ];
}
