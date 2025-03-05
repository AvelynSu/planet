import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:planet/enum/network_type.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/service/wallet/wallet_service.dart';
import 'package:planet/util/app_constant.dart';
import 'package:planet/util/wallet_config.dart';

import '../service/local_storage_service.dart';

class ApiRepository {
  final _planetNameDoc = FirebaseFirestore.instance
      .collection(AppConstant.fbCommon)
      .doc(AppConstant.fbPlanetNameDoc);
  final _planetCol =
      FirebaseFirestore.instance.collection(AppConstant.fbPlanet);

  final _commonCol =
      FirebaseFirestore.instance.collection(AppConstant.fbCommon);

  /// 현재 앱 버전 가져오기
  /// 행성 전부 불러오기
  Future<String> getVersion() async {
    var res = await _commonCol.doc("admin").get();
    var result = res.data()?["latest_version"] ?? "";

    return result;
  }

  Future<Planet?> getRequiredNicknamePlanet({
    required String mnemonic,
    required Function onAppInitialize,
  }) async {
    var planet = Planet.empty;
    var planets = await getPlanetsByParents(mnemonic: mnemonic);

    // 등록된 지갑이 아니면
    if (planets.isEmpty) {
      // 등록된 지갑이 아니면 빈 Planet 생성
      var address = await WalletService()
          .generateHDAddress(NetworkType.ethereum, mnemonic, 0);
      planet = Planet(
        networkType: NetworkType.ethereum,
        address: address,
        mnemonic: mnemonic,
      );
      return planet;
    } else {
      // 등록된 지갑이면 저장해주기
      await LocalStorageService.saveMnemonics(planets);
      onAppInitialize();
    }
  }

  /// 부모의 하위 행성들 모두 가져오기
  // 부모가 포함된 배열이 나옴
  // networkType 이 따로 없는 경우 모두 가져옴
  Future<List<Planet>> getPlanetsByParents(
      {required String mnemonic, NetworkType? network}) async {
    var eth = await WalletService()
        .generateHDAddress(NetworkType.ethereum, mnemonic, 0);
    var btc = await WalletService()
        .generateHDAddress(NetworkType.bitcoin, mnemonic, 0);

    var parents = [
      Planet(networkType: NetworkType.ethereum, parentsAddress: eth),
      Planet(networkType: NetworkType.bitcoin, parentsAddress: btc)
    ];

    var res = await _planetCol.where("parentsAddress",
        whereIn: [...parents.map((e) => e.parentsAddress)]).get();

    // 가져온 문서들을 Planet 객체로 변환
    var planets = res.docs
        .map((e) => Planet.fromJson(e.data(), id: e.id).copyWith(
              mnemonic: mnemonic,
            ))
        .toList();

    var result = planets.where((planet) {
      return parents.any((parent) =>
          parent.parentsAddress == planet.parentsAddress &&
          parent.networkType == planet.networkType);
    }).toList();

    if (network != null) {
      result = result.where((e) => e.networkType == network).toList();
    }

    return result;
  }

  /// 행성 전부 불러오기
  Future<List<Planet>> getAllPlanetForTest({NetworkType? networkType}) async {
    var res = networkType == null
        ? await _planetCol.get()
        : await _planetCol
            .where("networkType", isEqualTo: networkType.name)
            .get();

    var result =
        res.docs.map((e) => Planet.fromJson(e.data(), id: e.id)).toList();
    result = result.where((e) => e.env == WalletConfig.env).toList();
    return result;
  }

  /// 닉네임 전부 불러오기
  Future<List<String>> getAllNickName() async {
    var res = await _planetNameDoc.get();

    var result = (res.data()!["items"] as List<dynamic>)
        .map((e) => e as String)
        .toList();

    return result;
  }

  /// 행성 저장하기
  Future<Planet> addPlanet(Planet planet) async {
    planet = planet.copyWith(env: WalletConfig.env);
    var res = await _planetCol.add(planet.toJson(isLocal: false));
    await _planetNameDoc.update({
      "items": FieldValue.arrayUnion([planet.name])
    });
    return planet.copyWith(id: res.id);
  }

  /// 이름 변경
  Future<Planet> updatePlanet(Planet planet, String name) async {
    await _planetNameDoc.update({
      "items": FieldValue.arrayRemove([planet.name])
    });

    var res = await _planetCol.doc(planet.id).update({"name": name});
    return planet.copyWith(name: name);
  }

  ///  행성 숨기기 변경
  Future<Planet> hidePlanet(Planet planet, bool isDeleted) async {
    var res = await _planetCol.doc(planet.id).update({"isDeleted": isDeleted});
    return planet.copyWith(isDeleted: isDeleted);
  }

  /// 로컬에 니모닉 저장

  /// 사용 가능한 닉네임인지 확인
  Future<bool> enablePlanetName(String name) async {
    var res = await _planetCol.where("name", isEqualTo: name).get();
    return res.docs.isEmpty;
  }

  /// 주소로 행성 불러오기.
  Future<Planet> getPlanetByAddress(String address, {String? mnemonic}) async {
    var res = await _planetCol.where("address", isEqualTo: address).get();

    return res.docs.isEmpty
        ? Planet.empty
        : Planet.fromJson(
            res.docs.first.data(),
            id: res.docs.first.id,
          ).copyWith(mnemonic: mnemonic);
  }

  /// 로컬에 있는 플래닛 정보로 FB에서 불러오기
  Future<List<Planet>> getPlanetByLocalInfo(List<Planet> local) async {
    List<Future<Planet>> planetFutures = local.map((item) async {
      var planet =
          await getPlanetByAddress(item.address, mnemonic: item.mnemonic);
      return planet.copyWith(
        isCurrent: item.isCurrent,
      );
    }).toList();

    List<Planet> planets = await Future.wait(planetFutures);

    return planets;
  }

  Future<void> signOut() async {
    const storage = FlutterSecureStorage();
    await storage.deleteAll();
  }
}
