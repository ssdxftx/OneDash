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
  String get websites_stopped => 'Site stopped';

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
  String get websites_start => 'Start site';

  @override
  String get websites_stop => 'Stop site';

  @override
  String get websites_delete => 'Delete site';

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
      'Site files, Nginx configuration and SSL certificates will be deleted. This cannot be undone.';

  @override
  String websites_deleteDatabaseCount(int count) {
    return 'Also delete $count linked database(s)';
  }

  @override
  String get websites_deleteBackup => 'Also delete site backups';

  @override
  String get websites_forceDelete => 'Force delete and ignore errors';

  @override
  String get websites_deleted => 'Site deleted';

  @override
  String get websites_started => 'Site started';

  @override
  String get websites_actions => 'Site actions';

  @override
  String get containers_create => 'Create container';

  @override
  String get containers_image => 'Image';

  @override
  String get containers_name => 'Name';

  @override
  String get containers_ports => 'Port mappings';

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
  String get websites_templateEmpty => 'No templates yet';

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
  String get websites_templateVariables => 'Variables';

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
  String get websites_templateOutputs => 'Generated sites';

  @override
  String get websites_templateOutputName => 'Output name';

  @override
  String get websites_templateOutputEmpty => 'No generated sites';

  @override
  String get websites_templateOutputGenerated => 'Site generated';

  @override
  String get websites_templateOutputDelete => 'Delete generated site';

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
}
