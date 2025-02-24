import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:planet/model/planet_dto.dart';
import 'package:planet/util/app_constant.dart';

class ApiRepository {
  final fbAuth = auth.FirebaseAuth.instance;
  final _planetNameDoc = FirebaseFirestore.instance
      .collection(AppConstant.fbCommon)
      .doc(AppConstant.fbPlanetNameDoc);
  final _planetCol =
      FirebaseFirestore.instance.collection(AppConstant.fbPlanet);

  /// 행성 전부 불러오기
  Future<List<PlanetDto>> getAllPlanetForTest() async {
    var res = await _planetCol.get();

    var result =
        res.docs.map((e) => PlanetDto.fromJson(e.data(), id: e.id)).toList();

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
  Future<PlanetDto> addPlanet(PlanetDto planet) async {
    var json = planet.toJson();
    json["mnemonic"] = "";
    var res = await _planetCol.add(planet.toJson());
    await _planetNameDoc.update({
      "items": FieldValue.arrayUnion([planet.name])
    });
    return planet.copyWith(id: res.id);
  }

  /// 이름 변경
  Future<PlanetDto> updatePlanet(PlanetDto planet, String name) async {
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
  Future<PlanetDto> getPlanetByAddress(String address,
      {String? mnemonic}) async {
    var res = await _planetCol.where("address", isEqualTo: address).get();

    return res.docs.isEmpty
        ? PlanetDto.empty
        : PlanetDto.fromJson(
            res.docs.first.data(),
            id: res.docs.first.id,
          ).copyWith(mnemonic: mnemonic);
  }

  /// 로컬에 있는 플래닛 정보로 FB에서 불러오기
  Future<List<PlanetDto>> getPlanetByLocalInfo(List<PlanetDto> local) async {
    List<Future<PlanetDto>> planetTask = [];
    for (var item in local) {
      var planet = getPlanetByAddress(item.address, mnemonic: item.mnemonic);
      planetTask.add(planet);
    }

    var planets = await Future.wait(planetTask);
    return planets;
  }

  Future<void> signOut() async {
    const storage = FlutterSecureStorage();
    await storage.deleteAll();
  }
}
