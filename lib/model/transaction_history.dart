import 'package:planet/model/token_info.dart';

import '../util/data/token_data.dart';

enum TransactionHistoryStatus {
  isPending,
  isSent,
  isReceived;

  String get iconPath {
    switch (this) {
      case isPending:
        return "icons/ic_pending.svg";
      case isSent:
        return "icons/ic_sent.svg";
      case isReceived:
        return "icons/ic_received.svg";
    }
  }

  String get title {
    switch (this) {
      case isPending:
        return "Pending";
      case isSent:
        return "Sent";
      case isReceived:
        return "Received";
    }
  }
}

class TransactionHistory {
  // 공통 필드
  final String hash; // 트랜잭션 해시 (이더리움/비트코인 공통)
  final String from; // 송신자 주소 (이더리움/비트코인 공통)
  final String to; // 수신자 주소 (이더리움/비트코인 공통)
  final DateTime? timestamp; // 트랜잭션 타임스탬프 (이더리움/비트코인 공통)
  final int? confirmations; // 확인 수 (이더리움/비트코인 공통)
  final bool? isSuccess; // 성공 여부 (이더리움/비트코인 공통)

  // 토큰 관련 필드
  final String? tokenSymbol; // 토큰 심볼 (이더리움에서 주로 사용, 비트코인은 "BTC" 고정)
  final double? amount; // 거래 금액 (이더리움/비트코인 공통)
  final int? decimals; // 토큰 소수점 자릿수 (이더리움에서 주로 사용, 비트코인은 8 고정)
  final String? tokenAddress; // 토큰 컨트랙트 주소 (이더리움에서만 사용)

  // 추가 필드
  final double? fee; // 트랜잭션 수수료 (이더리움/비트코인 공통)
  final int? gas; // 가스 한도 (이더리움 전용)
  final double? gasPrice; // 가스 가격 (이더리움 전용)
  final int? gasUsed; // 사용된 가스 (이더리움 전용)
  final TransactionHistoryStatus? status; // 트랜잭션 상태 (이더리움/비트코인 공통)

  const TransactionHistory({
    this.hash = "",
    this.from = "",
    this.to = "",
    this.timestamp,
    this.tokenSymbol,
    this.amount,
    this.confirmations,
    this.isSuccess,
    this.decimals,
    this.tokenAddress,
    this.fee,
    this.gas,
    this.gasPrice,
    this.gasUsed,
    this.status,
  });

  static const empty = const TransactionHistory();

  // Etherscan ETH 트랜잭션 응답에서 생성
  factory TransactionHistory.fromEtherscanTx(
    Map<String, dynamic> tx,
    String userAddress,
  ) {
    final decimals =
        TokenData.ethTokens.where((e) => e.symbol == "ETH").first.decimals;

    // Dart에서는 BigInt를 double로 직접 나눌 수 없으므로 계산 방식 변경
    final amountInWei = BigInt.parse(tx['value']);
    final divisor = BigInt.from(10).pow(decimals);
    final wholeNumber = amountInWei ~/ divisor;
    final fraction = amountInWei % divisor;

    // 소수점 이하 계산
    final fractionalPart = fraction.toDouble() / divisor.toDouble();
    final amount = wholeNumber.toDouble() + fractionalPart;

    // 수수료 계산 (gasPrice * gasUsed)
    final gasPrice = BigInt.parse(tx['gasPrice']);
    final gasUsed = BigInt.parse(tx['gasUsed']);
    final feeInWei = gasPrice * gasUsed;
    final feeWhole = feeInWei ~/ divisor;
    final feeFraction = feeInWei % divisor;
    final fee =
        feeWhole.toDouble() + (feeFraction.toDouble() / divisor.toDouble());

    final isSuccess = tx['txreceipt_status'] == '1';

    bool isIncoming = tx['to'].toLowerCase() == userAddress.toLowerCase();
    return TransactionHistory(
      hash: tx['hash'],
      from: tx['from'],
      to: tx['to'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        int.parse(tx['timeStamp']) * 1000,
      ),
      // isIncoming: ,
      tokenSymbol: 'ETH',
      amount: amount,
      confirmations: int.parse(tx['confirmations']),
      isSuccess: isSuccess,
      decimals: decimals,
      tokenAddress: null,
      // ETH는 토큰 주소가 없음
      fee: fee,
      gas: int.parse(tx['gas']),
      gasPrice: double.parse(tx['gasPrice']) / 1e9,
      // Gwei로 변환
      gasUsed: int.parse(tx['gasUsed']),
      status: tx["confirmations"] == 0
          ? TransactionHistoryStatus.isPending
          : (isIncoming
              ? TransactionHistoryStatus.isReceived
              : TransactionHistoryStatus.isSent),
    );
  }

  // Etherscan 토큰 트랜잭션 응답에서 생성
  factory TransactionHistory.fromEtherscanTokenTx(
    Map<String, dynamic> tx,
    String userAddress,
  ) {
    var info = TokenData.ethTokens
        .where((e) => e.symbol == tx['tokenSymbol'])
        .firstOrNull;
    if (info == null) {
      return TransactionHistory.empty;
    }

    final decimals = info.decimals;

    // Dart에서는 BigInt를 double로 직접 나눌 수 없으므로 계산 방식 변경
    final amountInWei = BigInt.parse(tx['value']);
    final divisor = BigInt.from(10).pow(decimals);
    final wholeNumber = amountInWei ~/ divisor;
    final fraction = amountInWei % divisor;

    // 소수점 이하 계산
    final fractionalPart = fraction.toDouble() / divisor.toDouble();
    final amount = wholeNumber.toDouble() + fractionalPart;

    // 수수료 계산 (가능한 경우)
    double? fee;
    try {
      final gasPrice = BigInt.parse(tx['gasPrice'] ?? '0');
      final gasUsed = BigInt.parse(tx['gasUsed'] ?? '0');
      final ethDivisor = BigInt.from(10).pow(18); // ETH는 항상 18 자리
      final feeInWei = gasPrice * gasUsed;
      final feeWhole = feeInWei ~/ ethDivisor;
      final feeFraction = feeInWei % ethDivisor;
      fee = feeWhole.toDouble() +
          (feeFraction.toDouble() / ethDivisor.toDouble());
    } catch (e) {
      fee = null;
    }

    bool isIncoming = tx['to'].toLowerCase() == userAddress.toLowerCase();
    return TransactionHistory(
      hash: tx['hash'],
      from: tx['from'],
      to: tx['to'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        int.parse(tx['timeStamp']) * 1000,
      ),
      tokenSymbol: tx['tokenSymbol'],
      amount: amount,
      confirmations: int.parse(tx['confirmations']),
      isSuccess: true,
      // 토큰 트랜잭션은 성공한 것으로 간주
      decimals: decimals,
      tokenAddress: tx['contractAddress'],
      fee: fee,
      gas: tx['gas'] != null ? int.parse(tx['gas']) : null,
      gasPrice:
          tx['gasPrice'] != null ? double.parse(tx['gasPrice']) / 1e9 : null,
      // Gwei로 변환
      gasUsed: tx['gasUsed'] != null ? int.parse(tx['gasUsed']) : null,
      status: tx["confirmations"] == 0
          ? TransactionHistoryStatus.isPending
          : (isIncoming
              ? TransactionHistoryStatus.isReceived
              : TransactionHistoryStatus.isSent),
    );
  }

  // 내부 트랜잭션 응답에서 생성 (이더리움 전용)
  factory TransactionHistory.fromEtherscanInternalTx(
    Map<String, dynamic> tx,
    String userAddress,
  ) {
    var info = TokenData.ethTokens
        .where((e) => e.symbol == tx['tokenSymbol'])
        .firstOrNull;
    if (info == null) {
      return TransactionHistory.empty;
    }
    // Dart에서는 BigInt를 double로 직접 나눌 수 없으므로 계산 방식 변경
    final amountInWei = BigInt.parse(tx['value']);
    final divisor = BigInt.from(10).pow(info.decimals);
    final wholeNumber = amountInWei ~/ divisor;
    final fraction = amountInWei % divisor;

    // 소수점 이하 계산
    final fractionalPart = fraction.toDouble() / divisor.toDouble();
    final amount = wholeNumber.toDouble() + fractionalPart;

    bool isIncoming = tx['to'].toLowerCase() == userAddress.toLowerCase();
    return TransactionHistory(
      hash: tx['hash'],
      from: tx['from'],
      to: tx['to'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        int.parse(tx['timeStamp']) * 1000,
      ),
      tokenSymbol: 'ETH',
      amount: amount,
      confirmations: int.parse(tx['blockNumber']),
      // 내부 트랜잭션은 confirmations 대신 blockNumber 사용
      isSuccess: true,
      // 내부 트랜잭션은 성공한 트랜잭션만 반환됨
      decimals: info.decimals,
      tokenAddress: null,
      // ETH는 토큰 주소가 없음
      fee: 0,
      // 내부 트랜잭션은 별도의 수수료가 없음
      gas: 0,
      gasPrice: 0,
      gasUsed: 0,
      status: tx["confirmations"] == 0
          ? TransactionHistoryStatus.isPending
          : (isIncoming
              ? TransactionHistoryStatus.isReceived
              : TransactionHistoryStatus.isSent),
    );
  }

  // BlockCypher 비트코인 트랜잭션 응답에서 생성 (비트코인 전용)
  // BlockCypher 비트코인 트랜잭션 응답에서 생성 (비트코인 전용)
  factory TransactionHistory.fromBlockCypherTx(
    Map<String, dynamic> tx,
    String userAddress,
  ) {
    try {
      final String txHash = tx['hash'] ?? '';
      final int confirmations = tx['confirmations'] ?? 0;
      final DateTime? timestamp =
          tx['received'] != null ? DateTime.parse(tx['received']) : null;

      // 총 입력 및 출력 리스트 가져오기
      List inputs = tx['inputs'] ?? [];
      List outputs = tx['outputs'] ?? [];

      // 사용자 주소가 inputs에 포함되어 있는지 확인 (내가 보낸 거래인지 체크)
      bool isSentTransaction = inputs.any((input) {
        List addresses = input['addresses'] ?? [];
        return addresses.contains(userAddress);
      });

      // 사용자 주소가 outputs에 포함되어 있는지 확인 (내가 받은 거래인지 체크)
      bool isReceivedTransaction = outputs.any((output) {
        List addresses = output['addresses'] ?? [];
        return addresses.contains(userAddress);
      });

      // 거래 유형 결정 (보낸 것인지 받은 것인지)
      bool isIncoming = isReceivedTransaction && !isSentTransaction;

      // 송금액 계산
      double amount = 0;

      if (isIncoming) {
        // 받은 경우: outputs에서 내 주소로 들어온 금액 합산
        for (var output in outputs) {
          List addresses = output['addresses'] ?? [];
          if (addresses.contains(userAddress)) {
            amount += (output['value'] ?? 0) / 100000000; // satoshi -> BTC 변환
          }
        }
      } else {
        // 보낸 경우: 내가 보낸 총 금액 - 잔돈
        double totalSent = 0;
        double changeAmount = 0;

        // Inputs에서 내가 보낸 총 금액 계산
        for (var input in inputs) {
          List addresses = input['addresses'] ?? [];
          if (addresses.contains(userAddress)) {
            totalSent +=
                (input['output_value'] ?? 0) / 100000000; // satoshi -> BTC 변환
          }
        }

        // Outputs에서 내가 다시 받은 잔돈 확인
        for (var output in outputs) {
          List addresses = output['addresses'] ?? [];
          if (addresses.contains(userAddress)) {
            changeAmount +=
                (output['value'] ?? 0) / 100000000; // satoshi -> BTC 변환
          }
        }

        // 실제 송금액 = 내가 보낸 총 금액 - 내가 받은 잔돈
        amount = totalSent - changeAmount;
      }

      // 수수료 계산
      double fee = (tx['fees'] ?? 0) / 100000000; // satoshi -> BTC 변환

      // 송신자 주소 설정
      String from = 'Unknown';
      if (inputs.isNotEmpty &&
          inputs[0]['addresses'] is List &&
          inputs[0]['addresses'].isNotEmpty) {
        from = inputs[0]['addresses'][0];
      }

      // 수신자 주소 설정
      String to = 'Unknown';
      if (outputs.isNotEmpty &&
          outputs[0]['addresses'] is List &&
          outputs[0]['addresses'].isNotEmpty) {
        to = outputs[0]['addresses'][0];
      }

      // 트랜잭션 상태 결정
      TransactionHistoryStatus transactionStatus;
      if (confirmations == 0) {
        transactionStatus = TransactionHistoryStatus.isPending;
      } else {
        transactionStatus = isIncoming
            ? TransactionHistoryStatus.isReceived
            : TransactionHistoryStatus.isSent;
      }

      return TransactionHistory(
        hash: txHash,
        from: from,
        to: to,
        timestamp: timestamp,
        tokenSymbol: 'BTC',
        amount: amount.abs(),
        // 절대값 사용
        confirmations: confirmations,
        isSuccess: true,
        // BlockCypher API는 성공한 트랜잭션만 반환
        decimals: 8,
        // BTC는 항상 8 소수점
        tokenAddress: null,
        // BTC는 토큰 주소가 없음
        fee: fee,
        gas: 0,
        // Bitcoin에는 해당 없음
        gasPrice: 0,
        // Bitcoin에는 해당 없음
        gasUsed: 0,
        // Bitcoin에는 해당 없음
        status: transactionStatus,
      );
    } catch (e) {
      print('Error parsing Bitcoin transaction: $e');
      return TransactionHistory.empty;
    }
  }

  // ETH 트랜잭션 생성을 위한 factory 생성자
  factory TransactionHistory.createEthTransaction(
      CommonTransactionData data, double value) {
    return TransactionHistory(
      hash: data.hash,
      from: data.from,
      to: data.to,
      timestamp: data.timestamp,
      tokenSymbol: 'ETH',
      amount: value,
      confirmations: data.confirmations,
      isSuccess: true,
      decimals: 18,
      // ETH의 기본 decimals
      tokenAddress: null,
      fee: null,
      gas: null,
      gasPrice: null,
      gasUsed: null,
      status: data.status,
    );
  }

  // 토큰 트랜잭션 생성을 위한 factory 생성자
  factory TransactionHistory.createTokenTransaction(
      CommonTransactionData data, Map<String, dynamic> tx, double value) {
    final tokenAddress = tx['rawContract']?['address']?.toString();
    final decimal = tx['rawContract']?['decimal'] != null
        ? int.tryParse(tx['rawContract']['decimal'].toString()) ?? 18
        : 18;
    final tokenSymbol = tx['asset']?.toString();

    return TransactionHistory(
      hash: data.hash,
      from: data.from,
      to: data.to,
      timestamp: data.timestamp,
      tokenSymbol: tokenSymbol,
      amount: value,
      confirmations: data.confirmations,
      isSuccess: true,
      decimals: decimal,
      tokenAddress: tokenAddress,
      fee: null,
      gas: null,
      gasPrice: null,
      gasUsed: null,
      status: data.status,
    );
  }
}

/// 솔라나 트랜잭션 파싱을 위한 헬퍼 클래스
class SolanaTransactionHistoryParser {
  /// 솔라나 트랜잭션 정보로부터 TransactionHistory 객체 생성
  static TransactionHistory fromSolanaTransaction(
    Map<String, dynamic> tx,
    String userAddress,
  ) {
    try {
      final String txHash = tx['signature'] ?? '';
      final DateTime? timestamp = tx['blockTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(tx['blockTime'] * 1000)
          : null;

      // 송신자와 수신자 주소
      String from = 'Unknown';
      String to = 'Unknown';

      // 거래 유형과 금액
      bool isIncoming = false;
      double amount = 0;
      String tokenSymbol = 'SOL';
      String? tokenAddress;
      int decimals = 9; // SOL 기본

      // 토큰 유형 및 금액 처리
      if (tx['tokenTransfers'] != null && tx['tokenTransfers'].isNotEmpty) {
        // SPL 토큰 트랜잭션
        final tokenTransfer = tx['tokenTransfers'][0];
        from = tokenTransfer['fromUserAccount'] ?? 'Unknown';
        to = tokenTransfer['toUserAccount'] ?? 'Unknown';

        // 토큰 정보
        tokenAddress = tokenTransfer['mint'];

        // 토큰 심볼과 데시멀 찾기
        if (tokenAddress != null) {
          final tokenInfo = TokenData.solanaTokens.firstWhere(
            (t) => t.address.toLowerCase() == tokenAddress!.toLowerCase(),
            orElse: () => TokenInfo(
              symbol: 'Unknown',
              name: 'Unknown Token',
              address: tokenAddress!,
              decimals: 0,
              logoUrl: '',
              coingeckoKey: '',
            ),
          );

          tokenSymbol = tokenInfo.symbol;
          decimals = tokenInfo.decimals;
        }

        // 금액 처리
        amount = tokenTransfer['tokenAmount'] != null
            ? (tokenTransfer['tokenAmount']['uiAmount'] ?? 0).toDouble()
            : 0;

        // 거래 방향
        isIncoming = to.toLowerCase() == userAddress.toLowerCase();
      } else {
        // SOL 네이티브 트랜잭션
        final List<dynamic> instructions = tx['instructions'] ?? [];

        if (instructions.isNotEmpty) {
          from = instructions[0]['accounts'][0] ?? 'Unknown';
          to = instructions[0]['accounts'][1] ?? 'Unknown';

          // SOL 전송 금액 (lamports를 SOL로 변환)
          if (tx['meta'] != null &&
              tx['meta']['postBalances'] != null &&
              tx['meta']['preBalances'] != null) {
            // 복잡한 솔라나 트랜잭션에서 금액 계산은 어려울 수 있음
            // 간단한 추정: 송신자 계정의 잔액 변화
            final List<dynamic> preBalances = tx['meta']['preBalances'];
            final List<dynamic> postBalances = tx['meta']['postBalances'];

            if (preBalances.length > 0 && postBalances.length > 0) {
              final double preBalance =
                  preBalances[0] / 1000000000; // lamports to SOL
              final double postBalance = postBalances[0] / 1000000000;
              amount = (preBalance - postBalance).abs();
            }
          }

          // 거래 방향
          isIncoming = to.toLowerCase() == userAddress.toLowerCase();
        }
      }

      // 수수료
      double? fee;
      if (tx['meta'] != null && tx['meta']['fee'] != null) {
        fee = tx['meta']['fee'] / 1000000000; // lamports to SOL
      }

      // 트랜잭션 상태
      TransactionHistoryStatus status;
      if (tx['confirmations'] != null && tx['confirmations'] == 0) {
        status = TransactionHistoryStatus.isPending;
      } else {
        status = isIncoming
            ? TransactionHistoryStatus.isReceived
            : TransactionHistoryStatus.isSent;
      }

      return TransactionHistory(
        hash: txHash,
        from: from,
        to: to,
        timestamp: timestamp,
        tokenSymbol: tokenSymbol,
        amount: amount,
        confirmations: tx['confirmations'] ?? 1,
        isSuccess: tx['err'] == null,
        // err가 null이면 성공
        decimals: decimals,
        tokenAddress: tokenAddress,
        fee: fee,
        status: status,
      );
    } catch (e) {
      print('Error parsing Solana transaction: $e');
      return TransactionHistory.empty;
    }
  }
}

// 공통 데이터를 위한 클래스 (일단 이더리움에서 만들어짐)
class CommonTransactionData {
  final String hash;
  final String from;
  final String to;
  final DateTime? timestamp;
  final int confirmations;
  final TransactionHistoryStatus status;

  CommonTransactionData({
    required this.hash,
    required this.from,
    required this.to,
    required this.timestamp,
    required this.confirmations,
    required this.status,
  });
}
