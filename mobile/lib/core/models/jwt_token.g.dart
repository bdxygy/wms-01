// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jwt_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JwtToken _$JwtTokenFromJson(Map<String, dynamic> json) => JwtToken(
      token: json['token'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      type: json['type'] as String,
    );

Map<String, dynamic> _$JwtTokenToJson(JwtToken instance) => <String, dynamic>{
      'token': instance.token,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'type': instance.type,
    };
