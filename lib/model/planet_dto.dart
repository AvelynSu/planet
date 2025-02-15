import 'package:equatable/equatable.dart';
import 'package:planet/ui/util/fb_formatter.dart';

import '../enum/network_type.dart';

class PlanetDto extends Equatable {
  final String id;
  final String planetName;
  final NetworkType? networkType;
  final String address;
  final String mnemonic;
  final DateTime? createdAt;

  const PlanetDto({
    this.id = "",
    this.planetName = "",
    this.networkType,
    this.address = "",
    this.mnemonic = "",
    this.createdAt,
  });

  static const empty = PlanetDto();

  factory PlanetDto.fromJson(Map<String, dynamic> json, {String id = ""}) {
    return PlanetDto(
      id: id,
      networkType: NetworkType.fromJson(json["networkType"]),
      planetName: json['planetName'] ?? '',
      address: json["address"] ?? "",
      createdAt: FBFormatter.fromJsonDate(json["createdAt"]),
    );
  }

  Map<String, dynamic> toJson({bool isLocal = true}) {
    return {
      'id': id,
      'planetName': planetName,
      'networkType': networkType?.name,
      'address': address,
      'createdAt': FBFormatter.toJsonDate(createdAt),
    };
  }

  PlanetDto copyWith({
    String? id,
    String? address,
    NetworkType? networkType,
    String? planetName,
    String? mnemonic,
    DateTime? createdAt,
  }) {
    return PlanetDto(
      id: id ?? this.id,
      networkType: networkType ?? this.networkType,
      address: address ?? this.address,
      planetName: planetName ?? this.planetName,
      mnemonic: mnemonic ?? this.mnemonic,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        planetName,
        address,
        mnemonic,
        createdAt,
      ];
}
