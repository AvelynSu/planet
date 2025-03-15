part of 'wallet_balance_service.dart';

class _SolanaBalanceService implements _BlockchainBalanceService {
  // 상수 정의
  static const int _LAMPORTS_PER_SOL = 1000000000; // 9 decimals for SOL

  final sol.SolanaClient _solanaClient;

  _SolanaBalanceService()
      : _solanaClient = sol.SolanaClient(
          rpcUrl: Uri.parse(
              'https://solana-mainnet.g.alchemy.com/v2/AS2Fwk9-iN6gMwhHq96tsvnVoINK5FJI'),
          websocketUrl: Uri.parse(
              'wss://solana-mainnet.g.alchemy.com/v2/AS2Fwk9-iN6gMwhHq96tsvnVoINK5FJI'),
        );

  /// SOL 잔액을 lamports에서 SOL로 변환하는 유틸리티 메서드
  double _lamportsToSol(int lamports) {
    return lamports / _LAMPORTS_PER_SOL;
  }

  /// 특정 토큰 1개의 잔액 조회
  @override
  Future<TokenBalance> getTokenBalance({
    required String address,
    required TokenInfo info,
  }) async {
    try {
      // SOL(네이티브 토큰)인 경우
      if (info.symbol == "SOL") {
        final balance = await _solanaClient.rpcClient.getBalance(address);
        final value = _lamportsToSol(balance.value);
        return TokenBalance(address: address, info: info, balance: value);
      }

      // SPL 토큰인 경우
      try {
        // 토큰 계정 주소 찾기
        final tokenAccountAddress = await _findTokenAccountAddress(
          owner: address,
          mint: info.address,
        );

        if (tokenAccountAddress != null) {
          final accountInfo =
              await _solanaClient.rpcClient.getTokenAccountBalance(
            tokenAccountAddress,
          );

          if (accountInfo != null) {
            final amount =
                double.parse(accountInfo.value.uiAmountString ?? '0');
            return TokenBalance.fromInfo(info, address, amount);
          }
        }

        // 토큰 계정이 없는 경우 잔액은 0
        return TokenBalance.fromInfo(info, address, 0);
      } catch (e) {
        debugPrint('Error getting SPL token balance: $e');
        return TokenBalance.fromInfo(info, address, 0);
      }
    } catch (e) {
      debugPrint('Error getting ${info.symbol} balance: $e');
      throw Exception('Failed to get ${info.symbol} balance');
    }
  }

  /// 토큰 계정 주소 찾기
  Future<String?> _findTokenAccountAddress({
    required String owner,
    required String mint,
  }) async {
    try {
      final response = await _solanaClient.rpcClient.getTokenAccountsByOwner(
        owner,
        sol_dto.TokenAccountsFilter.byMint(mint),
        encoding: sol_dto.Encoding.jsonParsed,
      );

      if (response.value.isNotEmpty) {
        return response.value.first.pubkey;
      }
      return null;
    } catch (e) {
      debugPrint('Error finding token account: $e');
      return null;
    }
  }

  /// 지갑의 모든 지원 토큰 잔액 조회 - Alchemy API 사용 최적화
  @override
  Future<List<TokenBalance>> getAllTokenBalances({
    required String walletAddress,
  }) async {
    try {
      final results = <TokenBalance>[];

      // 1. SOL 잔액 조회 (네이티브 토큰)
      final solToken =
          TokenData.solanaTokens.firstWhere((t) => t.symbol == "SOL");
      final solBalance = await getTokenBalance(
        address: walletAddress,
        info: solToken,
      );
      results.add(solBalance);

      // 2. SPL 토큰 목록 가져오기
      final splTokens = TokenData.solanaTokens
          .where((token) => token.symbol != "SOL")
          .toList();

      if (splTokens.isEmpty) {
        return results; // SOL만 있는 경우
      }

      try {
        // 3. Alchemy API로 모든 토큰 계정 정보 한 번에 가져오기
        final allTokenAccounts =
            await _solanaClient.rpcClient.getTokenAccountsByOwner(
          walletAddress,
          const sol_dto.TokenAccountsFilter.byProgramId(
              sol.TokenProgram.programId),
          encoding: sol_dto.Encoding.jsonParsed,
        );

        // 4. 각 지원 토큰에 대한 계정 찾아서 잔액 조회
        for (final token in splTokens) {
          try {
            // 먼저 이미 가져온 모든 토큰 계정에서 찾기
            final tokenAccount = allTokenAccounts.value.firstWhere(
              (account) {
                try {
                  // AccountData가 ParsedAccountData인지 확인
                  if (account.account.data is! sol_dto.ParsedAccountData) {
                    return false;
                  }

                  final parsedData =
                      account.account.data as sol_dto.ParsedAccountData;
                  final dynamic parsedJson = parsedData.toJson();

                  if (parsedJson is! Map<String, dynamic> ||
                      !parsedJson.containsKey('parsed') ||
                      parsedJson['parsed'] is! Map<String, dynamic>) {
                    return false;
                  }

                  final parsed = parsedJson['parsed'] as Map<String, dynamic>;

                  if (!parsed.containsKey('info') ||
                      parsed['info'] is! Map<String, dynamic>) {
                    return false;
                  }

                  final info = parsed['info'] as Map<String, dynamic>;
                  return info.containsKey('mint') &&
                      info['mint'] == token.address;
                } catch (e) {
                  return false;
                }
              },
              orElse: () => throw Exception('Token account not found'),
            );

            try {
              // 해당 토큰 계정이 있으면 잔액 추출
              if (tokenAccount.account.data is! sol_dto.ParsedAccountData) {
                throw Exception('Not a ParsedAccountData');
              }

              final parsedData =
                  tokenAccount.account.data as sol_dto.ParsedAccountData;
              final dynamic parsedJson = parsedData.toJson();

              if (parsedJson is! Map<String, dynamic> ||
                  !parsedJson.containsKey('parsed') ||
                  parsedJson['parsed'] is! Map<String, dynamic>) {
                throw Exception('Invalid parsed data format');
              }

              final parsed = parsedJson['parsed'] as Map<String, dynamic>;

              if (!parsed.containsKey('info') ||
                  parsed['info'] is! Map<String, dynamic>) {
                throw Exception('Invalid info data format');
              }

              final info = parsed['info'] as Map<String, dynamic>;

              if (!info.containsKey('tokenAmount') ||
                  info['tokenAmount'] is! Map<String, dynamic>) {
                throw Exception('Invalid tokenAmount data format');
              }

              final tokenAmount = info['tokenAmount'] as Map<String, dynamic>;
              final amountStr = tokenAmount['uiAmountString'] as String? ?? '0';
              final amount = double.parse(amountStr);

              results.add(TokenBalance.fromInfo(token, walletAddress, amount));
            } catch (e) {
              debugPrint('Error extracting token balance: $e');
              results.add(TokenBalance.fromInfo(token, walletAddress, 0));
            }
          } catch (e) {
            // 개별 토큰 조회로 폴백
            try {
              // 배치 요청 실패 시 개별 요청으로 폴백 (오류 발생 가능성 감소)
              final balance = await getTokenBalance(
                address: walletAddress,
                info: token,
              );
              results.add(balance);
              // 속도 제한 방지를 위한 지연 추가
              await Future.delayed(const Duration(milliseconds: 200));
            } catch (e) {
              debugPrint('Error getting balance for ${token.symbol}: $e');
              results.add(TokenBalance.fromInfo(token, walletAddress, 0));
            }
          }
        }
      } catch (e) {
        // 배치 요청 자체가 실패한 경우, 개별 조회로 완전히 폴백
        debugPrint(
            'Batch query failed, falling back to individual queries: $e');
        for (final token in splTokens) {
          try {
            final balance = await getTokenBalance(
              address: walletAddress,
              info: token,
            );
            results.add(balance);
            // 속도 제한 방지를 위한 지연 추가
            await Future.delayed(const Duration(milliseconds: 200));
          } catch (e) {
            debugPrint('Error getting balance for ${token.symbol}: $e');
            results.add(TokenBalance.fromInfo(token, walletAddress, 0));
          }
        }
      }

      return results;
    } catch (e) {
      debugPrint('Error in getAllTokenBalances: $e');
      throw Exception('Failed to get all token balances: $e');
    }
  }

  /// 서비스 종료 시 리소스 해제
  @override
  void dispose() {
    debugPrint('Disposing Solana balance service');
  }
}
