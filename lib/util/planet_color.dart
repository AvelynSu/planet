import 'dart:ui';

import 'package:planet/enum/network_type.dart';

class PlanetColor {
  static List<Color> colors(NetworkType? network) {
    switch (network) {
      case NetworkType.ethereum:
        return baseColors;
      case NetworkType.bitcoin:
        return baseColors;
      case NetworkType.solana:
        return solanaColors;
      default:
        return baseColors;
    }
  }

  static const List<Color> baseColors = [
    Color(0xFFFFFD00),
    Color(0xFFFEB900),
    Color(0xFFEFA288),
    Color(0xFFEEA5B0),
    Color(0xFFFF99D6),
    Color(0xFFDD9278),
    Color(0xFFFC8F79),
    Color(0xFFE45641),
    Color(0xFFE62D38),
    Color(0xFFF94A62),
    Color(0xFFEB526F),
    Color(0xFFFF54B0),
    Color(0xFFFA198C),
    Color(0xFFC5147D),
    Color(0xFFE1A9E8),
    Color(0xFF9B5FE5),
    Color(0xFF7C00C7),
    Color(0xFF531CB3),
    Color(0xFFCCFF66),
    Color(0xFF00E291),
    Color(0xFF35D1BF),
    Color(0xFF028A81),
    Color(0xFF0A3748),
    Color(0xFF4F51B3),
    Color(0xFF1D00FF),
    Color(0xFF090080),
    Color(0xFF0A104D),
    Color(0xFF575756),
  ];
  static const List<Color> bitcoinColors = [
    Color(0xFFF7931A), // 비트코인 오렌지
    Color(0xFFFFD700), // 골드
    Color(0xFFFFE55C), // 밝은 골드
    Color(0xFFCC9900), // 어두운 골드
    Color(0xFFEFD8A4), // 밝은 황갈색
    Color(0xFFD1A75C), // 황동색
    Color(0xFF8B6914), // 어두운 황금색
    Color(0xFFB34700), // 구릿빛 오렌지
    Color(0xFFCD853F), // 페루
    Color(0xFFD2B48C), // 탄
    Color(0xFFBDB76B), // 다크카키
    Color(0xFFC19A6B), // 중간 황토색
    Color(0xFFF9BF3B), // 황색 오렌지
    Color(0xFFE6BE8A), // 샌드
    Color(0xFFE5AA70), // 살구색
    Color(0xFFFF7034), // 붉은 오렌지
    Color(0xFFFF5E4D), // 토마토 레드
    Color(0xFFFF8C69), // 연어색
    Color(0xFFFFB347), // 밝은 황갈색
    Color(0xFFE3B778), // 골든 하니
    Color(0xFFE69138), // 캐러멜
    Color(0xFFC35831), // 라이트 브릭
    Color(0xFFB22222), // 파이어 브릭
    Color(0xFFBF4F51), // 코랄 레드
    Color(0xFFFF7F50), // 코랄
    Color(0xFFB87333), // 구리색
    Color(0xFFFFB31A), // 호박색
    Color(0xFFB8860B), // 다크 골든로드
  ];
  static const List<Color> solanaColors = [
    Color(0xFF00FFBD), // 솔라나 그린
    Color(0xFF00C2FF), // 솔라나 블루
    Color(0xFF9945FF), // 솔라나 퍼플
    Color(0xFF14F195), // 밝은 민트
    Color(0xFF00E4C5), // 아쿠아마린
    Color(0xFF00D2FF), // 밝은 시안
    Color(0xFF19B6FF), // 스카이 블루
    Color(0xFF0072FF), // 브라이트 블루
    Color(0xFF7B61FF), // 연보라
    Color(0xFFAB71FF), // 라일락
    Color(0xFF7957FB), // 중간 퍼플
    Color(0xFF6647D7), // 라벤더
    Color(0xFF5636C5), // 인디고
    Color(0xFF4C26B6), // 바이올렛
    Color(0xFF3A1D8C), // 다크 퍼플
    Color(0xFF2C1675), // 진한 자주색
    Color(0xFF05C2BD), // 터키 청록색
    Color(0xFF08A5D1), // 페리윙클
    Color(0xFF0090EA), // 코발트 블루
    Color(0xFF2B77E5), // 로얄 블루
    Color(0xFF00BDAC), // 비취색
    Color(0xFF29B4A4), // 열대 청록색
    Color(0xFF287AB8), // 스틸 블루
    Color(0xFF21113A), // 딥 퍼플
    Color(0xFF1A0A46), // 어두운 자주색
    Color(0xFF142339), // 네이비 블루
    Color(0xFF001F3F), // 미드나이트
    Color(0xFF0F172A), // 진한 네이비
  ];
}
