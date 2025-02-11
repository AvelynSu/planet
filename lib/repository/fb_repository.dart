import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:planet/model/planet_dto.dart';
import 'package:planet/ui/util/app_constant.dart';

class ApiRepository {
  final fbAuth = auth.FirebaseAuth.instance;

  final _planetCol =
      FirebaseFirestore.instance.collection(AppConstant.fbPlanet);

  /// 사용 가능한 닉네임인지 확인
  Future<bool> enablePlanetName(String name) async {
    var res = await _planetCol.where("planetName", isEqualTo: name).get();
    return res.docs.isEmpty;
  }

  /// 주소로 행성 불러오기. 만약에 없으면 닉네임 설정 해야함
  Future<PlanetDto?> getPlanetByAddress(String address) async {
    var res = await _planetCol.where("address", isEqualTo: address).get();

    return res.docs.isEmpty
        ? null
        : PlanetDto.fromJson(
            res.docs.first.data(),
            res.docs.first.id,
          );
  }
}
