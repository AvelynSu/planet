import 'package:flutter/material.dart';
import 'package:planet/model/transfer_fee.dart';

import '../../../enum/gas_priority.dart';
import '../../../service/wallet/walltet_transfer_service.dart';
import '../../util/app_ui.dart';

class TestWithdrawScreen extends StatefulWidget {
  const TestWithdrawScreen({super.key});

  static push(BuildContext context) {
    AppUi.push(context, const TestWithdrawScreen());
  }

  @override
  State<TestWithdrawScreen> createState() => _TestWithdrawScreenState();
}

class _TestWithdrawScreenState extends State<TestWithdrawScreen> {
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  GasPriority _selectedGasPriority = GasPriority.medium;
  final _transactionService = WalletTransferService();
  bool _isLoading = false;
  Map<GasPriority, TransferFee>? _gasFees;

  @override
  void initState() {
    super.initState();
    _loadGasFees();
  }

  Future<void> _loadGasFees() async {
    try {
      final fees = await _transactionService.estimateGasFeesByPriority();
      setState(() => _gasFees = fees);
    } catch (e) {
      debugPrint('Error loading gas fees: $e');
    }
  }

  Future<void> _withdraw() async {
    if (_addressController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주소와 금액을 입력해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. ETH -> Wei 변환
      // final amountInWei =
      //     BigInt.from(double.parse(_amountController.text) * pow(10, 18));

      // 2. 트랜잭션 실행
      // final success = await _transactionService.sendAndWaitForTransaction(
      //   toAddress: _addressController.text,
      //   amount: amountInWei,
      //   credentials: "credentials", // HD 월렛에서 가져온 credentials
      //   gasPriority: _selectedGasPriority,
      // );

      if (false) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('출금이 완료되었습니다')),
        // );
        // Navigator.pop(context); // 화면 닫기
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('출금에 실패했습니다')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ETH 출금')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 주소 입력
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: '받는 주소',
                hintText: '0x...',
              ),
            ),
            const SizedBox(height: 16),

            // 금액 입력
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: '금액 (ETH)',
                hintText: '0.01',
              ),
            ),
            const SizedBox(height: 24),

            // 가스비 선택
            if (_gasFees != null) ...[
              Text('가스비 선택', style: Theme.of(context).textTheme.titleMedium),
              RadioListTile<GasPriority>(
                title: Text('느림 (${_gasFees![GasPriority.slow]?.formatted})'),
                value: GasPriority.slow,
                groupValue: _selectedGasPriority,
                onChanged: (value) =>
                    setState(() => _selectedGasPriority = value!),
              ),
              RadioListTile<GasPriority>(
                title: Text('보통 (${_gasFees![GasPriority.medium]?.formatted})'),
                value: GasPriority.medium,
                groupValue: _selectedGasPriority,
                onChanged: (value) =>
                    setState(() => _selectedGasPriority = value!),
              ),
              RadioListTile<GasPriority>(
                title: Text('빠름 (${_gasFees![GasPriority.fast]?.formatted})'),
                value: GasPriority.fast,
                groupValue: _selectedGasPriority,
                onChanged: (value) =>
                    setState(() => _selectedGasPriority = value!),
              ),
            ],

            const SizedBox(height: 24),

            // 출금 버튼
            ElevatedButton(
              onPressed: _isLoading ? null : _withdraw,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('출금하기'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
