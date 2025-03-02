import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:planet/enum/network_type.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/util/app_constant.dart';

class ApiRepository {
  final fbAuth = auth.FirebaseAuth.instance;
  final _planetNameDoc = FirebaseFirestore.instance
      .collection(AppConstant.fbCommon)
      .doc(AppConstant.fbPlanetNameDoc);
  final _planetCol =
      FirebaseFirestore.instance.collection(AppConstant.fbPlanet);

  /// 부모 주소의 하위 행성들 불러오기
  // parentPlanet : network 에 맞는 인덱스가 0인 행성
  Future<List<Planet>> getChildPlanets(
      String? parentPlanetAddress, NetworkType networkType) async {
    var res = await _planetCol
        .where("parentsAddress", isEqualTo: parentPlanetAddress)
        .where("networkType", isEqualTo: networkType.name)
        .get();
    var result =
        res.docs.map((e) => Planet.fromJson(e.data(), id: e.id)).toList();

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
    var json = planet.toJson();
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
