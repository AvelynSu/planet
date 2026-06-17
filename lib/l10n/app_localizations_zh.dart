// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get planets_list_my_planets => '我的星球';

  @override
  String get planets_list_hide_confirmation => '您想隐藏这个星球吗？';

  @override
  String get planets_list_current => '当前';

  @override
  String get network_select_title => '选择网络';

  @override
  String get network_ethereum => '以太坊';

  @override
  String get network_bitcoin => '比特币';

  @override
  String get network_select_button => '选择';

  @override
  String get planets_max_limit => '您最多可以添加20个星球。';

  @override
  String get planets_add_new => '添加新星球';

  @override
  String get home_show_address => '地址';

  @override
  String get planet_setting_title => '安全';

  @override
  String get settings_localization => '语言';

  @override
  String get settings_currency => '货币';

  @override
  String get settings_theme => '主题设置';

  @override
  String get settings_version => '版本';

  @override
  String get settings_sign_out => '登出';

  @override
  String get planet_backup_mnemonic => '备份助记词';

  @override
  String get planet_backup_private_key => '备份私钥';

  @override
  String get planet_address => '钱包地址';

  @override
  String get change_planet_name_title => '更改星球名称';

  @override
  String get mnemonic_phrase_title => '助记词';

  @override
  String get mnemonic_save_safely => '安全保存助记词。';

  @override
  String get copy_mnemonic => '复制助记词';

  @override
  String get success_copy => '复制成功';

  @override
  String success_copy_mnemonic(Object mnemonic) {
    return '*复制成功*\n$mnemonic';
  }

  @override
  String success_copy_private_key(Object privateKey) {
    return '*复制成功*\n$privateKey';
  }

  @override
  String get copy_private_key => '复制私钥';

  @override
  String get private_key_title => '私钥';

  @override
  String get you_are_on => '我的星球';

  @override
  String get change_pincode => '更改PIN码';

  @override
  String get modify_currency_daily_limit => '每天最多可修改3次';

  @override
  String get mnemonic_logout_warning => '如果您忘记了助记词，将无法再次登录。请妥善保存并务必记住它们。';

  @override
  String get mnemonic_logout_confirmation => '我理解登出过程并已保存我的助记词。';

  @override
  String get wallet_create_next => '下一步';

  @override
  String get wallet_create_store_mnemonic => '按顺序安全地存储这12个单词。';

  @override
  String get wallet_create_remember_note => '在下一步中，我们将要求您选择其中一些单词进行验证。请确保记住它们！';

  @override
  String get wallet_create_copy_words => '复制单词';

  @override
  String get wallet_create_warning => '这些助记词用于恢复您的钱包。切勿与他人分享。';

  @override
  String wallet_create_select_word(Object index) {
    return '请选择您的助记词中的\n第$index个单词。';
  }

  @override
  String get wallet_create_incorrect => '单词错误。请重试。';

  @override
  String get wallet_import_title => '输入恢复短语';

  @override
  String get wallet_import_recovery_phrase => '恢复短语';

  @override
  String get wallet_import_paste => '粘贴';

  @override
  String wallet_import_word_count(Object count) {
    return '已输入单词数: $count';
  }

  @override
  String get wallet_import_invalid_phrase => '恢复短语必须由12个或24个单词组成。';

  @override
  String get wallet_import_restore => '恢复钱包';

  @override
  String get wallet_import_placeholder => '单词1 单词2 单词3 单词4 单词5 单词6 ...';

  @override
  String get recovery_phrase_requirement => '恢复短语必须由12个或24个单词组成。';

  @override
  String get explore_friends_planets => '探索您的\n*朋友的星球！*';

  @override
  String get start_create_planet => '创建星球';

  @override
  String get start_import_planet => '导入其他星球';

  @override
  String get start_tagline => 'Make Your\nOwn Planet';

  @override
  String get transaction_transfer => '转账';

  @override
  String get transaction_empty_list => '列表为空';

  @override
  String get search_address_hint => '输入地址或星球名称';

  @override
  String get transfer_invalid_address => '请输入有效的钱包地址。';

  @override
  String get transfer_planets_list => '星球';

  @override
  String get transfer_address => '地址';

  @override
  String get gas_settings_advanced => '高级Gas设置';

  @override
  String get gas_settings_presets => 'Gas价格预设';

  @override
  String get gas_settings_custom => '自定义Gas设置';

  @override
  String get gas_settings_gas_price => 'Gas价格';

  @override
  String gas_settings_gas_limit_value(Object wei) {
    return 'Gas价格 : $wei';
  }

  @override
  String gas_settings_gas_price_title(Object wei) {
    return 'Gas价格 : $wei';
  }

  @override
  String get gas_settings_gas_limit => 'Gas限制';

  @override
  String get gas_settings_estimated_fee => '预估网络费用';

  @override
  String get gas_settings_apply => '应用';

  @override
  String get gas_settings_invalid => '无效的Gas设置';

  @override
  String get gas_settings_invalid_values => '请输入有效的Gas价格和Gas限制值。';

  @override
  String get gas_priority_slow => '慢速';

  @override
  String get gas_priority_average => '一般';

  @override
  String get gas_priority_fast => '快速';

  @override
  String gas_priority_estimated_time(Object time) {
    return '预估确认时间: $time';
  }

  @override
  String get transfer_label_to => '收款人';

  @override
  String get transfer_label_from => '发款人';

  @override
  String get transfer_label_fee => '费用';

  @override
  String get transfer_processing => '处理交易中';

  @override
  String get transfer_processing_wait => '请等待您的交易处理完成，这可能需要几分钟。';

  @override
  String get transfer_not_enough => '您没有足够的金额发送';

  @override
  String get transfer_invalid_amount => '请输入有效金额';

  @override
  String get using_custom_gas_settings => '使用自定义Gas设置';

  @override
  String get transfer_confirm => '确认转账';

  @override
  String transfer_confirm_message(
      Object planetName, Object recipient, Object symbol) {
    return '您确定要将$planetName\n$symbol发送给\n$recipient吗？';
  }

  @override
  String get transfer_successful => '交易成功';

  @override
  String get transfer_amount => '金额';

  @override
  String get transfer_date => '日期';

  @override
  String get transfer_complete => '完成';

  @override
  String get transfer_send => '发送';

  @override
  String transfer_token_send(Object token) {
    return '发送 $token';
  }

  @override
  String get transfer_submit => '提交';

  @override
  String get error_title => '错误';

  @override
  String error_message(Object error) {
    return '发生错误: $error';
  }

  @override
  String get pin_new => '输入您的新PIN码';

  @override
  String get pin_reenter => '重新输入您的PIN码';

  @override
  String get pin_enter => '输入您的PIN码';

  @override
  String get pin_passcode => '输入您的PIN码';

  @override
  String get pin_not_match => 'PIN码不匹配。请重试。';

  @override
  String get pin_incorrect => 'PIN码不正确。请重试。';

  @override
  String get update_title => '版本更新';

  @override
  String get update_message => '新的Planet钱包版本\n更新已经可用。';

  @override
  String get update_button => '更新';

  @override
  String get gas_priority_slow_time => '5分钟';

  @override
  String get gas_priority_medium_time => '2分钟';

  @override
  String get gas_priority_fast_time => '30秒';

  @override
  String get menu_type_home => '主页';

  @override
  String get menu_type_planets => '星球';

  @override
  String get menu_type_my => '我的';

  @override
  String get planet_name_duplicate => '此星球名称已被使用。';

  @override
  String get planet_name_change_info => '您可以更改您的星球名称';

  @override
  String get planet_name_enter => '输入星球名称';

  @override
  String get planet_name_display => '我的星球是';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get transaction_attemptsExceeded_msg => '请稍后再次确认。';

  @override
  String get sol_history_not_supported => '暂不支持SOL交易记录。\n(支持正在准备中)';

  @override
  String get planet_address_copy_button => '复制';

  @override
  String get planet_address_send_button => '发送';

  @override
  String planet_address_network_mismatch(
      Object currentNetwork, Object targetNetwork) {
    return '您当前在$currentNetwork行星上。*请切换到$targetNetwork行星*，然后重试。';
  }

  @override
  String get ethereum => '以太坊';

  @override
  String get bitcoin => '比特币';

  @override
  String get solana => '索拉纳';

  @override
  String get bnb_smart_chain => 'BNB智能链';

  @override
  String get input_format_hint => '请输入3至15个字符，仅限数字、英文和下划线(_)的组合。';

  @override
  String invalid_address_format(Object networkType) {
    return '这不是有效的$networkType地址格式。';
  }

  @override
  String get deleteAccount => '删除账户';

  @override
  String get deleteAccountWarning => '删除账户前，请确认以下信息。';

  @override
  String get mnemonicBackupTitle => '备份助记词';

  @override
  String get mnemonicBackupDescription => '删除账户后，您需要此助记词来访问区块链资产。请务必备份。';

  @override
  String get copyMnemonic => '复制';

  @override
  String get deleteAccountCheck1 => '使用此助记词创建的所有行星将被删除。';

  @override
  String get deleteAccountCheck2 => '区块链上的资产不会被删除，您可以使用助记词重新访问它们。';

  @override
  String get deleteAccountCheck3 => '其他用户可能会获得您的行星名称的所有权。';

  @override
  String get deleteAccountButton => '删除账户';

  @override
  String get deleteAccountConfirmTitle => '确认删除账户';

  @override
  String get deleteAccountConfirmDescription => '您确定要删除账户吗？此操作无法撤销。';

  @override
  String get deleteButton => '删除';

  @override
  String get pending => '待处理';

  @override
  String get sent => '已发送';

  @override
  String get received => '已接收';
}
