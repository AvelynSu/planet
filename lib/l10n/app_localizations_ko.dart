// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get planets_list_my_planets => '내 행성';

  @override
  String get planets_list_hide_confirmation => '행성을 숨기시겠습니까?';

  @override
  String get planets_list_current => '현재';

  @override
  String get network_select_title => '네트워크 선택';

  @override
  String get network_ethereum => '이더리움';

  @override
  String get network_bitcoin => '비트코인';

  @override
  String get network_select_button => '선택하기';

  @override
  String get planets_max_limit => '최대 20개의 행성을 추가할 수 있습니다.';

  @override
  String get planets_add_new => '새 행성 추가';

  @override
  String get home_show_address => '주소';

  @override
  String get planet_setting_title => '보안';

  @override
  String get settings_localization => '언어';

  @override
  String get settings_currency => '화폐';

  @override
  String get settings_theme => '테마 설정';

  @override
  String get settings_version => '버전';

  @override
  String get settings_sign_out => '로그아웃';

  @override
  String get planet_backup_mnemonic => '니모닉 단어 백업';

  @override
  String get planet_backup_private_key => '개인키 백업';

  @override
  String get planet_address => '지갑 주소';

  @override
  String get change_planet_name_title => '행성 이름 변경';

  @override
  String get mnemonic_phrase_title => '니모닉 단어';

  @override
  String get mnemonic_save_safely => '니모닉 단어를 안전하게 저장하세요.';

  @override
  String get copy_mnemonic => '니모닉 복사';

  @override
  String get success_copy => '복사 완료';

  @override
  String success_copy_mnemonic(Object mnemonic) {
    return '*복사 성공*\n$mnemonic';
  }

  @override
  String success_copy_private_key(Object privateKey) {
    return '*복사 성공*\n$privateKey';
  }

  @override
  String get copy_private_key => '개인키 복사';

  @override
  String get private_key_title => '개인키';

  @override
  String get you_are_on => '나의 행성';

  @override
  String get change_pincode => 'PIN 코드 변경';

  @override
  String get modify_currency_daily_limit => '하루 최대 3회 수정할 수 있습니다.';

  @override
  String get mnemonic_logout_warning =>
      '니모닉 단어를 기억하지 못하면 다시 로그인할 수 없습니다. 적절히 저장하고 반드시 기억해 두세요.';

  @override
  String get mnemonic_logout_confirmation => '로그아웃 과정을 이해했으며 니모닉을 저장했습니다.';

  @override
  String get wallet_create_next => '다음';

  @override
  String get wallet_create_store_mnemonic => '12개의 단어를 순서대로 안전하게 저장하세요.';

  @override
  String get wallet_create_remember_note =>
      '다음 단계에서 이 단어들 중 일부를 선택하여 확인할 것입니다. 잘 기억해 두세요!';

  @override
  String get wallet_create_copy_words => '단어 복사';

  @override
  String get wallet_create_warning =>
      '단어들은 지갑을 복구하는 데 사용됩니다. 절대 다른 사람과 공유하지 마세요.';

  @override
  String wallet_create_select_word(Object index) {
    return '니모닉 단어의\n$index번째 단어를 선택하세요.';
  }

  @override
  String get wallet_create_incorrect => '잘못된 단어입니다. 다시 시도해 주세요.';

  @override
  String get wallet_import_title => '복구 단어 입력';

  @override
  String get wallet_import_recovery_phrase => '복구 단어';

  @override
  String get wallet_import_paste => '붙여넣기';

  @override
  String wallet_import_word_count(Object count) {
    return '입력된 단어 수: $count';
  }

  @override
  String get wallet_import_invalid_phrase =>
      '복구 단어는 12개 또는 24개의 단어로 구성되어야 합니다.';

  @override
  String get wallet_import_restore => '지갑 복구';

  @override
  String get wallet_import_placeholder => '단어1 단어2 단어3 단어4 단어5 단어6 ...';

  @override
  String get recovery_phrase_requirement => '복구 단어는 12개 또는 24개의 단어로 구성되어야 합니다.';

  @override
  String get explore_friends_planets => '친구들의\n*행성을 탐험하세요!*';

  @override
  String get start_create_planet => '행성 만들기';

  @override
  String get start_import_planet => '기존 행성 가져오기';

  @override
  String get start_tagline => 'Make Your\nOwn Planet';

  @override
  String get transaction_transfer => '전송';

  @override
  String get transaction_empty_list => '목록이 비어있습니다';

  @override
  String get search_address_hint => '주소 또는 행성 이름 입력';

  @override
  String get transfer_invalid_address => '유효한 지갑 주소를 입력해 주세요.';

  @override
  String get transfer_planets_list => '행성';

  @override
  String get transfer_address => '주소';

  @override
  String get gas_settings_advanced => '고급 가스 설정';

  @override
  String get gas_settings_presets => '가스 가격 프리셋';

  @override
  String get gas_settings_custom => '사용자 지정 가스 설정';

  @override
  String get gas_settings_gas_price => '가스 가격';

  @override
  String gas_settings_gas_limit_value(Object wei) {
    return '가스 가격 : $wei';
  }

  @override
  String gas_settings_gas_price_title(Object wei) {
    return '가스 가격 : $wei';
  }

  @override
  String get gas_settings_gas_limit => '가스 한도';

  @override
  String get gas_settings_estimated_fee => '예상 네트워크 수수료';

  @override
  String get gas_settings_apply => '적용';

  @override
  String get gas_settings_invalid => '잘못된 가스 설정';

  @override
  String get gas_settings_invalid_values => '유효한 가스 가격과 가스 한도 값을 입력해 주세요.';

  @override
  String get gas_priority_slow => '느림';

  @override
  String get gas_priority_average => '보통';

  @override
  String get gas_priority_fast => '빠름';

  @override
  String gas_priority_estimated_time(Object time) {
    return '예상 확인 시간: $time';
  }

  @override
  String get transfer_label_to => '받는 사람';

  @override
  String get transfer_label_from => '보내는 사람';

  @override
  String get transfer_label_fee => '수수료';

  @override
  String get transfer_processing => '거래 처리 중';

  @override
  String get transfer_processing_wait =>
      '거래가 처리되는 동안 기다려 주세요. 몇 분 정도 소요될 수 있습니다.';

  @override
  String get transfer_not_enough => '전송할 수 있는 금액이 부족합니다';

  @override
  String get transfer_invalid_amount => '유효한 금액을 입력해 주세요';

  @override
  String get using_custom_gas_settings => '사용자 지정 가스 설정 사용';

  @override
  String get transfer_confirm => '전송 확인';

  @override
  String transfer_confirm_message(
      Object planetName, Object recipient, Object symbol) {
    return '$recipient에게\n$planetName\n$symbol을(를) 보내시겠습니까?';
  }

  @override
  String get transfer_successful => '거래 성공';

  @override
  String get transfer_amount => '금액';

  @override
  String get transfer_date => '날짜';

  @override
  String get transfer_complete => '완료';

  @override
  String get transfer_send => '보내기';

  @override
  String transfer_token_send(Object token) {
    return '$token 보내기';
  }

  @override
  String get transfer_submit => '제출';

  @override
  String get error_title => '오류';

  @override
  String error_message(Object error) {
    return '오류가 발생했습니다: $error';
  }

  @override
  String get pin_new => '새 PIN 코드를 입력하세요';

  @override
  String get pin_reenter => 'PIN 코드를 다시 입력하세요';

  @override
  String get pin_enter => 'PIN 코드를 입력하세요';

  @override
  String get pin_passcode => 'PIN 코드를 입력하세요';

  @override
  String get pin_not_match => 'PIN 코드가 일치하지 않습니다. 다시 시도해 주세요.';

  @override
  String get pin_incorrect => '잘못된 PIN 코드입니다. 다시 시도해 주세요.';

  @override
  String get update_title => '버전 업데이트';

  @override
  String get update_message => '새로운 Planet Wallet 버전\n업데이트가 있습니다.';

  @override
  String get update_button => '업데이트';

  @override
  String get gas_priority_slow_time => '5분';

  @override
  String get gas_priority_medium_time => '2분';

  @override
  String get gas_priority_fast_time => '30초';

  @override
  String get menu_type_home => '홈';

  @override
  String get menu_type_planets => '행성';

  @override
  String get menu_type_my => '내 정보';

  @override
  String get planet_name_duplicate => '이미 사용중인 행성 이름입니다.';

  @override
  String get planet_name_change_info => '행성 이름을 변경할 수 있습니다';

  @override
  String get planet_name_enter => '행성 이름 입력';

  @override
  String get planet_name_display => '나의 행성은';

  @override
  String get cancel => '취소';

  @override
  String get confirm => '확인';

  @override
  String get transaction_attemptsExceeded_msg => '잠시 후 다시 확인해주세요.';

  @override
  String get sol_history_not_supported => 'SOL 거래 내역은 지원하지 않습니다.\n(지원 준비중)';

  @override
  String get planet_address_copy_button => '복사하기';

  @override
  String get planet_address_send_button => '보내기';

  @override
  String planet_address_network_mismatch(
      Object currentNetwork, Object targetNetwork) {
    return '현재 $currentNetwork 행성에 있습니다. *$targetNetwork 행성으로 전환*한 후 다시 시도해 주세요.';
  }

  @override
  String get ethereum => '이더리움';

  @override
  String get bitcoin => '비트코인';

  @override
  String get solana => '솔라나';

  @override
  String get bnb_smart_chain => 'BNB 스마트 체인';

  @override
  String get input_format_hint => '숫자,영어,_ 조합의 3~15자로 입력해주세요.';

  @override
  String invalid_address_format(Object networkType) {
    return '$networkType의 주소 형식이 아닙니다.';
  }

  @override
  String get deleteAccount => '계정 삭제';

  @override
  String get deleteAccountWarning => '계정을 삭제하기 전에 아래 정보를 확인하세요.';

  @override
  String get mnemonicBackupTitle => '니모닉 구문 백업';

  @override
  String get mnemonicBackupDescription =>
      '계정 삭제 후에도 블록체인 자산에 접근하려면 니모닉 구문이 필요합니다. 반드시 백업하세요.';

  @override
  String get copyMnemonic => '복사하기';

  @override
  String get deleteAccountCheck1 => '이 니모닉으로 생성한 모든 행성이 삭제됩니다.';

  @override
  String get deleteAccountCheck2 =>
      '블록체인에 있는 자산은 삭제되지 않으며, 자산에는 니모닉을 통해 다시 접근할 수 있습니다.';

  @override
  String get deleteAccountCheck3 => '다른 사용자가 당신의 행성 이름을 소유할 수 있게 됩니다.';

  @override
  String get deleteAccountButton => '계정 삭제';

  @override
  String get deleteAccountConfirmTitle => '계정 삭제 확인';

  @override
  String get deleteAccountConfirmDescription =>
      '정말 계정을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';

  @override
  String get deleteButton => '삭제';

  @override
  String get pending => '대기중';

  @override
  String get sent => '보냄';

  @override
  String get received => '받음';
}
