import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/model/token_balance.dart';
import 'package:planet/model/token_info.dart';
import 'package:planet/repository/fb_repository.dart';
import 'package:planet/service/local_storage_service.dart';
import 'package:planet/util/app_constant.dart';
import 'package:planet/util/app_util.dart';
import 'package:planet/util/data/token_data.dart';

import '../../service/global_service.dart';
import '../../service/wallet/wallet_balance/wallet_balance_service.dart';
import 'bloc.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final GlobalService globalService;
  final ApiRepository apiRepository;

  AppBloc({
    required this.globalService,
    required this.apiRepository,
  }) : super(AppLoading());

  @override
  Stream<AppState> mapEventToState(event) async* {
    if (event is AppInitialize) {
      yield* mapAppInitializeToState(event);
    } else if (event is AppUpdate) {
      yield* mapAppUpdateToState(event);
    } else if (event is AppSignOut) {
      yield* mapAppSignOutToState(event);
    }
  }

  Stream<AppState> mapAppInitializeToState(AppInitialize event) async* {
    // await apiRepository.updateCustomtoken();

    /// 이더 커스텀 토큰에 넣기
    var customTokens = await apiRepository.getCustomToken();
    // await apiRepository.updateCustomtoken();
    TokenData.ethTokens = customTokens.etherium;
    TokenData.solanaTokens = customTokens.solana;
    TokenData.bscTokens = customTokens.bsc;
    globalService.initialize();

    // await apiRepository.signOut();
    yield AppLoading();
    FirebaseAnalytics.instance.logAppOpen();

    /// 강제 업데이트
    var latestVersion = await apiRepository.getVersion();
    if (AppUtil.isUpdateRequired(AppConstant.appVersion, latestVersion)) {
      yield AppRequiredVersionUpdate();
      return;
    }

    var localPlanets = await LocalStorageService.getLocalPlanets();

    // 로컬에 저장된 플래닛이 없는 경우
    if (localPlanets.isEmpty) {
      yield AppUnInitialized.sign;
    } else {
      // 로컬에 저장된거 있는데
      // 핀번호가 없는 경우
      var pin = SharedPrefsUtil.getString(AppConstant.pinCode) ?? "";
      if (pin.isEmpty) {
        yield AppUnInitialized.pin;
        return;
      }

      // 핀번호까지 잘 마친 경우
      //-
      // 로컬에 있는 플래닛 FB에서 정보 가져오기
      var planets = await apiRepository.getPlanetByLocalInfo(localPlanets);

      if (planets.isEmpty) {
        await apiRepository.signOut();
        yield AppUnInitialized.sign;
        return;
      }
      // 현재 앱에서 보여줄 메인 플래닛
      var current = _getCurrentPlanet(planets);

      // 현재 메인 플래닛의 토큰 밸런스들
      var updateBalance = await _getTokenBalance(
        oldValues: [],
        currentPlanet: current,
        updateAllBalance: true,
      );

      var tokens = updateBalance.map((e) => e.info).toList();
      var priceInfo = await apiRepository.fetchCoinPrices(tokens);

      List<TokenBalance> newBalance = [];
      for (var item in updateBalance) {
        var priceItem =
            priceInfo.where((e) => e.symbol == item.info.symbol).firstOrNull;
        item = item.copyWith(info: priceItem);
        newBalance.add(item);
      }

      yield AppLoaded(
        planets: planets,
        balances: newBalance,
        current: current,
      );
    }
  }

  Stream<AppState> mapAppUpdateToState(AppUpdate event) async* {
    yield (state as AppLoaded).copyWith(isLoading: true);

    try {
      // 로컬에서 플래닛 가져오기
      var planets = event.updatePlanets
          ? await _getPlanetDto()
          : (state as AppLoaded).planets;

      // 현재 앱에서 메인으로 다루는 플래닛
      var current = _getCurrentPlanet(planets);

      if ((state as AppLoaded).current.name != current.name) {
        yield (state as AppLoaded).copyWith(current: current);
      }

      // 메인 플래닛의 토큰 Balance 들
      List<TokenBalance> updateBalance = (state as AppLoaded).balances;

      // 밸런스 업데이트 필요한 경우
      if (event.updateBalance || event.updateBalanceToken != TokenInfo.empty) {
        updateBalance = await _getTokenBalance(
          oldValues: updateBalance,
          currentPlanet: current,
          updateAllBalance: event.updateBalance,
          updateBalanceToken: event.updateBalanceToken,
        );
      }

      // if (event.updatePrice) {
      var tokens = updateBalance.map((e) => e.info).toList();
      var priceInfo = await apiRepository.fetchCoinPrices(tokens);

      List<TokenBalance> newBalance = [];
      for (var item in updateBalance) {
        var priceItem =
            priceInfo.where((e) => e.symbol == item.info.symbol).firstOrNull;
        item = item.copyWith(info: priceItem);
        newBalance.add(item);
      }
      updateBalance = [...newBalance];
      // }

      yield AppLoaded(
        isLoading: false,
        planets: planets,
        balances: updateBalance,
        current: current,
      );
    } catch (err) {
      print(err);
    }
  }

  Stream<AppState> mapAppSignOutToState(AppSignOut event) async* {
    await apiRepository.signOut();
    add(AppInitialize());
  }

  /// functions ------------------------------------
  /// functions ------------------------------------
  /// functions ------------------------------------
  Future<List<Planet>> _getPlanetDto() async {
    var localPlanets = await LocalStorageService.getLocalPlanets();
    // 로컬에서 가져온 플래닛의 정보 FB에서 불러오기
    var planets = await apiRepository.getPlanetByLocalInfo(localPlanets);
    return planets;
  }

  Planet _getCurrentPlanet(List<Planet> planets) {
    return planets.where((e) => e.isCurrent).firstOrNull ?? planets.first;
  }

  /// 한개만 업데이트 필요한 경우와 전체 필요한 경우 구분해서 보여줌
  Future<List<TokenBalance>> _getTokenBalance({
    required List<TokenBalance> oldValues,
    required Planet currentPlanet,
    bool updateAllBalance = false,
    TokenInfo updateBalanceToken = TokenInfo.empty,
  }) async {
    List<TokenBalance> updateBalance = [...oldValues];
    var walletService = WalletBalanceService();
    var current = currentPlanet.address;
    var network = currentPlanet.networkType!;
    if (updateAllBalance) {
      // 모든 밸런스 업데이트
      updateBalance = await walletService.getAllTokenBalances(
          walletAddress: current, networkType: network);
    } else if (updateBalanceToken != TokenInfo.empty) {
      // 특정 한개 밸런스만 업데이트
      var updateTokenBalance = await walletService.getTokenBalance(
          address: current, info: updateBalanceToken, networkType: network);

      // 기존 밸런스에서 한개만 업데이트 하기
      updateBalance = updateBalance
          .map((e) => e.info.address == updateTokenBalance.info.address
              ? updateTokenBalance
              : e)
          .toList();
    }
    return updateBalance;
  }

  /// ---------------------------------------------------
  /// ---------------------------------------------------
  /// ---------------------------------------------------
}
