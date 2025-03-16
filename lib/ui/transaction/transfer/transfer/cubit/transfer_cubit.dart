import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_event.dart';
import 'package:planet/enum/gas_priority.dart';
import 'package:planet/enum/network_type.dart';
import 'package:planet/enum/screen_status.dart';
import 'package:planet/model/custom_exception.dart';
import 'package:planet/model/planet.dart';
import 'package:planet/model/token_balance.dart';
import 'package:planet/model/token_info.dart';
import 'package:planet/model/transfer_fee.dart';
import 'package:planet/service/wallet/wallet_service.dart';

import '../../../../../bloc/app/app_state.dart';
import '../../../../../service/wallet/wallet_transfer/walltet_transfer_service.dart';
import '../../../../../util/app_util.dart';

part 'transfer_state.dart';

class TokenTransferCubit extends Cubit<TokenTransferState> {
  final AppBloc appBloc;
  final TokenInfo tokenInfo;
  final Planet toPlanet;
  final String amount;

  late StreamSubscription subscription;

  TokenTransferCubit({
    required this.appBloc,
    required this.tokenInfo,
    required this.toPlanet,
    required this.amount,
  }) : super(const TokenTransferState()) {
    subscription = appBloc.stream.listen((state) {
      _update();
    });
  }

  NetworkType get networkType => tokenInfo.networkType;

  _update() {
    var appState = appBloc.state as AppLoaded;
    var balances = appState.balances
        .where((e) => e.info.symbol == tokenInfo.symbol)
        .firstOrNull;
    emit(state.copyWith(
        balance: balances ?? TokenBalance.empty, status: ScreenStatus.loaded));
  }

  final WalletTransferService _transferService = WalletTransferService();
  final WalletService _walletService = WalletService();

  Future<void> initialize() async {
    emit(state.copyWith(
        status: ScreenStatus.loading, toPlanet: toPlanet, amount: amount));

    try {
      // 앱 상태 가져오기
      var appState = appBloc.state as AppLoaded;

      // 현재 플래닛의 네트워크 타입과 주소 가져오기
      final fromAddress = appState.current.address;

      // estimateGasFeesByPriority 대신 estimateTransferFees 사용
      final gasFees = await _transferService.estimateTransferFees(
        networkType: networkType,
        fromAddress: fromAddress,
        toAddress: toPlanet.address,
      );

      var balances = appState.balances
          .where((e) => e.info.symbol == tokenInfo.symbol)
          .firstOrNull;
      emit(state.copyWith(
        toPlanet: toPlanet,
        amount: amount,
        balance: balances,
        status: ScreenStatus.loaded,
        gasFees: gasFees,
        selectedGasPriority: GasPriority.medium,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ScreenStatus.fail,
        exception: CustomException(
          errType: ExceptionType.failTransferInitailize,
          errMsg: e.toString(),
        ),
      ));
    }
  }

  /// 가스비 업데이트
  void updateGasPriority(GasPriority priority) {
    emit(state.copyWith(
      selectedGasPriority: priority,
      useCustomGas: false,
    ));
  }

  void updateGasStatus(bool isCustomGas) {
    emit(state.copyWith(
      useCustomGas: isCustomGas,
    ));
  }

  /// 커스텀 가스비 업데이트
  void setCustomGas(BigInt gasPrice, BigInt gasLimit) {
    final customFee = TransferFee(
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      estimatedFee: gasPrice * gasLimit,
    );

    final updatedGasFees = Map<GasPriority, TransferFee>.from(state.gasFees);
    emit(state.copyWith(
      gasFees: updatedGasFees,
      useCustomGas: true,
      customGasFee: customFee,
    ));
  }

  /// 실행
  Future<bool> executeTransfer() async {
    emit(state.copyWith(status: ScreenStatus.loading));

    try {
      // Get current wallet credentials
      final appState = appBloc.state as AppLoaded;
      final currentPlanet = appState.current;

      // Get wallet private key from mnemonic
      final mnemonic = currentPlanet.mnemonic;
      final privateKey = await _walletService.getPrivateKeyFromMnemonic(
          mnemonic, networkType, currentPlanet.pathIdx);

      // Parse amount
      final amountInWei = AppUtil.valueToRaw(state.amount, networkType);

      bool success;

      // Check if using custom gas settings
      if (state.useCustomGas && state.customGasFee != null) {
        // sendAndWaitForTransactionWithCustomGas 대신 sendTransactionWithCustomFee 사용
        final txHash = await _transferService.sendTransaction(
          fromAddress: currentPlanet.address,
          toAddress: state.toPlanet.address,
          amount: amountInWei,
          privateKey: privateKey,
          fee: state.customGasFee!.estimatedFee,
          networkType: networkType,
        );

        // 트랜잭션 상태 확인
        success = await _transferService.checkTransactionStatus(
          txHash: txHash,
          networkType: networkType,
        );
      } else {
        // sendAndWaitForTransaction 사용하되 필수 파라미터 추가
        success = await _transferService.sendAndWaitForTransaction(
          fromAddress: currentPlanet.address,
          toAddress: state.toPlanet.address,
          amount: amountInWei,
          privateKey: privateKey,
          fee: state.gasFees[state.selectedGasPriority]!.estimatedFee,
          networkType: networkType,
        );
      }

      if (success) {
        // Refresh balances
        appBloc.add(
            AppUpdate(updatePlanets: false, updateBalanceToken: tokenInfo));
      }

      emit(state.copyWith(status: ScreenStatus.success));
      return success;
    } on CustomException catch (e) {
      emit(state.copyWith(
        status: ScreenStatus.fail,
        exception: e,
      ));
      return false;
    }
  }

  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }
}
