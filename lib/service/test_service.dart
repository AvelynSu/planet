import 'dart:convert';

import 'package:http/http.dart' as http;

import '../util/wallet_config.dart';

class TestService {
  bitalicNft() async {
    final response = await http.Client().get(
      Uri.parse(
          'https://eth-mainnet.g.alchemy.com/v2/AS2Fwk9-iN6gMwhHq96tsvnVoINK5FJI/getNFTs/?owner=vitalik.eth'),
      headers: {'Content-Type': 'application/json'},
    );

    final data = json.decode(response.body);
// 모든 NFT의 이미지 URL 추출하기
    if (data['ownedNfts'] != null && data['ownedNfts'].isNotEmpty) {
      for (var nft in data['ownedNfts']) {
        String nftId = nft['id']['tokenId'] ?? 'ID 없음';

        // media 배열에서 이미지 확인
        if (nft['media'] != null && nft['media'].isNotEmpty) {
          var mediaUrl = nft['media'][0]['gateway'];
          print("NFT ID: $nftId - 미디어 URL: $mediaUrl");
        }

        // metadata에서 이미지 확인
        if (nft['metadata'] != null && nft['metadata']['image'] != null) {
          var imageUrl = nft['metadata']['image'];
          print("NFT ID: $nftId - 메타데이터 이미지 URL: $imageUrl");
        }

        // 이미지가 없는 경우
        if ((nft['media'] == null || nft['media'].isEmpty) &&
            (nft['metadata'] == null || nft['metadata']['image'] == null)) {
          print("NFT ID: $nftId - 이미지 없음");
        }

        print("-------------------------");
      }
    }
    //
  }

  /// 비트코인 충전
  static getBtcTest({required String address}) async {
    final response = await http.Client().post(
      Uri.parse(
          'https://api.blockcypher.com/v1/bcy/test/faucet?token=${WalletConfig().blockCypherToken}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'address': address, // 여기에 테스트넷 주소 입력
        'amount': 1000000 // 요청할 금액 (사토시 단위, 최대 1,000,000)
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to request testnet coins: ${response.statusCode}, ${response.body}');
    }
    return;
  }
}
