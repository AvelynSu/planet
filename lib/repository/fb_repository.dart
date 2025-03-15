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

  /// -- 관리자

  /// 커스텀 토큰 업데이트
  Future<void> updateCustomtoken() async {
    await _customTokenCol.doc("tokens").update({
      "solana": [
        ...[
          TokenInfo(
            symbol: 'SOL',
            name: 'Solana',
            address: '11111111111111111111111111111111',
            // SOL은 네이티브 토큰이라 시스템 주소 사용
            decimals: 9,
            logoUrl:
                "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_ethereum.png?alt=media&token=05f26182-cf5c-4521-aac6-f1bdf7279e94",
            coingeckoKey: "solana",
          ),
          TokenInfo(
            symbol: 'USDC',
            name: 'USD Coin',
            address: 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
            decimals: 6,
            logoUrl:
                "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_ethereum.png?alt=media&token=05f26182-cf5c-4521-aac6-f1bdf7279e94",
            coingeckoKey: "usd-coin",
          ),
          TokenInfo(
            symbol: 'BONK',
            name: 'BONK',
            address: 'DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263',
            decimals: 5,
            logoUrl:
                "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_ethereum.png?alt=media&token=05f26182-cf5c-4521-aac6-f1bdf7279e94",
            coingeckoKey: "bonk",
          ),
        ].map((e) => e.toJson()),
      ],
    });
    // await _customTokenCol.doc("tokens").set({
    //   "ethereum": [
    //     ...[
    //       TokenInfo(
    //         symbol: 'ETH',
    //         name: 'Ethereum',
    //         address: '0x0000000000000000000000000000000000000000',
    //         // ETH는 네이티브 토큰이라 주소가 0 주소
    //         decimals: 18,
    //         logoUrl: "icons/ic_ethereum.png",
    //         coingeckoKey: "ethereum",
    //       ),
    //       TokenInfo(
    //         symbol: 'USDT',
    //         name: 'Tether USD',
    //         address: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
    //         decimals: 6,
    //         logoUrl: "icons/ic_ethereum.png",
    //         coingeckoKey: "tether",
    //       ),
    //       TokenInfo(
    //         symbol: 'TON',
    //         name: 'Toncoin',
    //         address:
    //             '0x582d872A1B094FC48F5DE31D3B73F2D9bE47def1', // Wrapped TON on Ethereum
    //         decimals: 9,
    //         logoUrl: "icons/ic_ethereum.png",
    //         coingeckoKey: "the-open-network",
    //       ),
    //       TokenInfo(
    //         symbol: 'OM',
    //         name: 'MANTRA',
    //         address: '0x3593D125a4f7849a1B059E64F4517A86Dd60c95d',
    //         decimals: 18,
    //         logoUrl: "icons/ic_ethereum.png",
    //         coingeckoKey: "mantra",
    //       ),
    //       // TokenInfo(
    //       //   symbol: 'BGT',
    //       //   name: 'Bitget Token',
    //       //   address:
    //       //       '0x44070d4d84fb3fd53E99cA43Fdc3DAD4F6D7C7B5', // ERC-20 version
    //       //   decimals: 18,
    //       //   logoUrl: "icons/ic_bitget.png",
    //       //   coingeckoKey: "bitget-token",
    //       // ),
    //       TokenInfo(
    //         symbol: 'USde',
    //         name: 'Ethena USDe',
    //         address: '0x4c9EDD5852cd905f086C759E8383e09bff1E68B3',
    //         decimals: 18,
    //         logoUrl: "icons/ic_ethereum.png",
    //         coingeckoKey: "ethena-usde",
    //       ),
    //       TokenInfo(
    //         symbol: 'DAI',
    //         name: 'Dai Stablecoin',
    //         address: '0x6B175474E89094C44Da98b954EedeAC495271d0F',
    //         decimals: 18,
    //         logoUrl: "icons/ic_ethereum.png",
    //         coingeckoKey: "dai",
    //       ),
    //       TokenInfo(
    //         symbol: 'UNI',
    //         name: 'Uniswap',
    //         address: '0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984',
    //         decimals: 18,
    //         logoUrl: "icons/ic_ethereum.png",
    //         coingeckoKey: "uniswap",
    //       ),
    //       TokenInfo(
    //         symbol: 'ONDO',
    //         name: 'Ondo',
    //         address: '0xfaba6f8e4a5e8ab82f62fe7c39859fa577269be3',
    //         decimals: 18,
    //         logoUrl: "icons/ic_ethereum.png",
    //         coingeckoKey: "ondo-finance",
    //       ),
    //       TokenInfo(
    //         symbol: 'AAVE',
    //         name: 'Aave',
    //         address: '0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9',
    //         decimals: 18,
    //         logoUrl: "icons/ic_ethereum.png",
    //         coingeckoKey: "aave",
    //       ),
    //       TokenInfo(
    //         symbol: 'PEPE',
    //         name: 'Pepe',
    //         address: '0x6982508145454Ce325dDbE47a25d4ec3d2311933',
    //         decimals: 18,
    //         logoUrl: "icons/ic_ethereum.png",
    //         coingeckoKey: "pepe",
    //       ),
    //       TokenInfo(
    //         symbol: 'OKB',
    //         name: 'OKB',
    //         address:
    //             '0x75231F58b43240C9718Dd58B4967c5114342a86c', // ERC-20 version
    //         decimals: 18,
    //         logoUrl: "icons/ic_ethereum.png",
    //         coingeckoKey: "okb",
    //       ),
    //       TokenInfo(
    //         symbol: 'MNT',
    //         name: 'Mantle',
    //         address:
    //             '0x3c3a81e81dc49A522A592e7622A7E711c06bf354', // ERC-20 version
    //         decimals: 18,
    //         logoUrl: "icons/ic_ethereum.png",
    //         coingeckoKey: "mantle",
    //       ),
    //     ].map((e) => e.toJson()),
    //   ],
    // });
  }
}
