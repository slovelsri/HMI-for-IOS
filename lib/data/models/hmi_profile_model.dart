import 'dart:convert';
import '../../domain/entities/hmi_profile.dart';

/// JSON-serializable model for [HmiProfile] persistence.
class HmiProfileModel {
  final String id;
  final String name;
  final String ipAddress;
  final int port;

  const HmiProfileModel({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.port,
  });

  /// Create from domain entity.
  factory HmiProfileModel.fromEntity(HmiProfile entity) {
    return HmiProfileModel(
      id: entity.id,
      name: entity.name,
      ipAddress: entity.ipAddress,
      port: entity.port,
    );
  }

  /// Create from JSON map.
  factory HmiProfileModel.fromJson(Map<String, dynamic> json) {
    return HmiProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ipAddress: json['ipAddress'] as String,
      port: json['port'] as int? ?? 80,
    );
  }

  /// Convert to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ipAddress': ipAddress,
      'port': port,
    };
  }

  /// Convert to domain entity.
  HmiProfile toEntity() {
    return HmiProfile(
      id: id,
      name: name,
      ipAddress: ipAddress,
      port: port,
    );
  }

  /// Encode a list of models to a JSON string for storage.
  static String encodeList(List<HmiProfileModel> models) {
    return jsonEncode(models.map((m) => m.toJson()).toList());
  }

  /// Decode a JSON string to a list of models.
  static List<HmiProfileModel> decodeList(String jsonStr) {
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((item) => HmiProfileModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
