// // 1. 니모닉 생성 또는 입력 받음
// String originalMnemonic = "apple banana cat ...";
//
// // 2. 암호화
// String encryptionKey = await getEncryptionKey(); // 안전한 키 생성/조회
// String encryptedMnemonic = encryptMnemonic(originalMnemonic, encryptionKey);
//
// // 3. 안전하게 저장
// final storage = FlutterSecureStorage();
// await storage.write(key: 'mnemonic', value: encryptedMnemonic);
//
//
// Future<String> showStoredMnemonic() async {
// // 1. 저장된 암호화된 니모닉 읽기
// final storage = FlutterSecureStorage();
// String? encryptedMnemonic = await storage.read(key: 'mnemonic');
//
// // 2. 복호화
// String encryptionKey = await getEncryptionKey();
// String decryptedMnemonic = decryptMnemonic(encryptedMnemonic!, encryptionKey);
//
// return decryptedMnemonic; // UI에 표시
// }
