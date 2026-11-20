// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'OneDash';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_systemDefault => 'Follow System';

  @override
  String get common_saved => 'Saved';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_search => 'Search';

  @override
  String get common_yes => 'Yes';

  @override
  String get common_no => 'No';

  @override
  String get format_relativeUnknown => 'Unknown';

  @override
  String get format_relativeSoon => 'Soon';

  @override
  String get format_relativeJustNow => 'Just now';

  @override
  String format_relativeMinutesLater(int n) {
    return '$n min later';
  }

  @override
  String format_relativeHoursLater(int n) {
    return '$n h later';
  }

  @override
  String format_relativeDaysLater(int n) {
    return '$n d later';
  }

  @override
  String format_relativeMinutesAgo(int n) {
    return '$n min ago';
  }

  @override
  String format_relativeHoursAgo(int n) {
    return '$n h ago';
  }

  @override
  String format_relativeDaysAgo(int n) {
    return '$n d ago';
  }

  @override
  String get format_timeAgoPrefixBackup => 'Backed up ';

  @override
  String get terminal_disconnected => 'Disconnected';

  @override
  String get terminal_connecting => 'Connecting';

  @override
  String get nav_overview => 'Overview';

  @override
  String get nav_websites => 'Websites';

  @override
  String get nav_files => 'Files';

  @override
  String get nav_containers => 'Docker';

  @override
  String get nav_more => 'More';

  @override
  String get nav_network => 'Network';

  @override
  String get dashboard_system => 'System';

  @override
  String get dashboard_kernel => 'Kernel';

  @override
  String get dashboard_cpuCores => 'Cores';

  @override
  String get dashboard_uptime => 'Uptime';

  @override
  String get dashboard_load => 'Load';

  @override
  String get dashboard_processes => 'Processes';

  @override
  String get dashboard_arch => 'Arch';

  @override
  String get dashboard_memory => 'Memory';

  @override
  String get dashboard_disk => 'Disk';

  @override
  String get dashboard_download => 'Download';

  @override
  String get dashboard_upload => 'Upload';

  @override
  String dashboard_uptimeMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String dashboard_uptimeHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String dashboard_uptimeDaysHours(int days, int hours) {
    return '$days d $hours h';
  }

  @override
  String get files_sortName => 'Name';

  @override
  String get files_sortSize => 'Size';

  @override
  String get files_sortModifiedTime => 'Modified Time';

  @override
  String get files_homeDirectory => 'Home';

  @override
  String get files_rootDirectory => 'Root';

  @override
  String get files_actionPreviewImage => 'Preview Image';

  @override
  String get files_actionDecompress => 'Decompress';

  @override
  String get process_serverMissing => 'Server not found';

  @override
  String get process_stopTitle => 'Stop Process';

  @override
  String process_stopContent(int pid) {
    return 'Stop PID $pid?';
  }

  @override
  String get process_stopAction => 'Stop';

  @override
  String get more_appStoreSubtitle =>
      'Manage installed apps, upgrades, and app settings';

  @override
  String get servers_host => 'Host Address';

  @override
  String get servers_online => 'Online';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_appearance_modeLight => 'Light';

  @override
  String get settings_appearance_modeDark => 'Dark';

  @override
  String get firewall_panelPort => 'Panel port';

  @override
  String get firewall_portChanged => 'Port updated';

  @override
  String get firewall_newPort => 'New port';

  @override
  String get firewall_title => 'Firewall';

  @override
  String get firewall_port => 'Port';

  @override
  String get firewall_portPlaceholder => '80, 8080-8090, or 80,443';

  @override
  String get firewall_strategy => 'Strategy';

  @override
  String get firewall_ipAddress => 'IP Address';

  @override
  String get firewall_ipAddressPlaceholder => '192.168.1.100 or 10.0.0.0/8';

  @override
  String get firewall_protocolLabel => 'Protocol';

  @override
  String get firewall_descriptionLabel => 'Description';

  @override
  String get panelSettings_alerts => 'Alert Notifications';

  @override
  String get panelSettings_basicInfo => 'Basic Info';

  @override
  String get panelSettings_defaultAccessAddress => 'Default Access Address';

  @override
  String get panelSettings_notSet => 'Not Set';

  @override
  String get panelSettings_defaultAccessAddressPlaceholder =>
      'Enter the default access address';

  @override
  String get panelSettings_panelUsername => 'Panel Username';

  @override
  String get panelSettings_apiKeyManagement => 'Independent API keys';

  @override
  String get panelSettings_apiKeyManagementHint =>
      'Create, view and manage independent API keys.';

  @override
  String get panelSettings_apiKeyCreate => 'Create API key';

  @override
  String get panelSettings_apiKeyName => 'Name';

  @override
  String get panelSettings_apiKeyDescription => 'Description';

  @override
  String get panelSettings_apiKeyIpWhiteList => 'IP allowlist';

  @override
  String get panelSettings_apiKeyTrustedProxies => 'Trusted proxies';

  @override
  String get panelSettings_apiKeyValidity => 'Timestamp validity (minutes)';

  @override
  String get panelSettings_apiKeyAllowAppBinding => 'Allow app binding';

  @override
  String get panelSettings_apiKeyReveal => 'Reveal key';

  @override
  String get panelSettings_apiKeyEnable => 'Enable';

  @override
  String get panelSettings_apiKeyDisable => 'Disable';

  @override
  String get panelSettings_apiKeyRevoke => 'Revoke';

  @override
  String get panelSettings_apiKeyDelete => 'Delete';

  @override
  String get panelSettings_apiKeyEmpty => 'No independent API keys';

  @override
  String get panelSettings_apiKeyCreated => 'API key created and copied';

  @override
  String get panelSettings_apiKeyRevokeConfirm =>
      'Revoke cannot be undone. Continue?';

  @override
  String get panelSettings_apiKeyDeleteConfirm =>
      'Delete cannot be undone. Continue?';

  @override
  String get panelSettings_apiKeyExpires => 'Expires';

  @override
  String get panelSettings_panelLogin => 'Panel login';

  @override
  String get panelSettings_panelLoggedIn =>
      'Signed in. Password, MFA, Passkey and API Key management are available.';

  @override
  String get panelSettings_panelNotLoggedIn =>
      'Not signed in. Password, MFA, Passkey and API Key management require a panel session.';

  @override
  String get panelSettings_username => 'Username';

  @override
  String get panelSettings_password => 'Password';

  @override
  String get panelSettings_login => 'Sign in';

  @override
  String get panelSettings_loginRequired => 'Sign in to the panel first.';

  @override
  String get panelSettings_captcha => 'Verification code';

  @override
  String get panelSettings_logout => 'Sign out';

  @override
  String get panelSettings_panelLoginPassword => 'Panel Login Password';

  @override
  String get panelSettings_changePanelLoginPassword =>
      'Change the panel login password';

  @override
  String get panelSettings_displaySettingsWebOnly =>
      'Display Settings (Web UI Only)';

  @override
  String get panelSettings_theme => 'Theme';

  @override
  String get panelSettings_themeLight => 'Light';

  @override
  String get panelSettings_themeDark => 'Dark';

  @override
  String get panelSettings_language => 'Language';

  @override
  String get panelSettings_languageZh => 'Chinese';

  @override
  String get panelSettings_languageZhHant => 'Traditional Chinese';

  @override
  String get panelSettings_languageJa => 'Japanese';

  @override
  String get panelSettings_languageMs => 'Malay';

  @override
  String get panelSettings_languagePtBr => 'Portuguese (Brazil)';

  @override
  String get panelSettings_tabNavigation => 'Tab Navigation';

  @override
  String get panelSettings_tabNavigationSubtitle =>
      'Show page tabs in the top bar';

  @override
  String get panelSettings_securitySettings => 'Security Settings';

  @override
  String get panelSettings_sessionTimeout => 'Session Timeout';

  @override
  String get panelSettings_neverTimeout => 'Never timeout';

  @override
  String panelSettings_secondsValue(String seconds) {
    return '$seconds s';
  }

  @override
  String get panelSettings_sessionTimeoutPlaceholder => '0 = never timeout';

  @override
  String get panelSettings_sessionTimeoutDescription =>
      'Set the panel login session timeout in seconds. Use 0 to never timeout.';

  @override
  String get panelSettings_advancedSettings => 'Advanced Settings';

  @override
  String get panelSettings_apiInterface => 'API Interface';

  @override
  String get panelSettings_webPanelRequired =>
      'Manage this in the 1Panel web panel';

  @override
  String get panelSettings_localApiKey => 'Connection key saved in this app';

  @override
  String get panelSettings_enabled => 'Enabled';

  @override
  String get panelSettings_disabled => 'Disabled';

  @override
  String get panelSettings_settingUpdated => 'Settings updated';

  @override
  String get panelSettings_updateFailed => 'Update failed';

  @override
  String get panelSettings_panelPort => 'Panel Port';

  @override
  String get panelSettings_securityEntrance => 'Security Entrance';

  @override
  String get panelSettings_bindDomain => 'Bind Domain';

  @override
  String get panelSettings_operationFailed => 'Operation failed';

  @override
  String get panelSettings_alertList => 'Alert Rules';

  @override
  String get panelSettings_alertLogs => 'Alert Logs';

  @override
  String get panelSettings_noAlertRules => 'No alert rules';

  @override
  String get alerts_metaTypeLabel => 'Type: ';

  @override
  String alerts_metaType(String type) {
    return 'Type: $type';
  }

  @override
  String get alerts_metaMethodLabel => 'Method: ';

  @override
  String alerts_metaMethod(String method) {
    return 'Method: $method';
  }

  @override
  String get panelSettings_deleted => 'Deleted';

  @override
  String get panelSettings_deleteFailed => 'Delete failed';

  @override
  String get panelSettings_logsCleared => 'Logs cleared';

  @override
  String get panelSettings_clearFailed => 'Clear failed';

  @override
  String get panelSettings_clearLogs => 'Clear Logs';

  @override
  String get panelSettings_noLogs => 'No logs';

  @override
  String get panelSettings_notificationMethods => 'Notification Methods';

  @override
  String get panelSettings_emailNotification => 'Email Notification';

  @override
  String get panelSettings_smtpSubtitle => 'Configure SMTP email delivery';

  @override
  String get panelSettings_webhookSubtitle => 'Configure Webhook';

  @override
  String get panelSettings_weCom => 'WeCom';

  @override
  String get panelSettings_dingTalk => 'DingTalk';

  @override
  String get panelSettings_feishu => 'Feishu';

  @override
  String get panelSettings_type => 'Type';

  @override
  String get panelSettings_credentials => 'Credentials';

  @override
  String get cronjobs_title => 'Scheduled tasks';

  @override
  String get cronjobs_enable => 'Enable';

  @override
  String get cronjobs_disable => 'Disable';

  @override
  String get cronjobs_runOnce => 'Run Now';

  @override
  String cronjobs_everyMinutes(String n) {
    return 'Every $n minutes';
  }

  @override
  String cronjobs_everySeconds(String n) {
    return 'Every $n seconds';
  }

  @override
  String cronjobs_everyHourAtMinute(String minute) {
    return 'Every hour at minute $minute';
  }

  @override
  String cronjobs_dailyAt(String time) {
    return 'Daily at $time';
  }

  @override
  String cronjobs_everyHours(String n) {
    return 'Every $n hours';
  }

  @override
  String cronjobs_weeklyAt(String weekday, String time) {
    return 'Every $weekday at $time';
  }

  @override
  String cronjobs_monthlyAt(String day, String time) {
    return 'Monthly on day $day at $time';
  }

  @override
  String cronjobs_everyDaysAt(String n, String time) {
    return 'Every $n days at $time';
  }

  @override
  String get cronjobs_weekdaySun => 'Sunday';

  @override
  String get cronjobs_weekdayMon => 'Monday';

  @override
  String get cronjobs_weekdayTue => 'Tuesday';

  @override
  String get cronjobs_weekdayWed => 'Wednesday';

  @override
  String get cronjobs_weekdayThu => 'Thursday';

  @override
  String get cronjobs_weekdayFri => 'Friday';

  @override
  String get cronjobs_weekdaySat => 'Saturday';

  @override
  String cronjobs_weekdayFallback(String day) {
    return 'Day $day';
  }

  @override
  String get appStore_installed => 'Installed';

  @override
  String get appStore_appKey => 'App Key';

  @override
  String get websites_basicConfig => 'Basic Configuration';

  @override
  String get websites_alias => 'Alias';

  @override
  String get websites_runtime => 'Runtime';

  @override
  String get websites_proxySettings => 'Reverse Proxy Settings';

  @override
  String get websites_website => 'Website';

  @override
  String get websites_sslCertificate => 'SSL Certificate';

  @override
  String get websites_noReverseProxy => 'No reverse proxy';

  @override
  String get websites_websiteAlias => 'Website Alias';

  @override
  String get websites_rootDirectory => 'Root Directory';

  @override
  String get websites_domains => 'Domains';

  @override
  String get websites_remark => 'Remark';

  @override
  String get websites_optional => 'Optional';

  @override
  String get websites_domain => 'Domain';

  @override
  String get websites_removeDomain => 'Remove Domain';

  @override
  String get websites_noDomains => 'No domains';

  @override
  String get websites_siteDirectory => 'Website Directory';

  @override
  String get websites_deleteReverseProxy => 'Delete Reverse Proxy';

  @override
  String get websites_targetAddress => 'Target Address';

  @override
  String get websites_logs => 'Logs';

  @override
  String get websites_configFile => 'Config File';

  @override
  String get websites_accessLog => 'Access Log';

  @override
  String get websites_errorLog => 'Error Log';

  @override
  String get websites_path => 'Path';

  @override
  String get containers_privilegedMode => 'Privileged Mode';

  @override
  String get containers_hostname => 'Hostname';

  @override
  String get containers_mountedVolumes => 'Mounted Volumes';

  @override
  String get containers_workingDir => 'Working Directory';

  @override
  String get containers_command => 'Command';

  @override
  String get containers_entrypoint => 'Entrypoint';

  @override
  String get containers_envVars => 'Environment Variables';

  @override
  String get containers_restartPolicy => 'Restart Policy';

  @override
  String get containers_start => 'Start';

  @override
  String get containers_stop => 'Stop';

  @override
  String get containers_restart => 'Restart';

  @override
  String get containers_running => 'Running';

  @override
  String get containers_stopped => 'Stopped';

  @override
  String get containers_compose => 'Compose';

  @override
  String get containers_logs => 'Logs';

  @override
  String get containers_all => 'All';

  @override
  String get containers_terminal => 'Terminal';

  @override
  String get containers_images => 'Images';

  @override
  String get containers_pause => 'Pause';

  @override
  String get containers_memory => 'Memory';

  @override
  String get databases_changePassword => 'Change Password';

  @override
  String get databases_changePasswordSubtitle => 'Change database password';

  @override
  String get databases_address => 'Address';

  @override
  String get databases_port => 'Port';

  @override
  String get databases_username => 'Username';

  @override
  String get databases_password => 'Password';

  @override
  String get databases_remoteAccess => 'Remote Access';

  @override
  String get databases_enabled => 'Enabled';

  @override
  String get databases_disabled => 'Disabled';

  @override
  String get databases_deleteDatabase => 'Delete Database';

  @override
  String get databases_passwordChanged => 'Password changed';

  @override
  String get databases_newPassword => 'New Password';

  @override
  String get common_notAvailable => 'Not available';

  @override
  String get common_empty_title => 'Nothing here yet';

  @override
  String get common_empty_message => 'No data to show.';

  @override
  String get error_details => 'Details';

  @override
  String get error_auth_title => 'Invalid API key';

  @override
  String get error_auth_message =>
      'The API key is invalid or expired. Generate a new key in 1Panel panel settings.';

  @override
  String get error_network_title => 'Cannot reach the panel';

  @override
  String get error_network_message =>
      'Check the network and the panel address, then retry.';

  @override
  String get error_cert_title => 'Certificate not trusted';

  @override
  String get error_cert_message =>
      'The panel uses a self-signed certificate. Allow it in server settings if you trust this host.';

  @override
  String get error_server_title => 'Panel error';

  @override
  String error_server_message(int statusCode) {
    return 'The panel returned HTTP $statusCode.';
  }

  @override
  String get error_server_missing_message =>
      'The selected server is no longer available. Choose another server or add it again.';

  @override
  String get error_not_found_title => 'Not supported';

  @override
  String get error_not_found_message =>
      'This panel version does not provide the endpoint. The entry has been hidden.';

  @override
  String get error_request_title => 'Request rejected';

  @override
  String get error_business_title => 'Operation failed';

  @override
  String get error_format_title => 'Incompatible data';

  @override
  String get error_format_message =>
      'The panel response format is not compatible with this app version.';

  @override
  String get error_unknown_title => 'Something went wrong';

  @override
  String get error_unknown_message =>
      'Please retry. If it persists, check the panel logs.';

  @override
  String get servers_backToList => 'Back to panels';

  @override
  String get servers_websites => 'Websites';

  @override
  String get servers_databases => 'Databases';

  @override
  String get servers_apps => 'Apps';

  @override
  String get servers_tasks => 'Tasks';

  @override
  String get servers_title => 'Panels';

  @override
  String get servers_empty_title => 'No panel connected';

  @override
  String get servers_empty_message =>
      'Generate an API key in 1Panel: Panel Settings - API Interface.';

  @override
  String get servers_add => 'Add panel';

  @override
  String get servers_current => 'Current';

  @override
  String get servers_offline => 'Offline';

  @override
  String get servers_neverConnected => 'Never connected';

  @override
  String get servers_sessionActive => 'This session';

  @override
  String servers_last_seen(String time) {
    return 'Last connected $time';
  }

  @override
  String get servers_delete => 'Delete panel';

  @override
  String get servers_delete_message =>
      'Remove this panel from this device? The panel itself is not changed.';

  @override
  String get server_edit_add_title => 'Add panel';

  @override
  String get server_edit_edit_title => 'Edit panel';

  @override
  String get server_edit_address => 'Address';

  @override
  String get server_edit_name => 'Name';

  @override
  String get server_edit_name_hint => 'My server';

  @override
  String get server_edit_host => 'Host';

  @override
  String get server_edit_port => 'Port';

  @override
  String get server_edit_https => 'HTTPS';

  @override
  String get server_edit_api_key => 'API key';

  @override
  String get server_edit_api_key_hint => 'Paste the key generated by 1Panel';

  @override
  String get server_edit_allow_insecure => 'Allow self-signed certificate';

  @override
  String get server_edit_allow_insecure_hint =>
      'Only for this host. The certificate will not be verified.';

  @override
  String get server_edit_test => 'Test connection';

  @override
  String get server_edit_save => 'Save and open';

  @override
  String get server_edit_diag_network => 'Network reachable';

  @override
  String get server_edit_diag_tls => 'Certificate trusted';

  @override
  String get server_edit_diag_auth => 'Authentication';

  @override
  String get server_edit_diag_capability => 'Endpoint capability';

  @override
  String get server_edit_host_hint => 'e.g. 192.168.1.10';

  @override
  String get server_edit_key_guide =>
      '1Panel - Panel Settings - API Interface - Generate key';

  @override
  String get dashboard_health => 'Health';

  @override
  String get dashboard_health_excellent => 'Excellent';

  @override
  String get dashboard_health_good => 'Good';

  @override
  String get dashboard_health_fair => 'Fair';

  @override
  String get dashboard_health_poor => 'Poor';

  @override
  String get dashboard_cpu => 'CPU';

  @override
  String get dashboard_network => 'Network';

  @override
  String get dashboard_system_info => 'System information';

  @override
  String get dashboard_sites_containers => 'Websites and containers';

  @override
  String get dashboard_quick_actions => 'Quick actions';

  @override
  String get dashboard_clear_cache => 'Clear cache';

  @override
  String get dashboard_view_logs => 'View logs';

  @override
  String get dashboard_terminal => 'Terminal';

  @override
  String get dashboard_firewall => 'Firewall';

  @override
  String dashboard_cores(int count) {
    return '$count cores';
  }

  @override
  String dashboard_used_of(String used, String total) {
    return '$used / $total';
  }

  @override
  String get dashboard_offline_banner => 'Connection interrupted, retrying';

  @override
  String get files_empty_title => 'This folder is empty';

  @override
  String get files_empty_message =>
      'Upload a file or create a folder to get started.';

  @override
  String get files_upload => 'Upload';

  @override
  String get files_new_folder => 'New folder';

  @override
  String get files_new_file => 'New file';

  @override
  String get files_download => 'Download';

  @override
  String get files_delete => 'Delete';

  @override
  String get files_rename => 'Rename';

  @override
  String get files_compress => 'Compress';

  @override
  String get files_preview => 'Preview';

  @override
  String get files_directoryTree => 'Directory tree';

  @override
  String get files_remark => 'Remark';

  @override
  String get files_remarkSaved => 'Remark saved';

  @override
  String get files_shareQr => 'Share QR code';

  @override
  String get files_mounts => 'System mounts';

  @override
  String get files_mountPoint => 'Mount point';

  @override
  String get files_share => 'Share';

  @override
  String get files_sort => 'Sort';

  @override
  String get files_parent => 'Up';

  @override
  String get websites_title => 'Websites';

  @override
  String get websites_empty_title => 'No websites yet';

  @override
  String get websites_empty_message =>
      'Create a website to serve a static folder or reverse proxy.';

  @override
  String get websites_create => 'Create website';

  @override
  String get websites_all => 'All';

  @override
  String get websites_running => 'Running';

  @override
  String get websites_stopped => 'Stopped';

  @override
  String get websites_static => 'Static';

  @override
  String get websites_proxy => 'Reverse proxy';

  @override
  String get websites_deployment => 'Application';

  @override
  String get websites_subsite => 'Subsite';

  @override
  String get websites_php => 'PHP';

  @override
  String websites_expire_days(int days) {
    return '$days days left';
  }

  @override
  String websites_expired_days(int days) {
    return 'Expired $days days ago';
  }

  @override
  String get websites_expire_today => 'Expires today';

  @override
  String get containers_title => 'Containers';

  @override
  String get containers_empty_title => 'No containers';

  @override
  String get containers_empty_message =>
      'Containers created on this panel will appear here.';

  @override
  String get containers_abnormal => 'Abnormal';

  @override
  String get containers_config => 'Config';

  @override
  String get more_title => 'More';

  @override
  String get more_group_apps => 'Apps and services';

  @override
  String get more_group_web => 'Web services';

  @override
  String get more_group_ops => 'Operations';

  @override
  String get more_group_system => 'System';

  @override
  String get more_app_store => 'App store';

  @override
  String get more_installed_apps => 'Installed apps';

  @override
  String get more_databases => 'Databases';

  @override
  String get more_cronjobs => 'Scheduled tasks';

  @override
  String get more_firewall => 'Firewall';

  @override
  String get more_logs => 'Logs';

  @override
  String get more_terminal => 'Terminal';

  @override
  String get more_panel_settings => 'Panel settings';

  @override
  String get more_app_settings => 'App settings';

  @override
  String get more_process => 'Processes';

  @override
  String get more_backups => 'Backups';

  @override
  String get more_logsSubtitle => 'Operation, login, and task logs';

  @override
  String get more_processSubtitle => 'Inspect resource usage and end processes';

  @override
  String get more_backupsSubtitle => 'Backup plans, accounts, and restore';

  @override
  String get more_firewallSubtitle => 'Port rules and IP allowlists';

  @override
  String get more_supervisorSubtitle =>
      'Process supervision and restart policy';

  @override
  String get more_toolboxSubtitle => 'Everyday maintenance tools';

  @override
  String get more_runtimes => 'Runtimes';

  @override
  String get settings_appearance => 'Appearance';

  @override
  String get settings_theme_mode => 'Theme mode';

  @override
  String get settings_accent => 'Accent color';

  @override
  String get settings_dynamic_color => 'Dynamic color';

  @override
  String get settings_dynamic_color_hint =>
      'Use the Android 12+ wallpaper color';

  @override
  String get settings_oled => 'OLED black';

  @override
  String get settings_oled_hint => 'Only applies to dark theme';

  @override
  String get settings_accent_forest => 'Forest';

  @override
  String get settings_accent_ocean => 'Ocean';

  @override
  String get settings_accent_indigo => 'Indigo';

  @override
  String get settings_accent_violet => 'Violet';

  @override
  String get settings_accent_rose => 'Rose';

  @override
  String get settings_accent_amber => 'Amber';

  @override
  String get settings_accent_teal => 'Teal';

  @override
  String get settings_accent_graphite => 'Graphite';

  @override
  String get settings_text_scale => 'Text size';

  @override
  String get settings_interaction => 'Interaction';

  @override
  String get settings_haptics => 'Haptic feedback';

  @override
  String get settings_list_animations => 'List animations';

  @override
  String get settings_appLanguage => 'App language';

  @override
  String get settings_appLanguageZh => '简体中文';

  @override
  String get settings_appLanguageEn => 'English';

  @override
  String get settings_about => 'About';

  @override
  String get settings_version => 'Version';

  @override
  String get settings_licenses => 'Open source licenses';

  @override
  String get settings_privacy => 'Privacy';

  @override
  String get settings_security => 'Security';

  @override
  String get settings_secure_screen => 'Block screenshots';

  @override
  String get action_retry => 'Retry';

  @override
  String get action_edit => 'Edit';

  @override
  String get action_delete => 'Delete';

  @override
  String get action_cancel => 'Cancel';

  @override
  String get action_confirm => 'Confirm';

  @override
  String get action_save => 'Save';

  @override
  String get action_close => 'Close';

  @override
  String get action_search => 'Search';

  @override
  String get action_refresh => 'Refresh';

  @override
  String get action_copy => 'Copy';

  @override
  String get action_more => 'More';

  @override
  String get action_create => 'Create';

  @override
  String get action_done => 'Done';

  @override
  String get state_empty => 'No data';

  @override
  String get terminal_title => 'Terminal';

  @override
  String get terminal_connected => 'Connected';

  @override
  String get terminal_disconnect_confirm => 'Disconnect the current session?';

  @override
  String get logs_title => 'Logs';

  @override
  String get logs_operation => 'Operation';

  @override
  String get logs_login => 'Login';

  @override
  String get logs_ssh => 'SSH';

  @override
  String get logs_task => 'Task';

  @override
  String get apps_title => 'App store';

  @override
  String get apps_search_hint => 'Search apps';

  @override
  String get apps_emptyTitle => 'No apps found';

  @override
  String get apps_emptyMessage => 'Try another keyword or sync the app list.';

  @override
  String get apps_installedEmptyTitle => 'No installed apps';

  @override
  String get apps_installedEmptyMessage =>
      'Install an app from the catalog to see it here.';

  @override
  String get apps_install => 'Install';

  @override
  String get apps_installed => 'Installed';

  @override
  String get apps_update_available => 'Update available';

  @override
  String get databases_title => 'Databases';

  @override
  String get databases_empty_title => 'No databases';

  @override
  String get databases_empty_message => 'Create a database to manage it here.';

  @override
  String get cronjobs_empty_title => 'No scheduled tasks';

  @override
  String get cronjobs_empty_message =>
      'Create a task to run scripts on a schedule.';

  @override
  String get firewall_status => 'Firewall status';

  @override
  String get firewall_ports => 'Port rules';

  @override
  String get firewall_ips => 'IP rules';

  @override
  String get firewall_add_rule => 'Add rule';

  @override
  String get firewall_allow => 'Allow';

  @override
  String get firewall_deny => 'Deny';

  @override
  String get backups_title => 'Backups';

  @override
  String get backups_empty_title => 'No backups';

  @override
  String get backups_recordUntitled => 'Untitled backup';

  @override
  String get backups_empty_message =>
      'Configure a backup account to protect your data.';

  @override
  String get panel_settings_title => 'Panel settings';

  @override
  String get panel_settings_base => 'Basic';

  @override
  String get gallery_title => 'Component gallery';

  @override
  String get common_show => 'Show';

  @override
  String get common_hide => 'Hide';

  @override
  String common_copiedLabel(String label) {
    return '$label copied';
  }

  @override
  String get websites_addDomain => 'Add domain';

  @override
  String get websites_addDomainAction => 'Add';

  @override
  String get websites_domainAdded => 'Domain added';

  @override
  String get websites_removeDomainMessage =>
      'This domain will no longer point to this website.';

  @override
  String get websites_domainDeleted => 'Domain deleted';

  @override
  String get websites_noSslCertificate => 'No SSL certificate configured';

  @override
  String get websites_bindExistingCertificate => 'Bind existing certificate';

  @override
  String get websites_changeCertificate => 'Change or bind certificate';

  @override
  String get websites_noReverseProxyHint =>
      'Add a reverse proxy rule to this website in the panel.';

  @override
  String websites_deleteProxyMessage(String name, String match) {
    return 'The rule $name ($match) will be deleted.';
  }

  @override
  String get backups_tabApps => 'Apps';

  @override
  String get backups_tabDatabases => 'Databases';

  @override
  String get backups_tabWebsites => 'Websites';

  @override
  String get backups_tabDirectories => 'Directories';

  @override
  String get backups_downloadUrl => 'Get download URL';

  @override
  String get backups_restoreThis => 'Restore this backup';

  @override
  String get backups_restoreTitle => 'Restore backup';

  @override
  String get backups_resourceName => 'Resource name';

  @override
  String get backups_appNameHint => 'App name';

  @override
  String get backups_databaseInstanceHint => 'Database instance name';

  @override
  String get backups_detailName => 'Detail name';

  @override
  String get backups_appDetailHint => 'App detail name';

  @override
  String get backups_databaseNameHint => 'Database name';

  @override
  String get backups_databaseType => 'Database type';

  @override
  String get backups_restoreSecret => 'Restore secret';

  @override
  String get backups_confirmRestore => 'Restore';

  @override
  String get backups_restoreParamsRequired => 'Enter all restore parameters';

  @override
  String get backups_restoreSubmitted => 'Restore task submitted';

  @override
  String get server_edit_validation_host_required => 'Enter a host address';

  @override
  String get server_edit_validation_host_protocol =>
      'Enter only the host name or IP, without a protocol';

  @override
  String get server_edit_validation_host_space =>
      'Host address cannot contain spaces';

  @override
  String get server_edit_validation_port_range =>
      'Port must be between 1 and 65535';

  @override
  String get server_edit_validation_key_length =>
      'API key must be at least 16 characters';

  @override
  String get server_edit_validation_key_space =>
      'API key cannot contain spaces';

  @override
  String get server_edit_not_found => 'Server not found';

  @override
  String get server_edit_self_signed_allowed =>
      'Self-signed certificate allowed';

  @override
  String server_edit_clock_drift(int seconds) {
    return 'Device time differs from the panel by $seconds seconds';
  }

  @override
  String get files_nameHint => 'Name';

  @override
  String get files_archiveName => 'Archive name';

  @override
  String get files_extractTitle => 'Extract file';

  @override
  String files_extractMessage(String name) {
    return 'Extract $name to the current directory.';
  }

  @override
  String get files_extractToCurrent => 'Extract to current directory';

  @override
  String get files_imageTooLarge => 'Image exceeds 30 MB. Download it to view.';

  @override
  String get files_downloadTooLarge =>
      'File exceeds 50 MB. Use the web version to download.';

  @override
  String get files_downloadReady =>
      'File is ready. Save or share it from the share sheet.';

  @override
  String files_savedTo(String path) {
    return 'Saved to $path';
  }

  @override
  String files_itemCount(int count) {
    return '$count items';
  }

  @override
  String get databases_deleteMessage =>
      'This database will be permanently deleted.';

  @override
  String databases_deleteRelatedMessage(int count) {
    return '$count linked resources found. Deleting the database will affect them.';
  }

  @override
  String get common_running => 'Running';

  @override
  String get common_stopped => 'Stopped';

  @override
  String common_typeToContinue(String value) {
    return 'Type \"$value\" to continue';
  }

  @override
  String get common_resourceName => 'Resource name';

  @override
  String get websites_type => 'Type';

  @override
  String get websites_invalidDomainFormat => 'Invalid domain format';

  @override
  String get websites_domainAtLeastOne => 'Enter at least one domain';

  @override
  String get websites_proxyTargetRequired => 'Enter a reverse proxy target';

  @override
  String get firewall_addIpRule => 'Add IP rule';

  @override
  String get terminal_sensitivePasteTitle => 'Paste sensitive content?';

  @override
  String get terminal_sensitivePasteMessage =>
      'Clipboard content may contain passwords or tokens.';

  @override
  String get terminal_paste => 'Paste';

  @override
  String get terminal_fontSize => 'Font size';

  @override
  String get log_empty => 'No logs';

  @override
  String get log_jumpLatest => 'Jump to latest';

  @override
  String get log_pause => 'Pause';

  @override
  String get log_resume => 'Resume';

  @override
  String get log_clear => 'Clear';

  @override
  String get log_export => 'Export';

  @override
  String get ssl_selectCertificate => 'Select a certificate';

  @override
  String get ssl_bindTitle => 'Bind SSL certificate';

  @override
  String get ssl_acmeAccount => 'ACME account';

  @override
  String get ssl_certificate => 'Certificate';

  @override
  String get ssl_noCertificates =>
      'No certificates available. Apply for or upload one first.';

  @override
  String apps_requiredMissing(String fields) {
    return 'Required: $fields';
  }

  @override
  String get apps_version => 'Version';

  @override
  String get apps_installParams => 'Install parameters';

  @override
  String get apps_required => 'Required';

  @override
  String get cronjobs_neverRun => 'Never run';

  @override
  String get file_editor_unsavedLeave => 'Discard unsaved changes?';

  @override
  String get settings_localOnly => 'Data stays on device';

  @override
  String get action_clear => 'Clear';

  @override
  String get dashboard_coreUsage => 'Per-core usage';

  @override
  String get dashboard_noCoreData => 'The panel did not return per-core data';

  @override
  String get containers_dockerNotRunningShort =>
      'Docker service is not running';

  @override
  String get apps_detailMissing =>
      'Missing app detail ID; cannot perform this action';

  @override
  String get panelSettings_openWeb => 'Open web panel';

  @override
  String get containers_unlimited => 'Unlimited';

  @override
  String get websites_createdAt => 'Created';

  @override
  String get websites_sslProvider => 'Provider';

  @override
  String get websites_sslExpire => 'Expires';

  @override
  String get websites_sslValidity => 'Remaining validity';

  @override
  String websites_sslDaysCount(int days) {
    return '$days days';
  }

  @override
  String websites_sslDomainsMore(int count) {
    return 'and $count more';
  }

  @override
  String get websites_sslExpired => 'Expired';

  @override
  String get websites_sslProviderDnsAccount => 'DNS account';

  @override
  String get websites_sslProviderDnsManual => 'Manual DNS';

  @override
  String get websites_sslProviderHttp => 'HTTP';

  @override
  String get websites_sslProviderSelfSigned => 'Self-signed';

  @override
  String get websites_sslProviderManual => 'Uploaded';

  @override
  String get websites_sslProviderFromMaster => 'From main node';

  @override
  String panelSettings_deleteAlertConfirm(String title) {
    return 'Delete alert \"$title\"?';
  }

  @override
  String get panelSettings_clearLogsConfirm =>
      'Clear all alert logs? This cannot be undone.';

  @override
  String get server_edit_port_default => '9999';

  @override
  String websites_count(int count) {
    return '$count websites';
  }

  @override
  String containers_count(int count) {
    return '$count containers';
  }

  @override
  String dashboard_trafficTotal(String value) {
    return 'Total $value';
  }

  @override
  String get error_request_message =>
      'The panel rejected this request. Try again later.';

  @override
  String get supervisor_title => 'Process Guard';

  @override
  String get supervisor_serviceStart => 'Start Supervisor';

  @override
  String get supervisor_serviceStop => 'Stop Supervisor';

  @override
  String get supervisor_serviceRestart => 'Restart Supervisor';

  @override
  String get supervisor_initSupervisor => 'Initialize Supervisor';

  @override
  String supervisor_serviceOperateConfirm(String operation) {
    return 'Confirm $operation for the Supervisor service?';
  }

  @override
  String supervisor_processOperateConfirm(String operation, String name) {
    return 'Confirm $operation for $name?';
  }

  @override
  String get supervisor_operationSuccess => 'Operation succeeded';

  @override
  String get supervisor_operationFailed => 'Operation failed';

  @override
  String get supervisor_notInstalledTitle => 'supervisord Not Detected';

  @override
  String get supervisor_notInstalledSubtitle =>
      'Install Supervisor on the server first and make sure the systemd service exists.';

  @override
  String get supervisor_ctlMissingTitle => 'supervisorctl Not Detected';

  @override
  String get supervisor_ctlMissingSubtitle =>
      'The process list and process operations depend on supervisorctl.';

  @override
  String get supervisor_needInitTitle => 'Initialization Required';

  @override
  String get supervisor_needInitSubtitle =>
      'Initialization rewrites the [include] files parameter in the main config and restarts the Supervisor service.';

  @override
  String get supervisor_initTitle => 'Initialize Supervisor';

  @override
  String get supervisor_initWarning =>
      'Initialization modifies the [include] files parameter in the main config and restarts the matching systemd service.';

  @override
  String get supervisor_primaryConfig => 'Main Config File';

  @override
  String get supervisor_serviceName => 'Service Name';

  @override
  String get supervisor_configPathAndServiceRequired =>
      'Enter the main config path and service name';

  @override
  String get supervisor_initSuccess => 'Initialized';

  @override
  String get supervisor_initFailed => 'Initialization failed';

  @override
  String get supervisor_emptyTitle => 'No Guarded Processes';

  @override
  String get supervisor_emptySubtitle =>
      'After creating a process, the corresponding ini config and stdout/stderr log paths are generated.';

  @override
  String get supervisor_serviceStoppedWarn =>
      'The Supervisor service is not running, so process status may be unavailable. Start it from the top-right menu.';

  @override
  String get supervisor_createProcess => 'Create Guarded Process';

  @override
  String get supervisor_name => 'Name';

  @override
  String get supervisor_user => 'Run User';

  @override
  String get supervisor_command => 'Start Command';

  @override
  String get supervisor_numprocs => 'Process Count';

  @override
  String get supervisor_environment => 'Environment';

  @override
  String get supervisor_autoRestart => 'Auto Restart';

  @override
  String get supervisor_autoRestartSubtitle =>
      'Supervisor restarts the process after an abnormal exit';

  @override
  String get supervisor_autoStart => 'Auto Start';

  @override
  String get supervisor_autoStartSubtitle =>
      'Start this process automatically when Supervisor starts';

  @override
  String get supervisor_requiredFields => 'Fill in all required fields';

  @override
  String get supervisor_nameRule =>
      'Name supports letters, numbers, - and _, and cannot start with a special character';

  @override
  String get supervisor_numprocsRule =>
      'Process count must be between 1 and 9999';

  @override
  String get supervisor_updateSuccess => 'Updated';

  @override
  String get supervisor_createSuccess => 'Created';

  @override
  String get supervisor_saveFailed => 'Save failed';

  @override
  String get supervisor_processStartSubtitle => 'Start this process group';

  @override
  String get supervisor_processStopSubtitle => 'Stop this process group';

  @override
  String get supervisor_processRestartSubtitle => 'Restart this process group';

  @override
  String get supervisor_deleteSubtitle =>
      'Delete this process config and update Supervisor';

  @override
  String get supervisor_workDir => 'Working Directory';

  @override
  String get toolbox_title => 'Toolbox';

  @override
  String get toolbox_hostname => 'Hostname';

  @override
  String get toolbox_systemUser => 'System User';

  @override
  String get toolbox_timeZone => 'Time Zone';

  @override
  String get toolbox_localTime => 'Local Time';

  @override
  String get toolbox_cacheClean => 'Cache Cleanup';

  @override
  String get toolbox_scan => 'Scan';

  @override
  String get toolbox_scanFailed => 'Scan failed';

  @override
  String get toolbox_installed => 'Installed';

  @override
  String get toolbox_running => 'Running';

  @override
  String get toolbox_enabled => 'Enabled';

  @override
  String get toolbox_version => 'Version';

  @override
  String get toolbox_port => 'Port';

  @override
  String get toolbox_virusScan => 'Virus Scan';

  @override
  String get toolbox_clamAvRunning => 'ClamAV Running';

  @override
  String get toolbox_freshClamRunning => 'FreshClam Running';

  @override
  String get toolbox_virusDatabase => 'Virus Database';

  @override
  String get toolbox_noCleanItems => 'No cleanable items';

  @override
  String get toolbox_cleanGroupSystem => 'System Cache';

  @override
  String get toolbox_cleanGroupBackup => 'Backup Cache';

  @override
  String get toolbox_cleanGroupUpload => 'Upload Cache';

  @override
  String get toolbox_cleanGroupDownload => 'Download Cache';

  @override
  String get toolbox_cleanGroupSystemLog => 'System Logs';

  @override
  String get toolbox_cleanGroupContainer => 'Container Cache';

  @override
  String get websites_groupCreated => 'Group created';

  @override
  String get websites_groupUpdated => 'Group updated';

  @override
  String get websites_groupDeleted => 'Group deleted';

  @override
  String get websites_groupNameRequired => 'Enter a group name';

  @override
  String get common_edit => 'Edit';

  @override
  String get websites_groupManagement => 'Group Management';

  @override
  String get websites_groupName => 'Group Name';

  @override
  String get websites_groupSetDefault => 'Set as Default';

  @override
  String websites_groupDeleteConfirm(String name) {
    return 'Delete group \"$name\"? Websites in it will fall back to the default group.';
  }

  @override
  String get websites_groupEmpty => 'No groups';

  @override
  String supervisor_deleteConfirm(String name) {
    return 'Delete guarded process \"$name\"?';
  }

  @override
  String get supervisor_editProcess => 'Edit Guarded Process';

  @override
  String get supervisor_stateStarting => 'Starting';

  @override
  String get websites_groupSystemReserved =>
      'Reserved by 1Panel, cannot be deleted';

  @override
  String get panelSettings_webOnlyTag => 'Web panel only';

  @override
  String get alert_type_cpu => 'CPU';

  @override
  String get alert_type_memory => 'Memory';

  @override
  String get alert_type_disk => 'Disk';

  @override
  String get alert_type_load => 'Load';

  @override
  String get alert_type_network => 'Network';

  @override
  String get alert_type_smart => 'SMART';

  @override
  String get alert_type_log => 'Logs';

  @override
  String get alert_method_email => 'Email';

  @override
  String get alert_method_telegram => 'Telegram';

  @override
  String get alert_method_wecom => 'WeCom';

  @override
  String get alert_method_dingtalk => 'DingTalk';

  @override
  String get alert_method_feishu => 'Feishu';

  @override
  String get alert_method_bark => 'Bark';

  @override
  String get alert_method_webhook => 'Webhook';

  @override
  String get alert_method_sms => 'SMS';

  @override
  String get alert_status_success => 'Success';

  @override
  String get alert_status_failed => 'Failed';

  @override
  String get alert_status_pending => 'Pending';

  @override
  String get dashboard_collecting => 'Collecting…';

  @override
  String get toolbox_device_info => 'Device information';

  @override
  String get toolbox_actions => 'Actions';

  @override
  String get toolbox_readOnlyHint =>
      'Read-only data from the panel. Edit it in the 1Panel web UI.';

  @override
  String get app_detail_key => 'App key';

  @override
  String get app_detail_container => 'Container';

  @override
  String get app_detail_compose => 'Compose';

  @override
  String get app_detail_message => 'Message';

  @override
  String get server_edit_savedConnecting => 'Saved, connecting…';

  @override
  String get action_add => 'Add';

  @override
  String get firewall_tabRules => 'Rules';

  @override
  String get firewall_tabForward => 'Forwarding';

  @override
  String get firewall_tabDocker => 'Docker';

  @override
  String get firewall_tabSettings => 'Settings';

  @override
  String firewall_rulesCount(int count) {
    return 'Rules: $count';
  }

  @override
  String get firewall_searchHint => 'Search address, port or note';

  @override
  String get firewall_filterAll => 'All';

  @override
  String get firewall_filterIpv4 => 'IPv4';

  @override
  String get firewall_filterIpv6 => 'IPv6';

  @override
  String get firewall_filterAllow => 'Allow';

  @override
  String get firewall_filterDeny => 'Deny';

  @override
  String get firewall_anyAddress => 'Any address';

  @override
  String get firewall_anyPort => 'Any port';

  @override
  String firewall_ruleDeleteTitle(String name) {
    return 'Delete rule $name?';
  }

  @override
  String get firewall_ruleDeleteMessage =>
      'This rule will be removed from the panel firewall.';

  @override
  String get firewall_addForward => 'Add forwarding rule';

  @override
  String get firewall_editForward => 'Edit forwarding rule';

  @override
  String get firewall_forwardEmptyTitle => 'No forwarding rules';

  @override
  String get firewall_forwardEmptyMessage =>
      'Create a rule to forward a host port to an internal service.';

  @override
  String get firewall_forwardPort => 'Listen port';

  @override
  String get firewall_forwardTargetIp => 'Target IP';

  @override
  String get firewall_forwardTargetPort => 'Target port';

  @override
  String get firewall_forwardInterface => 'Interface (optional)';

  @override
  String get firewall_forwardEnabled => 'Forwarding enabled';

  @override
  String get firewall_enableForward => 'Enable forwarding';

  @override
  String get firewall_dockerGuard => 'Docker port guard';

  @override
  String get firewall_dockerGuardEnabled => 'Guard active';

  @override
  String get firewall_dockerGuardDisabled => 'Guard inactive';

  @override
  String get firewall_dockerGuardEmpty => 'No published container ports';

  @override
  String get firewall_dockerEndpoint => 'Container endpoint';

  @override
  String get firewall_settingsService => 'Service info';

  @override
  String get firewall_settingsBackend => 'Firewall backend';

  @override
  String get firewall_settingsVersion => 'Version';

  @override
  String get firewall_settingsIpv6 => 'IPv6';

  @override
  String get firewall_settingsIpv6Hint =>
      'Allow the panel to manage IPv6 rules';

  @override
  String get firewall_settingsWhitelist => 'Port whitelist';

  @override
  String get firewall_settingsPanelPort => 'Panel port';

  @override
  String get firewall_settingsSshPort => 'SSH port';

  @override
  String get firewall_whitelistAdd => 'Add whitelist port';

  @override
  String get firewall_whitelistPort => 'Port';

  @override
  String get firewall_whitelistProtocol => 'Protocol';

  @override
  String get firewall_whitelistSources => 'Allowed sources';

  @override
  String get firewall_whitelistSourcesHint => 'Comma separated, e.g. 0.0.0.0/0';

  @override
  String get firewall_ruleAddress => 'Source address';

  @override
  String get firewall_rulePort => 'Destination port';

  @override
  String get firewall_ruleProtocol => 'Protocol';

  @override
  String get firewall_ruleFamily => 'IP family';

  @override
  String get firewall_ruleStrategy => 'Action';

  @override
  String get firewall_ruleRemark => 'Note';

  @override
  String get firewall_ruleInterface => 'Interface';

  @override
  String get firewall_rulePortHint => '80, 8000-8100, or 80,443';

  @override
  String get firewall_ruleAddressHint => 'Leave empty for any address';

  @override
  String get firewall_ruleInvalidPort => 'Enter a valid port or port range';

  @override
  String get firewall_editRule => 'Edit rule';

  @override
  String get firewall_deleteRule => 'Delete rule';

  @override
  String get firewall_moveUp => 'Move up';

  @override
  String get firewall_moveDown => 'Move down';

  @override
  String get firewall_forwardRequired =>
      'Fill in listen port, target IP and target port';

  @override
  String get firewall_whitelistRequired =>
      'Fill in port and at least one source';

  @override
  String get websites_start => 'Start website';

  @override
  String get websites_stop => 'Stop website';

  @override
  String get websites_delete => 'Delete website';

  @override
  String get websites_copyDomain => 'Copy domain';

  @override
  String get websites_open => 'Open website';

  @override
  String websites_deleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get websites_deleteMessage =>
      'Website files, Nginx configuration and SSL certificates will be deleted. This cannot be undone.';

  @override
  String websites_deleteDatabaseCount(int count) {
    return 'Also delete $count linked database(s)';
  }

  @override
  String get websites_deleteBackup => 'Also delete website backups';

  @override
  String get websites_forceDelete => 'Force delete and ignore errors';

  @override
  String get websites_deleted => 'Website deleted';

  @override
  String get websites_started => 'Website started';

  @override
  String get websites_actions => 'Website actions';

  @override
  String get containers_create => 'Create container';

  @override
  String get containers_image => 'Image';

  @override
  String get containers_name => 'Name';

  @override
  String get containers_ports => 'Port mappings';

  @override
  String get containers_storageVolumes => 'Storage volumes';

  @override
  String get containers_volumes => 'Volumes';

  @override
  String get containers_env => 'Environment';

  @override
  String get containers_advanced => 'Advanced';

  @override
  String get containers_add => 'Add';

  @override
  String get containers_hostPort => 'Host port';

  @override
  String get containers_containerPort => 'Container port';

  @override
  String get containers_sourceDir => 'Host path';

  @override
  String get containers_containerDir => 'Container path';

  @override
  String get containers_envHint => 'KEY=VALUE';

  @override
  String get containers_createSubmit => 'Create container';

  @override
  String get containers_nameInvalid =>
      'Use letters, numbers, dots, dashes or underscores';

  @override
  String get containers_imageRequired => 'Select or enter an image';

  @override
  String get containers_nameRequired => 'Enter a container name';

  @override
  String get containers_selectImage => 'Select image';

  @override
  String get containers_manualInput => 'Enter manually';

  @override
  String get containers_noImages => 'No local images';

  @override
  String get containers_created => 'Container created';

  @override
  String get containers_removeRow => 'Remove';

  @override
  String get containers_cpuLimit => 'CPU limit';

  @override
  String get containers_memoryLimit => 'Memory limit (MB)';

  @override
  String get containers_autoRemove => 'Auto remove';

  @override
  String get containers_privileged => 'Privileged';

  @override
  String get containers_restartPolicyHint => 'unless-stopped';

  @override
  String get containers_cmdHint => 'Command, space separated';

  @override
  String get containers_entrypointHint => 'Entrypoint, space separated';

  @override
  String get containers_workingDirHint => '/usr/share/nginx/html';

  @override
  String get containers_network => 'Network';

  @override
  String get containers_defaultNetwork => '1panel-network';

  @override
  String get containers_advancedHint =>
      'Command, entrypoint, working directory, network and limits';

  @override
  String get action_restart => 'Restart';

  @override
  String get system_restartPanel => 'Restart panel';

  @override
  String get system_restartPanelSubtitle => 'Only the panel service restarts';

  @override
  String get system_restartPanelMessage =>
      'The panel will restart in a few seconds. The connection may drop for 10 to 30 seconds.';

  @override
  String get system_restartServer => 'Restart server';

  @override
  String get system_restartServerSubtitle => 'All services will be interrupted';

  @override
  String get system_restartServerMessage =>
      'The server will reboot immediately. All services stop and the connection usually recovers in 10 to 30 seconds.';

  @override
  String get system_restartSubmitted =>
      'Restart requested. The connection may drop briefly.';

  @override
  String get databases_create => 'Create database';

  @override
  String get databases_createType => 'Choose database type';

  @override
  String get databases_databaseName => 'Database name';

  @override
  String get databases_instance => 'Instance';

  @override
  String get databases_noInstance =>
      'No installed instance of this type. Install it from the app store first.';

  @override
  String get databases_charset => 'Character set';

  @override
  String get databases_collation => 'Collation';

  @override
  String get databases_template => 'Template database';

  @override
  String get databases_host => 'Allowed host';

  @override
  String get databases_hostHint => '% for any host, or a specific IP';

  @override
  String get databases_superUser => 'Superuser';

  @override
  String get databases_permission => 'Permission';

  @override
  String get databases_permissionRead => 'Read only';

  @override
  String get databases_permissionReadWrite => 'Read and write';

  @override
  String get databases_permissionDbOwner => 'Database owner';

  @override
  String get databases_permissionUserAdmin => 'User admin';

  @override
  String get databases_nameRequired => 'Enter a database name';

  @override
  String get databases_usernameRequired => 'Enter a username';

  @override
  String get databases_passwordRequired => 'Enter a password';

  @override
  String get databases_created => 'Database created';

  @override
  String get databases_usersGrants => 'Users and grants';

  @override
  String get databases_addUser => 'Add user';

  @override
  String get databases_bindUser => 'Bind user';

  @override
  String get databases_noUsers => 'No users';

  @override
  String get databases_userHost => 'Allowed from';

  @override
  String get databases_deleteUser => 'Delete user';

  @override
  String get databases_grant => 'Grant access';

  @override
  String get databases_grantDatabase => 'Database to grant';

  @override
  String get databases_revoke => 'Revoke access';

  @override
  String get databases_permissionUpdated => 'Permission updated';

  @override
  String get databases_redisRemote => 'Redis connection';

  @override
  String get databases_redisHint =>
      'Local Redis is installed as an app. This form registers a remote Redis connection.';

  @override
  String get databases_normalUser => 'Normal user';

  @override
  String get databases_description => 'Description';

  @override
  String get databases_userDescription => 'User description';

  @override
  String get databases_userCreated => 'User created';

  @override
  String get databases_grantedDatabases => 'Granted databases';

  @override
  String get databases_noGrants => 'No granted databases';

  @override
  String get files_permission => 'Permission';

  @override
  String get files_permissionOwner => 'Owner';

  @override
  String get files_permissionGroup => 'Group';

  @override
  String get files_permissionPublic => 'Public';

  @override
  String get files_permissionRead => 'Read';

  @override
  String get files_permissionWrite => 'Write';

  @override
  String get files_permissionExecute => 'Execute';

  @override
  String get files_permissionMode => 'Mode';

  @override
  String get files_permissionUser => 'User';

  @override
  String get files_permissionGroupName => 'Group name';

  @override
  String get files_permissionUpdated => 'Permission updated';

  @override
  String files_selectCount(int count) {
    return '$count selected';
  }

  @override
  String get files_selectAll => 'Select all';

  @override
  String get files_cancelSelection => 'Cancel';

  @override
  String get files_batchDelete => 'Delete selected';

  @override
  String files_batchDeleteMessage(int count) {
    return 'Delete $count selected items?';
  }

  @override
  String get files_calculateSize => 'Calculate size';

  @override
  String files_sizeCalculated(String size) {
    return 'Size: $size';
  }

  @override
  String get files_history => 'History';

  @override
  String get files_historyEmpty => 'No history versions';

  @override
  String get files_historyRestore => 'Restore';

  @override
  String get files_historyRestoreConfirm =>
      'Restore this version? The current file content will be replaced.';

  @override
  String get files_historyDelete => 'Delete version';

  @override
  String get files_historyRestored => 'Version restored';

  @override
  String get files_moreActions => 'More actions';

  @override
  String get host_title => 'Host';

  @override
  String get host_monitor => 'Monitoring';

  @override
  String get host_cleanSshLog => 'Clean SSH logs';

  @override
  String get dashboard_cleanMonitor => 'Clean monitor data';

  @override
  String get dashboard_cleanMonitorConfirm =>
      'Collected monitoring data will be deleted. Continue?';

  @override
  String get host_ssh => 'SSH';

  @override
  String get host_range1h => '1h';

  @override
  String get host_range6h => '6h';

  @override
  String get host_range24h => '24h';

  @override
  String get host_cpu => 'CPU';

  @override
  String get host_memory => 'Memory';

  @override
  String get host_load => 'Load';

  @override
  String get host_sshPort => 'SSH port';

  @override
  String get host_rootLogin => 'Root login';

  @override
  String get host_passwordAuth => 'Password login';

  @override
  String get host_pubkeyAuth => 'Public key login';

  @override
  String get host_sshStatus => 'SSH service';

  @override
  String get host_sshUpdated => 'SSH configuration updated';

  @override
  String get host_monitorEmpty => 'No monitoring data yet';

  @override
  String get host_monitorEmptyHint =>
      'Data appears after the first monitoring interval.';

  @override
  String get runtime_detail => 'Runtime';

  @override
  String get runtime_extensions => 'Extensions';

  @override
  String get runtime_phpIni => 'php.ini';

  @override
  String get runtime_fpm => 'FPM';

  @override
  String get runtime_modules => 'Modules';

  @override
  String get runtime_install => 'Install';

  @override
  String get runtime_uninstall => 'Uninstall';

  @override
  String get runtime_update => 'Update';

  @override
  String get runtime_installed => 'Installed';

  @override
  String get runtime_notInstalled => 'Not installed';

  @override
  String get runtime_moduleHint => 'Package name';

  @override
  String get runtime_restartPhpHint =>
      'Restart PHP for changes to take effect.';

  @override
  String get runtime_saved => 'Saved';

  @override
  String get toolbox_group_system => 'System';

  @override
  String get toolbox_group_security => 'Security';

  @override
  String get toolbox_group_service => 'Services';

  @override
  String get toolbox_group_maintenance => 'Maintenance';

  @override
  String get toolbox_time => 'Time and timezone';

  @override
  String get toolbox_swapDns => 'Swap and DNS';

  @override
  String get toolbox_clam => 'ClamAV';

  @override
  String get toolbox_fail2ban => 'Fail2ban';

  @override
  String get toolbox_ftp => 'FTP accounts';

  @override
  String get toolbox_timezone => 'Timezone';

  @override
  String get toolbox_dns => 'DNS';

  @override
  String get toolbox_swap => 'Swap';

  @override
  String get toolbox_addSwap => 'Add swap';

  @override
  String get toolbox_swapPath => 'Swap file path';

  @override
  String get toolbox_swapSize => 'Size (MB)';

  @override
  String get toolbox_sshBan => 'Banned IPs';

  @override
  String get toolbox_unban => 'Unban';

  @override
  String get toolbox_sshProtection => 'SSH protection';

  @override
  String get toolbox_ftpAdd => 'Add FTP account';

  @override
  String get toolbox_ftpUser => 'FTP user';

  @override
  String get toolbox_ftpPassword => 'FTP password';

  @override
  String get toolbox_ftpPath => 'FTP root path';

  @override
  String get toolbox_scanPath => 'Scan path';

  @override
  String get toolbox_scanName => 'Scan name';

  @override
  String get toolbox_startScan => 'Start scan';

  @override
  String get toolbox_stopScan => 'Stop scan';

  @override
  String get toolbox_scanRecords => 'Scan tasks';

  @override
  String get toolbox_noScans => 'No scan tasks';

  @override
  String get server_edit_diag_failed => 'Check failed';

  @override
  String get host_monitorSettings => 'Monitor settings';

  @override
  String get host_monitorInterval => 'Interval (seconds)';

  @override
  String get host_monitorStoreDays => 'Retention (days)';

  @override
  String get host_monitorEnabled => 'Monitoring enabled';

  @override
  String get host_sshKeys => 'SSH keys';

  @override
  String get host_generateKey => 'Generate key';

  @override
  String get host_keyName => 'Key name';

  @override
  String get host_keyType => 'Key type';

  @override
  String get host_keyPassphrase => 'Passphrase';

  @override
  String get host_keyGenerated => 'SSH key generated';

  @override
  String get host_deleteKey => 'Delete key';

  @override
  String get host_publicKey => 'Public key';

  @override
  String get toolbox_clamRecords => 'Scan results';

  @override
  String get toolbox_clamNoRecords => 'No scan results';

  @override
  String get runtime_fpmConfig => 'FPM configuration';

  @override
  String get runtime_pm => 'Process manager';

  @override
  String get runtime_maxChildren => 'Max children';

  @override
  String get runtime_startServers => 'Start servers';

  @override
  String get runtime_minSpare => 'Min spare servers';

  @override
  String get runtime_maxSpare => 'Max spare servers';

  @override
  String get host_disks => 'Disks';

  @override
  String get host_diagnostics => 'Diagnostics';

  @override
  String get host_remoteHosts => 'Remote hosts';

  @override
  String get host_addRemote => 'Add remote host';

  @override
  String get host_noRemote => 'No remote hosts';

  @override
  String get host_noRemoteHint => 'Remote hosts can be used from the terminal.';

  @override
  String get host_remoteName => 'Name';

  @override
  String get host_address => 'Address';

  @override
  String get host_port => 'Port';

  @override
  String get host_user => 'User';

  @override
  String get host_authMode => 'Authentication';

  @override
  String get host_authPassword => 'Password';

  @override
  String get host_authKey => 'Private key';

  @override
  String get host_password => 'Password';

  @override
  String get host_privateKey => 'Private key';

  @override
  String get host_passphrase => 'Key passphrase';

  @override
  String get host_rememberPassword => 'Remember password';

  @override
  String get host_description => 'Description';

  @override
  String get host_group => 'Group';

  @override
  String get host_noGroup => 'No group';

  @override
  String get host_testConnection => 'Test connection';

  @override
  String get host_connectionOk => 'Connection succeeded';

  @override
  String get host_connectionFailed => 'Connection failed';

  @override
  String get host_deleteRemote => 'Delete remote host';

  @override
  String host_deleteRemoteMessage(String name) {
    return 'Delete $name?';
  }

  @override
  String get host_remoteSaved => 'Remote host saved';

  @override
  String get action_test => 'Test';

  @override
  String get host_diskSystem => 'System disks';

  @override
  String get host_diskUnpartitioned => 'Unpartitioned disks';

  @override
  String get host_diskNormal => 'Data disks';

  @override
  String get host_diskPartitions => 'Partitions';

  @override
  String get host_diskFilesystem => 'Filesystem';

  @override
  String get host_diskUsed => 'Used';

  @override
  String get host_diskAvail => 'Available';

  @override
  String get host_diskMountPoint => 'Mount point';

  @override
  String get host_diskUnmounted => 'Not mounted';

  @override
  String get host_diskSystemHint =>
      'System disk partitions are read-only here.';

  @override
  String get host_diskPartition => 'Partition';

  @override
  String get host_diskMount => 'Mount';

  @override
  String get host_diskUnmount => 'Unmount';

  @override
  String get host_diskAutoMount => 'Mount on boot';

  @override
  String get host_diskNoFail => 'Allow boot without disk';

  @override
  String get host_diskMountPointField => 'Mount point path';

  @override
  String get host_diskLabel => 'Volume label';

  @override
  String get host_diskActionDone => 'Disk operation completed';

  @override
  String get host_diskPartitionWarning =>
      'Partitioning erases data on this disk. Continue only with a disk you can rebuild.';

  @override
  String get host_diagSummary => 'Runtime summary';

  @override
  String get host_diagRss => 'Resident memory';

  @override
  String get host_diagHeap => 'Heap in use';

  @override
  String get host_diagObjects => 'Heap objects';

  @override
  String get host_diagGoroutines => 'Goroutines';

  @override
  String get host_diagSnapshot => 'Goroutine snapshot';

  @override
  String get host_diagCapturedAt => 'Captured at';

  @override
  String get host_diagTotal => 'Total';

  @override
  String get host_diagGroups => 'Groups';

  @override
  String get host_diagTruncated => 'Snapshot was truncated by the panel.';

  @override
  String get host_diagStack => 'Call stack';

  @override
  String get toolbox_fail2banBase => 'Basic rules';

  @override
  String get toolbox_maxRetry => 'Max retries';

  @override
  String get toolbox_banTime => 'Ban duration';

  @override
  String get toolbox_findTime => 'Detection window';

  @override
  String get toolbox_banAction => 'Ban action';

  @override
  String get toolbox_logPath => 'Log path';

  @override
  String get toolbox_durationHint =>
      'Use a value with unit, for example 300s, 10m, 1h or -1.';

  @override
  String get toolbox_fail2banChanged => 'Update Fail2ban rule';

  @override
  String get host_diagCapture => 'Manual capture';

  @override
  String get host_diagProfileType => 'Profile type';

  @override
  String get host_diagProfileCpu => 'CPU profile';

  @override
  String get host_diagProfileHeap => 'Heap profile';

  @override
  String get host_diagProfileGoroutine => 'Goroutine profile';

  @override
  String get host_diagProfileMutex => 'Mutex profile';

  @override
  String get host_diagProfileBlock => 'Block profile';

  @override
  String get host_diagDuration => 'Duration (seconds)';

  @override
  String get host_diagStartCapture => 'Start capture';

  @override
  String get host_diagProfileSaved => 'Profile saved';

  @override
  String get host_diagComponent => 'Component check';

  @override
  String get host_diagComponentName => 'Component name';

  @override
  String get host_diagCheck => 'Check';

  @override
  String get host_diagComponentExists => 'Status';

  @override
  String get host_diagComponentPath => 'Path';

  @override
  String get host_diagComponentMissing => 'Executable not found';

  @override
  String get websites_loadBalance => 'Load balancing';

  @override
  String get websites_lbAdd => 'Add upstream';

  @override
  String get websites_lbEmpty => 'No upstreams yet';

  @override
  String get websites_lbName => 'Upstream name';

  @override
  String get websites_lbAlgorithm => 'Algorithm';

  @override
  String get websites_lbDefault => 'Default (round robin)';

  @override
  String get websites_lbIpHash => 'IP hash';

  @override
  String get websites_lbLeastConn => 'Least connections';

  @override
  String get websites_lbServers => 'Servers';

  @override
  String get websites_lbAddServer => 'Add server';

  @override
  String get websites_lbServerAddress => 'Server address';

  @override
  String get websites_lbWeight => 'Weight';

  @override
  String get websites_lbFlag => 'Status';

  @override
  String get websites_lbFlagNone => 'Enabled';

  @override
  String get websites_lbFlagDown => 'Down';

  @override
  String get websites_lbFlagBackup => 'Backup';

  @override
  String get websites_lbMaxFails => 'Max failures';

  @override
  String get websites_lbFailTimeout => 'Fail timeout';

  @override
  String get websites_lbMaxConns => 'Max connections';

  @override
  String get websites_lbDelete => 'Delete upstream';

  @override
  String get websites_lbSaved => 'Load balancing saved';

  @override
  String get websites_templates => 'Website templates';

  @override
  String get websites_templateAdd => 'New template';

  @override
  String get websites_templateEdit => 'Edit template';

  @override
  String get websites_templateEmpty =>
      'Save a site configuration as a template and reuse it next time';

  @override
  String get websites_templateName => 'Template name';

  @override
  String get websites_templateType => 'Template type';

  @override
  String get websites_templateSingle => 'Single page';

  @override
  String get websites_templateMulti => 'Multi-file';

  @override
  String get websites_templateContent => 'HTML content';

  @override
  String get websites_templateUpload => 'Upload ZIP';

  @override
  String get websites_templateUploaded => 'Template uploaded';

  @override
  String get websites_templateFilePath => 'Template package';

  @override
  String get websites_templateRemark => 'Remark';

  @override
  String get websites_templateVariables => 'Template variables';

  @override
  String get websites_templateAddVariable => 'Add variable';

  @override
  String get websites_templateVariableKey => 'Key';

  @override
  String get websites_templateVariableLabel => 'Label';

  @override
  String get websites_templateVariableType => 'Type';

  @override
  String get websites_templateVariableDefault => 'Default value';

  @override
  String get websites_templateVariableOptions => 'Options';

  @override
  String get websites_templateVariableRequired => 'Required';

  @override
  String get websites_templateAutoDetect => 'Detect variables';

  @override
  String get websites_templateSaved => 'Template saved';

  @override
  String get websites_templateDelete => 'Delete template';

  @override
  String get websites_templateGenerate => 'Generate';

  @override
  String get websites_templateOutputs => 'Generated websites';

  @override
  String get websites_templateOutputName => 'Output name';

  @override
  String get websites_templateOutputEmpty => 'No generated websites';

  @override
  String get websites_templateOutputGenerated => 'Website generated';

  @override
  String get websites_templateOutputDelete => 'Delete generated website';

  @override
  String get websites_templateNoVariables => 'No variables';

  @override
  String get websites_templateVariableTypeText => 'Text';

  @override
  String get websites_templateVariableTypeTextarea => 'Long text';

  @override
  String get websites_templateVariableTypeNumber => 'Number';

  @override
  String get websites_templateVariableTypeSelect => 'Select';

  @override
  String get websites_templateVariableTypeColor => 'Color';

  @override
  String get files_aiSearch => 'AI search';

  @override
  String get files_aiQuery => 'Search content';

  @override
  String get files_aiQueryHint => 'Text to find in file contents';

  @override
  String get files_aiContainSub => 'Include subdirectories';

  @override
  String get files_aiMatchCase => 'Match case';

  @override
  String get files_aiWholeWord => 'Whole word';

  @override
  String get files_aiUseRegex => 'Use regular expression';

  @override
  String get files_aiGrepMode =>
      'AI is not enabled on the panel. Showing content matches only.';

  @override
  String get files_aiSummary => 'AI summary';

  @override
  String get files_aiHits => 'Matches';

  @override
  String get files_aiScanned => 'Files scanned';

  @override
  String get files_aiTokens => 'Tokens';

  @override
  String get files_aiDuration => 'Duration';

  @override
  String get files_aiTruncated => 'Results were truncated by the panel.';

  @override
  String get files_aiEmpty => 'No matching content';

  @override
  String get files_aiLine => 'Line';

  @override
  String get terminal_sessions => 'Terminal sessions';

  @override
  String get terminal_sessionsEmpty => 'No terminal sessions';

  @override
  String get terminal_sessionAttached => 'Attached';

  @override
  String get terminal_sessionDetached => 'Detached';

  @override
  String get terminal_closeSession => 'Close';

  @override
  String get terminal_closeAllSessions => 'Close all';

  @override
  String get terminal_closeAllConfirm =>
      'All terminal sessions will be disconnected and cannot be recovered.';

  @override
  String get terminal_kindLocal => 'Local';

  @override
  String get terminal_kindSsh => 'SSH';

  @override
  String get terminal_kindContainer => 'Container';

  @override
  String get files_uploading => 'Uploading';

  @override
  String get files_uploadPaused => 'Paused';

  @override
  String get files_uploadPause => 'Pause';

  @override
  String get files_uploadResume => 'Resume';

  @override
  String get files_uploadFailed => 'Upload failed';

  @override
  String get toolbox_infectedStrategy => 'Infected file handling';

  @override
  String get toolbox_infectedNone => 'Take no action';

  @override
  String get toolbox_infectedRemove => 'Delete';

  @override
  String get toolbox_infectedMove => 'Move';

  @override
  String get toolbox_infectedCopy => 'Copy';

  @override
  String get toolbox_infectedDir => 'Infected directory';

  @override
  String get toolbox_infectedDirRequired => 'Enter an infected directory';

  @override
  String get firewall_whitelistEdit => 'Edit whitelist rule';

  @override
  String get firewall_backendUnavailable => 'No selectable backend';

  @override
  String get action_switch => 'Switch';

  @override
  String get firewall_resetRules => 'Reset rules';

  @override
  String get firewall_resetRulesMessage =>
      'Managed firewall rules will be reset. Continue?';

  @override
  String get firewall_restoreBackup => 'Restore backup';

  @override
  String firewall_restoreBackupMessage(String name) {
    return 'Restore rules from backup $name?';
  }

  @override
  String get firewall_nativeDetail => 'Native rule detail';

  @override
  String get firewall_nativeDetailHint =>
      'Read the native firewalld or ufw definition';

  @override
  String get firewall_ruleBackups => 'Rule backups';

  @override
  String get firewall_noBackups => 'No rule backups';

  @override
  String get firewall_nativeNameRequired => 'Enter a native rule name';

  @override
  String get firewall_nativeKind => 'Native kind';

  @override
  String get firewall_nativeZoneService => 'Zone service';

  @override
  String get firewall_nativeUfwApplication => 'UFW application';

  @override
  String get firewall_nativeName => 'Native name';

  @override
  String get firewall_nativePermanent => 'Permanent';

  @override
  String get firewall_nativeLoad => 'Load native detail';

  @override
  String get firewall_settingsBackendHint =>
      'Tap to switch the managed backend';

  @override
  String get firewall_backendSystem => 'System rules';

  @override
  String get firewall_backendForwarding => 'Port forwarding';

  @override
  String get firewall_backendDocker => 'Docker rules';

  @override
  String get firewall_advanced => 'Advanced actions';

  @override
  String get firewall_familyOperation => 'Initialize or repair firewall family';

  @override
  String get firewall_familyOperationHint =>
      'Initialize, repair or bind a subsystem for IPv4 or IPv6';

  @override
  String get firewall_filterChain => 'Base chain operations';

  @override
  String get firewall_filterChainHint =>
      'Initialize, bind or unbind the 1PANEL_BASIC chain';

  @override
  String get firewall_subsystem => 'Subsystem';

  @override
  String get firewall_family => 'Family';

  @override
  String get firewall_operation => 'Operation';

  @override
  String get firewall_subsystemSystem => 'System rules';

  @override
  String get firewall_subsystemForwarding => 'Port forwarding';

  @override
  String get firewall_subsystemDocker => 'Docker rules';

  @override
  String get firewall_operationInitialize => 'Initialize';

  @override
  String get firewall_operationRepair => 'Repair';

  @override
  String get firewall_operationBind => 'Bind';

  @override
  String get firewall_filterInit => 'Initialize base chain';

  @override
  String get firewall_filterBind => 'Bind base chain';

  @override
  String get firewall_filterUnbind => 'Unbind base chain';

  @override
  String get firewall_dockerPolicy => 'Port guard policy';

  @override
  String get firewall_dockerPolicyHint =>
      'Restrict sources for a published container port';

  @override
  String get firewall_dockerMode => 'Policy mode';

  @override
  String get firewall_dockerSources => 'Source addresses';

  @override
  String get firewall_dockerSourcesHint =>
      'Separate multiple addresses with commas';

  @override
  String get firewall_dockerPolicySaved => 'Port guard policy saved';

  @override
  String get firewall_dockerPolicyDeleted => 'Port guard policy deleted';

  @override
  String get firewall_dockerModeDenySources => 'Deny specified sources';

  @override
  String get firewall_dockerModeAllowSources => 'Allow only specified sources';

  @override
  String get firewall_dockerModeDenyAll => 'Deny all sources';

  @override
  String get firewall_dockerModeAcceptSources => 'Accept specified sources';

  @override
  String get firewall_dockerModeAcceptAll => 'Accept all sources';

  @override
  String get host_sshCheckFailed =>
      'Local SSH connection check failed. Save cancelled.';

  @override
  String get host_sshCheckAfterSave =>
      'SSH port saved, but the local connection check still fails. Verify the new port.';

  @override
  String get containers_creating => 'Creating container…';

  @override
  String get host_sshValueOn => 'On';

  @override
  String get host_sshValueOff => 'Off';

  @override
  String get host_sshValueKeyOnly => 'Key only';

  @override
  String get host_sshValuePasswordForbidden => 'Password disabled';

  @override
  String get toolbox_stopped => 'Stopped';

  @override
  String get toolbox_notInstalledHint =>
      'Fail2ban is not installed. Install it from the panel app store first.';

  @override
  String get dashboard_networkTrend => 'Network trend (last 5 minutes)';

  @override
  String get dashboard_networkCollectHint =>
      'The curve appears after 3 samples are collected.';

  @override
  String get websites_openFailed => 'Failed to open the website';

  @override
  String get task_failedTitle => 'Task failed';

  @override
  String get task_timeoutTitle => 'Task timed out';

  @override
  String get task_failedNoDetail => 'Check the panel logs for details.';

  @override
  String get task_timeoutMessage =>
      'The task is still running. Refresh the list later.';

  @override
  String get firewall_whitelist => 'Whitelist';

  @override
  String get containers_continueInBackground => 'Continue in background';

  @override
  String get files_folder => 'Folder';

  @override
  String get task_runningHint => 'Running…';

  @override
  String get containers_groupMaintenance => 'Maintenance';

  @override
  String get containers_viewLogs => 'View logs';

  @override
  String get containers_liveMonitor => 'Live monitor';

  @override
  String get containers_groupLifecycle => 'Lifecycle';

  @override
  String get containers_resume => 'Resume';

  @override
  String get containers_kill => 'Force stop';

  @override
  String get containers_groupConfig => 'Configuration';

  @override
  String get containers_edit => 'Edit container';

  @override
  String get containers_editSubtitle =>
      'Change image, ports, volumes and limits';

  @override
  String get containers_upgrade => 'Upgrade container';

  @override
  String get containers_upgradeSubtitle => 'Recreate with a newer image';

  @override
  String get containers_commit => 'Commit as image';

  @override
  String get containers_commitSubtitle =>
      'Save the current container as an image';

  @override
  String get containers_groupDanger => 'Danger zone';

  @override
  String get containers_remove => 'Delete container';

  @override
  String get containers_removeSubtitle => 'Stop and remove this container';

  @override
  String get containers_forcePull => 'Always pull the latest image';

  @override
  String get containers_newImageName => 'New image name';

  @override
  String get containers_commitComment => 'Comment';

  @override
  String get containers_commitAuthor => 'Author';

  @override
  String get containers_pauseDuringCommit =>
      'Pause the container while committing';

  @override
  String get containers_logsEmpty => 'No log output in the last hour';

  @override
  String get containers_cache => 'Cache';

  @override
  String get containers_diskRead => 'Disk read';

  @override
  String get containers_diskWrite => 'Disk write';

  @override
  String get containers_networkRX => 'Network received';

  @override
  String get containers_networkTX => 'Network sent';

  @override
  String get containers_updated => 'Container updated';

  @override
  String get containers_saving => 'Saving…';

  @override
  String get containers_prune => 'Prune unused containers';

  @override
  String get containers_pruneConfirm =>
      'Unused stopped containers and build cache will be removed. Running containers stay intact.';

  @override
  String get containers_removeTitle => 'Delete container';

  @override
  String containers_removeMessage(String name) {
    return 'This permanently deletes $name and its writable layer. Mounted data remains on disk.';
  }

  @override
  String get cronjobs_create => 'Create scheduled task';

  @override
  String get cronjobs_edit => 'Edit scheduled task';

  @override
  String get cronjobs_updated => 'Scheduled task updated';

  @override
  String get cronjobs_created => 'Scheduled task created';

  @override
  String get cronjobs_saving => 'Saving…';

  @override
  String get cronjobs_name => 'Task name';

  @override
  String get cronjobs_type => 'Task type';

  @override
  String get cronjobs_spec => 'Cron expression';

  @override
  String get cronjobs_specHint => 'Five-field cron, or @every 10m';

  @override
  String get cronjobs_basic => 'Basic information';

  @override
  String get cronjobs_taskConfig => 'Task configuration';

  @override
  String get cronjobs_execution => 'Execution policy';

  @override
  String get cronjobs_script => 'Shell script';

  @override
  String get cronjobs_logFiles => 'Log files';

  @override
  String get cronjobs_logFilesHint => 'Comma-separated absolute paths';

  @override
  String get cronjobs_url => 'Request URL';

  @override
  String get cronjobs_urlHeader => 'User-Agent';

  @override
  String get cronjobs_website => 'Website';

  @override
  String get cronjobs_databaseType => 'Database type';

  @override
  String get cronjobs_databaseName => 'Database name';

  @override
  String get cronjobs_directory => 'Directory';

  @override
  String get cronjobs_files => 'Files';

  @override
  String get cronjobs_backupDirectory => 'Back up a directory';

  @override
  String get cronjobs_app => 'App install ID';

  @override
  String get cronjobs_withImage => 'Include container images';

  @override
  String get cronjobs_scopes => 'Log scopes';

  @override
  String get cronjobs_scopesHint => 'Comma-separated, for example system,ssh';

  @override
  String get cronjobs_ntpHint =>
      'Synchronize the system clock with the configured time source.';

  @override
  String get cronjobs_cleanHint =>
      'Clean temporary files and caches created by the panel.';

  @override
  String get cronjobs_retainCopies => 'Retained copies';

  @override
  String get cronjobs_retryTimes => 'Retry times';

  @override
  String get cronjobs_timeout => 'Timeout (seconds)';

  @override
  String get cronjobs_timeoutHint => '0 means no timeout';

  @override
  String get cronjobs_nameRequired => 'Enter a task name';

  @override
  String get cronjobs_specRequired => 'Enter a cron expression';

  @override
  String get cronjobs_scriptRequired => 'Enter a shell script';

  @override
  String get cronjobs_urlRequired => 'Enter a request URL';

  @override
  String get cronjobs_enabled => 'Enabled';

  @override
  String get cronjobs_disabled => 'Disabled';

  @override
  String get cronjobs_actions => 'Task actions';

  @override
  String get cronjobs_stopRunning => 'Stop running task';

  @override
  String get cronjobs_records => 'Execution records';

  @override
  String get cronjobs_cleanRecords => 'Clean records';

  @override
  String cronjobs_cleanRecordsConfirm(String name) {
    return 'Delete every execution record of $name?';
  }

  @override
  String cronjobs_recordsRange(int days) {
    return 'Last $days days';
  }

  @override
  String cronjobs_recordsTotal(int count) {
    return '$count records';
  }

  @override
  String get containers_diskStatsUnsupported =>
      'Disk usage is unavailable on this panel version.';

  @override
  String get cronjobs_noRecords => 'No execution records';

  @override
  String get cronjobs_noRecordsHint => 'Records appear after the task runs.';

  @override
  String get cronjobs_recordLog => 'Execution log';

  @override
  String get cronjobs_recordLogEmpty => 'This record has no log output.';

  @override
  String cronjobs_deleteTitle(String name) {
    return 'Delete $name';
  }

  @override
  String get cronjobs_deleteMessage =>
      'The scheduled task and its records will be removed.';

  @override
  String get cronjobs_typeShell => 'Shell script';

  @override
  String get cronjobs_typeLog => 'Split logs';

  @override
  String get cronjobs_typeCurl => 'Access URL';

  @override
  String get cronjobs_typeWebsite => 'Back up website';

  @override
  String get cronjobs_typeDatabase => 'Back up database';

  @override
  String get cronjobs_typeDirectory => 'Back up directory';

  @override
  String get cronjobs_typeApp => 'Back up app';

  @override
  String get cronjobs_typeSnapshot => 'Snapshot';

  @override
  String get cronjobs_typeCleanLog => 'Clean panel logs';

  @override
  String get cronjobs_typeClean => 'Clean garbage';

  @override
  String get cronjobs_typeNtp => 'Sync time';

  @override
  String get alerts_create => 'Create alert rule';

  @override
  String get alerts_edit => 'Edit alert rule';

  @override
  String get alerts_updated => 'Alert rule updated';

  @override
  String get alerts_created => 'Alert rule created';

  @override
  String get alerts_saving => 'Saving…';

  @override
  String get alerts_rule => 'Rule';

  @override
  String get alerts_type => 'Alert type';

  @override
  String get alerts_title => 'Title';

  @override
  String get alerts_titleHint => 'Leave empty to use the type name';

  @override
  String get alerts_project => 'Target';

  @override
  String get alerts_projectHint => 'Website ID, disk path, or all';

  @override
  String get alerts_threshold => 'Threshold';

  @override
  String get alerts_count => 'Trigger value';

  @override
  String get alerts_countHint => 'CPU, memory or load percentage';

  @override
  String get alerts_cycle => 'Cycle (days)';

  @override
  String get alerts_sendCount => 'Send limit per day';

  @override
  String get alerts_sendCountHint => 'Range 1-30';

  @override
  String get alerts_advancedParams => 'Advanced parameters';

  @override
  String get alerts_advancedParamsHint => 'Optional JSON or trigger mode';

  @override
  String get alerts_notification => 'Notification method';

  @override
  String get alerts_noConfigs =>
      'No enabled notification config. Add one on the panel first.';

  @override
  String get alerts_method => 'Notification config IDs';

  @override
  String get alerts_methodHint => 'Comma-separated config IDs';

  @override
  String get alerts_methodRequired => 'Select at least one notification method';

  @override
  String get alerts_typeCpu => 'CPU usage';

  @override
  String get alerts_typeMemory => 'Memory usage';

  @override
  String get alerts_typeDisk => 'Disk usage';

  @override
  String get alerts_typeLoad => 'Load average';

  @override
  String get alerts_typeSshLogin => 'SSH login';

  @override
  String get alerts_typePanelLogin => 'Panel login';

  @override
  String get alerts_typeSsl => 'Certificate expiry';

  @override
  String get alerts_typeSiteEndTime => 'Website expiry';

  @override
  String get alerts_typePanelUpdate => 'Panel update';

  @override
  String get containers_resources => 'Images and networks';

  @override
  String get containers_pullImage => 'Pull image';

  @override
  String get containers_createNetwork => 'Create network';

  @override
  String get containers_tagImage => 'Tag image';

  @override
  String get containers_inUse => 'In use';

  @override
  String get containers_unused => 'Unused';

  @override
  String get containers_imageInUseHint =>
      'Delete containers using this image first';

  @override
  String get containers_removeImage => 'Delete image';

  @override
  String containers_removeImageConfirm(String name) {
    return 'Delete image $name?';
  }

  @override
  String get containers_pullImageHint =>
      'Pull an image by name, or create a container to pull one.';

  @override
  String get containers_noNetworks => 'No networks';

  @override
  String get containers_createNetworkHint =>
      'Create a bridge network for your containers.';

  @override
  String get containers_removeNetwork => 'Delete network';

  @override
  String containers_removeNetworkConfirm(String name) {
    return 'Delete network $name?';
  }

  @override
  String get containers_system => 'System';

  @override
  String get containers_driver => 'Driver';

  @override
  String get containers_subnet => 'Subnet';

  @override
  String get containers_gateway => 'Gateway';

  @override
  String get containers_up => 'Start';

  @override
  String get containers_down => 'Take down';

  @override
  String get containers_rebuild => 'Rebuild';

  @override
  String get containers_createCompose => 'Create compose';

  @override
  String get containers_updateCompose => 'Edit compose';

  @override
  String get containers_composeLogs => 'Compose logs';

  @override
  String get containers_cleanComposeLogs => 'Clear compose logs';

  @override
  String get containers_deleteCompose => 'Delete compose';

  @override
  String containers_deleteComposeConfirm(String name) {
    return 'Delete compose project $name?';
  }

  @override
  String get containers_testCompose => 'Validate compose file';

  @override
  String get containers_composeValid => 'Compose file is valid';

  @override
  String get containers_composeInvalid => 'Compose file is invalid';

  @override
  String get containers_composeContentRequired =>
      'Enter the compose file content';

  @override
  String get containers_dockerfileRequired => 'Enter the Dockerfile content';

  @override
  String get containers_dockerSettings => 'Docker settings';

  @override
  String get containers_dockerService => 'Docker service';

  @override
  String get containers_dockerRunning => 'Docker is running';

  @override
  String get containers_dockerStopped => 'Docker is stopped';

  @override
  String get containers_logSettings => 'Log rotation';

  @override
  String get containers_logMaxSize => 'Max size';

  @override
  String get containers_logMaxFile => 'Max files';

  @override
  String get containers_ipv6 => 'IPv6';

  @override
  String get containers_fixedCidrV6 => 'Fixed CIDR';

  @override
  String get containers_ip6Tables => 'Manage ip6tables';

  @override
  String get containers_experimental => 'Experimental';

  @override
  String get cronjobs_notFound => 'Scheduled task not found';

  @override
  String get files_tools => 'File tools';

  @override
  String get files_favorites => 'Favorites';

  @override
  String get files_recycleBin => 'Recycle bin';

  @override
  String get files_shares => 'Shared links';

  @override
  String get files_remoteDownload => 'Remote download';

  @override
  String get files_noFavorites => 'No favorites';

  @override
  String get files_noFavoritesHint =>
      'Star a file or folder from its action sheet.';

  @override
  String get files_removeFavorite => 'Remove favorite';

  @override
  String get files_addFavorite => 'Add to favorites';

  @override
  String get files_favoriteAdded => 'Added to favorites';

  @override
  String get files_clearRecycleBin => 'Empty recycle bin';

  @override
  String get files_clearRecycleBinConfirm =>
      'All recycled files will be permanently deleted.';

  @override
  String get files_recycleEmpty => 'Recycle bin is empty';

  @override
  String get files_recycleEmptyHint => 'Deleted files will appear here.';

  @override
  String get files_restore => 'Restore';

  @override
  String get files_noShares => 'No shared links';

  @override
  String get files_noSharesHint => 'Create a share from a file action sheet.';

  @override
  String get files_permanentShare => 'Permanent';

  @override
  String files_shareCode(String code) {
    return 'Code $code';
  }

  @override
  String get files_cancelShare => 'Cancel share';

  @override
  String files_cancelShareConfirm(String name) {
    return 'Cancel the share for $name?';
  }

  @override
  String get files_shareDetail => 'Share details';

  @override
  String get files_name => 'Name';

  @override
  String get files_nameRequired => 'Enter a file name';

  @override
  String get files_path => 'Path';

  @override
  String get files_shareCodeLabel => 'Share code';

  @override
  String get files_sharePassword => 'Password';

  @override
  String get files_shareExpire => 'Expires';

  @override
  String get files_copyShareCode => 'Copy share code';

  @override
  String get files_remoteDownloadStarted => 'Remote download started';

  @override
  String get files_noRemoteDownloads => 'No active downloads';

  @override
  String get files_noRemoteDownloadsHint =>
      'Active remote downloads appear here.';

  @override
  String get files_url => 'URL';

  @override
  String get files_targetDirectory => 'Target directory';

  @override
  String get files_ignoreCertificate => 'Ignore certificate errors';

  @override
  String get files_startDownload => 'Start download';

  @override
  String get files_moveCopy => 'Move or copy';

  @override
  String get files_batchPermission => 'Batch permissions';

  @override
  String get files_convert => 'Convert format';

  @override
  String get files_convertFormat => 'Output format';

  @override
  String get files_convertOutput => 'Output directory';

  @override
  String get files_convertDeleteSource =>
      'Delete source files after conversion';

  @override
  String get files_convertStarted => 'Conversion task submitted';

  @override
  String get files_convertOnlyFiles =>
      'Only files can be converted, not directories';

  @override
  String get files_convertNoFile => 'Select files to convert first';

  @override
  String get files_uploadRecords => 'Upload records';

  @override
  String get files_noUploadRecords => 'No upload records';

  @override
  String get files_noUploadRecordsHint =>
      'Uploaded files in the current directory appear here.';

  @override
  String get files_convertLogs => 'Conversion records';

  @override
  String get files_noConvertLogs => 'No conversion records';

  @override
  String get files_noConvertLogsHint =>
      'Completed file conversions appear here.';

  @override
  String get files_removeDownloadRecord => 'Remove record';

  @override
  String get files_copyMode => 'Copy instead of move';

  @override
  String get files_overwrite => 'Overwrite existing files';

  @override
  String get files_copy => 'Copy';

  @override
  String get files_move => 'Move';

  @override
  String get files_recursive => 'Apply to subdirectories';

  @override
  String get action_stop => 'Stop';

  @override
  String get websites_advanced => 'Advanced settings';

  @override
  String get websites_security => 'Security';

  @override
  String get websites_rewrite => 'Rewrite';

  @override
  String get websites_redirect => 'Redirects';

  @override
  String get websites_editInfo => 'Edit website info';

  @override
  String get websites_favorite => 'Add to favorites';

  @override
  String get websites_indexConfig => 'Default documents';

  @override
  String get websites_indexConfigHint =>
      'Set the files served for directory requests';

  @override
  String get websites_limitConfig => 'Traffic limits';

  @override
  String get websites_limitConfigHint =>
      'Limit concurrent connections and rate';

  @override
  String get websites_dirPermission => 'Directory owner';

  @override
  String get websites_dirPermissionHint => 'Change the runtime user and group';

  @override
  String get action_enable => 'Enable';

  @override
  String get action_disable => 'Disable';

  @override
  String get websites_enabled => 'Enabled';

  @override
  String get websites_disabled => 'Disabled';

  @override
  String get websites_indexFiles => 'Index files';

  @override
  String get websites_perServer => 'Per-server connections';

  @override
  String get websites_perIp => 'Per-IP connections';

  @override
  String get websites_rateKb => 'Rate limit (KB/s)';

  @override
  String get websites_owner => 'User';

  @override
  String get websites_batchActions => 'Batch actions';

  @override
  String get websites_batchSuccess => 'Batch operation completed';

  @override
  String get websites_changeGroup => 'Change group';

  @override
  String get websites_bindSsl => 'Bind certificate';

  @override
  String get websites_selectGroup => 'Select group';

  @override
  String get websites_selectSsl => 'Select certificate';

  @override
  String get websites_defaultSite => 'Default site';

  @override
  String get websites_crossSite => 'Cross-site access';

  @override
  String get websites_proxyCache => 'Proxy cache';

  @override
  String get websites_cacheLimit => 'Cache limit';

  @override
  String get websites_cacheShare => 'Shared cache';

  @override
  String get websites_cacheExpire => 'Cache expiry';

  @override
  String get websites_clearProxyCache => 'Clear proxy cache';

  @override
  String get websites_composer => 'Composer';

  @override
  String get websites_composerCommand => 'Command';

  @override
  String get websites_composerMirror => 'Mirror';

  @override
  String get websites_composerDir => 'Working directory';

  @override
  String get websites_composerUser => 'Run as user';

  @override
  String get websites_cacheCleared => 'Proxy cache cleared';

  @override
  String get websites_pushSsl => 'Push to nodes';

  @override
  String get websites_nodes => 'Nodes';

  @override
  String get websites_mergeGroup => 'Move to group';

  @override
  String get websites_defaultHtml => 'Default pages';

  @override
  String get websites_htmlType => 'Page type';

  @override
  String get websites_htmlContent => 'HTML content';

  @override
  String get websites_htmlSaved => 'Default page saved';

  @override
  String get websites_htmlIndex => 'index.html';

  @override
  String get websites_html404 => '404.html';

  @override
  String get websites_htmlPhp => 'index.php';

  @override
  String get websites_htmlDomain404 => 'domain404.html';

  @override
  String get websites_htmlStop => 'stop/index.html';

  @override
  String get websites_group => 'Group';

  @override
  String get websites_accessAuth => 'Access authentication';

  @override
  String get websites_username => 'Username';

  @override
  String get websites_password => 'Password';

  @override
  String get websites_allowOrigins => 'Allowed origins';

  @override
  String get websites_allowMethods => 'Allowed methods';

  @override
  String get websites_allowHeaders => 'Allowed headers';

  @override
  String get websites_allowCredentials => 'Allow credentials';

  @override
  String get websites_preflight => 'Preflight cache';

  @override
  String get websites_leech => 'Hotlink protection';

  @override
  String get websites_allowedExtensions => 'Allowed extensions';

  @override
  String get websites_returnCode => 'Blocked response code';

  @override
  String get websites_blocked => 'Block hotlinking';

  @override
  String get websites_logEnabled => 'Log blocked requests';

  @override
  String get websites_realIp => 'Real IP';

  @override
  String get websites_ipFrom => 'Trusted proxy';

  @override
  String get websites_ipHeader => 'IP header';

  @override
  String get websites_ipOther => 'Other proxy';

  @override
  String get websites_rewriteTemplates => 'Templates';

  @override
  String get websites_rewriteName => 'Rule name';

  @override
  String get websites_rewriteContent => 'Rewrite rules';

  @override
  String get websites_addRedirect => 'Add redirect';

  @override
  String get websites_editRedirect => 'Edit redirect';

  @override
  String get websites_deleteRedirect => 'Delete redirect';

  @override
  String get websites_redirectDeleted => 'Redirect deleted';

  @override
  String get websites_redirectType => 'Type';

  @override
  String get websites_redirectDomain => 'Domain';

  @override
  String get websites_redirectPath => 'Path';

  @override
  String get websites_redirectTarget => 'Target URL';

  @override
  String get websites_redirectCode => 'Status code';

  @override
  String get websites_keepPath => 'Keep path';

  @override
  String get websites_redirectRoot => 'Redirect root';

  @override
  String get websites_noRedirects => 'No redirects';

  @override
  String get websites_noRedirectsHint =>
      'Add a redirect rule for this website.';

  @override
  String get websites_addProxy => 'Add reverse proxy';

  @override
  String get websites_editProxy => 'Edit reverse proxy';

  @override
  String get websites_proxyName => 'Proxy name';

  @override
  String get websites_proxyMatch => 'Match path';

  @override
  String get websites_proxyPass => 'Upstream URL';

  @override
  String get websites_proxyHost => 'Proxy host header';

  @override
  String get websites_sni => 'SNI';

  @override
  String get websites_sslVerify => 'Verify upstream certificate';

  @override
  String get action_saved => 'Saved';

  @override
  String get action_loading => 'Loading…';

  @override
  String get websites_sslManage => 'Certificate management';

  @override
  String get websites_sslManageHint =>
      'Apply, upload and delete certificates here. Bind one from the SSL tab.';

  @override
  String websites_sslFallbackName(int id) {
    return 'Certificate #$id';
  }

  @override
  String get websites_uploadSsl => 'Upload certificate';

  @override
  String get websites_applySsl => 'Apply certificate';

  @override
  String get websites_certificatePem => 'Certificate PEM';

  @override
  String get websites_privateKeyPem => 'Private key PEM';

  @override
  String get websites_sslUploaded => 'Certificate uploaded';

  @override
  String get websites_sslRequested => 'Certificate request submitted';

  @override
  String get websites_noAcmeAccount =>
      'Create an ACME account on the panel first';

  @override
  String get websites_acmeAccount => 'ACME account';

  @override
  String get websites_autoRenew => 'Auto renew';

  @override
  String get websites_deleteSsl => 'Delete certificate';

  @override
  String websites_deleteSslConfirm(String name) {
    return 'Delete certificate for $name?';
  }

  @override
  String get action_upload => 'Upload';

  @override
  String get websites_changeDatabase => 'Change database';

  @override
  String websites_currentDatabase(String names) {
    return 'Current: $names';
  }

  @override
  String get websites_database => 'Database';

  @override
  String get websites_unbindDatabase => 'Unbind database';

  @override
  String get apps_upgrade => 'Upgrade';

  @override
  String get apps_editParams => 'Edit parameters';

  @override
  String get apps_changePort => 'Change port';

  @override
  String get apps_connInfo => 'Connection info';

  @override
  String get apps_ignoreUpdate => 'Ignore update';

  @override
  String get apps_uninstall => 'Uninstall';

  @override
  String apps_uninstallHint(String name) {
    return 'Uninstall $name? This stops and removes the app containers.';
  }

  @override
  String get apps_deleteDatabase => 'Delete database';

  @override
  String get apps_deleteBackup => 'Delete backups';

  @override
  String get apps_deleteImage => 'Delete images';

  @override
  String get apps_forceDelete => 'Force delete';

  @override
  String get apps_latestVersion => 'Already on the latest version';

  @override
  String get apps_backupBeforeUpgrade => 'Back up before upgrading';

  @override
  String get apps_pullImage => 'Pull latest image';

  @override
  String get apps_advancedParams => 'Advanced parameters';

  @override
  String get apps_containerName => 'Container name';

  @override
  String get apps_port => 'Port';

  @override
  String get databases_advanced => 'Advanced';

  @override
  String get databases_configFile => 'Configuration file';

  @override
  String get databases_configFileHint =>
      'Read and edit the database configuration';

  @override
  String get databases_slowLog => 'Slow query log';

  @override
  String get databases_slowLogHint => 'Read the latest slow query log lines';

  @override
  String get databases_slowLogEmpty => 'No slow query log entries';

  @override
  String get databases_redis => 'Redis';

  @override
  String get databases_redisConfig => 'Redis configuration';

  @override
  String get databases_redisPassword => 'Redis password';

  @override
  String get databases_redisPersistence => 'Redis persistence';

  @override
  String get backups_create => 'Create backup';

  @override
  String get backups_type => 'Backup type';

  @override
  String get backups_dbPassword => 'Database password';

  @override
  String get backups_description => 'Description';

  @override
  String get backups_stopBefore => 'Stop container before backup';

  @override
  String get backups_startBackup => 'Start backup';

  @override
  String get backups_accounts => 'Backup accounts';

  @override
  String get backups_addAccount => 'Add backup account';

  @override
  String get backups_editAccount => 'Edit backup account';

  @override
  String get backups_noAccounts => 'No backup accounts';

  @override
  String get backups_noAccountsHint =>
      'Add an account to store backups remotely.';

  @override
  String get backups_testConnection => 'Test connection';

  @override
  String get backups_accountName => 'Account name';

  @override
  String get backups_accountType => 'Account type';

  @override
  String get backups_accessKey => 'Access key';

  @override
  String get backups_credential => 'Secret key';

  @override
  String get backups_bucket => 'Bucket';

  @override
  String get backups_backupPath => 'Backup path';

  @override
  String get backups_vars => 'Account variables';

  @override
  String get backups_rememberAuth => 'Remember credentials';

  @override
  String get backups_connectionOk => 'Connection succeeded';

  @override
  String get backups_connectionFailed => 'Connection failed';

  @override
  String backups_deleteAccountConfirm(String name) {
    return 'Delete backup account $name?';
  }

  @override
  String get runtimes_sync => 'Sync runtimes';

  @override
  String get runtimes_delete => 'Delete runtime';

  @override
  String runtimes_deleteConfirm(String name) {
    return 'Delete runtime $name?';
  }

  @override
  String get host_syncKeys => 'Sync SSH keys';

  @override
  String get panelSettings_oldPassword => 'Current password';

  @override
  String get panelSettings_newPassword => 'New password';

  @override
  String get panelSettings_confirmPassword => 'Confirm password';

  @override
  String get panelSettings_passwordMismatch => 'Passwords do not match';

  @override
  String get panelSettings_portChangeWarning =>
      'Changing the panel port disconnects the current session. Make sure the new port is open in the firewall.';

  @override
  String panelSettings_portChanged(int port) {
    return 'Panel port changed to $port';
  }

  @override
  String get panelSettings_apiKeyCopied => 'API key generated and copied';

  @override
  String get panelSettings_snapshots => 'Snapshots';

  @override
  String get panelSettings_snapshotsHint =>
      'Create, recreate and delete panel snapshots';

  @override
  String get panelSettings_createSnapshot => 'Create snapshot';

  @override
  String get panelSettings_noSnapshots => 'No snapshots';

  @override
  String get panelSettings_noSnapshotsHint =>
      'Create a snapshot to back up panel data.';

  @override
  String get panelSettings_snapshotName => 'Snapshot name';

  @override
  String get panelSettings_snapshotDescription => 'Description';

  @override
  String get panelSettings_recreateSnapshot => 'Recreate snapshot';

  @override
  String get panelSettings_recreateSnapshotHint =>
      'Recreate this snapshot with current panel data?';

  @override
  String get panelSettings_deleteSnapshotHint =>
      'Delete this snapshot and its files?';

  @override
  String get panelSettings_snapshotCreated => 'Snapshot task submitted';

  @override
  String get panelSettings_withDockerConf => 'Include Docker config';

  @override
  String get panelSettings_withMonitorData => 'Include monitoring data';

  @override
  String get panelSettings_withLoginLog => 'Include login logs';

  @override
  String get panelSettings_withOperationLog => 'Include operation logs';

  @override
  String get panelSettings_withSystemLog => 'Include system logs';

  @override
  String get panelSettings_withTaskLog => 'Include task logs';

  @override
  String get websites_openRestyPerformance => 'OpenResty performance';

  @override
  String get websites_openRestyConfig => 'OpenResty main config';

  @override
  String get websites_loadConfig => 'Load config';

  @override
  String get apps_syncRemote => 'Sync remote apps';

  @override
  String get apps_syncLocal => 'Sync local apps';

  @override
  String get websites_pathAuth => 'Path authentication';

  @override
  String get websites_noPathAuth => 'No path authentication';

  @override
  String get websites_addPathAuth => 'Add path authentication';

  @override
  String get websites_editPathAuth => 'Edit path authentication';

  @override
  String websites_deletePathAuth(String path) {
    return 'Delete authentication for $path?';
  }

  @override
  String get containers_imageRepos => 'Registries';

  @override
  String get containers_addRepo => 'Add registry';

  @override
  String get containers_editRepo => 'Edit registry';

  @override
  String get containers_noRepos => 'No registries';

  @override
  String get containers_noReposHint =>
      'Add a registry to pull and push images.';

  @override
  String get containers_repoUrl => 'Registry URL';

  @override
  String get containers_protocol => 'Protocol';

  @override
  String get containers_repoAuth => 'Requires authentication';

  @override
  String get containers_repoId => 'Registry ID';

  @override
  String get containers_buildImage => 'Build image';

  @override
  String get containers_exportImage => 'Export image';

  @override
  String get containers_importImage => 'Import image';

  @override
  String get containers_pushImage => 'Push image';

  @override
  String get containers_baseImage => 'Base image';

  @override
  String get containers_imageArchive => 'Image archive paths';

  @override
  String get databases_variables => 'Performance variables';

  @override
  String get databases_variablesHint =>
      'Read and update MySQL runtime variables';

  @override
  String get databases_redisStatus => 'Redis status';

  @override
  String get databases_installRedisCli => 'Install Redis CLI';

  @override
  String get host_terminalSessions => 'Terminal sessions';

  @override
  String get host_terminalSessionsHint =>
      'Review and close active SSH sessions';

  @override
  String get host_closeAllSessions => 'Close all';

  @override
  String get websites_certificateAccounts => 'Certificate accounts';

  @override
  String get websites_addAcme => 'Add ACME account';

  @override
  String get websites_email => 'Email';

  @override
  String get websites_acmeType => 'ACME type';

  @override
  String get websites_caDirUrl => 'CA directory URL';

  @override
  String get websites_useProxy => 'Use proxy';

  @override
  String get websites_eabKid => 'EAB Kid';

  @override
  String get websites_eabHmacKey => 'EAB HmacKey';

  @override
  String get websites_useEab => 'Use EAB';

  @override
  String get websites_noAcme => 'No ACME accounts';

  @override
  String get websites_noAcmeHint =>
      'Add an ACME account to request certificates.';

  @override
  String get websites_addDns => 'Add DNS account';

  @override
  String get websites_dnsType => 'DNS provider';

  @override
  String get websites_authorization => 'Authorization JSON';

  @override
  String get websites_noDns => 'No DNS accounts';

  @override
  String get websites_noDnsHint => 'Add a DNS account for DNS-01 validation.';

  @override
  String get websites_addCa => 'Add CA';

  @override
  String get websites_commonName => 'Common name';

  @override
  String get websites_country => 'Country';

  @override
  String get websites_organization => 'Organization';

  @override
  String get websites_noCa => 'No CA certificates';

  @override
  String get websites_noCaHint =>
      'Create a self-signed CA and issue certificates from it.';

  @override
  String get websites_obtainCa => 'Issue certificate';

  @override
  String get websites_renewCa => 'Renew';

  @override
  String get apps_cancelIgnore => 'Cancel ignored update';

  @override
  String get apps_notIgnored => 'This app is not ignored';

  @override
  String get files_exactSize => 'Calculate exact size';

  @override
  String get containers_rename => 'Rename';

  @override
  String get containers_newName => 'New name';

  @override
  String get containers_checkImageUpdates => 'Check image updates';

  @override
  String get containers_imageUpdatesDone => 'Image update check started';

  @override
  String get containers_searchRemote => 'Search remote images';

  @override
  String get containers_scheduleImageUpdates => 'Schedule image update checks';

  @override
  String get containers_downloadLog => 'Download logs';

  @override
  String get containers_fileBrowser => 'Container files';

  @override
  String get containers_uploadFile => 'Upload file';

  @override
  String get containers_fileContent => 'File content';

  @override
  String get containers_binaryFile => 'Binary file, cannot preview';

  @override
  String get containers_parentDir => 'Parent directory';

  @override
  String get containers_fileDeleted => 'File deleted';

  @override
  String get containers_fileEmpty => 'Directory is empty';

  @override
  String get containers_composeEnv => 'Compose environment';

  @override
  String get containers_pinCompose => 'Pin compose';

  @override
  String get containers_unpinCompose => 'Unpin compose';

  @override
  String get containers_cleanLogs => 'Clear container logs';

  @override
  String containers_cleanLogsConfirm(String name) {
    return 'Clear logs for $name?';
  }

  @override
  String get backups_listBuckets => 'List buckets';

  @override
  String get backups_refreshToken => 'Refresh token';

  @override
  String get backups_buckets => 'Buckets';

  @override
  String get websites_switchPhp => 'Switch PHP version';

  @override
  String get websites_switchPhpHint =>
      'Change the PHP runtime or serve as a static website';

  @override
  String get websites_staticSite => 'Static website';

  @override
  String get websites_editSsl => 'Edit certificate';

  @override
  String get logs_clean => 'Clean logs';

  @override
  String get logs_cleanOperation => 'Clean operation logs';

  @override
  String get logs_cleanLogin => 'Clean login logs';

  @override
  String get logs_cleanConfirm => 'This permanently clears the selected logs.';

  @override
  String get logs_exportSsh => 'Export SSH logs';

  @override
  String get panelSettings_memo => 'Panel memo';

  @override
  String get panelSettings_memoHint => 'No memo yet';

  @override
  String get panelSettings_memoContentHint => 'Write a memo for this panel';

  @override
  String logs_exported(String path) {
    return 'Exported to $path';
  }

  @override
  String get websites_saveAsCustomRewrite => 'Save as custom template';

  @override
  String get websites_checkDns => 'Check DNS';

  @override
  String get alerts_addNotification => 'Add notification method';

  @override
  String get alerts_editNotification => 'Edit notification method';

  @override
  String get alerts_testNotification => 'Send test notification';

  @override
  String get alerts_configContent => 'Configuration (JSON)';

  @override
  String get alerts_configInvalid => 'Configuration is not valid JSON';

  @override
  String get alerts_testSent => 'Test notification sent';

  @override
  String get alerts_testFailed => 'Test notification failed';

  @override
  String get backups_calculateSizes => 'Calculate backup sizes';

  @override
  String get backups_recordCount => 'Records';

  @override
  String get backups_totalSize => 'Total size';

  @override
  String get backups_containerHint => 'Container name';

  @override
  String get files_websiteRoot => 'Website root directory';

  @override
  String get files_pickOwner => 'Pick user or group';

  @override
  String get panelSettings_apiConfigUnavailable =>
      'The API Key mode cannot safely read the API whitelist. Update it in the panel web UI.';

  @override
  String get panelSettings_apiInterfaceToggleHint =>
      'Allow API access for this panel';

  @override
  String get panelSettings_restoreSnapshot => 'Restore snapshot';

  @override
  String get panelSettings_rollbackSnapshot => 'Rollback snapshot';

  @override
  String get panelSettings_snapshotSecret => 'Backup password (optional)';

  @override
  String get panelSettings_snapshotRestoreSubmitted => 'Restore task submitted';

  @override
  String get action_continue => 'Continue';

  @override
  String get panelSettings_importSnapshot => 'Import snapshot';

  @override
  String get panelSettings_snapshotJson => 'Snapshot JSON';

  @override
  String get panelSettings_snapshotJsonInvalid => 'Snapshot JSON is invalid';

  @override
  String get action_import => 'Import';

  @override
  String get databases_status => 'Runtime status';

  @override
  String files_alreadyExists(String name) {
    return '$name already exists';
  }

  @override
  String get runtime_extensionPresets => 'Extension presets';

  @override
  String get containers_containersUsingImage => 'Containers using this image';

  @override
  String get containers_diskUsage => 'Docker disk usage';

  @override
  String get containers_usageContainers => 'Containers';

  @override
  String get containers_usageImages => 'Images';

  @override
  String get containers_usageVolumes => 'Volumes';

  @override
  String get containers_usageBuildCache => 'Build cache';

  @override
  String get databases_remoteInstances => 'Remote instances';

  @override
  String get databases_addRemote => 'Add remote instance';

  @override
  String get databases_editRemote => 'Edit remote instance';

  @override
  String get databases_loadDatabases => 'Load databases';

  @override
  String get databases_testConnection => 'Test connection';

  @override
  String get databases_connectionOk => 'Connection succeeded';

  @override
  String get databases_connectionFailed => 'Connection failed';

  @override
  String get databases_ssl => 'Use SSL';

  @override
  String get files_checkExistence => 'Verify existence';

  @override
  String get panelSettings_closeMfa => 'Close MFA';

  @override
  String get panelSettings_mfaClosed => 'MFA closed';

  @override
  String get panelSettings_resetExpiredPassword => 'Reset expired password';

  @override
  String get panelSettings_passwordReset => 'Password reset';

  @override
  String get panelSettings_commandLibrary => 'Command library';

  @override
  String get commandLibrary_add => 'New command';

  @override
  String get commandLibrary_name => 'Command name';

  @override
  String get commandLibrary_command => 'Command';

  @override
  String get commandLibrary_empty => 'No commands';

  @override
  String get commandLibrary_tree => 'Command tree';

  @override
  String get commandLibrary_import => 'Import commands';

  @override
  String get commandLibrary_export => 'Export commands';

  @override
  String get commandLibrary_imported => 'Commands imported';

  @override
  String get commandLibrary_exported => 'Commands exported';

  @override
  String get commandLibrary_importEmpty => 'No importable commands in CSV';

  @override
  String get commandLibrary_copied => 'Command copied';

  @override
  String get scriptLibrary_run => 'Run script';

  @override
  String get panelSettings_groupManagement => 'Group management';

  @override
  String get group_add => 'New group';

  @override
  String get group_name => 'Group name';

  @override
  String get group_empty => 'No groups';

  @override
  String get group_typeScript => 'Script';

  @override
  String get group_typeCommand => 'Command';

  @override
  String get group_typeCronjob => 'Cronjob';

  @override
  String get panelSettings_scriptLibrary => 'Script library';

  @override
  String get scriptLibrary_add => 'New script';

  @override
  String get scriptLibrary_name => 'Script name';

  @override
  String get scriptLibrary_description => 'Description';

  @override
  String get scriptLibrary_content => 'Script content';

  @override
  String get scriptLibrary_interactive => 'Interactive script';

  @override
  String get scriptLibrary_sync => 'Sync scripts';

  @override
  String get scriptLibrary_syncStarted => 'Sync task started';

  @override
  String get scriptLibrary_empty => 'No scripts';

  @override
  String get panelSettings_mfa => 'Two-factor authentication';

  @override
  String get panelSettings_mfaHint => 'Bind an authenticator app';

  @override
  String get panelSettings_mfaCode => 'Verification code';

  @override
  String get panelSettings_bindMfa => 'Bind';

  @override
  String get panelSettings_passkeys => 'Passkeys';

  @override
  String get panelSettings_passkeysHint => 'Manage registered passkeys';

  @override
  String get panelSettings_noPasskeys => 'No passkeys registered';

  @override
  String get websites_downloadSsl => 'Download certificate';

  @override
  String get websites_downloadCa => 'Download CA';

  @override
  String websites_downloaded(String path) {
    return 'Saved to $path';
  }

  @override
  String get apps_storeSettings => 'App store settings';

  @override
  String get apps_uninstallDeleteImage => 'Delete image when uninstalling';

  @override
  String get apps_upgradeBackup => 'Back up before upgrade';

  @override
  String get apps_uninstallDeleteBackup => 'Delete backup when uninstalling';

  @override
  String get apps_installAllowPort => 'Check port availability on install';

  @override
  String get containers_users => 'Container users';

  @override
  String get runtime_scripts => 'package.json scripts';

  @override
  String get runtime_codeDir => 'Code directory';

  @override
  String get supervisor_configFile => 'Supervisor configuration';

  @override
  String get containers_composeTemplates => 'Compose templates';

  @override
  String get containers_importTemplates => 'Import templates';

  @override
  String get containers_templateJsonInvalid => 'Template JSON must be a list';

  @override
  String get containers_daemonKeyValue => 'Daemon key-value';

  @override
  String get containers_daemonKey => 'Key';

  @override
  String get containers_daemonValue => 'Value';

  @override
  String get runtime_name => 'Runtime name';

  @override
  String get runtime_port => 'Port';

  @override
  String get runtime_remark => 'Remark';

  @override
  String get host_sshConfigFile => 'SSH configuration file';

  @override
  String get host_sshConfigFileHint => 'Edit sshd_config directly';

  @override
  String get host_sshConfigNotFound => 'No SSH configuration file found';

  @override
  String get host_sshConfigWarning =>
      'Saving an invalid configuration may break SSH access.';

  @override
  String get host_sshConfigSaved => 'SSH configuration saved';

  @override
  String get host_testSsh => 'Test SSH connection';

  @override
  String get host_testSshHint => 'Verify address, port and credentials';

  @override
  String get websites_viewAccessLog => 'View access log';

  @override
  String get websites_viewErrorLog => 'View error log';

  @override
  String get websites_liveLogHint => 'Read the latest lines in-app';

  @override
  String get websites_descriptionPin => 'Description and pin';

  @override
  String get websites_descriptionPinHint =>
      'Set the panel description and pin state';

  @override
  String get websites_description => 'Description';

  @override
  String get websites_pin => 'Pin to top';

  @override
  String get websites_copyFromExisting => 'Copy from existing website';

  @override
  String get panelSettings_panelSsl => 'Panel HTTPS';

  @override
  String get panelSettings_panelSslHint =>
      'Configure HTTPS for the panel entry';

  @override
  String get panelSettings_panelSslWarning =>
      'Changing panel HTTPS may interrupt the current session.';

  @override
  String get panelSettings_panelSslMode => 'SSL mode';

  @override
  String get panelSettings_panelSslType => 'Certificate source';

  @override
  String get supervisor_editConfig => 'Edit process config';

  @override
  String get supervisor_viewOutLog => 'View stdout log';

  @override
  String get supervisor_viewErrLog => 'View error log';

  @override
  String get backups_restoreFromFile => 'Restore from server file';

  @override
  String get backups_restoreFromFileHint =>
      'Upload a backup file already present on the server, then restore it.';

  @override
  String get backups_serverFilePath => 'Server file path';

  @override
  String get websites_editSource => 'Edit source';

  @override
  String get runtime_create => 'Create runtime';

  @override
  String get runtime_typeLabel => 'Type';

  @override
  String get runtime_image => 'Image';

  @override
  String get runtime_appDetailId => 'App detail ID';

  @override
  String get runtime_resource => 'Resource';

  @override
  String get runtime_version => 'Version';

  @override
  String get runtime_paramsJson => 'Parameters (JSON)';

  @override
  String get runtime_paramsInvalid => 'Parameters must be a JSON object';

  @override
  String get apps_alreadyInstalled =>
      'This app is already installed. Manage it from the installed list.';

  @override
  String common_errorLine(String title, String message) {
    return '$title: $message';
  }

  @override
  String get websites_ssl => 'SSL';

  @override
  String get websites_proxyDeleted => 'Reverse proxy deleted';

  @override
  String get websites_proxyRequired =>
      'Proxy name and upstream address are required.';

  @override
  String get websites_requiredFields => 'Complete all required fields.';

  @override
  String get websites_usernameRequired =>
      'Username is required when authentication is enabled.';

  @override
  String get apps_cancelIgnoreUpdate => 'Resume update reminders';

  @override
  String get more_runtimesSubtitle => 'PHP / Node / Python';

  @override
  String get more_composeSubtitle => 'docker compose';

  @override
  String get firewall_noMatchingRules => 'No matching rules';

  @override
  String get firewall_clearFiltersHint =>
      'Adjust the keyword or clear the filters.';

  @override
  String get panelSettings_apiKeyRow => 'API key';

  @override
  String get panelSettings_sslModeEnable => 'Enable';

  @override
  String get panelSettings_sslModeDisable => 'Disable';

  @override
  String get panelSettings_sslModeMux => 'Mux';

  @override
  String get panelSettings_sslPaste => 'Paste certificate';

  @override
  String get panelSettings_sslSelectExisting => 'Select existing';

  @override
  String get panelSettings_sslSelfSigned => 'Self-signed';

  @override
  String get panelSettings_languageEn => 'English';

  @override
  String get backups_typeLocal => 'Local';

  @override
  String get backups_typeSftp => 'SFTP';

  @override
  String get backups_typeS3 => 'S3';

  @override
  String get backups_typeOss => 'Alibaba Cloud OSS';

  @override
  String get backups_typeCos => 'Tencent Cloud COS';

  @override
  String get backups_typeMinio => 'MinIO';

  @override
  String get backups_typeOneDrive => 'OneDrive';

  @override
  String get backups_typeWebdav => 'WebDAV';

  @override
  String get backups_typeKodo => 'Qiniu Kodo';

  @override
  String get backups_typeUpyun => 'UPYUN';

  @override
  String get backups_typeAliyun => 'Aliyun Drive';

  @override
  String get backups_typeGoogleDrive => 'Google Drive';

  @override
  String get runtimes_emptyTitle => 'No runtimes installed';

  @override
  String get runtime_extensionsEmptyTitle => 'No extensions available';

  @override
  String get runtime_modulesEmptyTitle => 'No modules installed';

  @override
  String get websites_templatesEmptyTitle => 'No website templates yet';

  @override
  String get websites_templateOutputsEmptyTitle => 'No generated websites yet';

  @override
  String get host_sshUnavailableTitle => 'SSH service unavailable';

  @override
  String get host_disksEmptyTitle => 'No disks detected';

  @override
  String get host_diagnosticsEmptyTitle => 'No diagnostics yet';

  @override
  String get host_diagSnapshotEmptyTitle => 'No snapshots yet';

  @override
  String get toolbox_ftpEmptyTitle => 'No FTP accounts yet';

  @override
  String get toolbox_sshBanEmptyTitle => 'No banned IPs';

  @override
  String get toolbox_clamScanEmptyTitle => 'No scan records yet';

  @override
  String get panelSettings_notificationMethodsEmptyTitle =>
      'No notification methods configured';

  @override
  String get process_title => 'Processes';

  @override
  String get process_stopRequested => 'Stop request sent';

  @override
  String get process_stopFailed => 'Failed to stop process';

  @override
  String get process_searchNamePlaceholder => 'Search process name';

  @override
  String get process_searchNameOrPortPlaceholder =>
      'Search process name or port';

  @override
  String get process_connectionFailed => 'Connection failed';

  @override
  String get process_noResults => 'No matching results';

  @override
  String get process_noData => 'No data';

  @override
  String get process_noResultsSubtitle => 'Try a different search keyword';

  @override
  String get process_waitingData => 'Waiting for data';

  @override
  String get process_connecting => 'Connecting to process service';

  @override
  String get process_readingDetail => 'Reading process details';

  @override
  String get process_readFailed => 'Read failed';

  @override
  String get process_basicInfo => 'Basic Info';

  @override
  String get process_user => 'User';

  @override
  String get process_status => 'Status';

  @override
  String get process_startTime => 'Start Time';

  @override
  String process_threads(int count) {
    return '$count threads';
  }

  @override
  String get process_threadCount => 'Threads';

  @override
  String process_connections(int count) {
    return '$count connections';
  }

  @override
  String get process_connectionCount => 'Connections';

  @override
  String get process_commandLine => 'Command Line';

  @override
  String get process_cpuDisk => 'CPU / Disk';

  @override
  String get process_memory => 'Memory';

  @override
  String get process_diskRead => 'Disk Read';

  @override
  String get process_diskWrite => 'Disk Write';

  @override
  String get process_memoryDetails => 'Memory Details';

  @override
  String get process_openFiles => 'Open Files';

  @override
  String get process_networkConnections => 'Network Connections';

  @override
  String get process_environmentVariables => 'Environment Variables';

  @override
  String get process_sort => 'Sort';

  @override
  String get process_sortCpu => 'CPU Usage';

  @override
  String get process_sortMemory => 'Memory';

  @override
  String get process_sortConnections => 'Connections';

  @override
  String get process_emptyTitle => 'No processes';

  @override
  String get terminal_emptySessionsTitle => 'No terminal sessions';

  @override
  String get files_historyEmptyTitle => 'No file history';

  @override
  String get files_aiHitsEmptyTitle => 'No matching files';

  @override
  String get websites_loadBalanceEmptyTitle => 'No upstream nodes';

  @override
  String servers_count(int count) {
    return '$count panels';
  }

  @override
  String get servers_sectionConnected => 'Connected panels';

  @override
  String get supervisor_sectionProcesses => 'Guarded processes';

  @override
  String get toolbox_timeSection => 'Time zone and time';

  @override
  String more_appsCount(int count) {
    return '$count apps';
  }

  @override
  String more_databasesCount(int count) {
    return '$count databases';
  }

  @override
  String more_cronjobsCount(int count) {
    return '$count scheduled tasks';
  }

  @override
  String websites_templateVariableCount(int count) {
    return '$count variables';
  }

  @override
  String get log_emptyMessage => 'No log entries in this category yet.';

  @override
  String get process_emptyMessage =>
      'No processes are available on this server.';

  @override
  String get runtimes_emptyMessage =>
      'Runtimes installed from the app store will appear here.';

  @override
  String get logs_searchHint => 'Search log lines';

  @override
  String get logs_raw => 'Raw';

  @override
  String get logs_rawData => 'Raw data';

  @override
  String get logs_structured => 'Structured';

  @override
  String get logs_time => 'Time';

  @override
  String get logs_startOfFile => 'Start of file reached';

  @override
  String logs_exportLoadedCount(int count) {
    return 'Export the $count loaded lines';
  }

  @override
  String get logs_copyRaw => 'Copy raw line';

  @override
  String get logs_copied => 'Copied';

  @override
  String get logs_status => 'Status';

  @override
  String get logs_method => 'Method';

  @override
  String get logs_path => 'Path';

  @override
  String get logs_ip => 'Client IP';

  @override
  String get logs_userAgent => 'User-Agent';

  @override
  String get logs_referer => 'Referer';

  @override
  String get logs_bytes => 'Bytes';

  @override
  String get logs_upstream => 'Upstream';

  @override
  String get logs_duration => 'Duration';

  @override
  String get logs_follow => 'Follow';

  @override
  String get logs_stopFollow => 'Stop follow';

  @override
  String get logs_loadEarlier => 'Load earlier lines';

  @override
  String get logs_noMatches => 'No matching lines';

  @override
  String logs_lineCount(int count) {
    return '$count lines';
  }

  @override
  String logs_matchCount(int count) {
    return '$count matches';
  }

  @override
  String get logs_following => 'Following';

  @override
  String get apps_upgradable => 'Updatable';

  @override
  String get apps_allApps => 'All apps';

  @override
  String get apps_upgradableEmptyTitle => 'No updates available';

  @override
  String get apps_upgradableEmptyMessage =>
      'Every installed app is on its latest version.';

  @override
  String get logs_system => 'System logs';

  @override
  String get websites_sslStatusReady => 'Issued';

  @override
  String get websites_sslStatusApplied => 'Deployed';

  @override
  String get websites_sslStatusPending => 'Processing';

  @override
  String get websites_sslStatusError => 'Error';

  @override
  String get app_detail_arch => 'Architecture';

  @override
  String get app_detail_gpu => 'GPU support';

  @override
  String get app_detail_latestVersion => 'Latest version';

  @override
  String get app_detail_website => 'Website';

  @override
  String get app_detail_github => 'GitHub';

  @override
  String get app_detail_docs => 'Docs';

  @override
  String get app_detail_intro => 'About this app';

  @override
  String get logs_cards => 'Cards';

  @override
  String get containers_overview_resources => 'Resources';

  @override
  String get containers_overview_disk => 'Disk usage';

  @override
  String containers_overview_reclaimable(String size) {
    return 'Reclaimable $size';
  }

  @override
  String containers_overview_runningCount(int count) {
    return 'Running $count';
  }

  @override
  String get apps_rebuild => 'Rebuild';

  @override
  String get apps_reload => 'Reload';

  @override
  String get apps_rebuildConfirm =>
      'Rebuild recreates the container. Unsaved runtime data may be lost.';

  @override
  String get apps_installLog => 'Install log';

  @override
  String get apps_installLogEmpty => 'No install log for this app yet.';

  @override
  String get host_subtitleOps => 'SSH · Disk · Diagnostics';

  @override
  String get toolbox_timeSwapDns => 'Time · Swap · DNS';

  @override
  String get supervisor_titleLong => 'Supervisor';

  @override
  String get containers_volumesEmpty => 'No volumes';

  @override
  String get containers_volumesEmptyHint =>
      'Volumes created by containers will appear here.';

  @override
  String containers_volumeDeleteConfirm(String name) {
    return 'Delete volume $name? Data stored on it will be lost.';
  }

  @override
  String get files_recycleEnabled => 'Recycle bin is on';

  @override
  String get files_recycleDisabled => 'Recycle bin is off';

  @override
  String get dashboard_resourceUsage => 'Resource usage';

  @override
  String get dashboard_swap => 'Swap';

  @override
  String get dashboard_realtimeSpeed => 'Live speed';

  @override
  String get dashboard_chartNow => 'Now';

  @override
  String dashboard_chartSecondsAgo(int seconds) {
    return '${seconds}s ago';
  }

  @override
  String get dashboard_diskIo => 'Disk I/O';

  @override
  String get dashboard_read => 'Read';

  @override
  String get dashboard_write => 'Write';

  @override
  String get dashboard_latency => 'Latency';

  @override
  String get dashboard_partitions => 'Disk partitions';

  @override
  String get dashboard_hostDetails => 'Host details';

  @override
  String dashboard_coreThreads(int physical, int logical) {
    return '$physical cores / $logical threads';
  }

  @override
  String dashboard_latencyValue(String value) {
    return '$value ms/op';
  }

  @override
  String get dashboard_monitorOptions => 'Monitor devices';

  @override
  String get dashboard_monitorDisk => 'Disk IO';

  @override
  String get dashboard_monitorNetwork => 'Network interface';

  @override
  String containers_limitAvailable(int cpu, int memory) {
    return 'Host limit: $cpu cores · $memory MB';
  }

  @override
  String get alerts_disk => 'Monitored disk';

  @override
  String get alerts_diskHint => 'Choose the mount path to monitor';

  @override
  String get backups_localDir => 'Local directory';

  @override
  String get panelSettings_bindAddress => 'Interface address';

  @override
  String get apps_filterTags => 'Tags';

  @override
  String get dashboard_monitorAll => 'All';

  @override
  String get toolbox_ftpSystemUser => 'System user';

  @override
  String get websites_uploadSslFile => 'Upload from file';

  @override
  String get websites_uploadSslPaste => 'Paste PEM';

  @override
  String get websites_selectCertificateFile => 'Select certificate file';

  @override
  String get websites_selectPrivateKeyFile => 'Select private key file';

  @override
  String get websites_openRestyStatus => 'OpenResty status';

  @override
  String get websites_openRestyActive => 'Active connections';

  @override
  String get websites_openRestyRequests => 'Requests';

  @override
  String get websites_openRestyAcceptsHandled => 'Accepted / handled';

  @override
  String get panelSettings_previewSnapshot => 'Preview';

  @override
  String get panelSettings_snapshotContent => 'Snapshot content';

  @override
  String get servers_reorder => 'Reorder';

  @override
  String get servers_reorderHint => 'Drag to reorder servers';

  @override
  String get websites_organizationUnit => 'Organization unit';

  @override
  String get websites_province => 'Province';

  @override
  String get websites_city => 'City';

  @override
  String get websites_keyType => 'Key type';

  @override
  String get websites_certPath => 'Certificate path';

  @override
  String get websites_privateKeyPath => 'Private key path';

  @override
  String get websites_status => 'Status';

  @override
  String get ai_title => 'AI tools';

  @override
  String get ai_models => 'Models';

  @override
  String get ai_gpu => 'GPU';

  @override
  String get ai_mcp => 'MCP servers';

  @override
  String get ai_models_empty => 'No models';

  @override
  String get ai_models_empty_hint => 'Add an Ollama model to start.';

  @override
  String get ai_gpu_empty => 'No GPU detected';

  @override
  String get ai_gpu_empty_hint =>
      'GPU information appears when a supported device is present.';

  @override
  String get ai_mcp_empty => 'No MCP servers';

  @override
  String get ai_mcp_empty_hint => 'Add an MCP server to expose tools.';

  @override
  String get ai_model_add => 'Add model';

  @override
  String get ai_model_name => 'Model name';

  @override
  String get ai_model_size => 'Size';

  @override
  String get ai_model_status => 'Status';

  @override
  String get ai_model_from => 'Source';

  @override
  String get ai_model_load => 'Load';

  @override
  String get ai_model_unload => 'Unload';

  @override
  String get ai_mcp_add => 'Add MCP server';

  @override
  String get ai_mcp_name => 'Server name';

  @override
  String get ai_mcp_type => 'Runtime';

  @override
  String get ai_mcp_command => 'Command';

  @override
  String get ai_mcp_container => 'Container name';

  @override
  String get ai_mcp_port => 'Port';

  @override
  String get ai_mcp_sse_path => 'SSE path';

  @override
  String get ai_mcp_url => 'Base URL';

  @override
  String get ai_mcp_protocol => 'Output protocol';

  @override
  String get ai_mcp_transport => 'Transport';

  @override
  String get ai_mcp_running => 'Running';

  @override
  String get ai_mcp_stopped => 'Stopped';

  @override
  String get ai_mcp_start => 'Start';

  @override
  String get ai_mcp_stop => 'Stop';

  @override
  String get ai_mcp_restart => 'Restart';

  @override
  String get ai_mcp_test => 'Test connection';

  @override
  String ai_mcp_delete_confirm(String name) {
    return 'Delete MCP server $name?';
  }

  @override
  String get ai_gpu_driver => 'Driver';

  @override
  String get ai_gpu_cuda => 'CUDA';

  @override
  String get ai_gpu_memory => 'Memory';

  @override
  String get ai_gpu_utilization => 'Utilization';

  @override
  String get ai_gpu_temperature => 'Temperature';

  @override
  String get ai_gpu_processes => 'Processes';

  @override
  String get ai_mcp_connection_ok => 'Connection OK';

  @override
  String get ai_mcp_connection_failed => 'Connection failed';

  @override
  String get databases_redisCommand => 'Redis command line';

  @override
  String get ai_subtitle => 'Models · GPU · MCP';

  @override
  String get ai_mcp_detail => 'Details';

  @override
  String get ai_mcp_environments => 'Environment variables';

  @override
  String get ai_mcp_volumes => 'Volumes';

  @override
  String get ai_mcp_env_hint => 'One KEY=VALUE per line';

  @override
  String get ai_mcp_volume_hint => 'One source:target per line';

  @override
  String get ai_mcp_domain => 'MCP domain';

  @override
  String get ai_mcp_bind_domain => 'Bind domain';

  @override
  String get ai_mcp_update_domain => 'Update domain';

  @override
  String get ai_mcp_ssl_id => 'SSL ID';

  @override
  String get ai_mcp_ip_list => 'Allowed IPs';

  @override
  String get ai_mcp_conn_url => 'Connection URL';

  @override
  String get ai_mcp_sync_status => 'Sync status';

  @override
  String get ai_accounts => 'Model accounts';

  @override
  String get ai_agents => 'Agents';

  @override
  String get ai_accounts_empty => 'No model accounts';

  @override
  String get ai_accounts_empty_hint => 'Add a provider account to use models.';

  @override
  String get ai_agents_empty => 'No agents';

  @override
  String get ai_agents_empty_hint => 'Installed agents will appear here.';

  @override
  String get ai_account_provider => 'Provider';

  @override
  String get ai_account_verified => 'Verified';

  @override
  String get ai_account_unverified => 'Unverified';

  @override
  String get ai_agent_status => 'Status';

  @override
  String get ai_agent_model => 'Model';

  @override
  String get ai_agent_website => 'Website';

  @override
  String get ai_agent_token_reset => 'Reset token';

  @override
  String get ai_agent_remark => 'Remark';

  @override
  String ai_agent_delete_confirm(String name) {
    return 'Delete agent $name?';
  }

  @override
  String get ai_agent_upgradable => 'Upgrade available';

  @override
  String get ai_account_add => 'Add model account';

  @override
  String get ai_account_models => 'Models';

  @override
  String get ai_model_id => 'Model ID';

  @override
  String get ai_model_verify => 'Set as verification model';

  @override
  String get ai_model_verified => 'Verification model';

  @override
  String get ai_account_verify => 'Verify account';

  @override
  String get ai_account_edit => 'Edit model account';

  @override
  String get ai_account_name => 'Account name';

  @override
  String get ai_account_api_key => 'API key';

  @override
  String get ai_account_base_url => 'Base URL';

  @override
  String get ai_account_api_type => 'API type';

  @override
  String get ai_account_verify_model => 'Verify model';

  @override
  String get ai_account_validate => 'Validate availability';

  @override
  String get ai_account_remember_key => 'Remember API key';

  @override
  String get ai_account_remark => 'Remark';

  @override
  String get ai_agent_model_config => 'Model configuration';

  @override
  String get ai_agent_fallbacks => 'Fallback models';

  @override
  String get ai_agent_add => 'Add agent';

  @override
  String get ai_agent_type => 'Agent type';

  @override
  String get ai_agent_version => 'Version';

  @override
  String get ai_agent_port => 'WebUI port';

  @override
  String get ai_agent_access_host => 'Access host';

  @override
  String get ai_agent_username => 'Dashboard username';

  @override
  String get ai_agent_password => 'Dashboard password';

  @override
  String get ai_agent_bind_website => 'Bind website';

  @override
  String get ai_agent_unbind_website => 'Unbind website';

  @override
  String get ai_agent_select_website => 'Select website';

  @override
  String get ai_agent_roles => 'Roles';

  @override
  String get ai_agent_channels => 'Channels';

  @override
  String get ai_agent_roles_empty => 'No roles';

  @override
  String get ai_agent_channels_empty => 'No channels';

  @override
  String ai_agent_delete_role_confirm(String name) {
    return 'Delete role $name?';
  }

  @override
  String get ai_agent_bound => 'Bound';

  @override
  String get ai_agent_unbound => 'Unbound';

  @override
  String get ai_agent_role_add => 'Add role';

  @override
  String get ai_agent_binding_channel => 'Channel';

  @override
  String get ai_agent_account_id => 'Account ID';

  @override
  String get ai_agent_role_name => 'Role name';

  @override
  String get ai_agent_bind_channel => 'Bind channel';

  @override
  String get ai_agent_unbind_channel => 'Unbind channel';

  @override
  String get ai_agent_feishu => 'Feishu channel';

  @override
  String get ai_agent_channel_enabled => 'Enabled';

  @override
  String get ai_agent_group_policy => 'Group policy';

  @override
  String get ai_agent_require_mention => 'Require mention';

  @override
  String get ai_agent_streaming => 'Streaming replies';

  @override
  String get ai_agent_thread_session => 'Thread session';

  @override
  String get ai_agent_connection_mode => 'Connection mode';

  @override
  String get ai_agent_bots => 'Bots';

  @override
  String get ai_agent_channel_saved => 'Channel settings saved';

  @override
  String get ai_agent_channel_config => 'Channel configuration';

  @override
  String get ai_agent_channel_json => 'Channel JSON';

  @override
  String get ai_agent_channel_json_invalid => 'Channel JSON is invalid';

  @override
  String get ai_agent_channel_json_hint =>
      'Edit the JSON returned by the panel. agentId is added on save.';

  @override
  String get ai_agent_channel_delete => 'Remove channel config';

  @override
  String ai_agent_channel_delete_confirm(String channel) {
    return 'Remove $channel configuration for this agent?';
  }

  @override
  String get databases_redisKeys => 'Browse keys';

  @override
  String get ai_agent_weixin_login => 'Weixin QR login';

  @override
  String get ai_agent_weixin_login_hint =>
      'Scan the QR code shown in the task log to connect Weixin.';

  @override
  String get websites_basicConfigHint =>
      'Domain, directory, port and index files';

  @override
  String get websites_securityHint =>
      'Auth, CORS, hotlink protection and real IP';

  @override
  String get websites_rewriteHint => 'Rewrite rules';

  @override
  String get websites_redirectHint => 'Redirect rules';

  @override
  String get websites_proxyHint => 'Forward a domain to an existing service';

  @override
  String get websites_staticHint => 'Serve HTML / CSS / JS directly';

  @override
  String get websites_runtimeHint =>
      'PHP / Java / Node.js / Go / Python / .NET';

  @override
  String get websites_tunnel => 'TCP/UDP proxy';

  @override
  String get websites_tunnelHint => 'Layer 4 forwarding without HTTP';

  @override
  String get websites_port => 'Port';

  @override
  String get websites_protocol => 'Protocol';

  @override
  String get websites_enableSsl => 'Enable SSL';

  @override
  String get websites_ipv6 => 'IPv6';

  @override
  String websites_relativeDir(Object path) {
    return 'Relative to $path';
  }

  @override
  String get websites_createSuccess => 'Website created';

  @override
  String get websites_sslRequired => 'Select a certificate';

  @override
  String get websites_menu => 'Menu';

  @override
  String get websites_openRestyNotInstalled => 'OpenResty is not installed';

  @override
  String get websites_openRestyStopped => 'OpenResty is stopped';

  @override
  String get websites_openRestyInstall => 'Open the app store';

  @override
  String get websites_openRestyService => 'Service';

  @override
  String get websites_openRestyStart => 'Start';

  @override
  String get websites_openRestyStop => 'Stop';

  @override
  String get websites_openRestyRestart => 'Restart';

  @override
  String get websites_openRestyReload => 'Reload';

  @override
  String get websites_serverNamesHash => 'Server names hash bucket size';

  @override
  String get websites_clientHeaderBuffer => 'Client header buffer size';

  @override
  String get websites_maxBodySize => 'Maximum upload size';

  @override
  String get websites_keepaliveTimeout => 'Keepalive timeout';

  @override
  String get websites_gzip => 'Enable compression';

  @override
  String get websites_gzipMinLength => 'Minimum compressed size';

  @override
  String get websites_gzipCompLevel => 'Compression level';

  @override
  String get websites_openRestyLogs => 'OpenResty logs';

  @override
  String get websites_openRestyConfigFile => 'Main configuration';

  @override
  String get websites_openRestyPerformanceTitle => 'Performance';

  @override
  String get websites_createProxyTitle => 'New reverse proxy';

  @override
  String get websites_createStaticTitle => 'New static site';

  @override
  String get websites_createRuntimeTitle => 'New runtime site';

  @override
  String get websites_createStreamTitle => 'New TCP-UDP proxy';

  @override
  String get websites_openRestyReading => 'Reading';

  @override
  String get websites_openRestyWriting => 'Writing';

  @override
  String get websites_openRestyWaiting => 'Waiting';

  @override
  String get websites_openRestyServiceHint =>
      'Start OpenResty from the service menu first.';

  @override
  String get websites_openRestyInstallHint =>
      'Install OpenResty before changing global settings.';

  @override
  String websites_openRestyServiceConfirm(Object action) {
    return 'Run \"$action\" on OpenResty?';
  }

  @override
  String get websites_createDb => 'Create database';

  @override
  String get websites_dbName => 'Database name';

  @override
  String get websites_enableFtp => 'Create FTP';

  @override
  String get websites_ftpUser => 'FTP user';

  @override
  String get websites_ftpPassword => 'FTP password';

  @override
  String get common_success => 'Success';

  @override
  String get common_failed => 'Failed';

  @override
  String get common_unknown => 'Unknown';

  @override
  String get logs_source => 'Source';

  @override
  String get logs_address => 'Location';

  @override
  String get logs_device => 'Device';

  @override
  String get taskLog_copy => 'Copy log';

  @override
  String get taskLog_copied => 'Copied';

  @override
  String get taskLog_emptyTitle => 'No log yet';

  @override
  String get taskLog_readFailedTitle => 'Failed to read task log';

  @override
  String get taskLog_executing => 'Running';

  @override
  String get taskLog_expired => 'The log for this task has been cleaned';

  @override
  String taskLog_lines(int count) {
    return '$count lines';
  }

  @override
  String get common_custom => 'Custom';

  @override
  String get ai_channel_qqBot => 'QQ Bot';

  @override
  String get ai_channel_weixin => 'Weixin';

  @override
  String get error_wsPreflightFailed =>
      'Failed to establish realtime connection';

  @override
  String get error_wsPreflightTimeout => 'Realtime connection timed out';

  @override
  String get runtimes_packageManager => 'Package manager';

  @override
  String get websites_sslId => 'SSL ID';

  @override
  String get ai_mcp_gatewayImage => 'Gateway image';

  @override
  String get common_installing => 'Installing';

  @override
  String get common_restarting => 'Restarting';

  @override
  String get common_paused => 'Paused';

  @override
  String get common_abnormal => 'Abnormal';

  @override
  String get logs_authMode => 'Auth method';

  @override
  String get logs_user => 'User';

  @override
  String get logs_apiKey => 'API key';

  @override
  String get logs_message => 'Error message';

  @override
  String get common_removing => 'Removing';

  @override
  String get logs_result => 'Result';

  @override
  String get ai_agent_plugins => 'Plugins';

  @override
  String get ai_agent_skills => 'Skills';

  @override
  String get ai_plugin_installed => 'Installed plugins';

  @override
  String get ai_plugin_market => 'Plugin marketplace';

  @override
  String get ai_plugin_searchHint => 'Search plugins';

  @override
  String get ai_plugin_enable => 'Enable';

  @override
  String get ai_plugin_disable => 'Disable';

  @override
  String get ai_plugin_version => 'Version';

  @override
  String get ai_plugin_install => 'Install';

  @override
  String get ai_plugin_empty => 'No installed plugins';

  @override
  String get ai_plugin_noResults => 'No matching plugins';

  @override
  String get ai_skill_installed => 'Installed skills';

  @override
  String get ai_skill_market => 'Skill marketplace';

  @override
  String get ai_skill_searchHint => 'Search skills';

  @override
  String get ai_skill_source => 'Source';

  @override
  String get ai_skill_install => 'Install';

  @override
  String get ai_skill_uninstall => 'Uninstall';

  @override
  String get ai_skill_empty => 'No installed skills';

  @override
  String get ai_skill_noResults => 'No matching skills';

  @override
  String get ai_model_syncAccount => 'Sync to account';

  @override
  String get ai_model_recreate => 'Recreate';

  @override
  String get ai_model_baseUrlType => 'Address type';

  @override
  String get ai_model_baseUrl => 'Base URL';

  @override
  String get ai_gpu_monitor => 'GPU monitor';

  @override
  String get ai_gpu_benchmark => 'Benchmark sources';

  @override
  String get ai_gpu_benchmarkEmpty => 'No benchmark sources';

  @override
  String get ai_gpu_utilizationChart => 'GPU utilization';

  @override
  String get ai_gpu_memoryChart => 'Memory usage';

  @override
  String get ai_model_baseUrlContainer => 'Container';

  @override
  String get ai_model_baseUrlLocalhost => 'Localhost';

  @override
  String get ai_model_baseUrlSystemIp => 'Panel IP';

  @override
  String get ai_model_baseUrlCustom => 'Custom';

  @override
  String get ai_skill_sourceOfficial => 'Official';

  @override
  String get ai_skill_sourceClawhubGlobal => 'ClawHub global';

  @override
  String get ai_skill_sourceClawhubCn => 'ClawHub China';

  @override
  String get ai_skill_sourceSkillhub => 'SkillHub';

  @override
  String get ai_skill_sourceSkillsSh => 'skills.sh';

  @override
  String get ai_skill_sourceLocalHub => 'Local skill hub';

  @override
  String get ai_vllm_monitor => 'vLLM monitor';

  @override
  String get ai_vllm_app => 'vLLM app';

  @override
  String get ai_vllm_noApps => 'No vLLM apps found';

  @override
  String get ai_vllm_samples => 'Samples';

  @override
  String get ai_vllm_running => 'Running requests';

  @override
  String get ai_vllm_waiting => 'Waiting requests';

  @override
  String get ai_vllm_cache => 'Cache usage';

  @override
  String get ai_agent_sessions => 'Chat sessions';

  @override
  String get ai_session_rename => 'Rename session';

  @override
  String get ai_session_delete => 'Delete session';

  @override
  String get ai_agent_batch => 'Batch operations';

  @override
  String get ai_batch_type => 'App type';

  @override
  String get ai_batch_operate => 'Operation';

  @override
  String get ai_batch_start => 'Start';

  @override
  String get ai_batch_stop => 'Stop';

  @override
  String get ai_batch_restart => 'Restart';

  @override
  String get ai_batch_delete => 'Delete';

  @override
  String get ai_batch_force => 'Force delete';

  @override
  String ai_batch_result(int success, int skipped) {
    return 'Succeeded $success, skipped $skipped';
  }

  @override
  String get ai_agent_overview => 'Agent overview';

  @override
  String get ai_vllm_clean => 'Clean monitor data';

  @override
  String get dashboard_nodeInfo => 'Node info';

  @override
  String get dashboard_quickJumps => 'Quick jumps';

  @override
  String get dashboard_manageQuick => 'Manage quick jumps and directories';

  @override
  String get dashboard_quickDirectories => 'Quick directories';

  @override
  String get dashboard_quickDirectoryPath => 'Directory path';

  @override
  String get dashboard_quickDirectoryAlias => 'Alias';

  @override
  String get dashboard_launcher => 'App launcher';

  @override
  String get dashboard_manageLauncher => 'Manage launcher';

  @override
  String get dashboard_topCpu => 'Top CPU processes';

  @override
  String get dashboard_topMem => 'Top memory processes';

  @override
  String get dashboard_noData => 'No data';

  @override
  String get dashboard_appInstalled => 'Installed';

  @override
  String get dashboard_appNotInstalled => 'Not installed';

  @override
  String get dashboard_addQuickDirectory => 'Add quick directory';

  @override
  String get dashboard_editQuickDirectory => 'Edit quick directory';

  @override
  String get files_openShare => 'Open share';

  @override
  String get backups_editDescription => 'Edit description';

  @override
  String get backups_snapshotFiles => 'Snapshot files';

  @override
  String get backups_noSnapshotFiles => 'No snapshot files';

  @override
  String get cronjobs_nextRun => 'Next run';

  @override
  String get cronjobs_updateGroup => 'Change group';

  @override
  String get apps_checkUpdates => 'Check store updates';

  @override
  String get apps_storeCanUpdate => 'App store update available';

  @override
  String get apps_storeLatest => 'App store is up to date';

  @override
  String get apps_editWebUi => 'Edit WebUI URL';

  @override
  String get apps_webUi => 'WebUI URL';

  @override
  String get alerts_clamScans => 'Clam scans';

  @override
  String get alerts_cronjobTargets => 'Cron jobs';

  @override
  String get alerts_targetsEmpty => 'No alert targets available';

  @override
  String alerts_targetPath(String path) {
    return 'Path: $path';
  }

  @override
  String alerts_targetType(String type) {
    return 'Type: $type';
  }

  @override
  String get host_sshLogs => 'SSH login logs';

  @override
  String get host_sshLogsHint => 'View and filter SSH login records';

  @override
  String get host_sshLogInfo => 'Keyword';

  @override
  String get host_sshLogInfoHint => 'User, IP or message';

  @override
  String get host_sshLogStatus => 'Status';

  @override
  String get host_sshLogAll => 'All';

  @override
  String get host_sshLogSuccess => 'Success';

  @override
  String get host_sshLogFailed => 'Failed';

  @override
  String get host_sshLogRange => 'Time range';

  @override
  String host_sshLogDays(String days) {
    return '$days days';
  }

  @override
  String get host_sshLogEmpty => 'No SSH login logs match the filters';

  @override
  String get host_sshLogExport => 'Export logs';

  @override
  String host_sshLogExported(String path) {
    return 'Logs exported to $path';
  }

  @override
  String get host_sshLogSearch => 'Search';

  @override
  String get ai_batch_operation => 'Batch operate';

  @override
  String get ai_batch_install => 'Batch install';

  @override
  String get ai_batch_upgrade => 'Batch upgrade';

  @override
  String get ai_batch_version => 'Target version';

  @override
  String get ai_batch_backup => 'Backup before upgrade';

  @override
  String get ai_batch_pullImage => 'Pull image';

  @override
  String get ai_batch_port => 'WebUI port';

  @override
  String get ai_batch_name => 'Name (auto when empty)';

  @override
  String get ai_agent_security => 'Security config';

  @override
  String get ai_agent_security_origins => 'Allowed origins';

  @override
  String get ai_agent_security_hint => 'Separate multiple origins with commas';

  @override
  String get ai_agent_config_file => 'Agent config file';

  @override
  String get ai_agent_config_file_hint =>
      'Edit the channel config file directly';

  @override
  String get ai_domain => 'AI domain binding';

  @override
  String get ai_domain_name => 'Domain';

  @override
  String get ai_domain_ssl => 'SSL ID';

  @override
  String get ai_domain_website => 'Website ID';

  @override
  String get ai_domain_ipList => 'Allowed IPs';

  @override
  String get ai_domain_hint => 'Separate multiple IPs with commas';

  @override
  String get ai_domain_noApp => 'No installed Ollama app found';

  @override
  String ai_domain_bound(String domain) {
    return 'Bound domain: $domain';
  }

  @override
  String get ai_domain_saved => 'Domain settings saved';

  @override
  String get files_batchMove => 'Batch move/copy';

  @override
  String get files_pickFromTree => 'Pick from directory tree';

  @override
  String get vm_title => 'Virtual machines';

  @override
  String get vm_subtitle => 'KVM virtual machine management';

  @override
  String get vm_environment => 'Runtime environment';

  @override
  String get vm_envReady => 'Runtime environment ready';

  @override
  String get vm_envNotReady => 'Runtime environment not ready';

  @override
  String get vm_enable => 'Enable runtime environment';

  @override
  String get vm_enabled => 'Runtime environment enabled';

  @override
  String get vm_arch => 'Architecture';

  @override
  String get vm_kvm => 'KVM';

  @override
  String get vm_libvirt => 'libvirt';

  @override
  String get vm_storage => 'Storage';

  @override
  String get vm_empty => 'No virtual machines';

  @override
  String get vm_emptyHint =>
      'Enable the KVM runtime environment before creating a VM';

  @override
  String get vm_create => 'New virtual machine';

  @override
  String get vm_update => 'Edit virtual machine';

  @override
  String get vm_name => 'Name';

  @override
  String get vm_cpu => 'CPU cores';

  @override
  String get vm_memory => 'Memory (MB)';

  @override
  String get vm_disk => 'Disk (GB)';

  @override
  String get vm_network => 'Network';

  @override
  String get vm_osType => 'OS type';

  @override
  String get vm_description => 'Description';

  @override
  String get vm_start => 'Start';

  @override
  String get vm_shutdown => 'Shut down';

  @override
  String get vm_reboot => 'Reboot';

  @override
  String get vm_destroy => 'Force stop';

  @override
  String get vm_suspend => 'Suspend';

  @override
  String get vm_resume => 'Resume';

  @override
  String get vm_delete => 'Delete virtual machine';

  @override
  String get vm_rename => 'Rename';

  @override
  String get vm_newName => 'New name';

  @override
  String get vm_stats => 'Runtime status';

  @override
  String get vm_snapshots => 'Snapshots';

  @override
  String get vm_snapshotCreate => 'Create snapshot';

  @override
  String get vm_snapshotName => 'Snapshot name';

  @override
  String get vm_snapshotRecover => 'Recover snapshot';

  @override
  String get vm_snapshotDelete => 'Delete snapshot';

  @override
  String get vm_snapshotEmpty => 'No snapshots';

  @override
  String get vm_needEnv => 'Enable the VM runtime environment first';

  @override
  String vm_confirmDelete(String name) {
    return 'Delete virtual machine $name?';
  }

  @override
  String get vm_forceDelete => 'Force delete';

  @override
  String get vm_startAfterCreate => 'Start after creation';

  @override
  String get vm_autoStart => 'Start on boot';

  @override
  String vm_limit(String limit) {
    return 'Quota $limit VMs';
  }

  @override
  String get vm_osOther => 'Other';

  @override
  String get vm_sync => 'Sync virtual machines';

  @override
  String get vm_storagePool => 'Storage pool';

  @override
  String get vm_template => 'Template (optional)';

  @override
  String get vm_osLinux => 'Linux';

  @override
  String get vm_osWindows => 'Windows';

  @override
  String get ai_account_discover => 'Discover models';

  @override
  String get ai_account_discover_empty => 'No models found';

  @override
  String ai_account_discover_result(String count) {
    return 'Found $count models';
  }

  @override
  String get ai_channel_plugins => 'Channel plugins';

  @override
  String get ai_channel_installed => 'Installed';

  @override
  String get ai_channel_notInstalled => 'Not installed';

  @override
  String ai_channel_upgradable(String version) {
    return 'Upgrade to $version';
  }

  @override
  String get ai_channel_install => 'Install plugin';

  @override
  String get ai_channel_upgrade => 'Upgrade plugin';

  @override
  String get ai_channel_uninstall => 'Uninstall plugin';

  @override
  String get vm_resources => 'Resources';

  @override
  String get vm_networks => 'Networks';

  @override
  String get vm_storages => 'Storages';

  @override
  String get vm_templates => 'Templates';

  @override
  String get vm_isos => 'ISO images';

  @override
  String get vm_type => 'Type';

  @override
  String get vm_path => 'Path';

  @override
  String get vm_cidr => 'CIDR';

  @override
  String get vm_gateway => 'Gateway';

  @override
  String get vm_sourceInterface => 'Source interface';

  @override
  String get vm_templateName => 'Template name';

  @override
  String get vm_sourceVm => 'Source virtual machine';

  @override
  String get vm_isoType => 'Image type';

  @override
  String get vm_resourceEmpty => 'No resources';

  @override
  String vm_deleteResource(String name) {
    return 'Delete $name?';
  }

  @override
  String get vm_deleteFile => 'Delete file as well';

  @override
  String get vm_isoImage => 'ISO image';

  @override
  String get vm_isoDisk => 'Disk';

  @override
  String get vm_netNat => 'NAT';

  @override
  String get vm_netBridge => 'Bridge';

  @override
  String get vm_netMacvtap => 'Macvtap';

  @override
  String get ai_channel_pairing => 'Approve pairing';

  @override
  String get ai_channel_pairingCode => 'Pairing code';

  @override
  String get ai_channel_pairingAccount => 'Account ID (optional)';

  @override
  String get ai_channel_pairingApproved => 'Pairing approved';

  @override
  String get ai_channel_feishu => 'Feishu';

  @override
  String get ai_channel_telegram => 'Telegram';

  @override
  String get ai_channel_discord => 'Discord';

  @override
  String get ai_channel_wecom => 'WeCom';

  @override
  String get ai_channel_qqbot => 'QQBot';

  @override
  String get ai_channel_dingtalk => 'DingTalk';

  @override
  String get vm_console => 'Console';

  @override
  String get vm_consoleConnecting => 'Connecting to console…';

  @override
  String get vm_consoleFailed => 'Console connection failed';

  @override
  String get vm_consoleHint =>
      'Drag to move the pointer, use the keyboard to type';

  @override
  String get vm_consoleDisconnected => 'Console disconnected';

  @override
  String get websites_clearLog => 'Clear logs';

  @override
  String get websites_logType => 'Log type';

  @override
  String get websites_lbEditFile => 'Edit source file';

  @override
  String get websites_lbFileHint =>
      'Edit the load balance configuration directly';

  @override
  String get websites_streamPorts => 'Listen ports';

  @override
  String get websites_streamName => 'Upstream name';

  @override
  String get websites_streamAlgorithm => 'Algorithm';

  @override
  String get websites_streamServer => 'Backend address';

  @override
  String get websites_streamUdp => 'UDP forwarding';

  @override
  String get websites_lbRoundRobin => 'Round robin';

  @override
  String get websites_lbLeastConnections => 'Least connections';

  @override
  String get websites_lbIpHashShort => 'IP hash';

  @override
  String get websites_parentWebsite => 'Parent website';

  @override
  String get websites_subsitePath => 'Subsite directory';

  @override
  String get websites_deploymentApp => 'Application';

  @override
  String get websites_templatePreview => 'Preview template';

  @override
  String get websites_deploymentRunning => 'Application is running and ready';

  @override
  String get websites_deploymentStopped =>
      'Application is stopped; start it first';

  @override
  String get websites_templatePreviewResult => 'Preview result';

  @override
  String get websites_templatePreviewFailed => 'No preview available';

  @override
  String get websites_templateOutputDetail => 'Output detail';

  @override
  String get websites_templateOutputTemplate => 'Template';

  @override
  String get websites_templateOutputVariables => 'Variable values';

  @override
  String get websites_templateOutputCreatedAt => 'Created at';

  @override
  String get websites_templateOutputPath => 'Output path';

  @override
  String get panelSettings_aiSettings => 'AI settings';

  @override
  String get panelSettings_aiSettingsHint =>
      'Terminal and file management AI assistant';

  @override
  String get panelSettings_terminalAi => 'Terminal AI';

  @override
  String get panelSettings_fileAi => 'File AI';

  @override
  String get panelSettings_aiEnabled => 'Enable AI';

  @override
  String get panelSettings_aiPrefix => 'Trigger prefix';

  @override
  String get panelSettings_aiAccount => 'AI account ID';

  @override
  String get panelSettings_aiAccountHint => 'Enter a configured AI account ID';

  @override
  String get panelSettings_aiRiskCommands => 'Risk command prompt';

  @override
  String get panelSettings_aiRiskCommandsHint =>
      'Describe risky commands to block';

  @override
  String get panelSettings_fileHistory => 'File history';

  @override
  String get panelSettings_fileHistoryHint =>
      'Revision history and quota for configuration files';

  @override
  String get panelSettings_fileHistoryEnable => 'Enable file history';

  @override
  String get panelSettings_fileHistoryMaxPerPath => 'Revisions per path';

  @override
  String get panelSettings_fileHistoryQuota => 'Disk quota (MB)';

  @override
  String get panelSettings_localSsh => 'Local SSH connection';

  @override
  String get panelSettings_localSshHint => 'SSH credentials for the panel host';

  @override
  String get panelSettings_testConnection => 'Test connection';

  @override
  String get panelSettings_sshCheckOk => 'SSH connection is healthy';

  @override
  String get panelSettings_sshRequired => 'Address and user are required';

  @override
  String get panelSettings_sshAddress => 'Address';

  @override
  String get panelSettings_sshPort => 'Port';

  @override
  String get panelSettings_sshUser => 'Username';

  @override
  String get panelSettings_sshAuthMode => 'Authentication';

  @override
  String get panelSettings_sshAuthPassword => 'Password';

  @override
  String get panelSettings_sshAuthKey => 'Key';

  @override
  String get panelSettings_sshPassword => 'Password';

  @override
  String get panelSettings_sshPrivateKey => 'Private key';

  @override
  String get panelSettings_sshPassPhrase => 'Key passphrase';

  @override
  String get panelSettings_defaultSshConn => 'Default terminal connection';

  @override
  String get panelSettings_defaultSshConnHint =>
      'Connection used when opening the terminal';

  @override
  String get panelSettings_defaultSshConnPlaceholder =>
      'Enter a connection name or address';

  @override
  String get panelSettings_resetMenu => 'Restore default menu';

  @override
  String get panelSettings_resetMenuHint =>
      'Restore the panel menu to default visibility';

  @override
  String get panelSettings_resetMenuConfirm => 'Restore the default menu?';

  @override
  String get websites_openRestyModules => 'OpenResty modules';

  @override
  String get websites_openRestyModuleAdd => 'Add module';

  @override
  String get websites_openRestyModuleDelete => 'Delete module';

  @override
  String websites_openRestyModuleDeleteConfirm(Object name) {
    return 'Delete module $name?';
  }

  @override
  String get websites_openRestyModuleEmpty => 'No custom modules';

  @override
  String get websites_openRestyModuleName => 'Module name';

  @override
  String get websites_openRestyModuleProvider => 'Provider';

  @override
  String get websites_openRestyModuleBuildMode => 'Build mode';

  @override
  String get websites_openRestyModuleLoadOrder => 'Load order';

  @override
  String get websites_openRestyModulePackages => 'Packages';

  @override
  String get websites_openRestyModuleParams => 'Build parameters';

  @override
  String get websites_openRestyModuleScript => 'Build script';

  @override
  String get websites_openRestyBuild => 'Build OpenResty';

  @override
  String get websites_openRestyBuildHint =>
      'Select modules and rebuild in the background';

  @override
  String get websites_openRestyBuildModules => 'Modules to build';

  @override
  String get websites_openRestyMirror => 'Download mirror';

  @override
  String get websites_openRestyForce => 'Force rebuild';

  @override
  String get websites_openRestyBuildSubmitted => 'Build task submitted';

  @override
  String get websites_openRestyHttps => 'Default HTTPS';

  @override
  String get websites_openRestyHttpsHint =>
      'Control HTTPS behavior for the default site';

  @override
  String get websites_openRestyHttpsReject => 'Reject unmatched SSL handshakes';

  @override
  String get logs_systemServices => 'System service logs';

  @override
  String get logs_systemFiles => 'Log files';

  @override
  String get logs_service => 'Service';

  @override
  String get logs_serviceAll => 'All services';

  @override
  String get logs_priority => 'Priority';

  @override
  String get logs_priorityAll => 'All priorities';

  @override
  String get logs_keyword => 'Keyword';

  @override
  String get logs_loadMore => 'Load more';

  @override
  String get logs_noSystemLog => 'No system logs';

  @override
  String get toolbox_updateVirusDatabase => 'Update virus database';

  @override
  String get toolbox_updateVirusDatabaseHint =>
      'Fetch the latest ClamAV signatures';

  @override
  String get toolbox_enableScan => 'Enable scan rule';

  @override
  String get toolbox_disableScan => 'Disable scan rule';

  @override
  String get toolbox_clamConfigFile => 'Scan configuration file';

  @override
  String get toolbox_ftpEdit => 'Edit FTP account';

  @override
  String get toolbox_ftpPasswordKeep =>
      'Leave empty to keep the current password';

  @override
  String get toolbox_ftpStatus => 'Status';

  @override
  String get toolbox_ftpService => 'FTP service actions';

  @override
  String get toolbox_ftpStart => 'Start';

  @override
  String get toolbox_ftpStop => 'Stop';

  @override
  String get toolbox_ftpRestart => 'Restart';

  @override
  String get toolbox_ftpReload => 'Reload';

  @override
  String get toolbox_ftpSync => 'Sync FTP accounts';

  @override
  String get toolbox_ftpSyncDone => 'FTP accounts synced';

  @override
  String get toolbox_ftpLogs => 'FTP operation logs';

  @override
  String get toolbox_ftpLogEmpty => 'No operation logs';

  @override
  String get toolbox_fail2banConfFile => 'Fail2ban configuration file';

  @override
  String get toolbox_fail2banConfFileHint =>
      'View and update the full jail configuration';

  @override
  String get panelSettings_panelUpgrade => 'Panel upgrade';

  @override
  String get panelSettings_panelUpgradeHint =>
      'Check for and install 1Panel updates';

  @override
  String get panelSettings_upgradeAvailable => 'New version available';

  @override
  String get panelSettings_upToDate => 'Already up to date';

  @override
  String panelSettings_upgradeTo(Object version) {
    return 'Upgrade to $version';
  }

  @override
  String panelSettings_upgradeConfirm(Object version) {
    return 'The panel will upgrade to $version. Services restart briefly.';
  }

  @override
  String get panelSettings_upgradeSubmitted => 'Upgrade task submitted';

  @override
  String get panelSettings_latestVersion => 'Latest version';

  @override
  String get panelSettings_testVersion => 'Test version';

  @override
  String get panelSettings_releaseNotesTitle => 'Release history';

  @override
  String panelSettings_newCount(Object count) {
    return '$count new';
  }

  @override
  String panelSettings_fixCount(Object count) {
    return '$count fixes';
  }

  @override
  String panelSettings_optimizationCount(Object count) {
    return '$count optimizations';
  }

  @override
  String get backups_publicAccount => 'Panel-level backup account';

  @override
  String get backups_publicAccountHint =>
      'Stored on the panel and shared across nodes';

  @override
  String get panelSettings_sshCheckFailed => 'SSH connection failed';

  @override
  String get panelSettings_loadFailed =>
      'Failed to load settings. Please retry.';

  @override
  String get panelSettings_noReleaseNotes => 'No release notes yet';

  @override
  String get toolbox_ftpPasswordRequired => 'Enter a new FTP password';

  @override
  String get toolbox_loadFailed => 'Failed to load. Please retry.';

  @override
  String get toolbox_clamAdd => 'New scan task';

  @override
  String get websites_groupCreate => 'New group';

  @override
  String get websites_groupMergeEmpty => 'No other group to merge into';

  @override
  String get websites_templateNameRequired => 'Enter a template name';

  @override
  String get websites_templateFileRequired => 'Upload the template file';

  @override
  String get websites_templateOutputNameRequired => 'Enter an output name';

  @override
  String get logs_loadFailed => 'Failed to load logs. Please retry.';

  @override
  String get host_sshLogLoadFailed => 'Failed to load SSH logs';

  @override
  String vm_forceStopConfirm(Object name) {
    return 'Force stop $name? Data loss is possible.';
  }

  @override
  String vm_snapshotRecoverConfirm(Object name) {
    return 'Restore snapshot $name? The current state will be replaced.';
  }

  @override
  String vm_snapshotDeleteConfirm(Object name) {
    return 'Delete snapshot $name?';
  }

  @override
  String get vm_statsCpu => 'CPU';

  @override
  String get vm_statsMemory => 'Memory';

  @override
  String get vm_statsDisk => 'Disk R/W';

  @override
  String get vm_statsNetwork => 'Network RX/TX';

  @override
  String get websites_openRestyHttpsLoadFailed =>
      'Failed to load HTTPS settings';

  @override
  String get toolbox_ftpServiceConfirm =>
      'This interrupts active FTP connections. Continue?';

  @override
  String get toolbox_fail2banStop => 'Stop Fail2ban';

  @override
  String get toolbox_fail2banStopConfirm =>
      'Brute-force protection stops until restarted. Continue?';

  @override
  String get panelMcp_title => 'MCP';

  @override
  String get panelMcp_subtitle =>
      'Panel MCP service, credentials and invocations';

  @override
  String get panelMcp_service => 'MCP service';

  @override
  String get panelMcp_notInstalled => 'Not installed';

  @override
  String get panelMcp_installed => 'Installed';

  @override
  String get panelMcp_ready => 'Ready';

  @override
  String get panelMcp_serviceRunning => 'Service running';

  @override
  String get panelMcp_serviceStopped => 'Service stopped';

  @override
  String get panelMcp_install => 'Install MCP service';

  @override
  String get panelMcp_start => 'Start';

  @override
  String get panelMcp_stop => 'Stop';

  @override
  String get panelMcp_restart => 'Restart';

  @override
  String get panelMcp_logs => 'Service logs';

  @override
  String get panelMcp_settings => 'Runtime settings';

  @override
  String get panelMcp_endpoint => 'Endpoint';

  @override
  String get panelMcp_runtimeType => 'Runtime type';

  @override
  String get panelMcp_dockerImage => 'Docker image';

  @override
  String get panelMcp_listenPort => 'Listen port';

  @override
  String get panelMcp_externalUrl => 'External URL';

  @override
  String get panelMcp_accessPolicy => 'Access policy';

  @override
  String get panelMcp_allowedIPs => 'Allowed IPs';

  @override
  String get panelMcp_allowedIPsHint => 'One IP or CIDR per line';

  @override
  String get panelMcp_saveSettings => 'Save settings';

  @override
  String get panelMcp_website => 'Website binding';

  @override
  String get panelMcp_unbound => 'Unbound';

  @override
  String get panelMcp_bound => 'Bound';

  @override
  String get panelMcp_domain => 'Domain';

  @override
  String get panelMcp_enableSsl => 'Enable SSL';

  @override
  String get panelMcp_sslId => 'SSL ID';

  @override
  String get panelMcp_bindWebsite => 'Bind website';

  @override
  String get panelMcp_updateWebsite => 'Update binding';

  @override
  String get panelMcp_unbindWebsite => 'Unbind website';

  @override
  String get panelMcp_deleteWebsite => 'Delete linked website';

  @override
  String panelMcp_unbindConfirm(String domain) {
    return 'Unbind MCP website $domain?';
  }

  @override
  String get panelMcp_credentials => 'Credentials';

  @override
  String get panelMcp_createCredential => 'Create credential';

  @override
  String get panelMcp_editCredential => 'Edit credential';

  @override
  String get panelMcp_credentialName => 'Credential name';

  @override
  String get panelMcp_credentialDescription => 'Description';

  @override
  String get panelMcp_expiresAt => 'Expires at (ISO 8601, optional)';

  @override
  String get panelMcp_tools => 'Allowed tools';

  @override
  String get panelMcp_nodes => 'Nodes';

  @override
  String get panelMcp_noCredentials => 'No MCP credentials';

  @override
  String get panelMcp_noInvocations => 'No MCP invocations';

  @override
  String get panelMcp_invocations => 'Invocations';

  @override
  String get panelMcp_tool => 'Tool';

  @override
  String get panelMcp_credential => 'Credential';

  @override
  String get panelMcp_revealToken => 'Reveal token';

  @override
  String get panelMcp_rotateToken => 'Rotate token';

  @override
  String get panelMcp_exportCredential => 'Export enrollment';

  @override
  String get panelMcp_revoke => 'Revoke';

  @override
  String panelMcp_revokeConfirm(String name) {
    return 'Revoke credential $name?';
  }

  @override
  String panelMcp_deleteConfirm(String name) {
    return 'Delete credential $name?';
  }

  @override
  String get panelMcp_tokenTitle => 'MCP token';

  @override
  String get panelMcp_tokenHint =>
      'Copy this token now. It will not be shown again.';

  @override
  String get panelMcp_exportTitle => 'Enrollment document';

  @override
  String get panelMcp_exportClient => 'Client';

  @override
  String get panelMcp_exportClientHint => 'For example: claude, cursor, vscode';

  @override
  String get panelMcp_catalog => 'Tool catalog';

  @override
  String get panelMcp_catalogHint => 'Tools available to this panel';

  @override
  String panelMcp_serviceConfirm(String operation) {
    return 'Operate MCP service: $operation?';
  }

  @override
  String get panelMcp_requiredFields => 'Fill in required fields';

  @override
  String get panelMcp_status => 'Status';

  @override
  String get panelMcp_reason => 'Reason';

  @override
  String get panelMcp_noNodes => 'No nodes';

  @override
  String get panelMcp_operationCompleted => 'Operation completed';

  @override
  String get panelMcp_loadFailed => 'Failed to load MCP data';

  @override
  String get panelMcp_createSuccess => 'Credential created';

  @override
  String get panelMcp_revision => 'Revision';

  @override
  String panelMcp_pending(String operation) {
    return 'Pending request: $operation';
  }

  @override
  String get panelMcp_sslHint => 'Required when SSL is enabled';

  @override
  String get panelMcp_websiteState => 'Website state';

  @override
  String get panelMcp_installing => 'Installing MCP service';

  @override
  String get panelMcp_taskId => 'Task ID';

  @override
  String get panelMcp_saved => 'MCP settings saved';

  @override
  String panelMcp_toolsCount(int count) {
    return '$count tools';
  }

  @override
  String get panelMcp_tokenCopied => 'Token copied';

  @override
  String get ai_gpuGroups => 'GPU groups';

  @override
  String get ai_gpuGroupsEmpty => 'No GPU groups';

  @override
  String get ai_gpuGroupAdd => 'Add GPU group';

  @override
  String get ai_gpuGroupEdit => 'Edit GPU group';

  @override
  String get ai_gpuGroupName => 'Group name';

  @override
  String get ai_gpuGroupDescription => 'Description';

  @override
  String get ai_gpuGroupImageType => 'GPU type';

  @override
  String get ai_gpuGroupDevices => 'GPU devices';

  @override
  String get ai_gpuGroupCapabilities => 'Capabilities (comma separated)';

  @override
  String ai_gpuGroupDeleteConfirm(String name) {
    return 'Delete GPU group $name?';
  }

  @override
  String get ai_gpuUsage => 'GPU usage check';

  @override
  String get ai_gpuUsageCompose => 'Docker Compose';

  @override
  String get ai_gpuUsageEnv => 'Environment variables';

  @override
  String get ai_gpuUsageResult => 'GPU usage result';

  @override
  String get ai_gpuUsageWarnings => 'Warnings';

  @override
  String get ai_gpuUsagePossible => 'Possible deployments';

  @override
  String get ai_chat_title => 'Model chat';

  @override
  String get ai_chat_model => 'Model';

  @override
  String get ai_chat_input => 'Message';

  @override
  String get ai_chat_send => 'Send';

  @override
  String get ai_chat_empty => 'Send a message to test this model';

  @override
  String get ai_chat_failed => 'Chat failed';

  @override
  String get ai_chat_stop => 'Stop';

  @override
  String get ai_chat_noModels => 'No models configured for this account';

  @override
  String get ai_agent_otherConfig => 'Other configuration';

  @override
  String get ai_agent_otherTimezone => 'User timezone';

  @override
  String get ai_agent_otherBrowser => 'Enable browser';

  @override
  String get ai_agent_otherNpm => 'NPM registry';

  @override
  String get ai_agent_otherUsername => 'Dashboard username';

  @override
  String get ai_agent_otherPassword => 'Dashboard password';

  @override
  String get ai_agent_markdown => 'Markdown files';

  @override
  String get ai_agent_markdownEmpty => 'No markdown files';

  @override
  String get ai_agent_markdownContent => 'Content';

  @override
  String get ai_agent_batchSkill => 'Batch install skill';

  @override
  String get ai_agent_skillName => 'Skill name';

  @override
  String get ai_agent_skillPackage => 'Package path';

  @override
  String get ai_agent_feishuSwitch => 'Switch Feishu plugin';

  @override
  String get ai_agent_groupScope => 'Group session scope';

  @override
  String get ai_agent_requireMention => 'Require mention';

  @override
  String get ai_agent_deleteResources => 'Resources linked to this agent';

  @override
  String get ai_agent_noDeleteResources => 'No linked resources';

  @override
  String get databases_editUser => 'Edit user';

  @override
  String get databases_savePassword => 'Save password locally';

  @override
  String get databases_grantsSummary => 'Grant summary';

  @override
  String get databases_commonInfo => 'Instance information';

  @override
  String get databases_editDescription => 'Edit description';

  @override
  String get databases_rootPassword => 'Root password';

  @override
  String get vm_resizeDisk => 'Resize disk';

  @override
  String get vm_diskTarget => 'Disk target';

  @override
  String get vm_diskSizeNew => 'New size (GiB)';

  @override
  String get vm_healthCheck => 'Health check';

  @override
  String get vm_healthPass => 'Passed';

  @override
  String get vm_healthWarn => 'Warnings';

  @override
  String get vm_healthFail => 'Failed';

  @override
  String get vm_orphans => 'Orphan resources';

  @override
  String get vm_orphansEmpty => 'No orphan resources';

  @override
  String get vm_orphansScan => 'Scan orphan resources';

  @override
  String get vm_orphansClean => 'Clean selected';

  @override
  String vm_cleanConfirm(int count) {
    return 'Delete $count orphan resources?';
  }

  @override
  String get runtime_phpConfig => 'PHP configuration';

  @override
  String get runtime_phpParams => 'PHP parameters (JSON)';

  @override
  String get runtime_disableFunctions => 'Disabled functions';

  @override
  String get runtime_uploadMaxSize => 'Upload limit';

  @override
  String get runtime_maxExecutionTime => 'Max execution time';

  @override
  String get runtime_container => 'PHP container';

  @override
  String get runtime_containerName => 'Container name';

  @override
  String get runtime_exposedPorts => 'Exposed ports (JSON)';

  @override
  String get runtime_environments => 'Environment variables (JSON)';

  @override
  String get runtime_volumes => 'Volumes (JSON)';

  @override
  String get runtime_extraHosts => 'Extra hosts (JSON)';

  @override
  String get runtime_jsonHint => 'Enter a valid JSON array';

  @override
  String get toolbox_hosts => 'Hosts file';

  @override
  String get toolbox_hostsEdit => 'Edit hosts file';

  @override
  String get toolbox_password => 'Root password';

  @override
  String get toolbox_passwordChanged => 'Root password updated';

  @override
  String get toolbox_dnsCheck => 'Test DNS resolution';

  @override
  String get toolbox_dnsOk => 'DNS resolution works';

  @override
  String get toolbox_dnsFail => 'DNS resolution failed';

  @override
  String get toolbox_systemClean => 'Clean system junk';

  @override
  String get toolbox_systemCleanConfirm => 'Clean scanned junk files?';

  @override
  String get toolbox_users => 'System users';

  @override
  String get toolbox_addHost => 'Add host entry';

  @override
  String get panelMcp_accessInherit => 'Inherit';

  @override
  String get panelMcp_accessAll => 'All';

  @override
  String get panelMcp_accessRestricted => 'Restricted';

  @override
  String get ai_gpuTypeNvidia => 'NVIDIA';

  @override
  String get ai_gpuTypeIntel => 'Intel';

  @override
  String get ai_gpuTypeAscend => 'Ascend';

  @override
  String get apps_linkedResources => 'Linked resources';

  @override
  String get files_wgetDetails => 'Download details';

  @override
  String files_wgetProgress(Object percent) {
    return 'Progress: $percent%';
  }

  @override
  String get files_wgetWaiting => 'Waiting for download progress...';

  @override
  String get runtime_presetNew => 'New extension preset';

  @override
  String get runtime_presetName => 'Preset name';

  @override
  String get runtime_presetExtensions => 'Extensions';

  @override
  String get runtime_presetExtensionsHint =>
      'Separate extensions with commas, e.g. redis,opcache';

  @override
  String get runtime_presetImport => 'Import extension preset';

  @override
  String get runtime_presetImported => 'Extension preset imported';

  @override
  String get runtime_presetSkipped =>
      'Preset already exists with the same content';

  @override
  String get runtime_presetPush => 'Push preset';

  @override
  String get runtime_presetSourceNode => 'Source node';

  @override
  String get runtime_presetTargetNodes => 'Target nodes';

  @override
  String get runtime_presetNodesHint => 'Separate nodes with commas';

  @override
  String runtime_presetDeleteConfirm(Object name) {
    return 'Delete extension preset \"$name\"?';
  }

  @override
  String get runtime_presetPushed => 'Push task submitted';

  @override
  String get runtime_supervisor => 'Supervisor';

  @override
  String get vm_isoSearch => 'Search ISO';

  @override
  String get vm_isoSearchHint => 'Name keyword';

  @override
  String get vm_isoCreateRecord => 'Add image record';

  @override
  String get vm_isoImport => 'Import from path';

  @override
  String get vm_networkInterfaces => 'Network interfaces';

  @override
  String get apps_sort => 'Installed app order';

  @override
  String get apps_sortHint => 'Smaller values appear first';

  @override
  String get apps_defaultConfig => 'Default config';

  @override
  String get apps_defaultConfigEmpty => 'No default config';

  @override
  String get databases_redisCliInstalled => 'redis-cli is installed';

  @override
  String get databases_redisCliMissing =>
      'redis-cli is missing; remote Redis terminal is unavailable';

  @override
  String get cronjobs_export => 'Export cron jobs';

  @override
  String get cronjobs_import => 'Import cron jobs';

  @override
  String get cronjobs_exported => 'Cron jobs exported';

  @override
  String get cronjobs_imported => 'Cron jobs imported';

  @override
  String get cronjobs_importEmpty => 'No cron jobs found in the file';

  @override
  String get websites_importCa => 'Import CA';

  @override
  String get websites_uploadCa => 'Upload CA archive';

  @override
  String get websites_caName => 'CA name';

  @override
  String get websites_importType => 'Import type';

  @override
  String get websites_importPaste => 'Paste certificate';

  @override
  String get websites_importLocal => 'Server files';

  @override
  String get websites_certificatePath => 'Certificate path';

  @override
  String ai_accountCountLabel(String name, int count) {
    return '$name: $count';
  }

  @override
  String get panelSettings_proxy => 'Server proxy';

  @override
  String get panelSettings_proxyHint =>
      'Configure HTTP/HTTPS/SOCKS5 proxy for outbound panel traffic';

  @override
  String get panelSettings_proxyType => 'Proxy type';

  @override
  String get panelSettings_proxyHttp => 'HTTP';

  @override
  String get panelSettings_proxyHttps => 'HTTPS';

  @override
  String get panelSettings_proxySocks5 => 'SOCKS5';

  @override
  String get panelSettings_proxyClose => 'Disable proxy';

  @override
  String get panelSettings_proxyUrl => 'Proxy host';

  @override
  String get panelSettings_proxyUrlHint =>
      'e.g. 127.0.0.1 or proxy.example.com';

  @override
  String get panelSettings_proxyPort => 'Proxy port';

  @override
  String get panelSettings_proxyUser => 'Proxy user';

  @override
  String get panelSettings_proxyPassword => 'Proxy password';

  @override
  String get panelSettings_proxyPasswordHint =>
      'Leave empty to clear the saved proxy password';

  @override
  String get panelSettings_proxyDocker => 'Proxy Docker too';

  @override
  String get panelSettings_proxyRestartDocker =>
      'Restart Docker after applying';

  @override
  String get panelSettings_proxyRequired => 'Enter proxy host and port';

  @override
  String get panelSettings_downloadPreference => 'Download preference';

  @override
  String get panelSettings_downloadPreferenceHint =>
      'Choose the filename used when downloading files';

  @override
  String get panelSettings_useServerFilename => 'Use server filename';

  @override
  String get panelSettings_useServerFilenameHint =>
      'Prefer the original filename returned by the server';

  @override
  String get panelSettings_downloadSsl => 'Download panel certificate';

  @override
  String get panelSettings_downloadSslHint =>
      'Export the panel self-signed SSL certificate for trust';

  @override
  String get panelSettings_terminalAppearance => 'Terminal appearance';

  @override
  String get panelSettings_terminalAppearanceHint =>
      'Adjust the font, colors and cursor of the panel web terminal';

  @override
  String get panelSettings_terminalBehavior => 'Terminal behavior';

  @override
  String get panelSettings_showTerminalButton => 'Show terminal button';

  @override
  String get panelSettings_showTerminalButtonHint =>
      'Show a shortcut to open the terminal in the panel';

  @override
  String get panelSettings_cursorBlink => 'Blinking cursor';

  @override
  String get panelSettings_cursorStyle => 'Cursor style';

  @override
  String get panelSettings_cursorBlock => 'Block';

  @override
  String get panelSettings_cursorUnderline => 'Underline';

  @override
  String get panelSettings_cursorBar => 'Bar';

  @override
  String get panelSettings_scrollback => 'Scrollback lines';

  @override
  String get panelSettings_scrollSensitivity => 'Scroll sensitivity';

  @override
  String get panelSettings_terminalTypography => 'Typography';

  @override
  String get panelSettings_fontFamily => 'Font family';

  @override
  String get panelSettings_fontFamilyHint =>
      'Leave empty to use the panel default font';

  @override
  String get panelSettings_fontSize => 'Font size';

  @override
  String get panelSettings_lineHeight => 'Line height';

  @override
  String get panelSettings_letterSpacing => 'Letter spacing';

  @override
  String get panelSettings_terminalColors => 'Colors';

  @override
  String get panelSettings_backgroundColor => 'Background color';

  @override
  String get panelSettings_foregroundColor => 'Foreground color';

  @override
  String get panelSettings_colorHint => 'Hex color such as #1e1e1e';

  @override
  String get panelSettings_registerPasskey => 'Register in browser';

  @override
  String get panelSettings_registerPasskeyHint =>
      'Browser registration also requires the bound panel domain over HTTPS';

  @override
  String get host_sshTerminal => 'SSH terminal';

  @override
  String get websites_editStream => 'Edit tunnel';

  @override
  String get cronjobs_pickScript => 'Choose from library';

  @override
  String get containers_createVolume => 'Create volume';

  @override
  String get containers_volumeName => 'Volume name';

  @override
  String get containers_volumeDriver => 'Driver';

  @override
  String get containers_volumeOptions => 'Driver options';

  @override
  String get containers_volumeLabels => 'Labels';

  @override
  String get containers_volumeKeyValueHint => 'One key=value pair per line';

  @override
  String get panelSettings_menuSettings => 'Menu settings';

  @override
  String get panelSettings_menuSettingsHint =>
      'Choose which panel menu entries are visible';

  @override
  String get panelSettings_menuSaveConfirm =>
      'Save the current menu visibility?';

  @override
  String get panelSettings_menuUpdated => 'Menu updated';

  @override
  String get panelSettings_menuEmpty => 'No menu entries';

  @override
  String get websites_importMasterSsl => 'Import master certificate';

  @override
  String get websites_sslStart => 'Valid from';

  @override
  String get websites_masterSslId => 'Master certificate ID';

  @override
  String get websites_domainsHint =>
      'Comma-separated domains; leave empty to use the primary domain';

  @override
  String get ai_agent_dm_policy => 'Direct message policy';

  @override
  String get ai_agent_policy_pairing => 'Pairing';

  @override
  String get ai_agent_policy_open => 'Open';

  @override
  String get ai_agent_policy_allowlist => 'Allowlist';

  @override
  String get ai_agent_policy_disabled => 'Disabled';

  @override
  String get ai_agent_allow_from => 'Allowed senders';

  @override
  String get ai_agent_allow_from_hint => 'Separate IDs with commas';

  @override
  String get ai_agent_group_allow_from => 'Allowed group senders';

  @override
  String get ai_agent_proxy => 'Proxy';

  @override
  String get ai_agent_default_account => 'Default account';

  @override
  String get ai_agent_streaming_off => 'Off';

  @override
  String get ai_agent_streaming_partial => 'Partial';

  @override
  String get ai_agent_streaming_block => 'Block';

  @override
  String get ai_agent_streaming_progress => 'Progress';

  @override
  String get ai_agent_group_session_scope => 'Group session scope';

  @override
  String get ai_agent_group_scope_group => 'Group';

  @override
  String get ai_agent_group_scope_sender => 'Group and sender';

  @override
  String get ai_agent_group_scope_topic => 'Group and topic';

  @override
  String get ai_agent_group_scope_topic_sender => 'Group, topic and sender';

  @override
  String get ai_agent_separate_session => 'Separate session per conversation';

  @override
  String get ai_agent_shared_memory => 'Share memory across conversations';

  @override
  String get ai_agent_async_mode => 'Async mode';

  @override
  String get ai_agent_ack_text => 'Acknowledgement text';

  @override
  String get ai_agent_bot_id => 'Bot ID';

  @override
  String get ai_agent_bot_secret => 'Bot secret';

  @override
  String get ai_agent_bot_token => 'Bot token';

  @override
  String get ai_agent_bot_app_id => 'App ID';

  @override
  String get ai_agent_bot_client_id => 'Client ID';

  @override
  String get ai_agent_bot_client_secret => 'Client secret';

  @override
  String get ai_agent_bot_system_prompt => 'System prompt';

  @override
  String get ai_agent_bot_name => 'Bot name';

  @override
  String get ai_agent_bot_default => 'Default bot';

  @override
  String get ai_agent_add_bot => 'Add bot';

  @override
  String get ai_agent_remove_bot => 'Remove bot';

  @override
  String get vm_bridgeName => 'Bridge name';

  @override
  String get vm_noBridges => 'No host bridges found';

  @override
  String get panelSettings_usePasskey => 'Sign in with passkey';

  @override
  String get panelSettings_passkeyLoginHint =>
      'Use a passkey saved for the bound panel domain';

  @override
  String get panelSettings_registerPasskeyDevice => 'Register on this device';

  @override
  String get panelSettings_passkeyName => 'Passkey name';

  @override
  String get panelSettings_passkeyPrereq =>
      'Requires the bound panel domain over HTTPS and Android assetlinks.json on that domain';
}
