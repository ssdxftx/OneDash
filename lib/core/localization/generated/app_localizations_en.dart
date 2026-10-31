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
  String get nav_containers => 'Containers';

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
  String panelSettings_alertCardMeta(String type, String method) {
    return 'Type: $type  Method: $method';
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
  String get dashboard_sites_containers => 'Sites and containers';

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
      'Create a site to serve a static folder or reverse proxy.';

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
  String get websites_php => 'PHP';

  @override
  String websites_expire_days(int days) {
    return '$days days left';
  }

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
  String get settings_text_scale => 'Text size';

  @override
  String get settings_interaction => 'Interaction';

  @override
  String get settings_haptics => 'Haptic feedback';

  @override
  String get settings_list_animations => 'List animations';

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
      'This domain will no longer point to this site.';

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
      'Reverse proxy rules added in the panel will appear here.';

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
  String get websites_logsFileHint =>
      'Logs open as files with search and download support.';

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
      'No certificates under this account. Apply in the panel first.';

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
    return '$count sites';
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
    return 'Delete group \"$name\"? Sites in it will fall back to the default group.';
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
}
