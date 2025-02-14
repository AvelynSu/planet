import 'package:planet/model/planet_dto.dart';

class TestHdWallet {
  static String mnemonic = "";
  static int ethIdx = 0;
  static List<PlanetDto> ethAddress = [];

  static int btcIdx = 0;
  static List<PlanetDto> btcAddress = [];

  static int solIdx = 0;
  static List<PlanetDto> solAddress = [];

  static initialize() {
    mnemonic = "";
    ethIdx = 0;
    ethAddress = [];

    btcIdx = 0;
    btcAddress = [];

    solIdx = 0;
    solAddress = [];
  }
}
