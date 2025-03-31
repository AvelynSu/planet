import 'package:equatable/equatable.dart';
import 'package:planet/util/fb_formatter.dart';
import 'package:planet/util/wallet_config.dart';

import '../enum/network_type.dart';

class Planet extends Equatable {
  final String id;
  final String name;
  final NetworkType? networkType;
  final String address;
  final String mnemonic;
  final DateTime? createdAt;
  final bool isDeleted;

  final Environment env;

  final String parentsAddress; // idx 0 의 주소
  final int pathIdx;

  const Planet({
    this.id = "",
    this.name = "",
    this.networkType,
    this.address = "",
    this.mnemonic = "",
    this.createdAt,
    this.pathIdx = 0,
    this.parentsAddress = "",
    this.isDeleted = false,
    this.env = Environment.prod,
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
      parentsAddress: json["parentsAddress"] ?? json["address"] ?? "",
      isDeleted: json["isDeleted"] ?? false,
      env: Environment.fromJson(json["env"]),
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
      'pathIdx': pathIdx,
      'parentsAddress': parentsAddress.isEmpty ? address : parentsAddress,
      'isDeleted': isDeleted ?? false,
      'env': env.name,
    };
  }

  Planet copyWith({
    String? id,
    String? address,
    NetworkType? networkType,
    String? name,
    String? mnemonic,
    DateTime? createdAt,
    int? pathIdx,
    String? parentsAddress,
    bool? isDeleted,
    Environment? env,
  }) {
    return Planet(
      id: id ?? this.id,
      networkType: networkType ?? this.networkType,
      address: address ?? this.address,
      name: name ?? this.name,
      mnemonic: mnemonic ?? this.mnemonic,
      createdAt: createdAt ?? this.createdAt,
      pathIdx: pathIdx ?? this.pathIdx,
      parentsAddress: parentsAddress ?? this.parentsAddress,
      isDeleted: isDeleted ?? this.isDeleted,
      env: env ?? this.env,
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
        pathIdx,
        parentsAddress,
        isDeleted,
        env,
      ];
}
