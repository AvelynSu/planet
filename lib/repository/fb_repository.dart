import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:planet/model/planet_dto.dart';
import 'package:planet/ui/util/app_constant.dart';

class ApiRepository {
  final fbAuth = auth.FirebaseAuth.instance;

  final _planetCol =
      FirebaseFirestore.instance.collection(AppConstant.fbPlanet);

  /// 로컬에 니모닉 저장

  /// 사용 가능한 닉네임인지 확인
  Future<bool> enablePlanetName(String name) async {
    var res = await _planetCol.where("planetName", isEqualTo: name).get();
    return res.docs.isEmpty;
  }

  /// 주소로 행성 불러오기.
  Future<PlanetDto> getPlanetByAddress(String address) async {
    var res = await _planetCol.where("address", isEqualTo: address).get();

    return res.docs.isEmpty
        ? PlanetDto.empty
        : PlanetDto.fromJson(
            res.docs.first.data(),
            id: res.docs.first.id,
          );
  }

  /// 로컬에 있는 플래닛 정보로 FB에서 불러오기
  Future<List<PlanetDto>> getPlanetByLocalInfo(List<PlanetDto> local) async {
    List<Future<PlanetDto>> planetTask = [];
    for (var item in local) {
      var planet = getPlanetByAddress(item.address);
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
