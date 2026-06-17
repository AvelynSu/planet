// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get planets_list_my_planets => 'マイプラネット';

  @override
  String get planets_list_hide_confirmation => 'このプラネットを非表示にしますか？';

  @override
  String get planets_list_current => '現在';

  @override
  String get network_select_title => 'ネットワーク選択';

  @override
  String get network_ethereum => 'イーサリアム';

  @override
  String get network_bitcoin => 'ビットコイン';

  @override
  String get network_select_button => '選択';

  @override
  String get planets_max_limit => '最大20個のプラネットを追加できます。';

  @override
  String get planets_add_new => '新しいプラネットを追加';

  @override
  String get home_show_address => 'アドレス';

  @override
  String get planet_setting_title => 'セキュリティ';

  @override
  String get settings_localization => '言語';

  @override
  String get settings_currency => '通貨';

  @override
  String get settings_theme => 'テーマ設定';

  @override
  String get settings_version => 'バージョン';

  @override
  String get settings_sign_out => 'ログアウト';

  @override
  String get planet_backup_mnemonic => 'ニーモニックフレーズのバックアップ';

  @override
  String get planet_backup_private_key => '秘密鍵のバックアップ';

  @override
  String get planet_address => 'ウォレットアドレス';

  @override
  String get change_planet_name_title => 'プラネット名の変更';

  @override
  String get mnemonic_phrase_title => 'ニーモニックフレーズ';

  @override
  String get mnemonic_save_safely => 'ニーモニックフレーズを安全に保存してください。';

  @override
  String get copy_mnemonic => 'ニーモニックをコピー';

  @override
  String get success_copy => 'コピー完了';

  @override
  String success_copy_mnemonic(Object mnemonic) {
    return '*コピー成功*\n$mnemonic';
  }

  @override
  String success_copy_private_key(Object privateKey) {
    return '*コピー成功*\n$privateKey';
  }

  @override
  String get copy_private_key => '秘密鍵をコピー';

  @override
  String get private_key_title => '秘密鍵';

  @override
  String get you_are_on => 'マイプラネット';

  @override
  String get change_pincode => 'PINコードの変更';

  @override
  String get modify_currency_daily_limit => '1日に最大3回変更できます。';

  @override
  String get mnemonic_logout_warning =>
      'ニーモニックワードを覚えていないと、再度ログインできなくなります。適切に保存し、必ず覚えておいてください。';

  @override
  String get mnemonic_logout_confirmation => 'ログアウトプロセスを理解し、ニーモニックを保存しました。';

  @override
  String get wallet_create_next => '次へ';

  @override
  String get wallet_create_store_mnemonic => 'これら12個の単語を順番通りに安全に保存してください。';

  @override
  String get wallet_create_remember_note =>
      '次のステップでは、これらの単語のいくつかを選択して確認します。しっかり覚えておいてください！';

  @override
  String get wallet_create_copy_words => '単語をコピー';

  @override
  String get wallet_create_warning =>
      'これらのニーモニック単語はウォレットを復元するために使用されます。絶対に他の人と共有しないでください。';

  @override
  String wallet_create_select_word(Object index) {
    return 'ニーモニックフレーズの\n$index番目の単語を選択してください。';
  }

  @override
  String get wallet_create_incorrect => '単語が間違っています。もう一度お試しください。';

  @override
  String get wallet_import_title => 'リカバリーフレーズの入力';

  @override
  String get wallet_import_recovery_phrase => 'リカバリーフレーズ';

  @override
  String get wallet_import_paste => '貼り付け';

  @override
  String wallet_import_word_count(Object count) {
    return '入力された単語数: $count';
  }

  @override
  String get wallet_import_invalid_phrase =>
      'リカバリーフレーズは12個または24個の単語で構成する必要があります。';

  @override
  String get wallet_import_restore => 'ウォレットの復元';

  @override
  String get wallet_import_placeholder => '単語1 単語2 単語3 単語4 単語5 単語6 ...';

  @override
  String get recovery_phrase_requirement =>
      'リカバリーフレーズは12個または24個の単語で構成する必要があります。';

  @override
  String get explore_friends_planets => '友達の\n*プラネットを探索しよう！*';

  @override
  String get start_create_planet => 'プラネットを作成';

  @override
  String get start_import_planet => '他のプラネットをインポート';

  @override
  String get start_tagline => 'Make Your\nOwn Planet';

  @override
  String get transaction_transfer => '送金';

  @override
  String get transaction_empty_list => 'リストが空です';

  @override
  String get search_address_hint => 'アドレスまたはプラネット名を入力';

  @override
  String get transfer_invalid_address => '有効なウォレットアドレスを入力してください。';

  @override
  String get transfer_planets_list => 'プラネット';

  @override
  String get transfer_address => 'アドレス';

  @override
  String get gas_settings_advanced => '高度なガス設定';

  @override
  String get gas_settings_presets => 'ガス価格プリセット';

  @override
  String get gas_settings_custom => 'カスタムガス設定';

  @override
  String get gas_settings_gas_price => 'ガス価格';

  @override
  String gas_settings_gas_limit_value(Object wei) {
    return 'ガス価格 : $wei';
  }

  @override
  String gas_settings_gas_price_title(Object wei) {
    return 'ガス価格 : $wei';
  }

  @override
  String get gas_settings_gas_limit => 'ガスリミット';

  @override
  String get gas_settings_estimated_fee => '推定ネットワーク手数料';

  @override
  String get gas_settings_apply => '適用';

  @override
  String get gas_settings_invalid => '無効なガス設定';

  @override
  String get gas_settings_invalid_values => '有効なガス価格とガスリミット値を入力してください。';

  @override
  String get gas_priority_slow => '遅い';

  @override
  String get gas_priority_average => '普通';

  @override
  String get gas_priority_fast => '速い';

  @override
  String gas_priority_estimated_time(Object time) {
    return '推定確認時間: $time';
  }

  @override
  String get transfer_label_to => '受取人';

  @override
  String get transfer_label_from => '送信元';

  @override
  String get transfer_label_fee => '手数料';

  @override
  String get transfer_processing => '取引処理中';

  @override
  String get transfer_processing_wait => '取引が処理されるまでお待ちください。数分かかることがあります。';

  @override
  String get transfer_not_enough => '送金するための金額が不足しています';

  @override
  String get transfer_invalid_amount => '有効な金額を入力してください';

  @override
  String get using_custom_gas_settings => 'カスタムガス設定を使用';

  @override
  String get transfer_confirm => '送金確認';

  @override
  String transfer_confirm_message(
      Object planetName, Object recipient, Object symbol) {
    return '$recipientに\n$planetName\n$symbolを送信しますか？';
  }

  @override
  String get transfer_successful => '取引成功';

  @override
  String get transfer_amount => '金額';

  @override
  String get transfer_date => '日付';

  @override
  String get transfer_complete => '完了';

  @override
  String get transfer_send => '送信';

  @override
  String transfer_token_send(Object token) {
    return '$tokenを送信';
  }

  @override
  String get transfer_submit => '送信';

  @override
  String get error_title => 'エラー';

  @override
  String error_message(Object error) {
    return 'エラーが発生しました: $error';
  }

  @override
  String get pin_new => '新しいPINコードを入力してください';

  @override
  String get pin_reenter => 'PINコードを再入力してください';

  @override
  String get pin_enter => 'PINコードを入力してください';

  @override
  String get pin_passcode => 'PINコードを入力してください';

  @override
  String get pin_not_match => 'PINコードが一致しません。もう一度お試しください。';

  @override
  String get pin_incorrect => 'PINコードが正しくありません。もう一度お試しください。';

  @override
  String get update_title => 'バージョンアップデート';

  @override
  String get update_message => '新しいPlanet Walletバージョンの\nアップデートが利用可能です。';

  @override
  String get update_button => 'アップデート';

  @override
  String get gas_priority_slow_time => '5分';

  @override
  String get gas_priority_medium_time => '2分';

  @override
  String get gas_priority_fast_time => '30秒';

  @override
  String get menu_type_home => 'ホーム';

  @override
  String get menu_type_planets => 'プラネット';

  @override
  String get menu_type_my => 'マイページ';

  @override
  String get planet_name_duplicate => 'このプラネット名は既に使用されています。';

  @override
  String get planet_name_change_info => 'プラネット名を変更できます';

  @override
  String get planet_name_enter => 'プラネット名を入力';

  @override
  String get planet_name_display => '私のプラネットは';

  @override
  String get cancel => 'キャンセル';

  @override
  String get confirm => '確認';

  @override
  String get transaction_attemptsExceeded_msg => 'しばらくしてからもう一度ご確認ください。';

  @override
  String get sol_history_not_supported => 'SOL履歴は現在サポートされていません。\n(サポート準備中)';

  @override
  String get planet_address_copy_button => 'コピー';

  @override
  String get planet_address_send_button => '送信';

  @override
  String planet_address_network_mismatch(
      Object currentNetwork, Object targetNetwork) {
    return '現在$currentNetwork惑星にいます。*$targetNetwork惑星に切り替えて*からもう一度お試しください。';
  }

  @override
  String get ethereum => 'イーサリアム';

  @override
  String get bitcoin => 'ビットコイン';

  @override
  String get solana => 'ソラナ';

  @override
  String get bnb_smart_chain => 'BNBスマートチェーン';

  @override
  String get input_format_hint => '数字、英語、_の組み合わせで3〜15文字で入力してください。';

  @override
  String invalid_address_format(Object networkType) {
    return '$networkTypeのアドレス形式ではありません。';
  }

  @override
  String get deleteAccount => 'アカウント削除';

  @override
  String get deleteAccountWarning => 'アカウントを削除する前に、以下の情報を確認してください。';

  @override
  String get mnemonicBackupTitle => 'ニーモニックフレーズのバックアップ';

  @override
  String get mnemonicBackupDescription =>
      'アカウント削除後もブロックチェーン資産にアクセスするには、このニーモニックフレーズが必要です。必ずバックアップしてください。';

  @override
  String get copyMnemonic => 'コピー';

  @override
  String get deleteAccountCheck1 => 'このニーモニックで作成されたすべての惑星が削除されます。';

  @override
  String get deleteAccountCheck2 =>
      'ブロックチェーン上の資産は削除されず、ニーモニックフレーズを使って再度アクセスできます。';

  @override
  String get deleteAccountCheck3 => '他のユーザーがあなたの惑星名を所有できるようになります。';

  @override
  String get deleteAccountButton => 'アカウントを削除';

  @override
  String get deleteAccountConfirmTitle => 'アカウント削除の確認';

  @override
  String get deleteAccountConfirmDescription => '本当にアカウントを削除しますか？この操作は元に戻せません。';

  @override
  String get deleteButton => '削除';

  @override
  String get pending => '保留中';

  @override
  String get sent => '送信済み';

  @override
  String get received => '受信済み';
}
