import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/model/token_balance.dart';
import 'package:planet/model/token_info.dart';
import 'package:planet/repository/fb_repository.dart';
import 'package:planet/service/local_storage_service.dart';
import 'package:planet/service/wallet/wallet_balance_service.dart';

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
      var walletService = WalletBalanceService();

      // 로컬에 있는 플래닛 FB에서 정보 가져오기
      var planets = await apiRepository.getPlanetByLocalInfo(localPlanets);
      // 현재 앱에서 보여줄 메인 플래닛
      var current =
          planets.where((e) => e.isCurrent).firstOrNull ?? planets.first;
      // 현재 메인 플래닛의 토큰 밸런스들
      var updateBalance = await walletService.getAllTokenBalances(
          walletAddress: current.address, networkType: current.networkType!);
      await Future.delayed(const Duration(seconds: 2));
      yield AppLoaded(
        myPlanets: planets,
        currentTokens: updateBalance,
        currentPlanet: current,
      );
    }

    // await userRepository.signOut();
  }

  Stream<AppState> mapAppUpdateToState(AppUpdate event) async* {
    try {
      var walletService = WalletBalanceService();

      // 로컬에서 플래닛 가져오기
      var localPlanets = await LocalStorageService.getLocalPlanets();

      // 로컬에서 가져온 플래닛의 정보 FB에서 불러오기
      var planets = await apiRepository.getPlanetByLocalInfo(localPlanets);

      // 현재 앱에서 메인으로 다루는 플래닛
      var currentPlanet =
          planets.where((e) => e.isCurrent).firstOrNull ?? planets.first;

      // 메인 플래닛의 토큰 Balance 들
      List<TokenBalance> updateBalance = (state as AppLoaded).currentTokens;

      // 밸런스 업데이트 필요한 경우
      if (event.updateBalance) {
        // 모든 밸런스 업데이트
        updateBalance = await walletService.getAllTokenBalances(
            walletAddress: currentPlanet.address,
            networkType: currentPlanet.networkType!);
      } else if (event.updateBalanceToken != TokenInfo.empty) {
        // 특정 한개 밸런스만 업데이트
        var updateTokenBalance = await walletService.getTokenBalance(
          address: currentPlanet.address,
          info: event.updateBalanceToken,
          networkType: currentPlanet.networkType!,
        );

        // 기존 밸런스에서 한개만 업데이트 하기
        updateBalance = updateBalance
            .map((e) => e.info.address == updateTokenBalance.info.address
                ? updateTokenBalance
                : e)
            .toList();
      }

      yield AppLoaded(
        myPlanets: planets,
        currentTokens: updateBalance,
        currentPlanet: currentPlanet,
      );
    } catch (_) {}
  }

  Stream<AppState> mapAppSignOutToState(AppSignOut event) async* {
    await apiRepository.signOut();
    add(AppInitialize());
  }
}
