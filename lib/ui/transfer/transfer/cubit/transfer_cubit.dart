import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planet/bloc/app/app_bloc.dart';
import 'package:planet/bloc/app/app_event.dart';
import 'package:planet/enum/gas_priority.dart';
import 'package:planet/enum/network_type.dart';
import 'package:planet/enum/screen_status.dart';
import 'package:planet/model/custom_exception.dart';
import 'package:planet/model/token_balance.dart';
import 'package:planet/model/transfer_fee.dart';
import 'package:planet/service/wallet/wallet_service.dart';
import 'package:planet/ui/util/app_util.dart';

import '../../../../bloc/app/app_state.dart';
import '../../../../service/wallet/walltet_transfer_service.dart';

part 'transfer_state.dart';

class TokenTransferCubit extends Cubit<TokenTransferState> {
  final AppBloc appBloc;
  final TokenBalance tokenBalance;

  TokenTransferCubit({
    required this.appBloc,
    required this.tokenBalance,
  }) : super(const TokenTransferState());

  final WalletTransferService _transferService = WalletTransferService();
  final WalletService _walletService = WalletService();

  Future<void> initialize() async {
    emit(state.copyWith(status: ScreenStatus.loading));

    try {
      final gasFees = await _transferService.estimateGasFeesByPriority();

      emit(state.copyWith(
        balance: tokenBalance,
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

  /// 받는사람 업데이트
  void updateRecipientAddress(String address) {
    emit(state.copyWith(recipientAddress: address));
  }

  /// 받는 양 업데이트
  void updateAmount(String amount) {
    emit(state.copyWith(amount: amount));
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

      // Get wallet credentials
      final mnemonic = appState.current.mnemonic;
      final credentials = await _walletService.getCredentialsFromMnemonic(
          mnemonic, NetworkType.ethereum, 0);

      // Parse amount
      final amountInWei = AppUtil.convertToWei(state.amount);

      bool success;

      // todo : 이거 이더리움만인지 하위 토큰도인지
      // Check if using custom gas settings
      if (state.useCustomGas && state.customGasFee != null) {
        // Execute transaction with custom gas settings
        success = await _transferService.sendAndWaitForTransactionWithCustomGas(
          toAddress: state.recipientAddress,
          amount: amountInWei,
          credentials: credentials,
          gasPrice: state.customGasFee!.gasPrice,
          gasLimit: state.customGasFee!.gasLimit,
        );
      } else {
        // Execute transaction with predefined gas priority
        success = await _transferService.sendAndWaitForTransaction(
          toAddress: state.recipientAddress,
          amount: amountInWei,
          credentials: credentials,
          gasPriority: state.selectedGasPriority,
        );
      }

      if (success) {
        // Refresh balances
        appBloc.add(AppUpdate(updateBalance: true));
      }

      emit(state.copyWith(status: ScreenStatus.success));
      return success;
    } catch (e) {
      emit(state.copyWith(
        status: ScreenStatus.fail,
        exception: CustomException(errMsg: e.toString()),
      ));
      return false;
    }
  }
}
