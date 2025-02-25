class TokenAbi {
  // ERC-20 표준 인터페이스의 ABI (Application Binary Interface)
  // balanceOf 함수만 포함된 최소 버전
  static const String ERC20 = '''[
    {
      "constant": true,
      "inputs": [{"name": "_owner", "type": "address"}],
      "name": "balanceOf",
      "outputs": [{"name": "balance", "type": "uint256"}],
      "type": "function"
    }
  ]''';

  static const String ERC721 = '''[
    // NFT 표준 인터페이스
  ]''';
}
