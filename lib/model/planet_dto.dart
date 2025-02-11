import 'package:equatable/equatable.dart';

class PlanetDto extends Equatable {
  final String id;
  final String planetName;
  final String address;

  final String mnemonic;

  const PlanetDto({
    this.id = "",
    this.planetName = "",
    this.address = "",
    this.mnemonic = "",
  });

  static const empty = PlanetDto();

  factory PlanetDto.fromJson(Map<String, dynamic> json, {String id = ""}) {
    return PlanetDto(
      id: id,
      planetName: json['planetName'] ?? '',
      address: json["address"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planetName': planetName,
      'address': address,
    };
  }

  PlanetDto copyWith({
    String? id,
    String? address,
    String? planetName,
    String? mnemonic,
  }) {
    return PlanetDto(
      id: id ?? this.id,
      address: address ?? this.address,
      planetName: planetName ?? this.planetName,
      mnemonic: mnemonic ?? this.mnemonic,
    );
  }

  @override
  List<Object?> get props => [
        id,
        planetName,
        address,
        mnemonic,
      ];
}
