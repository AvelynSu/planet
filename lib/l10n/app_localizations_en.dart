// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get planets_list_my_planets => 'My Planets';

  @override
  String get planets_list_hide_confirmation =>
      'Would you like to hide the planet?';

  @override
  String get planets_list_current => 'Current';

  @override
  String get network_select_title => 'Select Network';

  @override
  String get network_ethereum => 'ETHEREUM';

  @override
  String get network_bitcoin => 'BITCOIN';

  @override
  String get network_select_button => 'Select';

  @override
  String get planets_max_limit => 'You can add up to 20 planets.';

  @override
  String get planets_add_new => 'Add New Planet';

  @override
  String get home_show_address => 'Address';

  @override
  String get planet_setting_title => 'Security';

  @override
  String get settings_localization => 'Language';

  @override
  String get settings_currency => 'Currency';

  @override
  String get settings_theme => 'Theme Setting';

  @override
  String get settings_version => 'Version';

  @override
  String get settings_sign_out => 'Sign Out';

  @override
  String get planet_backup_mnemonic => 'Backup Mnemonic Phrase';

  @override
  String get planet_backup_private_key => 'Backup Private Key';

  @override
  String get planet_address => 'Address';

  @override
  String get change_planet_name_title => 'Change Planet Name';

  @override
  String get mnemonic_phrase_title => 'Mnemonic Phrase';

  @override
  String get mnemonic_save_safely => 'Save the Mnemonic Phrase safely.';

  @override
  String get copy_mnemonic => 'Copy Mnemonic';

  @override
  String get success_copy => 'Success copy';

  @override
  String success_copy_mnemonic(Object mnemonic) {
    return '*Success copy*\n$mnemonic';
  }

  @override
  String success_copy_private_key(Object privateKey) {
    return '*Success copy*\n$privateKey';
  }

  @override
  String get copy_private_key => 'Copy Private Key';

  @override
  String get private_key_title => 'Private Key';

  @override
  String get you_are_on => 'You\'re on';

  @override
  String get change_pincode => 'Change Pin Code';

  @override
  String get modify_currency_daily_limit =>
      'You can modify up to 3 times per day';

  @override
  String get mnemonic_logout_warning =>
      'If you do not remember your mnemonic words, you will not be able to log in again. Save them appropriately and make sure to remember them.';

  @override
  String get mnemonic_logout_confirmation =>
      'I understand the logout process and have saved my mnemonics.';

  @override
  String get wallet_create_next => 'Next';

  @override
  String get wallet_create_store_mnemonic =>
      'Securely store these 12 words in order.';

  @override
  String get wallet_create_remember_note =>
      'In the next step, we will ask you to select some of these words for verification. Make sure to remember them well!';

  @override
  String get wallet_create_copy_words => 'Copy Words';

  @override
  String get wallet_create_warning =>
      'These mnemonic words are used to recover your wallet. Never share them with anyone else.';

  @override
  String wallet_create_select_word(Object index) {
    return 'Select the ${index}th word\nof your mnemonic phrase.';
  }

  @override
  String get wallet_create_incorrect => 'Incorrect word. Please try again.';

  @override
  String get wallet_import_title => 'Enter Recovery Phrase';

  @override
  String get wallet_import_recovery_phrase => 'Recovery Phrase';

  @override
  String get wallet_import_paste => 'Paste';

  @override
  String wallet_import_word_count(Object count) {
    return 'Number of words entered: $count';
  }

  @override
  String get wallet_import_invalid_phrase =>
      'The recovery phrase must consist of 12 or 24 words.';

  @override
  String get wallet_import_restore => 'Restore Wallet';

  @override
  String get wallet_import_placeholder =>
      'word1 word2 word3 word4 word5 word6 ...';

  @override
  String get recovery_phrase_requirement =>
      'The recovery phrase must consist of 12 or 24 words.';

  @override
  String get explore_friends_planets => 'Explore your\n*Friends\' planets!*';

  @override
  String get start_create_planet => 'Create Planet';

  @override
  String get start_import_planet => 'Import Another Planet';

  @override
  String get start_tagline => 'Make Your\nOwn Planet';

  @override
  String get transaction_transfer => 'Transfer';

  @override
  String get transaction_empty_list => 'Empty List';

  @override
  String get search_address_hint => 'Enter Address or Planet name';

  @override
  String get transfer_invalid_address => 'Please enter a valid wallet address.';

  @override
  String get transfer_planets_list => 'Planets';

  @override
  String get transfer_address => 'Address';

  @override
  String get gas_settings_advanced => 'Advanced Gas Settings';

  @override
  String get gas_settings_presets => 'Gas Price Presets';

  @override
  String get gas_settings_custom => 'Custom Gas Settings';

  @override
  String get gas_settings_gas_price => 'Gas Price';

  @override
  String gas_settings_gas_limit_value(Object wei) {
    return 'Gas Price : $wei';
  }

  @override
  String gas_settings_gas_price_title(Object wei) {
    return 'Gas Price : $wei';
  }

  @override
  String get gas_settings_gas_limit => 'Gas Limit';

  @override
  String get gas_settings_estimated_fee => 'Estimated Network Fee';

  @override
  String get gas_settings_apply => 'Apply';

  @override
  String get gas_settings_invalid => 'Invalid Gas Settings';

  @override
  String get gas_settings_invalid_values =>
      'Please enter valid gas price and gas limit values.';

  @override
  String get gas_priority_slow => 'Slow';

  @override
  String get gas_priority_average => 'Average';

  @override
  String get gas_priority_fast => 'Fast';

  @override
  String gas_priority_estimated_time(Object time) {
    return 'Estimated confirmation time: $time';
  }

  @override
  String get transfer_label_to => 'To';

  @override
  String get transfer_label_from => 'From';

  @override
  String get transfer_label_fee => 'Fee';

  @override
  String get transfer_processing => 'Processing Transaction';

  @override
  String get transfer_processing_wait =>
      'Please wait while your transaction is being processed. This may take a few minutes.';

  @override
  String get transfer_not_enough => 'You don\'t have enough amount to send';

  @override
  String get transfer_invalid_amount => 'Please enter a valid amount';

  @override
  String get using_custom_gas_settings => 'Using Custom Gas Settings';

  @override
  String get transfer_confirm => 'Confirm Transfer';

  @override
  String transfer_confirm_message(
      Object planetName, Object recipient, Object symbol) {
    return 'Are you sure you want to send $planetName\n$symbol to\n$recipient?';
  }

  @override
  String get transfer_successful => 'Transaction Successful';

  @override
  String get transfer_amount => 'Amount';

  @override
  String get transfer_date => 'Date';

  @override
  String get transfer_complete => 'Complete';

  @override
  String get transfer_send => 'Send';

  @override
  String transfer_token_send(Object token) {
    return 'Send $token';
  }

  @override
  String get transfer_submit => 'Submit';

  @override
  String get error_title => 'Error';

  @override
  String error_message(Object error) {
    return 'An error occurred: $error';
  }

  @override
  String get pin_new => 'Enter your new PIN code';

  @override
  String get pin_reenter => 'Re-enter your PIN code';

  @override
  String get pin_enter => 'Enter your PIN code';

  @override
  String get pin_passcode => 'Enter your PIN code';

  @override
  String get pin_not_match => 'PIN codes don\'t match. Try again.';

  @override
  String get pin_incorrect => 'Incorrect PIN code. Try again.';

  @override
  String get update_title => 'Version Update';

  @override
  String get update_message =>
      'A new Planet Wallet version\nupdate is now available.';

  @override
  String get update_button => 'Update';

  @override
  String get gas_priority_slow_time => '5 min';

  @override
  String get gas_priority_medium_time => '2 min';

  @override
  String get gas_priority_fast_time => '30 sec';

  @override
  String get menu_type_home => 'Home';

  @override
  String get menu_type_planets => 'Planets';

  @override
  String get menu_type_my => 'My';

  @override
  String get planet_name_duplicate => 'This planet name is already in use.';

  @override
  String get planet_name_change_info => 'You can change your planet name';

  @override
  String get planet_name_enter => 'Enter Planet Name';

  @override
  String get planet_name_display => 'My Planet is';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get transaction_attemptsExceeded_msg =>
      'Please check again after a moment.';

  @override
  String get sol_history_not_supported =>
      'SOL history is not supported.\n(Support in preparation)';

  @override
  String get planet_address_copy_button => 'Copy';

  @override
  String get planet_address_send_button => 'Send';

  @override
  String planet_address_network_mismatch(
      Object currentNetwork, Object targetNetwork) {
    return 'You are currently on the $currentNetwork planet. *Please switch to the $targetNetwork planet* and try again.';
  }

  @override
  String get ethereum => 'Ethereum';

  @override
  String get bitcoin => 'Bitcoin';

  @override
  String get solana => 'Solana';

  @override
  String get bnb_smart_chain => 'BNB Smart Chain';

  @override
  String get input_format_hint =>
      'Please enter 3-15 characters using numbers, English letters, and _ only.';

  @override
  String invalid_address_format(Object networkType) {
    return 'This is not a valid $networkType address format.';
  }

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountWarning =>
      'Please review the information below before deleting your account.';

  @override
  String get mnemonicBackupTitle => 'Backup Mnemonic Phrase';

  @override
  String get mnemonicBackupDescription =>
      'You will need this mnemonic phrase to access your blockchain assets after account deletion. Make sure to back it up.';

  @override
  String get copyMnemonic => 'Copy';

  @override
  String get deleteAccountCheck1 =>
      'All planets created with this mnemonic will be deleted.';

  @override
  String get deleteAccountCheck2 =>
      'Your assets on the blockchain will not be deleted, and you can access them again using your mnemonic phrase.';

  @override
  String get deleteAccountCheck3 =>
      'Other users may be able to claim your planet names.';

  @override
  String get deleteAccountButton => 'Delete Account';

  @override
  String get deleteAccountConfirmTitle => 'Confirm Account Deletion';

  @override
  String get deleteAccountConfirmDescription =>
      'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get deleteButton => 'Delete';

  @override
  String get pending => 'Pending';

  @override
  String get sent => 'Sent';

  @override
  String get received => 'Received';
}
