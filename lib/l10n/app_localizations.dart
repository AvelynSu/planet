import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh')
  ];

  /// No description provided for @planets_list_my_planets.
  ///
  /// In en, this message translates to:
  /// **'My Planets'**
  String get planets_list_my_planets;

  /// No description provided for @planets_list_hide_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Would you like to hide the planet?'**
  String get planets_list_hide_confirmation;

  /// No description provided for @planets_list_current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get planets_list_current;

  /// No description provided for @network_select_title.
  ///
  /// In en, this message translates to:
  /// **'Select Network'**
  String get network_select_title;

  /// No description provided for @network_ethereum.
  ///
  /// In en, this message translates to:
  /// **'ETHEREUM'**
  String get network_ethereum;

  /// No description provided for @network_bitcoin.
  ///
  /// In en, this message translates to:
  /// **'BITCOIN'**
  String get network_bitcoin;

  /// No description provided for @network_select_button.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get network_select_button;

  /// No description provided for @planets_max_limit.
  ///
  /// In en, this message translates to:
  /// **'You can add up to 20 planets.'**
  String get planets_max_limit;

  /// No description provided for @planets_add_new.
  ///
  /// In en, this message translates to:
  /// **'Add New Planet'**
  String get planets_add_new;

  /// No description provided for @home_show_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get home_show_address;

  /// No description provided for @planet_setting_title.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get planet_setting_title;

  /// No description provided for @settings_localization.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_localization;

  /// No description provided for @settings_currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settings_currency;

  /// No description provided for @settings_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme Setting'**
  String get settings_theme;

  /// No description provided for @settings_version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settings_version;

  /// No description provided for @settings_sign_out.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settings_sign_out;

  /// No description provided for @planet_backup_mnemonic.
  ///
  /// In en, this message translates to:
  /// **'Backup Mnemonic Phrase'**
  String get planet_backup_mnemonic;

  /// No description provided for @planet_backup_private_key.
  ///
  /// In en, this message translates to:
  /// **'Backup Private Key'**
  String get planet_backup_private_key;

  /// No description provided for @planet_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get planet_address;

  /// No description provided for @change_planet_name_title.
  ///
  /// In en, this message translates to:
  /// **'Change Planet Name'**
  String get change_planet_name_title;

  /// No description provided for @mnemonic_phrase_title.
  ///
  /// In en, this message translates to:
  /// **'Mnemonic Phrase'**
  String get mnemonic_phrase_title;

  /// No description provided for @mnemonic_save_safely.
  ///
  /// In en, this message translates to:
  /// **'Save the Mnemonic Phrase safely.'**
  String get mnemonic_save_safely;

  /// No description provided for @copy_mnemonic.
  ///
  /// In en, this message translates to:
  /// **'Copy Mnemonic'**
  String get copy_mnemonic;

  /// No description provided for @success_copy.
  ///
  /// In en, this message translates to:
  /// **'Success copy'**
  String get success_copy;

  /// No description provided for @success_copy_mnemonic.
  ///
  /// In en, this message translates to:
  /// **'*Success copy*\n{mnemonic}'**
  String success_copy_mnemonic(Object mnemonic);

  /// No description provided for @success_copy_private_key.
  ///
  /// In en, this message translates to:
  /// **'*Success copy*\n{privateKey}'**
  String success_copy_private_key(Object privateKey);

  /// No description provided for @copy_private_key.
  ///
  /// In en, this message translates to:
  /// **'Copy Private Key'**
  String get copy_private_key;

  /// No description provided for @private_key_title.
  ///
  /// In en, this message translates to:
  /// **'Private Key'**
  String get private_key_title;

  /// No description provided for @you_are_on.
  ///
  /// In en, this message translates to:
  /// **'You\'re on'**
  String get you_are_on;

  /// No description provided for @change_pincode.
  ///
  /// In en, this message translates to:
  /// **'Change Pin Code'**
  String get change_pincode;

  /// No description provided for @modify_currency_daily_limit.
  ///
  /// In en, this message translates to:
  /// **'You can modify up to 3 times per day'**
  String get modify_currency_daily_limit;

  /// No description provided for @mnemonic_logout_warning.
  ///
  /// In en, this message translates to:
  /// **'If you do not remember your mnemonic words, you will not be able to log in again. Save them appropriately and make sure to remember them.'**
  String get mnemonic_logout_warning;

  /// No description provided for @mnemonic_logout_confirmation.
  ///
  /// In en, this message translates to:
  /// **'I understand the logout process and have saved my mnemonics.'**
  String get mnemonic_logout_confirmation;

  /// No description provided for @wallet_create_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get wallet_create_next;

  /// No description provided for @wallet_create_store_mnemonic.
  ///
  /// In en, this message translates to:
  /// **'Securely store these 12 words in order.'**
  String get wallet_create_store_mnemonic;

  /// No description provided for @wallet_create_remember_note.
  ///
  /// In en, this message translates to:
  /// **'In the next step, we will ask you to select some of these words for verification. Make sure to remember them well!'**
  String get wallet_create_remember_note;

  /// No description provided for @wallet_create_copy_words.
  ///
  /// In en, this message translates to:
  /// **'Copy Words'**
  String get wallet_create_copy_words;

  /// No description provided for @wallet_create_warning.
  ///
  /// In en, this message translates to:
  /// **'These mnemonic words are used to recover your wallet. Never share them with anyone else.'**
  String get wallet_create_warning;

  /// No description provided for @wallet_create_select_word.
  ///
  /// In en, this message translates to:
  /// **'Select the {index}th word\nof your mnemonic phrase.'**
  String wallet_create_select_word(Object index);

  /// No description provided for @wallet_create_incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect word. Please try again.'**
  String get wallet_create_incorrect;

  /// No description provided for @wallet_import_title.
  ///
  /// In en, this message translates to:
  /// **'Enter Recovery Phrase'**
  String get wallet_import_title;

  /// No description provided for @wallet_import_recovery_phrase.
  ///
  /// In en, this message translates to:
  /// **'Recovery Phrase'**
  String get wallet_import_recovery_phrase;

  /// No description provided for @wallet_import_paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get wallet_import_paste;

  /// No description provided for @wallet_import_word_count.
  ///
  /// In en, this message translates to:
  /// **'Number of words entered: {count}'**
  String wallet_import_word_count(Object count);

  /// No description provided for @wallet_import_invalid_phrase.
  ///
  /// In en, this message translates to:
  /// **'The recovery phrase must consist of 12 or 24 words.'**
  String get wallet_import_invalid_phrase;

  /// No description provided for @wallet_import_restore.
  ///
  /// In en, this message translates to:
  /// **'Restore Wallet'**
  String get wallet_import_restore;

  /// No description provided for @wallet_import_placeholder.
  ///
  /// In en, this message translates to:
  /// **'word1 word2 word3 word4 word5 word6 ...'**
  String get wallet_import_placeholder;

  /// No description provided for @recovery_phrase_requirement.
  ///
  /// In en, this message translates to:
  /// **'The recovery phrase must consist of 12 or 24 words.'**
  String get recovery_phrase_requirement;

  /// No description provided for @explore_friends_planets.
  ///
  /// In en, this message translates to:
  /// **'Explore your\n*Friends\' planets!*'**
  String get explore_friends_planets;

  /// No description provided for @start_create_planet.
  ///
  /// In en, this message translates to:
  /// **'Create Planet'**
  String get start_create_planet;

  /// No description provided for @start_import_planet.
  ///
  /// In en, this message translates to:
  /// **'Import Another Planet'**
  String get start_import_planet;

  /// No description provided for @start_tagline.
  ///
  /// In en, this message translates to:
  /// **'Make Your\nOwn Planet'**
  String get start_tagline;

  /// No description provided for @transaction_transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transaction_transfer;

  /// No description provided for @transaction_empty_list.
  ///
  /// In en, this message translates to:
  /// **'Empty List'**
  String get transaction_empty_list;

  /// No description provided for @search_address_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter Address or Planet name'**
  String get search_address_hint;

  /// No description provided for @transfer_invalid_address.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid wallet address.'**
  String get transfer_invalid_address;

  /// No description provided for @transfer_planets_list.
  ///
  /// In en, this message translates to:
  /// **'Planets'**
  String get transfer_planets_list;

  /// No description provided for @transfer_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get transfer_address;

  /// No description provided for @gas_settings_advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced Gas Settings'**
  String get gas_settings_advanced;

  /// No description provided for @gas_settings_presets.
  ///
  /// In en, this message translates to:
  /// **'Gas Price Presets'**
  String get gas_settings_presets;

  /// No description provided for @gas_settings_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom Gas Settings'**
  String get gas_settings_custom;

  /// No description provided for @gas_settings_gas_price.
  ///
  /// In en, this message translates to:
  /// **'Gas Price'**
  String get gas_settings_gas_price;

  /// No description provided for @gas_settings_gas_limit_value.
  ///
  /// In en, this message translates to:
  /// **'Gas Price : {wei}'**
  String gas_settings_gas_limit_value(Object wei);

  /// No description provided for @gas_settings_gas_price_title.
  ///
  /// In en, this message translates to:
  /// **'Gas Price : {wei}'**
  String gas_settings_gas_price_title(Object wei);

  /// No description provided for @gas_settings_gas_limit.
  ///
  /// In en, this message translates to:
  /// **'Gas Limit'**
  String get gas_settings_gas_limit;

  /// No description provided for @gas_settings_estimated_fee.
  ///
  /// In en, this message translates to:
  /// **'Estimated Network Fee'**
  String get gas_settings_estimated_fee;

  /// No description provided for @gas_settings_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get gas_settings_apply;

  /// No description provided for @gas_settings_invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid Gas Settings'**
  String get gas_settings_invalid;

  /// No description provided for @gas_settings_invalid_values.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid gas price and gas limit values.'**
  String get gas_settings_invalid_values;

  /// No description provided for @gas_priority_slow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get gas_priority_slow;

  /// No description provided for @gas_priority_average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get gas_priority_average;

  /// No description provided for @gas_priority_fast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get gas_priority_fast;

  /// No description provided for @gas_priority_estimated_time.
  ///
  /// In en, this message translates to:
  /// **'Estimated confirmation time: {time}'**
  String gas_priority_estimated_time(Object time);

  /// No description provided for @transfer_label_to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get transfer_label_to;

  /// No description provided for @transfer_label_from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get transfer_label_from;

  /// No description provided for @transfer_label_fee.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get transfer_label_fee;

  /// No description provided for @transfer_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing Transaction'**
  String get transfer_processing;

  /// No description provided for @transfer_processing_wait.
  ///
  /// In en, this message translates to:
  /// **'Please wait while your transaction is being processed. This may take a few minutes.'**
  String get transfer_processing_wait;

  /// No description provided for @transfer_not_enough.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have enough amount to send'**
  String get transfer_not_enough;

  /// No description provided for @transfer_invalid_amount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get transfer_invalid_amount;

  /// No description provided for @using_custom_gas_settings.
  ///
  /// In en, this message translates to:
  /// **'Using Custom Gas Settings'**
  String get using_custom_gas_settings;

  /// No description provided for @transfer_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Transfer'**
  String get transfer_confirm;

  /// No description provided for @transfer_confirm_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to send {planetName}\n{symbol} to\n{recipient}?'**
  String transfer_confirm_message(
      Object planetName, Object recipient, Object symbol);

  /// No description provided for @transfer_successful.
  ///
  /// In en, this message translates to:
  /// **'Transaction Successful'**
  String get transfer_successful;

  /// No description provided for @transfer_amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get transfer_amount;

  /// No description provided for @transfer_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get transfer_date;

  /// No description provided for @transfer_complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get transfer_complete;

  /// No description provided for @transfer_send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get transfer_send;

  /// No description provided for @transfer_token_send.
  ///
  /// In en, this message translates to:
  /// **'Send {token}'**
  String transfer_token_send(Object token);

  /// No description provided for @transfer_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get transfer_submit;

  /// No description provided for @error_title.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error_title;

  /// No description provided for @error_message.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String error_message(Object error);

  /// No description provided for @pin_new.
  ///
  /// In en, this message translates to:
  /// **'Enter your new PIN code'**
  String get pin_new;

  /// No description provided for @pin_reenter.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your PIN code'**
  String get pin_reenter;

  /// No description provided for @pin_enter.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN code'**
  String get pin_enter;

  /// No description provided for @pin_passcode.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN code'**
  String get pin_passcode;

  /// No description provided for @pin_not_match.
  ///
  /// In en, this message translates to:
  /// **'PIN codes don\'t match. Try again.'**
  String get pin_not_match;

  /// No description provided for @pin_incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN code. Try again.'**
  String get pin_incorrect;

  /// No description provided for @update_title.
  ///
  /// In en, this message translates to:
  /// **'Version Update'**
  String get update_title;

  /// No description provided for @update_message.
  ///
  /// In en, this message translates to:
  /// **'A new Planet Wallet version\nupdate is now available.'**
  String get update_message;

  /// No description provided for @update_button.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update_button;

  /// No description provided for @gas_priority_slow_time.
  ///
  /// In en, this message translates to:
  /// **'5 min'**
  String get gas_priority_slow_time;

  /// No description provided for @gas_priority_medium_time.
  ///
  /// In en, this message translates to:
  /// **'2 min'**
  String get gas_priority_medium_time;

  /// No description provided for @gas_priority_fast_time.
  ///
  /// In en, this message translates to:
  /// **'30 sec'**
  String get gas_priority_fast_time;

  /// No description provided for @menu_type_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get menu_type_home;

  /// No description provided for @menu_type_planets.
  ///
  /// In en, this message translates to:
  /// **'Planets'**
  String get menu_type_planets;

  /// No description provided for @menu_type_my.
  ///
  /// In en, this message translates to:
  /// **'My'**
  String get menu_type_my;

  /// No description provided for @planet_name_duplicate.
  ///
  /// In en, this message translates to:
  /// **'This planet name is already in use.'**
  String get planet_name_duplicate;

  /// No description provided for @planet_name_change_info.
  ///
  /// In en, this message translates to:
  /// **'You can change your planet name'**
  String get planet_name_change_info;

  /// No description provided for @planet_name_enter.
  ///
  /// In en, this message translates to:
  /// **'Enter Planet Name'**
  String get planet_name_enter;

  /// No description provided for @planet_name_display.
  ///
  /// In en, this message translates to:
  /// **'My Planet is'**
  String get planet_name_display;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @transaction_attemptsExceeded_msg.
  ///
  /// In en, this message translates to:
  /// **'Please check again after a moment.'**
  String get transaction_attemptsExceeded_msg;

  /// No description provided for @sol_history_not_supported.
  ///
  /// In en, this message translates to:
  /// **'SOL history is not supported.\n(Support in preparation)'**
  String get sol_history_not_supported;

  /// No description provided for @planet_address_copy_button.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get planet_address_copy_button;

  /// No description provided for @planet_address_send_button.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get planet_address_send_button;

  /// No description provided for @planet_address_network_mismatch.
  ///
  /// In en, this message translates to:
  /// **'You are currently on the {currentNetwork} planet. *Please switch to the {targetNetwork} planet* and try again.'**
  String planet_address_network_mismatch(
      Object currentNetwork, Object targetNetwork);

  /// No description provided for @ethereum.
  ///
  /// In en, this message translates to:
  /// **'Ethereum'**
  String get ethereum;

  /// No description provided for @bitcoin.
  ///
  /// In en, this message translates to:
  /// **'Bitcoin'**
  String get bitcoin;

  /// No description provided for @solana.
  ///
  /// In en, this message translates to:
  /// **'Solana'**
  String get solana;

  /// No description provided for @bnb_smart_chain.
  ///
  /// In en, this message translates to:
  /// **'BNB Smart Chain'**
  String get bnb_smart_chain;

  /// No description provided for @input_format_hint.
  ///
  /// In en, this message translates to:
  /// **'Please enter 3-15 characters using numbers, English letters, and _ only.'**
  String get input_format_hint;

  /// No description provided for @invalid_address_format.
  ///
  /// In en, this message translates to:
  /// **'This is not a valid {networkType} address format.'**
  String invalid_address_format(Object networkType);

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'Please review the information below before deleting your account.'**
  String get deleteAccountWarning;

  /// No description provided for @mnemonicBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup Mnemonic Phrase'**
  String get mnemonicBackupTitle;

  /// No description provided for @mnemonicBackupDescription.
  ///
  /// In en, this message translates to:
  /// **'You will need this mnemonic phrase to access your blockchain assets after account deletion. Make sure to back it up.'**
  String get mnemonicBackupDescription;

  /// No description provided for @copyMnemonic.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyMnemonic;

  /// No description provided for @deleteAccountCheck1.
  ///
  /// In en, this message translates to:
  /// **'All planets created with this mnemonic will be deleted.'**
  String get deleteAccountCheck1;

  /// No description provided for @deleteAccountCheck2.
  ///
  /// In en, this message translates to:
  /// **'Your assets on the blockchain will not be deleted, and you can access them again using your mnemonic phrase.'**
  String get deleteAccountCheck2;

  /// No description provided for @deleteAccountCheck3.
  ///
  /// In en, this message translates to:
  /// **'Other users may be able to claim your planet names.'**
  String get deleteAccountCheck3;

  /// No description provided for @deleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountButton;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Account Deletion'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmDescription.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirmDescription;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
