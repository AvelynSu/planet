import 'package:equatable/equatable.dart';
import 'package:planet/util/fb_formatter.dart';

import '../enum/network_type.dart';

class Planet extends Equatable {
  final String id;
  final String name;
  final NetworkType? networkType;
  final String address;
  final String mnemonic;
  final DateTime? createdAt;
  final bool isCurrent;
  final bool isDeleted;

  final String parentsAddress; // idx 0 의 주소
  final int pathIdx;

  const Planet({
    this.id = "",
    this.name = "",
    this.networkType,
    this.address = "",
    this.mnemonic = "",
    this.createdAt,
    this.isCurrent = false,
    this.pathIdx = 0,
    this.parentsAddress = "",
    this.isDeleted = false,
  });

  static const empty = Planet();

  factory Planet.fromJson(Map<String, dynamic> json, {String id = ""}) {
    return Planet(
      id: id,
      networkType: NetworkType.fromJson(json["networkType"]),
      name: json['name'] ?? '',
      address: json["address"] ?? "",
      createdAt: FBFormatter.fromJsonDate(json["createdAt"]),
      mnemonic: json["mnemonic"] ?? "",
      pathIdx: json["pathIdx"] ?? 0,
      isCurrent: json["isCurrent"] ?? false,
      parentsAddress: json["parentsAddress"] ?? json["address"] ?? "",
      isDeleted: json["isDeleted"] ?? false,
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
      'pathIdx': pathIdx,
      'parentsAddress': parentsAddress.isEmpty ? address : parentsAddress,
      'isDeleted': isDeleted ?? false,
    };
  }

  Planet copyWith({
    String? id,
    String? address,
    NetworkType? networkType,
    String? name,
    String? mnemonic,
    DateTime? createdAt,
    bool? isCurrent,
    int? pathIdx,
    String? parentsAddress,
    bool? isDeleted,
  }) {
    return Planet(
      id: id ?? this.id,
      networkType: networkType ?? this.networkType,
      address: address ?? this.address,
      name: name ?? this.name,
      mnemonic: mnemonic ?? this.mnemonic,
      createdAt: createdAt ?? this.createdAt,
      isCurrent: isCurrent ?? this.isCurrent,
      pathIdx: pathIdx ?? this.pathIdx,
      parentsAddress: parentsAddress ?? this.parentsAddress,
      isDeleted: isDeleted ?? this.isDeleted,
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
        pathIdx,
        parentsAddress,
        isDeleted,
      ];
}
