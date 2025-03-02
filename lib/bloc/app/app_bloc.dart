import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/model/token_balance.dart';
import 'package:planet/model/token_info.dart';
import 'package:planet/repository/fb_repository.dart';
import 'package:planet/service/local_storage_service.dart';

import '../../service/wallet/wallet_balance/wallet_balance_service.dart';
import 'bloc.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final ApiRepository apiRepository;

  AppBloc({
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
    // await apiRepository.signOut();

    yield AppLoading();
    FirebaseAnalytics.instance.logAppOpen();
    var localPlanets = await LocalStorageService.getLocalPlanets();

    /// 로컬에 저장된 플래닛이 없는 경우
    if (localPlanets.isEmpty) {
      yield AppUnInitialized.sign;
    } else {
      // 로컬에 있는 플래닛 FB에서 정보 가져오기
      var planets = await apiRepository.getPlanetByLocalInfo(localPlanets);
      // 현재 앱에서 보여줄 메인 플래닛
      var current = _getCurrentPlanet(planets);

      // 현재 메인 플래닛의 토큰 밸런스들
      var updateBalance = await _getTokenBalance(
        oldValues: [],
        currentPlanet: current,
        updateAllBalance: true,
      );

      // 심볼 보여주기 위한 딜레이
      await Future.delayed(const Duration(seconds: 2));
      yield AppLoaded(
        planets: planets,
        balances: updateBalance,
        current: current,
      );
    }
  }

  Stream<AppState> mapAppUpdateToState(AppUpdate event) async* {
    try {
      // 로컬에서 플래닛 가져오기
      var planets = event.updatePlanets
          ? await _getPlanetDto()
          : (state as AppLoaded).planets;

      // 현재 앱에서 메인으로 다루는 플래닛
      var current = _getCurrentPlanet(planets);

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

      yield AppLoaded(
        planets: planets,
        balances: updateBalance,
        current: current,
      );
    } catch (_) {}
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

  Stream<AppState> mapAppSignOutToState(AppSignOut event) async* {
    await apiRepository.signOut();
    add(AppInitialize());
  }
}
