import 'package:equatable/equatable.dart';
import 'package:planet/util/fb_formatter.dart';

import '../enum/network_type.dart';

class PlanetDto extends Equatable {
  final String id;
  final String name;
  final NetworkType? networkType;
  final String address;
  final String mnemonic;
  final DateTime? createdAt;
  final bool isCurrent;

  const PlanetDto({
    this.id = "",
    this.name = "",
    this.networkType,
    this.address = "",
    this.mnemonic = "",
    this.createdAt,
    this.isCurrent = false,
  });

  static const empty = PlanetDto();

  factory PlanetDto.fromJson(Map<String, dynamic> json, {String id = ""}) {
    return PlanetDto(
      id: id,
      networkType: NetworkType.fromJson(json["networkType"]),
      name: json['name'] ?? '',
      address: json["address"] ?? "",
      createdAt: FBFormatter.fromJsonDate(json["createdAt"]),
      mnemonic: json["mnemonic"] ?? "",
    );
  }

  Map<String, dynamic> toJson({bool isLocal = true}) {
    return {
      'id': id,
      'name': name,
      'networkType': networkType?.name,
      if (isLocal) 'mnemonic': mnemonic,
      'address': address,
      'createdAt': FBFormatter.toJsonDate(createdAt),
      'isCurrent': isCurrent,
    };
  }

  PlanetDto copyWith({
    String? id,
    String? address,
    NetworkType? networkType,
    String? name,
    String? mnemonic,
    DateTime? createdAt,
    bool? isCurrent,
  }) {
    return PlanetDto(
      id: id ?? this.id,
      networkType: networkType ?? this.networkType,
      address: address ?? this.address,
      name: name ?? this.name,
      mnemonic: mnemonic ?? this.mnemonic,
      createdAt: createdAt ?? this.createdAt,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        networkType,
        address,
        mnemonic,
        createdAt,
        isCurrent,
      ];
}
