import 'package:json_annotation/json_annotation.dart';

part 'jwt_token.g.dart';

@JsonSerializable()
class JwtToken {
  final String token;
  final DateTime expiresAt;
  final String type; // 'access' or 'refresh'

  JwtToken({
    required this.token,
    required this.expiresAt,
    required this.type,
  });

  factory JwtToken.fromJson(Map<String, dynamic> json) =>
      _$JwtTokenFromJson(json);

  Map<String, dynamic> toJson() => _$JwtTokenToJson(this);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isNearExpiry => DateTime.now().add(const Duration(minutes: 5)).isAfter(expiresAt);
  bool get isValid => !isExpired && token.isNotEmpty;

  // Helper factory methods
  factory JwtToken.accessToken(String token, DateTime expiresAt) {
    return JwtToken(
      token: token,
      expiresAt: expiresAt,
      type: 'access',
    );
  }

  factory JwtToken.refreshToken(String token, DateTime expiresAt) {
    return JwtToken(
      token: token,
      expiresAt: expiresAt,
      type: 'refresh',
    );
  }
}