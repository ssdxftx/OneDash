import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
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
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('zh'),
    Locale('en'),
  ];

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'OneDash'**
  String get app_title;

  /// Generic delete action.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// Option label for following the system setting.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get common_systemDefault;

  /// Generic toast shown after saving succeeds.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get common_saved;

  /// Generic retry action.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// Generic search action.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get common_search;

  /// Boolean yes value.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_yes;

  /// Boolean no value.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_no;

  /// Relative time fallback when the timestamp is missing.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get format_relativeUnknown;

  /// Relative time for a future timestamp less than one minute away.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get format_relativeSoon;

  /// Relative time for a past timestamp less than one minute ago.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get format_relativeJustNow;

  /// Relative time in minutes for future timestamps.
  ///
  /// In en, this message translates to:
  /// **'{n} min later'**
  String format_relativeMinutesLater(int n);

  /// Relative time in hours for future timestamps.
  ///
  /// In en, this message translates to:
  /// **'{n} h later'**
  String format_relativeHoursLater(int n);

  /// Relative time in days for future timestamps.
  ///
  /// In en, this message translates to:
  /// **'{n} d later'**
  String format_relativeDaysLater(int n);

  /// Relative time in minutes for past timestamps.
  ///
  /// In en, this message translates to:
  /// **'{n} min ago'**
  String format_relativeMinutesAgo(int n);

  /// Relative time in hours for past timestamps.
  ///
  /// In en, this message translates to:
  /// **'{n} h ago'**
  String format_relativeHoursAgo(int n);

  /// Relative time in days for past timestamps.
  ///
  /// In en, this message translates to:
  /// **'{n} d ago'**
  String format_relativeDaysAgo(int n);

  /// Default prefix prepended before a relative backup timestamp.
  ///
  /// In en, this message translates to:
  /// **'Backed up '**
  String get format_timeAgoPrefixBackup;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get terminal_disconnected;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get terminal_connecting;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get nav_overview;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Websites'**
  String get nav_websites;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get nav_files;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Containers'**
  String get nav_containers;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get nav_more;

  /// Bottom tab label for network.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get nav_network;

  /// Dashboard system row label.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get dashboard_system;

  /// Dashboard kernel row label.
  ///
  /// In en, this message translates to:
  /// **'Kernel'**
  String get dashboard_kernel;

  /// Dashboard CPU cores row label.
  ///
  /// In en, this message translates to:
  /// **'Cores'**
  String get dashboard_cpuCores;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Uptime'**
  String get dashboard_uptime;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get dashboard_load;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Processes'**
  String get dashboard_processes;

  /// Dashboard CPU architecture metric label.
  ///
  /// In en, this message translates to:
  /// **'Arch'**
  String get dashboard_arch;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get dashboard_memory;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Disk'**
  String get dashboard_disk;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get dashboard_download;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get dashboard_upload;

  /// Dashboard uptime in minutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String dashboard_uptimeMinutes(int minutes);

  /// Dashboard uptime in hours and minutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String dashboard_uptimeHoursMinutes(int hours, int minutes);

  /// Dashboard uptime in days and hours.
  ///
  /// In en, this message translates to:
  /// **'{days} d {hours} h'**
  String dashboard_uptimeDaysHours(int days, int hours);

  /// Files sort by name option.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get files_sortName;

  /// Files sort by size option.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get files_sortSize;

  /// Files sort by modified time option.
  ///
  /// In en, this message translates to:
  /// **'Modified Time'**
  String get files_sortModifiedTime;

  /// Files breadcrumb root directory label.
  ///
  /// In en, this message translates to:
  /// **'Root'**
  String get files_rootDirectory;

  /// Files context menu action to preview an image.
  ///
  /// In en, this message translates to:
  /// **'Preview Image'**
  String get files_actionPreviewImage;

  /// Files context menu action to decompress an archive.
  ///
  /// In en, this message translates to:
  /// **'Decompress'**
  String get files_actionDecompress;

  /// Process page error when active server cannot be found.
  ///
  /// In en, this message translates to:
  /// **'Server not found'**
  String get process_serverMissing;

  /// Dialog title for stopping a process.
  ///
  /// In en, this message translates to:
  /// **'Stop Process'**
  String get process_stopTitle;

  /// Dialog content for stopping a process.
  ///
  /// In en, this message translates to:
  /// **'Stop PID {pid}?'**
  String process_stopContent(int pid);

  /// Dialog action for stopping a process.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get process_stopAction;

  /// More page app store entry subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage installed apps, upgrades, and app settings'**
  String get more_appStoreSubtitle;

  /// Server host field label.
  ///
  /// In en, this message translates to:
  /// **'Host Address'**
  String get servers_host;

  /// Server card online status label.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get servers_online;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// Light appearance mode option.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_appearance_modeLight;

  /// Dark appearance mode option.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_appearance_modeDark;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Firewall'**
  String get firewall_title;

  /// Firewall port field label.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get firewall_port;

  /// Firewall port input placeholder.
  ///
  /// In en, this message translates to:
  /// **'80, 8080-8090, or 80,443'**
  String get firewall_portPlaceholder;

  /// Firewall strategy field label.
  ///
  /// In en, this message translates to:
  /// **'Strategy'**
  String get firewall_strategy;

  /// Firewall IP rule address field label.
  ///
  /// In en, this message translates to:
  /// **'IP Address'**
  String get firewall_ipAddress;

  /// Firewall IP rule address placeholder.
  ///
  /// In en, this message translates to:
  /// **'192.168.1.100 or 10.0.0.0/8'**
  String get firewall_ipAddressPlaceholder;

  /// Firewall card protocol meta label.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get firewall_protocolLabel;

  /// Firewall card description meta label.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get firewall_descriptionLabel;

  /// Panel alert notifications menu entry and page title.
  ///
  /// In en, this message translates to:
  /// **'Alert Notifications'**
  String get panelSettings_alerts;

  /// Panel basic information section title.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get panelSettings_basicInfo;

  /// Panel default access address setting title.
  ///
  /// In en, this message translates to:
  /// **'Default Access Address'**
  String get panelSettings_defaultAccessAddress;

  /// Panel settings empty value label.
  ///
  /// In en, this message translates to:
  /// **'Not Set'**
  String get panelSettings_notSet;

  /// Placeholder for panel default access address.
  ///
  /// In en, this message translates to:
  /// **'Enter the default access address'**
  String get panelSettings_defaultAccessAddressPlaceholder;

  /// Panel username setting title.
  ///
  /// In en, this message translates to:
  /// **'Panel Username'**
  String get panelSettings_panelUsername;

  /// Panel login password setting title.
  ///
  /// In en, this message translates to:
  /// **'Panel Login Password'**
  String get panelSettings_panelLoginPassword;

  /// Panel login password setting subtitle.
  ///
  /// In en, this message translates to:
  /// **'Change the panel login password'**
  String get panelSettings_changePanelLoginPassword;

  /// Section title for display settings that only affect the 1Panel web UI.
  ///
  /// In en, this message translates to:
  /// **'Display Settings (Web UI Only)'**
  String get panelSettings_displaySettingsWebOnly;

  /// Panel web UI theme setting title.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get panelSettings_theme;

  /// Light theme option.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get panelSettings_themeLight;

  /// Dark theme option.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get panelSettings_themeDark;

  /// Panel web UI language setting title.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get panelSettings_language;

  /// Chinese language option for the panel web UI.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get panelSettings_languageZh;

  /// Traditional Chinese language option for the panel web UI.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get panelSettings_languageZhHant;

  /// Japanese language option for the panel web UI.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get panelSettings_languageJa;

  /// Malay language option for the panel web UI.
  ///
  /// In en, this message translates to:
  /// **'Malay'**
  String get panelSettings_languageMs;

  /// Portuguese Brazil language option for the panel web UI.
  ///
  /// In en, this message translates to:
  /// **'Portuguese (Brazil)'**
  String get panelSettings_languagePtBr;

  /// Panel tab navigation setting title.
  ///
  /// In en, this message translates to:
  /// **'Tab Navigation'**
  String get panelSettings_tabNavigation;

  /// Panel tab navigation setting subtitle.
  ///
  /// In en, this message translates to:
  /// **'Show page tabs in the top bar'**
  String get panelSettings_tabNavigationSubtitle;

  /// Panel security settings section title.
  ///
  /// In en, this message translates to:
  /// **'Security Settings'**
  String get panelSettings_securitySettings;

  /// Panel session timeout setting title.
  ///
  /// In en, this message translates to:
  /// **'Session Timeout'**
  String get panelSettings_sessionTimeout;

  /// Panel session timeout disabled label.
  ///
  /// In en, this message translates to:
  /// **'Never timeout'**
  String get panelSettings_neverTimeout;

  /// Duration in seconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String panelSettings_secondsValue(String seconds);

  /// Placeholder for panel session timeout.
  ///
  /// In en, this message translates to:
  /// **'0 = never timeout'**
  String get panelSettings_sessionTimeoutPlaceholder;

  /// Description for the panel session timeout field.
  ///
  /// In en, this message translates to:
  /// **'Set the panel login session timeout in seconds. Use 0 to never timeout.'**
  String get panelSettings_sessionTimeoutDescription;

  /// Panel advanced settings section title.
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get panelSettings_advancedSettings;

  /// Panel API interface setting title.
  ///
  /// In en, this message translates to:
  /// **'API Interface'**
  String get panelSettings_apiInterface;

  /// Explains that session-only panel settings must be managed in the web panel.
  ///
  /// In en, this message translates to:
  /// **'Manage this in the 1Panel web panel'**
  String get panelSettings_webPanelRequired;

  /// Label for the locally stored API connection key.
  ///
  /// In en, this message translates to:
  /// **'Connection key saved in this app'**
  String get panelSettings_localApiKey;

  /// Enabled status label.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get panelSettings_enabled;

  /// Disabled status label.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get panelSettings_disabled;

  /// Toast shown after panel settings are updated.
  ///
  /// In en, this message translates to:
  /// **'Settings updated'**
  String get panelSettings_settingUpdated;

  /// Toast shown when updating panel settings fails.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get panelSettings_updateFailed;

  /// Panel port setting title.
  ///
  /// In en, this message translates to:
  /// **'Panel Port'**
  String get panelSettings_panelPort;

  /// Panel security entrance setting title.
  ///
  /// In en, this message translates to:
  /// **'Security Entrance'**
  String get panelSettings_securityEntrance;

  /// Panel bind domain setting title.
  ///
  /// In en, this message translates to:
  /// **'Bind Domain'**
  String get panelSettings_bindDomain;

  /// Generic panel settings operation failure toast title.
  ///
  /// In en, this message translates to:
  /// **'Operation failed'**
  String get panelSettings_operationFailed;

  /// Alert rules tab title.
  ///
  /// In en, this message translates to:
  /// **'Alert Rules'**
  String get panelSettings_alertList;

  /// Alert logs tab title.
  ///
  /// In en, this message translates to:
  /// **'Alert Logs'**
  String get panelSettings_alertLogs;

  /// Empty state for alert rules.
  ///
  /// In en, this message translates to:
  /// **'No alert rules'**
  String get panelSettings_noAlertRules;

  /// Alert card metadata text.
  ///
  /// In en, this message translates to:
  /// **'Type: {type}  Method: {method}'**
  String panelSettings_alertCardMeta(String type, String method);

  /// Toast shown after deleting an item.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get panelSettings_deleted;

  /// Toast shown when deleting an item fails.
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get panelSettings_deleteFailed;

  /// Toast shown after clearing alert logs.
  ///
  /// In en, this message translates to:
  /// **'Logs cleared'**
  String get panelSettings_logsCleared;

  /// Toast shown when clearing alert logs fails.
  ///
  /// In en, this message translates to:
  /// **'Clear failed'**
  String get panelSettings_clearFailed;

  /// Button label for clearing alert logs.
  ///
  /// In en, this message translates to:
  /// **'Clear Logs'**
  String get panelSettings_clearLogs;

  /// Empty state for alert logs.
  ///
  /// In en, this message translates to:
  /// **'No logs'**
  String get panelSettings_noLogs;

  /// Alert notification methods section title.
  ///
  /// In en, this message translates to:
  /// **'Notification Methods'**
  String get panelSettings_notificationMethods;

  /// Email notification setting title.
  ///
  /// In en, this message translates to:
  /// **'Email Notification'**
  String get panelSettings_emailNotification;

  /// SMTP notification setting subtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure SMTP email delivery'**
  String get panelSettings_smtpSubtitle;

  /// Webhook notification setting subtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure Webhook'**
  String get panelSettings_webhookSubtitle;

  /// WeCom notification setting title.
  ///
  /// In en, this message translates to:
  /// **'WeCom'**
  String get panelSettings_weCom;

  /// DingTalk notification setting title.
  ///
  /// In en, this message translates to:
  /// **'DingTalk'**
  String get panelSettings_dingTalk;

  /// Feishu notification setting title.
  ///
  /// In en, this message translates to:
  /// **'Feishu'**
  String get panelSettings_feishu;

  /// Todo toast for email notification configuration.
  ///
  /// In en, this message translates to:
  /// **'Email configuration is coming soon'**
  String get panelSettings_emailTodo;

  /// Todo toast for WeCom notification configuration.
  ///
  /// In en, this message translates to:
  /// **'WeCom configuration is coming soon'**
  String get panelSettings_weComTodo;

  /// Todo toast for DingTalk notification configuration.
  ///
  /// In en, this message translates to:
  /// **'DingTalk configuration is coming soon'**
  String get panelSettings_dingTalkTodo;

  /// Todo toast for Feishu notification configuration.
  ///
  /// In en, this message translates to:
  /// **'Feishu configuration is coming soon'**
  String get panelSettings_feishuTodo;

  /// Todo toast for Bark notification configuration.
  ///
  /// In en, this message translates to:
  /// **'Bark configuration is coming soon'**
  String get panelSettings_barkTodo;

  /// Backup account type field label.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get panelSettings_type;

  /// API credentials section title.
  ///
  /// In en, this message translates to:
  /// **'Credentials'**
  String get panelSettings_credentials;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Scheduled tasks'**
  String get cronjobs_title;

  /// Enable cron job action label.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get cronjobs_enable;

  /// Disable cron job action label.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get cronjobs_disable;

  /// Run cron job once action label.
  ///
  /// In en, this message translates to:
  /// **'Run Now'**
  String get cronjobs_runOnce;

  /// Cron expression description for every N minutes.
  ///
  /// In en, this message translates to:
  /// **'Every {n} minutes'**
  String cronjobs_everyMinutes(String n);

  /// Cron expression description for every N seconds.
  ///
  /// In en, this message translates to:
  /// **'Every {n} seconds'**
  String cronjobs_everySeconds(String n);

  /// Cron expression description for hourly schedule.
  ///
  /// In en, this message translates to:
  /// **'Every hour at minute {minute}'**
  String cronjobs_everyHourAtMinute(String minute);

  /// Cron expression description for daily schedule.
  ///
  /// In en, this message translates to:
  /// **'Daily at {time}'**
  String cronjobs_dailyAt(String time);

  /// Cron expression description for every N hours.
  ///
  /// In en, this message translates to:
  /// **'Every {n} hours'**
  String cronjobs_everyHours(String n);

  /// Cron expression description for weekly schedule.
  ///
  /// In en, this message translates to:
  /// **'Every {weekday} at {time}'**
  String cronjobs_weeklyAt(String weekday, String time);

  /// Cron expression description for monthly schedule.
  ///
  /// In en, this message translates to:
  /// **'Monthly on day {day} at {time}'**
  String cronjobs_monthlyAt(String day, String time);

  /// Cron expression description for every N days.
  ///
  /// In en, this message translates to:
  /// **'Every {n} days at {time}'**
  String cronjobs_everyDaysAt(String n, String time);

  /// Sunday label in cron expression descriptions.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get cronjobs_weekdaySun;

  /// Monday label in cron expression descriptions.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get cronjobs_weekdayMon;

  /// Tuesday label in cron expression descriptions.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get cronjobs_weekdayTue;

  /// Wednesday label in cron expression descriptions.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get cronjobs_weekdayWed;

  /// Thursday label in cron expression descriptions.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get cronjobs_weekdayThu;

  /// Friday label in cron expression descriptions.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get cronjobs_weekdayFri;

  /// Saturday label in cron expression descriptions.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get cronjobs_weekdaySat;

  /// Fallback weekday label in cron expression descriptions.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String cronjobs_weekdayFallback(String day);

  /// Installed app status label.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get appStore_installed;

  /// App detail app key label.
  ///
  /// In en, this message translates to:
  /// **'App Key'**
  String get appStore_appKey;

  /// Website create basic configuration section title.
  ///
  /// In en, this message translates to:
  /// **'Basic Configuration'**
  String get websites_basicConfig;

  /// Website alias field label.
  ///
  /// In en, this message translates to:
  /// **'Alias'**
  String get websites_alias;

  /// Website runtime section and field label.
  ///
  /// In en, this message translates to:
  /// **'Runtime'**
  String get websites_runtime;

  /// Reverse proxy create settings section title.
  ///
  /// In en, this message translates to:
  /// **'Reverse Proxy Settings'**
  String get websites_proxySettings;

  /// Generic website type fallback label.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get websites_website;

  /// Fallback SSL certificate label.
  ///
  /// In en, this message translates to:
  /// **'SSL Certificate'**
  String get websites_sslCertificate;

  /// Reverse proxy empty state title.
  ///
  /// In en, this message translates to:
  /// **'No reverse proxy'**
  String get websites_noReverseProxy;

  /// Website other settings website alias field label.
  ///
  /// In en, this message translates to:
  /// **'Website Alias'**
  String get websites_websiteAlias;

  /// Website directory sheet root directory row title.
  ///
  /// In en, this message translates to:
  /// **'Root Directory'**
  String get websites_rootDirectory;

  /// CA obtain domains field label.
  ///
  /// In en, this message translates to:
  /// **'Domains'**
  String get websites_domains;

  /// Website remark field label.
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get websites_remark;

  /// Optional field placeholder.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get websites_optional;

  /// Website domain field label.
  ///
  /// In en, this message translates to:
  /// **'Domain'**
  String get websites_domain;

  /// Website domain sheet remove domain confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Remove Domain'**
  String get websites_removeDomain;

  /// Website domain sheet empty state title.
  ///
  /// In en, this message translates to:
  /// **'No domains'**
  String get websites_noDomains;

  /// Website action sheet directory row title.
  ///
  /// In en, this message translates to:
  /// **'Website Directory'**
  String get websites_siteDirectory;

  /// Reverse proxy delete confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Delete Reverse Proxy'**
  String get websites_deleteReverseProxy;

  /// Redirect card target address label.
  ///
  /// In en, this message translates to:
  /// **'Target Address'**
  String get websites_targetAddress;

  /// Website action sheet logs row title.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get websites_logs;

  /// Website action sheet config file row title.
  ///
  /// In en, this message translates to:
  /// **'Config File'**
  String get websites_configFile;

  /// Website log sheet access log type label.
  ///
  /// In en, this message translates to:
  /// **'Access Log'**
  String get websites_accessLog;

  /// Website log sheet error log type label.
  ///
  /// In en, this message translates to:
  /// **'Error Log'**
  String get websites_errorLog;

  /// Website log entry path field label.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get websites_path;

  /// Container privileged mode option label.
  ///
  /// In en, this message translates to:
  /// **'Privileged Mode'**
  String get containers_privilegedMode;

  /// Container hostname field label.
  ///
  /// In en, this message translates to:
  /// **'Hostname'**
  String get containers_hostname;

  /// Container mounted volumes section title.
  ///
  /// In en, this message translates to:
  /// **'Mounted Volumes'**
  String get containers_mountedVolumes;

  /// Container working directory field label.
  ///
  /// In en, this message translates to:
  /// **'Working Directory'**
  String get containers_workingDir;

  /// Container command field label.
  ///
  /// In en, this message translates to:
  /// **'Command'**
  String get containers_command;

  /// Container entrypoint field label.
  ///
  /// In en, this message translates to:
  /// **'Entrypoint'**
  String get containers_entrypoint;

  /// Container environment variables section title.
  ///
  /// In en, this message translates to:
  /// **'Environment Variables'**
  String get containers_envVars;

  /// Container restart policy section title.
  ///
  /// In en, this message translates to:
  /// **'Restart Policy'**
  String get containers_restartPolicy;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get containers_start;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get containers_stop;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get containers_restart;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get containers_running;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get containers_stopped;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Compose'**
  String get containers_compose;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get containers_logs;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get containers_all;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get containers_terminal;

  /// Images resource label.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get containers_images;

  /// Pause action title.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get containers_pause;

  /// Memory short label.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get containers_memory;

  /// Database action title for changing password.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get databases_changePassword;

  /// Database action subtitle for changing password.
  ///
  /// In en, this message translates to:
  /// **'Change database password'**
  String get databases_changePasswordSubtitle;

  /// Connection address field label.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get databases_address;

  /// Connection port field label.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get databases_port;

  /// Database username field label.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get databases_username;

  /// Database password field label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get databases_password;

  /// Remote access switch label.
  ///
  /// In en, this message translates to:
  /// **'Remote Access'**
  String get databases_remoteAccess;

  /// Enabled status label.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get databases_enabled;

  /// Disabled status label.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get databases_disabled;

  /// Delete database sheet title.
  ///
  /// In en, this message translates to:
  /// **'Delete Database'**
  String get databases_deleteDatabase;

  /// Password change success toast.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get databases_passwordChanged;

  /// New password field label.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get databases_newPassword;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get common_empty_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'No data to show.'**
  String get common_empty_message;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get error_details;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Invalid API key'**
  String get error_auth_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'The API key is invalid or expired. Generate a new key in 1Panel panel settings.'**
  String get error_auth_message;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the panel'**
  String get error_network_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Check the network and the panel address, then retry.'**
  String get error_network_message;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Certificate not trusted'**
  String get error_cert_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'The panel uses a self-signed certificate. Allow it in server settings if you trust this host.'**
  String get error_cert_message;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Panel error'**
  String get error_server_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'The panel returned HTTP {statusCode}.'**
  String error_server_message(int statusCode);

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Not supported'**
  String get error_not_found_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'This panel version does not provide the endpoint. The entry has been hidden.'**
  String get error_not_found_message;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Request rejected'**
  String get error_request_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Operation failed'**
  String get error_business_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Incompatible data'**
  String get error_format_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'The panel response format is not compatible with this app version.'**
  String get error_format_message;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error_unknown_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Please retry. If it persists, check the panel logs.'**
  String get error_unknown_message;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Panels'**
  String get servers_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'No panel connected'**
  String get servers_empty_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Generate an API key in 1Panel: Panel Settings - API Interface.'**
  String get servers_empty_message;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Add panel'**
  String get servers_add;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get servers_current;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get servers_offline;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Last connected {time}'**
  String servers_last_seen(String time);

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Delete panel'**
  String get servers_delete;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Remove this panel from this device? The panel itself is not changed.'**
  String get servers_delete_message;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Add panel'**
  String get server_edit_add_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Edit panel'**
  String get server_edit_edit_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get server_edit_address;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get server_edit_name;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'My server'**
  String get server_edit_name_hint;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get server_edit_host;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get server_edit_port;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'HTTPS'**
  String get server_edit_https;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'API key'**
  String get server_edit_api_key;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Paste the key generated by 1Panel'**
  String get server_edit_api_key_hint;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Allow self-signed certificate'**
  String get server_edit_allow_insecure;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Only for this host. The certificate will not be verified.'**
  String get server_edit_allow_insecure_hint;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get server_edit_test;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Save and connect'**
  String get server_edit_save;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Network reachable'**
  String get server_edit_diag_network;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Certificate trusted'**
  String get server_edit_diag_tls;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get server_edit_diag_auth;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Endpoint capability'**
  String get server_edit_diag_capability;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'e.g. 192.168.1.10'**
  String get server_edit_host_hint;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'1Panel - Panel Settings - API Interface - Generate key'**
  String get server_edit_key_guide;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get dashboard_health;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get dashboard_health_excellent;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get dashboard_health_good;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get dashboard_health_fair;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get dashboard_health_poor;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'CPU'**
  String get dashboard_cpu;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get dashboard_network;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'System information'**
  String get dashboard_system_info;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Sites and containers'**
  String get dashboard_sites_containers;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get dashboard_quick_actions;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get dashboard_clear_cache;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'View logs'**
  String get dashboard_view_logs;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get dashboard_terminal;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Firewall'**
  String get dashboard_firewall;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'{count} cores'**
  String dashboard_cores(int count);

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'{used} / {total}'**
  String dashboard_used_of(String used, String total);

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Connection interrupted, retrying'**
  String get dashboard_offline_banner;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'This folder is empty'**
  String get files_empty_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Upload a file or create a folder to get started.'**
  String get files_empty_message;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get files_upload;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get files_new_folder;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'New file'**
  String get files_new_file;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get files_download;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get files_delete;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get files_rename;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Compress'**
  String get files_compress;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get files_share;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get files_sort;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get files_parent;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Websites'**
  String get websites_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'No websites yet'**
  String get websites_empty_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Create a site to serve a static folder or reverse proxy.'**
  String get websites_empty_message;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Create website'**
  String get websites_create;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get websites_all;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get websites_running;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get websites_stopped;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Static'**
  String get websites_static;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Reverse proxy'**
  String get websites_proxy;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'PHP'**
  String get websites_php;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String websites_expire_days(int days);

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Containers'**
  String get containers_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'No containers'**
  String get containers_empty_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Containers created on this panel will appear here.'**
  String get containers_empty_message;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Abnormal'**
  String get containers_abnormal;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Config'**
  String get containers_config;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Apps and services'**
  String get more_group_apps;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Web services'**
  String get more_group_web;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get more_group_ops;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get more_group_system;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'App store'**
  String get more_app_store;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Installed apps'**
  String get more_installed_apps;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Databases'**
  String get more_databases;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Scheduled tasks'**
  String get more_cronjobs;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Firewall'**
  String get more_firewall;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get more_logs;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get more_terminal;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Panel settings'**
  String get more_panel_settings;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get more_app_settings;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Processes'**
  String get more_process;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Backups'**
  String get more_backups;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Runtimes'**
  String get more_runtimes;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settings_appearance;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get settings_theme_mode;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get settings_accent;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Dynamic color'**
  String get settings_dynamic_color;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Use the Android 12+ wallpaper color'**
  String get settings_dynamic_color_hint;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'OLED black'**
  String get settings_oled;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get settings_text_scale;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Interaction'**
  String get settings_interaction;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get settings_haptics;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'List animations'**
  String get settings_list_animations;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settings_version;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get settings_licenses;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settings_privacy;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settings_security;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Block screenshots'**
  String get settings_secure_screen;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get action_retry;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get action_edit;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get action_delete;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get action_cancel;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get action_confirm;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get action_save;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get action_close;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get action_search;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get action_refresh;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get action_copy;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get action_more;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get action_create;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get action_done;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get state_empty;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get terminal_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get terminal_connected;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Disconnect the current session?'**
  String get terminal_disconnect_confirm;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Operation'**
  String get logs_operation;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get logs_login;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'SSH'**
  String get logs_ssh;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get logs_task;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'App store'**
  String get apps_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Search apps'**
  String get apps_search_hint;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get apps_install;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get apps_installed;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get apps_update_available;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Databases'**
  String get databases_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'No databases'**
  String get databases_empty_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Create a database to manage it here.'**
  String get databases_empty_message;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'No scheduled tasks'**
  String get cronjobs_empty_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Create a task to run scripts on a schedule.'**
  String get cronjobs_empty_message;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Firewall status'**
  String get firewall_status;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Port rules'**
  String get firewall_ports;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'IP rules'**
  String get firewall_ips;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Add rule'**
  String get firewall_add_rule;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get firewall_allow;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get firewall_deny;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Backups'**
  String get backups_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'No backups'**
  String get backups_empty_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Configure a backup account to protect your data.'**
  String get backups_empty_message;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Panel settings'**
  String get panel_settings_title;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get panel_settings_base;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'Component gallery'**
  String get gallery_title;

  /// Show hidden value.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get common_show;

  /// Hide visible value.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get common_hide;

  /// Toast after copying a labeled value.
  ///
  /// In en, this message translates to:
  /// **'{label} copied'**
  String common_copiedLabel(String label);

  /// Add a domain to a website.
  ///
  /// In en, this message translates to:
  /// **'Add domain'**
  String get websites_addDomain;

  /// Confirm adding a domain.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get websites_addDomainAction;

  /// Domain add success.
  ///
  /// In en, this message translates to:
  /// **'Domain added'**
  String get websites_domainAdded;

  /// Delete domain confirmation message.
  ///
  /// In en, this message translates to:
  /// **'This domain will no longer point to this site.'**
  String get websites_removeDomainMessage;

  /// Domain deleted.
  ///
  /// In en, this message translates to:
  /// **'Domain deleted'**
  String get websites_domainDeleted;

  /// SSL tab empty state.
  ///
  /// In en, this message translates to:
  /// **'No SSL certificate configured'**
  String get websites_noSslCertificate;

  /// Bind certificate button.
  ///
  /// In en, this message translates to:
  /// **'Bind existing certificate'**
  String get websites_bindExistingCertificate;

  /// Change certificate button.
  ///
  /// In en, this message translates to:
  /// **'Change or bind certificate'**
  String get websites_changeCertificate;

  /// Reverse proxy empty state.
  ///
  /// In en, this message translates to:
  /// **'Reverse proxy rules added in the panel will appear here.'**
  String get websites_noReverseProxyHint;

  /// Delete reverse proxy confirmation.
  ///
  /// In en, this message translates to:
  /// **'The rule {name} ({match}) will be deleted.'**
  String websites_deleteProxyMessage(String name, String match);

  /// Backups tab label.
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get backups_tabApps;

  /// Backups tab label.
  ///
  /// In en, this message translates to:
  /// **'Databases'**
  String get backups_tabDatabases;

  /// Backups tab label.
  ///
  /// In en, this message translates to:
  /// **'Websites'**
  String get backups_tabWebsites;

  /// Backups tab label.
  ///
  /// In en, this message translates to:
  /// **'Directories'**
  String get backups_tabDirectories;

  /// Backup action.
  ///
  /// In en, this message translates to:
  /// **'Get download URL'**
  String get backups_downloadUrl;

  /// Backup action.
  ///
  /// In en, this message translates to:
  /// **'Restore this backup'**
  String get backups_restoreThis;

  /// Restore form title.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get backups_restoreTitle;

  /// Restore form label.
  ///
  /// In en, this message translates to:
  /// **'Resource name'**
  String get backups_resourceName;

  /// Restore form hint.
  ///
  /// In en, this message translates to:
  /// **'App name'**
  String get backups_appNameHint;

  /// Restore form hint.
  ///
  /// In en, this message translates to:
  /// **'Database instance name'**
  String get backups_databaseInstanceHint;

  /// Restore form label.
  ///
  /// In en, this message translates to:
  /// **'Detail name'**
  String get backups_detailName;

  /// Restore form hint.
  ///
  /// In en, this message translates to:
  /// **'App detail name'**
  String get backups_appDetailHint;

  /// Restore form hint.
  ///
  /// In en, this message translates to:
  /// **'Database name'**
  String get backups_databaseNameHint;

  /// Restore form label.
  ///
  /// In en, this message translates to:
  /// **'Database type'**
  String get backups_databaseType;

  /// Restore form label.
  ///
  /// In en, this message translates to:
  /// **'Restore secret'**
  String get backups_restoreSecret;

  /// Restore form submit.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get backups_confirmRestore;

  /// Restore validation.
  ///
  /// In en, this message translates to:
  /// **'Enter all restore parameters'**
  String get backups_restoreParamsRequired;

  /// Restore submitted.
  ///
  /// In en, this message translates to:
  /// **'Restore task submitted'**
  String get backups_restoreSubmitted;

  /// Host validation.
  ///
  /// In en, this message translates to:
  /// **'Enter a host address'**
  String get server_edit_validation_host_required;

  /// Host validation.
  ///
  /// In en, this message translates to:
  /// **'Enter only the host name or IP, without a protocol'**
  String get server_edit_validation_host_protocol;

  /// Host validation.
  ///
  /// In en, this message translates to:
  /// **'Host address cannot contain spaces'**
  String get server_edit_validation_host_space;

  /// Port validation.
  ///
  /// In en, this message translates to:
  /// **'Port must be between 1 and 65535'**
  String get server_edit_validation_port_range;

  /// API key validation.
  ///
  /// In en, this message translates to:
  /// **'API key must be at least 16 characters'**
  String get server_edit_validation_key_length;

  /// API key validation.
  ///
  /// In en, this message translates to:
  /// **'API key cannot contain spaces'**
  String get server_edit_validation_key_space;

  /// Missing server.
  ///
  /// In en, this message translates to:
  /// **'Server not found'**
  String get server_edit_not_found;

  /// Diagnosis detail.
  ///
  /// In en, this message translates to:
  /// **'Self-signed certificate allowed'**
  String get server_edit_self_signed_allowed;

  /// Clock drift warning.
  ///
  /// In en, this message translates to:
  /// **'Device time differs from the panel by {seconds} seconds'**
  String server_edit_clock_drift(int seconds);

  /// File or folder name hint.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get files_nameHint;

  /// Compressed archive name.
  ///
  /// In en, this message translates to:
  /// **'Archive name'**
  String get files_archiveName;

  /// Extract confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Extract file'**
  String get files_extractTitle;

  /// Extract confirmation message.
  ///
  /// In en, this message translates to:
  /// **'Extract {name} to the current directory.'**
  String files_extractMessage(String name);

  /// Extract action.
  ///
  /// In en, this message translates to:
  /// **'Extract to current directory'**
  String get files_extractToCurrent;

  /// Image preview limit.
  ///
  /// In en, this message translates to:
  /// **'Image exceeds 30 MB. Download it to view.'**
  String get files_imageTooLarge;

  /// Download limit.
  ///
  /// In en, this message translates to:
  /// **'File exceeds 50 MB. Use the web version to download.'**
  String get files_downloadTooLarge;

  /// Download saved location.
  ///
  /// In en, this message translates to:
  /// **'Saved to {path}'**
  String files_savedTo(String path);

  /// Directory item count.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String files_itemCount(int count);

  /// Database delete confirmation.
  ///
  /// In en, this message translates to:
  /// **'This database will be permanently deleted.'**
  String get databases_deleteMessage;

  /// Database delete with linked resources.
  ///
  /// In en, this message translates to:
  /// **'{count} linked resources found. Deleting the database will affect them.'**
  String databases_deleteRelatedMessage(int count);

  /// Website logs tab hint.
  ///
  /// In en, this message translates to:
  /// **'Logs open as files with search and download support.'**
  String get websites_logsFileHint;

  /// Generic running status.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get common_running;

  /// Generic stopped status.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get common_stopped;

  /// Destructive confirmation instruction.
  ///
  /// In en, this message translates to:
  /// **'Type \"{value}\" to continue'**
  String common_typeToContinue(String value);

  /// Destructive confirmation input hint.
  ///
  /// In en, this message translates to:
  /// **'Resource name'**
  String get common_resourceName;

  /// Website type label.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get websites_type;

  /// Website create validation.
  ///
  /// In en, this message translates to:
  /// **'Invalid domain format'**
  String get websites_invalidDomainFormat;

  /// Website create validation.
  ///
  /// In en, this message translates to:
  /// **'Enter at least one domain'**
  String get websites_domainAtLeastOne;

  /// Website create validation.
  ///
  /// In en, this message translates to:
  /// **'Enter a reverse proxy target'**
  String get websites_proxyTargetRequired;

  /// Firewall add rule title.
  ///
  /// In en, this message translates to:
  /// **'Add IP rule'**
  String get firewall_addIpRule;

  /// Terminal paste warning title.
  ///
  /// In en, this message translates to:
  /// **'Paste sensitive content?'**
  String get terminal_sensitivePasteTitle;

  /// Terminal paste warning body.
  ///
  /// In en, this message translates to:
  /// **'Clipboard content may contain passwords or tokens.'**
  String get terminal_sensitivePasteMessage;

  /// Terminal paste button.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get terminal_paste;

  /// Terminal font size tooltip.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get terminal_fontSize;

  /// Empty log view.
  ///
  /// In en, this message translates to:
  /// **'No logs'**
  String get log_empty;

  /// Log scroll button.
  ///
  /// In en, this message translates to:
  /// **'Jump to latest'**
  String get log_jumpLatest;

  /// Log pause button.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get log_pause;

  /// Log resume button.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get log_resume;

  /// Log clear button.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get log_clear;

  /// Log export button.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get log_export;

  /// SSL certificate validation.
  ///
  /// In en, this message translates to:
  /// **'Select a certificate'**
  String get ssl_selectCertificate;

  /// SSL bind sheet title.
  ///
  /// In en, this message translates to:
  /// **'Bind SSL certificate'**
  String get ssl_bindTitle;

  /// SSL form label.
  ///
  /// In en, this message translates to:
  /// **'ACME account'**
  String get ssl_acmeAccount;

  /// SSL form label.
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get ssl_certificate;

  /// SSL empty hint.
  ///
  /// In en, this message translates to:
  /// **'No certificates under this account. Apply in the panel first.'**
  String get ssl_noCertificates;

  /// Install form validation.
  ///
  /// In en, this message translates to:
  /// **'Required: {fields}'**
  String apps_requiredMissing(String fields);

  /// App install section.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get apps_version;

  /// App install section.
  ///
  /// In en, this message translates to:
  /// **'Install parameters'**
  String get apps_installParams;

  /// Required field marker.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get apps_required;

  /// Cronjob last run.
  ///
  /// In en, this message translates to:
  /// **'Never run'**
  String get cronjobs_neverRun;

  /// Editor leave confirmation.
  ///
  /// In en, this message translates to:
  /// **'Discard unsaved changes?'**
  String get file_editor_unsavedLeave;

  /// App settings privacy note.
  ///
  /// In en, this message translates to:
  /// **'Data stays on device'**
  String get settings_localOnly;

  /// Clear an input field.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get action_clear;

  /// CPU core usage sheet title.
  ///
  /// In en, this message translates to:
  /// **'Per-core usage'**
  String get dashboard_coreUsage;

  /// CPU core usage empty state.
  ///
  /// In en, this message translates to:
  /// **'The panel did not return per-core data'**
  String get dashboard_noCoreData;

  /// Docker warning banner.
  ///
  /// In en, this message translates to:
  /// **'Docker service is not running'**
  String get containers_dockerNotRunningShort;

  /// Installed app action warning.
  ///
  /// In en, this message translates to:
  /// **'Missing app detail ID; cannot perform this action'**
  String get apps_detailMissing;

  /// Panel settings action.
  ///
  /// In en, this message translates to:
  /// **'Open web panel'**
  String get panelSettings_openWeb;

  /// Value shown when the container has no memory limit.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get containers_unlimited;

  /// Field label for website creation date.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get websites_createdAt;

  /// Field label for the SSL certificate provider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get websites_sslProvider;

  /// Field label for the SSL certificate expiry date.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get websites_sslExpire;

  /// Confirmation for deleting an alert rule.
  ///
  /// In en, this message translates to:
  /// **'Delete alert \"{title}\"?'**
  String panelSettings_deleteAlertConfirm(String title);

  /// Confirmation for clearing alert logs.
  ///
  /// In en, this message translates to:
  /// **'Clear all alert logs? This cannot be undone.'**
  String get panelSettings_clearLogsConfirm;

  /// Helper text showing the default panel port.
  ///
  /// In en, this message translates to:
  /// **'Default 9999'**
  String get server_edit_port_default;

  /// Count shown in list header.
  ///
  /// In en, this message translates to:
  /// **'{count} sites'**
  String websites_count(int count);

  /// Count shown in list header.
  ///
  /// In en, this message translates to:
  /// **'{count} containers'**
  String containers_count(int count);

  /// Cumulative network traffic caption.
  ///
  /// In en, this message translates to:
  /// **'Total {value}'**
  String dashboard_trafficTotal(String value);

  /// Generic message for rejected HTTP requests.
  ///
  /// In en, this message translates to:
  /// **'The panel rejected this request. Try again later.'**
  String get error_request_message;

  /// Text for supervisor_title.
  ///
  /// In en, this message translates to:
  /// **'Process Guard'**
  String get supervisor_title;

  /// Text for supervisor_serviceStart.
  ///
  /// In en, this message translates to:
  /// **'Start Supervisor'**
  String get supervisor_serviceStart;

  /// Text for supervisor_serviceStop.
  ///
  /// In en, this message translates to:
  /// **'Stop Supervisor'**
  String get supervisor_serviceStop;

  /// Text for supervisor_serviceRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart Supervisor'**
  String get supervisor_serviceRestart;

  /// Text for supervisor_initSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Initialize Supervisor'**
  String get supervisor_initSupervisor;

  /// Text for supervisor_serviceOperateConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm {operation} for the Supervisor service?'**
  String supervisor_serviceOperateConfirm(String operation);

  /// Text for supervisor_processOperateConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm {operation} for {name}?'**
  String supervisor_processOperateConfirm(String operation, String name);

  /// Text for supervisor_operationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Operation succeeded'**
  String get supervisor_operationSuccess;

  /// Text for supervisor_operationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed'**
  String get supervisor_operationFailed;

  /// Text for supervisor_notInstalledTitle.
  ///
  /// In en, this message translates to:
  /// **'supervisord Not Detected'**
  String get supervisor_notInstalledTitle;

  /// Text for supervisor_notInstalledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Install Supervisor on the server first and make sure the systemd service exists.'**
  String get supervisor_notInstalledSubtitle;

  /// Text for supervisor_ctlMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'supervisorctl Not Detected'**
  String get supervisor_ctlMissingTitle;

  /// Text for supervisor_ctlMissingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The process list and process operations depend on supervisorctl.'**
  String get supervisor_ctlMissingSubtitle;

  /// Text for supervisor_needInitTitle.
  ///
  /// In en, this message translates to:
  /// **'Initialization Required'**
  String get supervisor_needInitTitle;

  /// Text for supervisor_needInitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Initialization rewrites the [include] files parameter in the main config and restarts the Supervisor service.'**
  String get supervisor_needInitSubtitle;

  /// Text for supervisor_initTitle.
  ///
  /// In en, this message translates to:
  /// **'Initialize Supervisor'**
  String get supervisor_initTitle;

  /// Text for supervisor_initWarning.
  ///
  /// In en, this message translates to:
  /// **'Initialization modifies the [include] files parameter in the main config and restarts the matching systemd service.'**
  String get supervisor_initWarning;

  /// Text for supervisor_primaryConfig.
  ///
  /// In en, this message translates to:
  /// **'Main Config File'**
  String get supervisor_primaryConfig;

  /// Text for supervisor_serviceName.
  ///
  /// In en, this message translates to:
  /// **'Service Name'**
  String get supervisor_serviceName;

  /// Text for supervisor_configPathAndServiceRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the main config path and service name'**
  String get supervisor_configPathAndServiceRequired;

  /// Text for supervisor_initSuccess.
  ///
  /// In en, this message translates to:
  /// **'Initialized'**
  String get supervisor_initSuccess;

  /// Text for supervisor_initFailed.
  ///
  /// In en, this message translates to:
  /// **'Initialization failed'**
  String get supervisor_initFailed;

  /// Text for supervisor_emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Guarded Processes'**
  String get supervisor_emptyTitle;

  /// Text for supervisor_emptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'After creating a process, the corresponding ini config and stdout/stderr log paths are generated.'**
  String get supervisor_emptySubtitle;

  /// Text for supervisor_serviceStoppedWarn.
  ///
  /// In en, this message translates to:
  /// **'The Supervisor service is not running, so process status may be unavailable. Start it from the top-right menu.'**
  String get supervisor_serviceStoppedWarn;

  /// Text for supervisor_createProcess.
  ///
  /// In en, this message translates to:
  /// **'Create Guarded Process'**
  String get supervisor_createProcess;

  /// Text for supervisor_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get supervisor_name;

  /// Text for supervisor_user.
  ///
  /// In en, this message translates to:
  /// **'Run User'**
  String get supervisor_user;

  /// Text for supervisor_command.
  ///
  /// In en, this message translates to:
  /// **'Start Command'**
  String get supervisor_command;

  /// Text for supervisor_numprocs.
  ///
  /// In en, this message translates to:
  /// **'Process Count'**
  String get supervisor_numprocs;

  /// Text for supervisor_environment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get supervisor_environment;

  /// Text for supervisor_autoRestart.
  ///
  /// In en, this message translates to:
  /// **'Auto Restart'**
  String get supervisor_autoRestart;

  /// Text for supervisor_autoRestartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Supervisor restarts the process after an abnormal exit'**
  String get supervisor_autoRestartSubtitle;

  /// Text for supervisor_autoStart.
  ///
  /// In en, this message translates to:
  /// **'Auto Start'**
  String get supervisor_autoStart;

  /// Text for supervisor_autoStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start this process automatically when Supervisor starts'**
  String get supervisor_autoStartSubtitle;

  /// Text for supervisor_requiredFields.
  ///
  /// In en, this message translates to:
  /// **'Fill in all required fields'**
  String get supervisor_requiredFields;

  /// Text for supervisor_nameRule.
  ///
  /// In en, this message translates to:
  /// **'Name supports letters, numbers, - and _, and cannot start with a special character'**
  String get supervisor_nameRule;

  /// Text for supervisor_numprocsRule.
  ///
  /// In en, this message translates to:
  /// **'Process count must be between 1 and 9999'**
  String get supervisor_numprocsRule;

  /// Text for supervisor_updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get supervisor_updateSuccess;

  /// Text for supervisor_createSuccess.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get supervisor_createSuccess;

  /// Text for supervisor_saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get supervisor_saveFailed;

  /// Text for supervisor_processStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start this process group'**
  String get supervisor_processStartSubtitle;

  /// Text for supervisor_processStopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stop this process group'**
  String get supervisor_processStopSubtitle;

  /// Text for supervisor_processRestartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restart this process group'**
  String get supervisor_processRestartSubtitle;

  /// Text for supervisor_deleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this process config and update Supervisor'**
  String get supervisor_deleteSubtitle;

  /// Text for supervisor_workDir.
  ///
  /// In en, this message translates to:
  /// **'Working Directory'**
  String get supervisor_workDir;

  /// Text for toolbox_title.
  ///
  /// In en, this message translates to:
  /// **'Toolbox'**
  String get toolbox_title;

  /// Text for toolbox_quickSettings.
  ///
  /// In en, this message translates to:
  /// **'Quick Settings'**
  String get toolbox_quickSettings;

  /// Text for toolbox_hostname.
  ///
  /// In en, this message translates to:
  /// **'Hostname'**
  String get toolbox_hostname;

  /// Text for toolbox_systemUser.
  ///
  /// In en, this message translates to:
  /// **'System User'**
  String get toolbox_systemUser;

  /// Text for toolbox_timeZone.
  ///
  /// In en, this message translates to:
  /// **'Time Zone'**
  String get toolbox_timeZone;

  /// Text for toolbox_localTime.
  ///
  /// In en, this message translates to:
  /// **'Local Time'**
  String get toolbox_localTime;

  /// Text for toolbox_cacheClean.
  ///
  /// In en, this message translates to:
  /// **'Cache Cleanup'**
  String get toolbox_cacheClean;

  /// Text for toolbox_cleanSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get toolbox_cleanSource;

  /// Text for toolbox_cleanSourceValue.
  ///
  /// In en, this message translates to:
  /// **'1Panel toolbox scan API'**
  String get toolbox_cleanSourceValue;

  /// Text for toolbox_cleanAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get toolbox_cleanAction;

  /// Text for toolbox_cleanActionValue.
  ///
  /// In en, this message translates to:
  /// **'Scan cleanable items without deleting them'**
  String get toolbox_cleanActionValue;

  /// Text for toolbox_scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get toolbox_scan;

  /// Text for toolbox_scanFailed.
  ///
  /// In en, this message translates to:
  /// **'Scan failed'**
  String get toolbox_scanFailed;

  /// Text for toolbox_installed.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get toolbox_installed;

  /// Text for toolbox_running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get toolbox_running;

  /// Text for toolbox_enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get toolbox_enabled;

  /// Text for toolbox_version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get toolbox_version;

  /// Text for toolbox_port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get toolbox_port;

  /// Text for toolbox_virusScan.
  ///
  /// In en, this message translates to:
  /// **'Virus Scan'**
  String get toolbox_virusScan;

  /// Text for toolbox_clamAvRunning.
  ///
  /// In en, this message translates to:
  /// **'ClamAV Running'**
  String get toolbox_clamAvRunning;

  /// Text for toolbox_freshClamRunning.
  ///
  /// In en, this message translates to:
  /// **'FreshClam Running'**
  String get toolbox_freshClamRunning;

  /// Text for toolbox_virusDatabase.
  ///
  /// In en, this message translates to:
  /// **'Virus Database'**
  String get toolbox_virusDatabase;

  /// Text for toolbox_noCleanItems.
  ///
  /// In en, this message translates to:
  /// **'No cleanable items'**
  String get toolbox_noCleanItems;

  /// Text for toolbox_cleanGroupSystem.
  ///
  /// In en, this message translates to:
  /// **'System Cache'**
  String get toolbox_cleanGroupSystem;

  /// Text for toolbox_cleanGroupBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup Cache'**
  String get toolbox_cleanGroupBackup;

  /// Text for toolbox_cleanGroupUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload Cache'**
  String get toolbox_cleanGroupUpload;

  /// Text for toolbox_cleanGroupDownload.
  ///
  /// In en, this message translates to:
  /// **'Download Cache'**
  String get toolbox_cleanGroupDownload;

  /// Text for toolbox_cleanGroupSystemLog.
  ///
  /// In en, this message translates to:
  /// **'System Logs'**
  String get toolbox_cleanGroupSystemLog;

  /// Text for toolbox_cleanGroupContainer.
  ///
  /// In en, this message translates to:
  /// **'Container Cache'**
  String get toolbox_cleanGroupContainer;

  /// Text for websites_groupCreated.
  ///
  /// In en, this message translates to:
  /// **'Group created'**
  String get websites_groupCreated;

  /// Text for websites_groupUpdated.
  ///
  /// In en, this message translates to:
  /// **'Group updated'**
  String get websites_groupUpdated;

  /// Text for websites_groupDeleted.
  ///
  /// In en, this message translates to:
  /// **'Group deleted'**
  String get websites_groupDeleted;

  /// Text for websites_groupNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a group name'**
  String get websites_groupNameRequired;

  /// Text for common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// Text for websites_groupManagement.
  ///
  /// In en, this message translates to:
  /// **'Group Management'**
  String get websites_groupManagement;

  /// Text for websites_groupName.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get websites_groupName;

  /// Text for websites_groupDefault.
  ///
  /// In en, this message translates to:
  /// **'Default Group'**
  String get websites_groupDefault;

  /// Text for websites_groupSetDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get websites_groupSetDefault;

  /// Text for websites_groupDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete group \"{name}\"? Sites in it will fall back to the default group.'**
  String websites_groupDeleteConfirm(String name);

  /// Text for websites_groupEmpty.
  ///
  /// In en, this message translates to:
  /// **'No groups'**
  String get websites_groupEmpty;

  /// Text for supervisor_deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete guarded process \"{name}\"?'**
  String supervisor_deleteConfirm(String name);

  /// Text for supervisor_editProcess.
  ///
  /// In en, this message translates to:
  /// **'Edit Guarded Process'**
  String get supervisor_editProcess;

  /// Text for supervisor_stateStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting'**
  String get supervisor_stateStarting;

  /// Subtitle of the built-in default website group.
  ///
  /// In en, this message translates to:
  /// **'Reserved by 1Panel, cannot be deleted'**
  String get websites_groupSystemReserved;

  /// Tag shown on rows that can only be configured in the 1Panel web UI.
  ///
  /// In en, this message translates to:
  /// **'Web panel only'**
  String get panelSettings_webOnlyTag;

  /// Alert rule category: processor usage.
  ///
  /// In en, this message translates to:
  /// **'CPU'**
  String get alert_type_cpu;

  /// Alert rule category: memory usage.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get alert_type_memory;

  /// Alert rule category: disk usage.
  ///
  /// In en, this message translates to:
  /// **'Disk'**
  String get alert_type_disk;

  /// Alert rule category: system load.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get alert_type_load;

  /// Alert rule category: network traffic.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get alert_type_network;

  /// Alert rule category: disk SMART health.
  ///
  /// In en, this message translates to:
  /// **'SMART'**
  String get alert_type_smart;

  /// Alert rule category: system logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get alert_type_log;

  /// Alert delivery channel: email or SMTP.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get alert_method_email;

  /// Alert delivery channel: Telegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get alert_method_telegram;

  /// Alert delivery channel: WeCom.
  ///
  /// In en, this message translates to:
  /// **'WeCom'**
  String get alert_method_wecom;

  /// Alert delivery channel: DingTalk.
  ///
  /// In en, this message translates to:
  /// **'DingTalk'**
  String get alert_method_dingtalk;

  /// Alert delivery channel: Feishu or Lark.
  ///
  /// In en, this message translates to:
  /// **'Feishu'**
  String get alert_method_feishu;

  /// Alert delivery channel: Bark.
  ///
  /// In en, this message translates to:
  /// **'Bark'**
  String get alert_method_bark;

  /// Alert delivery channel: webhook.
  ///
  /// In en, this message translates to:
  /// **'Webhook'**
  String get alert_method_webhook;

  /// Alert delivery channel: SMS.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get alert_method_sms;

  /// Alert delivery log status: success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get alert_status_success;

  /// Alert delivery log status: failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get alert_status_failed;

  /// Alert delivery log status: pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get alert_status_pending;

  /// Placeholder shown while the network chart has fewer than three samples.
  ///
  /// In en, this message translates to:
  /// **'Collecting…'**
  String get dashboard_collecting;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
