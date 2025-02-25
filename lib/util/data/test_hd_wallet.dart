import 'package:planet/model/planet.dart';

class TestHdWallet {
  static String mnemonic = "";
  static int ethIdx = 0;
  static List<Planet> ethAddress = [];

  static int btcIdx = 0;
  static List<Planet> btcAddress = [];

  static int solIdx = 0;
  static List<Planet> solAddress = [];

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
