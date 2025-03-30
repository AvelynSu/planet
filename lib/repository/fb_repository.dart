import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:planet/enum/network_type.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/model/token_info.dart';
import 'package:planet/service/wallet/wallet_service.dart';
import 'package:planet/util/app_constant.dart';
import 'package:planet/util/wallet_config.dart';

import '../service/local_storage_service.dart';
import '../util/data/token_data.dart';

class ApiRepository {
  final _planetNameDoc = FirebaseFirestore.instance
      .collection(AppConstant.fbCommon)
      .doc(AppConstant.fbPlanetNameDoc);
  final _planetNamefnDoc = FirebaseFirestore.instance
      .collection(AppConstant.fbCommon)
      .doc(AppConstant.fbPlanetNameFnDoc);
  final _planetCol =
      FirebaseFirestore.instance.collection(AppConstant.fbPlanet);

  final _commonCol =
      FirebaseFirestore.instance.collection(AppConstant.fbCommon);
  final _customTokenCol =
      FirebaseFirestore.instance.collection(AppConstant.fbCustomToken);

  Future<List<TokenInfo>> fetchCoinPrices(List<TokenInfo> infos) async {
    List<TokenInfo> updatedInfos = [];
    try {
      var currency = SharedPrefsUtil.getString(AppConstant.currency) ?? "USD";
      var items = infos.map((e) => e.coingeckoKey ?? "").join(",");
      final response = await http.get(Uri.parse(
          'https://api.coingecko.com/api/v3/simple/price?ids=${items}&vs_currencies=${currency}&include_24hr_change=true'));

      currency = currency.toLowerCase();
      if (response.statusCode == 200) {
        final Map<String, dynamic> priceData = json.decode(response.body);

        // 각 토큰 정보 업데이트
        for (var token in infos) {
          // coingeckoKey가 있고 API 응답에 해당 키가 있는 경우
          if (priceData.containsKey(token.coingeckoKey)) {
            final tokenPriceData = priceData[token.coingeckoKey];

            // copyWith를 사용하여 새 TokenInfo 객체 생성
            final updatedToken = token.copyWith(
              tokenPrice: (tokenPriceData[currency] ?? 0) * 1.0,
              priceChangePercentage24h:
                  (tokenPriceData['${currency}_24h_change'] ?? 0) * 1.0,
            );

            updatedInfos.add(updatedToken);
          } else {
            // API 응답에 없는 경우 원본 토큰 추가
            updatedInfos.add(token);
          }
        }
      } else {
        print('Failed to load prices: ${response.statusCode}');
      }
      return updatedInfos;
    } catch (e) {
      rethrow;
      print('Error fetching coin data: $e');
    }
  }

  /// 커스텀 토큰 가져오기
  Future<TokenDataSet> getCustomToken() async {
    var res = await _customTokenCol.doc("tokens").get();
    return TokenDataSet.fromJson(res.data()!);
  }

  /// 현재 앱 버전 가져오기
  /// 행성 전부 불러오기
  Future<String> getVersion() async {
    var res = await _commonCol.doc("admin").get();
    var result = res.data()?["latest_version"] ?? "";

    return result;
  }

  /// 0이 없는 경우 닉네임 설정하라고 반환
  /// 네트워크 관계없이 다 불러와서 있으면 그거 보여주고, 없으면 이더리움으로 1개 생성
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
    return null;
  }

  /// 부모의 하위 행성들 모두 가져오기
  // 부모가 포함된 배열이 나옴
  // networkType 이 따로 없는 경우 모두 가져옴
  Future<List<Planet>> getPlanetsByParents(
      {required String mnemonic, NetworkType? network}) async {
    final results = await Future.wait([
      WalletService().generateHDAddress(NetworkType.ethereum, mnemonic, 0),
      WalletService().generateHDAddress(NetworkType.bitcoin, mnemonic, 0),
      WalletService().generateHDAddress(NetworkType.solana, mnemonic, 0),
      WalletService().generateHDAddress(NetworkType.bsc, mnemonic, 0),
    ]);

    var parents = [
      Planet(networkType: NetworkType.ethereum, parentsAddress: results[0]),
      Planet(networkType: NetworkType.bitcoin, parentsAddress: results[1]),
      Planet(networkType: NetworkType.solana, parentsAddress: results[2]),
      Planet(networkType: NetworkType.bsc, parentsAddress: results[3]),
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

    /// 네트워크 있으면 네트워크에 해당하는것만 반환해줌
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
    var res2 = await _planetNamefnDoc.get();

    var result = (res.data()!["items"] as List<dynamic>)
        .map((e) => e as String)
        .toList();
    var result2 = (res2.data()!["items"] as List<dynamic>)
        .map((e) => e as String)
        .toList();

    return result + result2;
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
  Future<Planet> updatePlanetName(
      Planet planet, String oldName, String name) async {
    await _planetNameDoc.update({
      "items": FieldValue.arrayRemove([oldName])
    });

    await _planetNameDoc.update({
      "items": FieldValue.arrayUnion([name])
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
    var res2 = await getAllNickName();

    return !res2.contains(name) && res.docs.isEmpty;
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
      if (planet == Planet.empty) {
        return Planet.empty;
      } else {
        return planet.copyWith(
          isCurrent: item.isCurrent,
        );
      }
    }).toList();

    List<Planet> planets = await Future.wait(planetFutures);

    return planets.where((e) => e != Planet.empty).toList();
  }

  Future<void> signOut() async {
    const storage = FlutterSecureStorage();
    await storage.deleteAll();
  }

  /// -- 관리자

  Future<WalletConfig> getWalletConfig() async {
    var doc = await FirebaseFirestore.instance
        .collection(AppConstant.fbCommon)
        .doc("config")
        .get();

    return WalletConfig.fromJson(doc.data()!["prod"]);
  }

  /// 커스텀 토큰 업데이트
  Future<void> updateAdmin() async {
    // await FirebaseFirestore.instance
    //     .collection(AppConstant.fbCommon)
    //     .doc("config")
    //     .set({
    //   "prod": WalletConfig(
    //     ethRpcUrl:
    //         'https://eth-mainnet.g.alchemy.com/v2/AS2Fwk9-iN6gMwhHq96tsvnVoINK5FJI',
    //     bitcoinApiUrl:
    //         'https://bnb-mainnet.g.alchemy.com/v2/AS2Fwk9-iN6gMwhHq96tsvnVoINK5FJI',
    //     blockCypherToken: "b0bce5d62dba4e308ec307c1f9b92f78",
    //     solanaRpcUrl:
    //         "https://solana-mainnet.g.alchemy.com/v2/AS2Fwk9-iN6gMwhHq96tsvnVoINK5FJI",
    //     bscRpcUrl:
    //         'https://bnb-mainnet.g.alchemy.com/v2/AS2Fwk9-iN6gMwhHq96tsvnVoINK5FJI',
    //   ).toJson()
    // });

    // await _customTokenCol.doc("tokens").update({
    //   "bsc": FieldValue.arrayUnion([].map((e) => e.toJson()).toList()),
    //   "ethereum": FieldValue.arrayUnion([].map((e) => e.toJson()).toList()),
    //   "solana": FieldValue.arrayUnion([].map((e) => e.toJson()).toList()),
    // });
  }
}
