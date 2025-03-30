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

  /// 커스텀 토큰 업데이트
  Future<void> updateCustomtoken() async {
    await _customTokenCol.doc("tokens").update({
      "bsc": FieldValue.arrayUnion(
        [
          // BNB (네이티브 토큰)
          TokenInfo(
            symbol: "BNB",
            name: "Binance Coin",
            address: "",
            // 네이티브 토큰은 주소 필요 없음
            decimals: 18,
            logoUrl:
                "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_bsc.png?alt=media&token=da3578ae-495c-49e0-9111-7ac0c09ee77d",
            networkType: NetworkType.bsc,
            coingeckoKey: "binancecoin",
          ),

          // USDT (BEP-20)
          TokenInfo(
            symbol: "USDT",
            name: "Tether USD",
            address: "0x55d398326f99059fF775485246999027B3197955",
            decimals: 18,
            logoUrl:
                "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_bsc.png?alt=media&token=da3578ae-495c-49e0-9111-7ac0c09ee77d",
            networkType: NetworkType.bsc,
            coingeckoKey: "tether",
          ),
          // CAKE (PancakeSwap 토큰)
          TokenInfo(
            symbol: "CAKE",
            name: "PancakeSwap Token",
            address: "0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82",
            decimals: 18,
            logoUrl:
                "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_bsc.png?alt=media&token=da3578ae-495c-49e0-9111-7ac0c09ee77d",
            networkType: NetworkType.bsc,
            coingeckoKey: "pancakeswap-token",
          ),
        ]
            .map(
              (e) => e.toJson(),
            )
            .toList(),
      ),
      // "ethereum": [
      //   TokenInfo(
      //     symbol: 'ETH',
      //     name: 'Ethereum',
      //     address: '0x0000000000000000000000000000000000000000',
      //     // ETH는 네이티브 토큰이라 주소가 0 주소
      //     decimals: 18,
      //     logoUrl:
      //         "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_ethereum.png?alt=media&token=b3f9b80a-dac6-49f7-be05-c2a8a44eaa2a",
      //     coingeckoKey: "ethereum",
      //   ),
      //   TokenInfo(
      //     symbol: 'USDT',
      //     name: 'Tether USD',
      //     address: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
      //     decimals: 6,
      //     logoUrl:
      //         "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_tether_usd.png?alt=media&token=90527f7e-2c16-430c-9575-0a23c4f1d165",
      //     coingeckoKey: "tether",
      //   ),
      //   TokenInfo(
      //     symbol: 'TON',
      //     name: 'Toncoin',
      //     address: '0x582d872A1B094FC48F5DE31D3B73F2D9bE47def1',
      //     // Wrapped TON on Ethereum
      //     decimals: 9,
      //     logoUrl:
      //         "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_ton.png?alt=media&token=5d051a5d-d44b-45cd-93b9-45de9ff36301",
      //     coingeckoKey: "the-open-network",
      //   ),
      //   TokenInfo(
      //     symbol: 'OM',
      //     name: 'MANTRA',
      //     address: '0x3593D125a4f7849a1B059E64F4517A86Dd60c95d',
      //     decimals: 18,
      //     logoUrl:
      //         "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_mantra.png?alt=media&token=f9613a28-bd0a-4f9b-95e2-6a628d738380",
      //     coingeckoKey: "mantra",
      //   ),
      //   // TokenInfo(
      //   //   symbol: 'BGT',
      //   //   name: 'Bitget Token',
      //   //   address:
      //   //       '0x44070d4d84fb3fd53E99cA43Fdc3DAD4F6D7C7B5', // ERC-20 version
      //   //   decimals: 18,
      //   //   logoUrl: "icons/ic_bitget.png",
      //   //   coingeckoKey: "bitget-token",
      //   // ),
      //   TokenInfo(
      //     symbol: 'USde',
      //     name: 'Ethena USDe',
      //     address: '0x4c9EDD5852cd905f086C759E8383e09bff1E68B3',
      //     decimals: 18,
      //     logoUrl:
      //         "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_ethena_usde.png?alt=media&token=809a2b8e-8a97-4149-9a5b-b4a0c00b224b",
      //     coingeckoKey: "ethena-usde",
      //   ),
      //   TokenInfo(
      //     symbol: 'DAI',
      //     name: 'Dai Stablecoin',
      //     address: '0x6B175474E89094C44Da98b954EedeAC495271d0F',
      //     decimals: 18,
      //     logoUrl:
      //         "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_dai_stablecoin.png?alt=media&token=339ca837-9bf5-4687-98c8-08c8953d0c1c",
      //     coingeckoKey: "dai",
      //   ),
      //   TokenInfo(
      //     symbol: 'UNI',
      //     name: 'Uniswap',
      //     address: '0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984',
      //     decimals: 18,
      //     logoUrl:
      //         "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_%20uniswap.png?alt=media&token=75d6b6e9-70e5-475e-8f16-0918f7e8fc51",
      //     coingeckoKey: "uniswap",
      //   ),
      //   TokenInfo(
      //     symbol: 'ONDO',
      //     name: 'Ondo',
      //     address: '0xfaba6f8e4a5e8ab82f62fe7c39859fa577269be3',
      //     decimals: 18,
      //     logoUrl:
      //         "https://console.firebase.google.com/u/0/project/planet-908b5/storage/planet-908b5.firebasestorage.app/files/~2Fcustom_token",
      //     coingeckoKey: "ondo-finance",
      //   ),
      //   TokenInfo(
      //     symbol: 'AAVE',
      //     name: 'Aave',
      //     address: '0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9',
      //     decimals: 18,
      //     logoUrl:
      //         "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_aave.png?alt=media&token=7ab18b09-e4f0-4267-9f41-df4cf7373239",
      //     coingeckoKey: "aave",
      //   ),
      //   TokenInfo(
      //     symbol: 'PEPE',
      //     name: 'Pepe',
      //     address: '0x6982508145454Ce325dDbE47a25d4ec3d2311933',
      //     decimals: 18,
      //     logoUrl: "icons/ic_ethereum.png",
      //     coingeckoKey: "pepe",
      //   ),
      //   TokenInfo(
      //     symbol: 'OKB',
      //     name: 'OKB',
      //     address: '0x75231F58b43240C9718Dd58B4967c5114342a86c',
      //     // ERC-20 version
      //     decimals: 18,
      //     logoUrl:
      //         "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_pepe.png?alt=media&token=b79795b1-fe16-4f44-a9d3-12655ce52cbb",
      //     coingeckoKey: "okb",
      //   ),
      //   TokenInfo(
      //     symbol: 'MNT',
      //     name: 'Mantle',
      //     address: '0x3c3a81e81dc49A522A592e7622A7E711c06bf354',
      //     // ERC-20 version
      //     decimals: 18,
      //     logoUrl:
      //         "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_mantle.png?alt=media&token=f30bd9ae-a500-4aa4-b277-69228687df38",
      //     coingeckoKey: "mantle",
      //   ),
      //
      //   TokenInfo(
      //     symbol: "EVZ",
      //     name: "Evz",
      //     address: "0x7A939Bb714fd2A48EbeB1E495AA9aaa74BA9fA68",
      //     decimals: 9,
      //     logoUrl:
      //         "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_ethereum.png?alt=media&token=b3f9b80a-dac6-49f7-be05-c2a8a44eaa2a",
      //     networkType: NetworkType.ethereum,
      //     coingeckoKey: "electric-vehicle-zone",
      //     tokenPrice: 0.0,
      //     priceChangePercentage24h: 0.0,
      //   )
      // ].map((e) => e.toJson())
      // "solana": [
      //   ...[
      //     TokenInfo(
      //       symbol: 'SOL',
      //       name: 'Solana',
      //       address: '11111111111111111111111111111111',
      //       // SOL은 네이티브 토큰이라 시스템 주소 사용
      //       decimals: 9,
      //       logoUrl:
      //           "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_ethereum.png?alt=media&token=05f26182-cf5c-4521-aac6-f1bdf7279e94",
      //       coingeckoKey: "solana",
      //     ),
      //     TokenInfo(
      //       symbol: 'USDC',
      //       name: 'USD Coin',
      //       address: 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
      //       decimals: 6,
      //       logoUrl:
      //           "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_ethereum.png?alt=media&token=05f26182-cf5c-4521-aac6-f1bdf7279e94",
      //       coingeckoKey: "usd-coin",
      //     ),
      //     TokenInfo(
      //       symbol: 'BONK',
      //       name: 'BONK',
      //       address: 'DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263',
      //       decimals: 5,
      //       logoUrl:
      //           "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_ethereum.png?alt=media&token=05f26182-cf5c-4521-aac6-f1bdf7279e94",
      //       coingeckoKey: "bonk",
      //     ),
      //     TokenInfo(
      //       symbol: "TRUMP",
      //       name: "Trump Official",
      //       address: "6p6xgHyF7AeE6TZkSmFsko444wqoP15icUSqi2jfGiPN",
      //       decimals: 9,
      //       logoUrl:
      //           "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_trump.png?alt=media&token=9f42",
      //       networkType: NetworkType.solana,
      //       coingeckoKey: "official-trump",
      //       tokenPrice: 0.0,
      //       priceChangePercentage24h: 0.0,
      //     ),
      //     TokenInfo(
      //       symbol: "USDT",
      //       name: "Tether",
      //       address:
      //           "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB", // 솔라나 네트워크의 USDT 주소
      //       decimals: 6,
      //       logoUrl:
      //           "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_tether.png?alt=media&token=9f45",
      //       networkType: NetworkType.solana,
      //       coingeckoKey: "tether",
      //       tokenPrice: 0.0,
      //       priceChangePercentage24h: 0.0,
      //     ),
      //     // TokenInfo(
      //     //   symbol: "GRT",
      //     //   name: "The Graph",
      //     //   address: "0xc944e90c64b2c07662a292be6244bdf05cda44a7",
      //     //   decimals: 18,
      //     //   logoUrl:
      //     //       "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_thegraph.png?alt=media&token=9f44",
      //     //   networkType: NetworkType.solana,
      //     //   coingeckoKey: "the-graph",
      //     // ),
      //     TokenInfo(
      //       symbol: "JUP",
      //       name: "Jupiter",
      //       address: "JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN",
      //       decimals: 6,
      //       logoUrl:
      //           "https://firebasestorage.googleapis.com/v0/b/planet-908b5.firebasestorage.app/o/custom_token%2Fic_jupiter.png?alt=media&token=9f43",
      //       networkType: NetworkType.solana,
      //       coingeckoKey: "jupiter",
      //     )
      //   ].map((e) => e.toJson()),
      // ],
    });
  }
}
