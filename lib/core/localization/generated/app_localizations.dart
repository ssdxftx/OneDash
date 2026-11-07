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

  /// Breadcrumb label for the filesystem root.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get files_homeDirectory;

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

  /// Short type label for compact alert cards.
  ///
  /// In en, this message translates to:
  /// **'Type: '**
  String get alerts_metaTypeLabel;

  /// Alert card type metadata segment.
  ///
  /// In en, this message translates to:
  /// **'Type: {type}'**
  String alerts_metaType(String type);

  /// Short method label for compact alert cards.
  ///
  /// In en, this message translates to:
  /// **'Method: '**
  String get alerts_metaMethodLabel;

  /// Alert card method metadata segment.
  ///
  /// In en, this message translates to:
  /// **'Method: {method}'**
  String alerts_metaMethod(String method);

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

  /// Placeholder for a value that could not be read.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get common_notAvailable;

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

  /// Shown when the locally stored server record is missing.
  ///
  /// In en, this message translates to:
  /// **'The selected server is no longer available. Choose another server or add it again.'**
  String get error_server_missing_message;

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
  /// **'Save and open'**
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
  /// **'Websites and containers'**
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
  /// **'Create a website to serve a static folder or reverse proxy.'**
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

  /// Toast shown after a website stops.
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

  /// Empty title when the app catalog has no matches.
  ///
  /// In en, this message translates to:
  /// **'No apps found'**
  String get apps_emptyTitle;

  /// Empty message when the app catalog has no matches.
  ///
  /// In en, this message translates to:
  /// **'Try another keyword or sync the app list.'**
  String get apps_emptyMessage;

  /// Empty title when no apps are installed.
  ///
  /// In en, this message translates to:
  /// **'No installed apps'**
  String get apps_installedEmptyTitle;

  /// Empty message when no apps are installed.
  ///
  /// In en, this message translates to:
  /// **'Install an app from the catalog to see it here.'**
  String get apps_installedEmptyMessage;

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

  /// Fallback title when a backup record has no file name.
  ///
  /// In en, this message translates to:
  /// **'Untitled backup'**
  String get backups_recordUntitled;

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
  /// **'This domain will no longer point to this website.'**
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
  /// **'Add a reverse proxy rule to this website in the panel.'**
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
  /// **'No certificates available. Apply for or upload one first.'**
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

  /// No description provided for @websites_sslValidity.
  ///
  /// In en, this message translates to:
  /// **'Remaining validity'**
  String get websites_sslValidity;

  /// OneDash UI string
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String websites_sslDaysCount(int days);

  /// No description provided for @websites_sslDomainsMore.
  ///
  /// In en, this message translates to:
  /// **'and {count} more'**
  String websites_sslDomainsMore(int count);

  /// Badge for an expired SSL certificate.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get websites_sslExpired;

  /// SSL provider label for DNS account validation.
  ///
  /// In en, this message translates to:
  /// **'DNS account'**
  String get websites_sslProviderDnsAccount;

  /// SSL provider label for manual DNS validation.
  ///
  /// In en, this message translates to:
  /// **'Manual DNS'**
  String get websites_sslProviderDnsManual;

  /// SSL provider label for HTTP validation.
  ///
  /// In en, this message translates to:
  /// **'HTTP'**
  String get websites_sslProviderHttp;

  /// SSL provider label for self-signed certificates.
  ///
  /// In en, this message translates to:
  /// **'Self-signed'**
  String get websites_sslProviderSelfSigned;

  /// SSL provider label for manually uploaded certificates.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get websites_sslProviderManual;

  /// SSL provider label for certificates synced from the main node.
  ///
  /// In en, this message translates to:
  /// **'From main node'**
  String get websites_sslProviderFromMaster;

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
  /// **'9999'**
  String get server_edit_port_default;

  /// Count shown in list header.
  ///
  /// In en, this message translates to:
  /// **'{count} websites'**
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

  /// Text for websites_groupSetDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get websites_groupSetDefault;

  /// Text for websites_groupDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete group \"{name}\"? Websites in it will fall back to the default group.'**
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

  /// Toolbox section containing read-only host details.
  ///
  /// In en, this message translates to:
  /// **'Device information'**
  String get toolbox_device_info;

  /// Toolbox section containing operations the app can trigger.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get toolbox_actions;

  /// Footer explaining that toolbox information is read-only.
  ///
  /// In en, this message translates to:
  /// **'Read-only data from the panel. Edit it in the 1Panel web UI.'**
  String get toolbox_readOnlyHint;

  /// Label for the installed application key.
  ///
  /// In en, this message translates to:
  /// **'App key'**
  String get app_detail_key;

  /// Label for the installed application container name.
  ///
  /// In en, this message translates to:
  /// **'Container'**
  String get app_detail_container;

  /// Label for the Compose file path.
  ///
  /// In en, this message translates to:
  /// **'Compose'**
  String get app_detail_compose;

  /// Label for the installed application message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get app_detail_message;

  /// Toast shown after a panel is saved locally and the app opens its overview.
  ///
  /// In en, this message translates to:
  /// **'Saved, connecting…'**
  String get server_edit_savedConnecting;

  /// Generic action to add an item.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get action_add;

  /// Firewall rules tab label.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get firewall_tabRules;

  /// Firewall port forwarding tab label.
  ///
  /// In en, this message translates to:
  /// **'Forwarding'**
  String get firewall_tabForward;

  /// Firewall Docker port guard tab label.
  ///
  /// In en, this message translates to:
  /// **'Docker'**
  String get firewall_tabDocker;

  /// Firewall settings tab label.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get firewall_tabSettings;

  /// Number of firewall rules.
  ///
  /// In en, this message translates to:
  /// **'Rules: {count}'**
  String firewall_rulesCount(int count);

  /// Firewall rule search field hint.
  ///
  /// In en, this message translates to:
  /// **'Search address, port or note'**
  String get firewall_searchHint;

  /// Firewall filter for all rules.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get firewall_filterAll;

  /// Firewall filter for IPv4 rules.
  ///
  /// In en, this message translates to:
  /// **'IPv4'**
  String get firewall_filterIpv4;

  /// Firewall filter for IPv6 rules.
  ///
  /// In en, this message translates to:
  /// **'IPv6'**
  String get firewall_filterIpv6;

  /// Firewall filter for allow rules.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get firewall_filterAllow;

  /// Firewall filter for deny rules.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get firewall_filterDeny;

  /// Placeholder when a firewall rule has no source address.
  ///
  /// In en, this message translates to:
  /// **'Any address'**
  String get firewall_anyAddress;

  /// Placeholder when a firewall rule has no port.
  ///
  /// In en, this message translates to:
  /// **'Any port'**
  String get firewall_anyPort;

  /// Confirmation title for deleting a firewall rule.
  ///
  /// In en, this message translates to:
  /// **'Delete rule {name}?'**
  String firewall_ruleDeleteTitle(String name);

  /// Confirmation message for deleting a firewall rule.
  ///
  /// In en, this message translates to:
  /// **'This rule will be removed from the panel firewall.'**
  String get firewall_ruleDeleteMessage;

  /// Action to add a port forwarding rule.
  ///
  /// In en, this message translates to:
  /// **'Add forwarding rule'**
  String get firewall_addForward;

  /// Title for editing a port forwarding rule.
  ///
  /// In en, this message translates to:
  /// **'Edit forwarding rule'**
  String get firewall_editForward;

  /// Empty state title for port forwarding.
  ///
  /// In en, this message translates to:
  /// **'No forwarding rules'**
  String get firewall_forwardEmptyTitle;

  /// Empty state message for port forwarding.
  ///
  /// In en, this message translates to:
  /// **'Create a rule to forward a host port to an internal service.'**
  String get firewall_forwardEmptyMessage;

  /// Port forwarding listen port label.
  ///
  /// In en, this message translates to:
  /// **'Listen port'**
  String get firewall_forwardPort;

  /// Port forwarding target IP label.
  ///
  /// In en, this message translates to:
  /// **'Target IP'**
  String get firewall_forwardTargetIp;

  /// Port forwarding target port label.
  ///
  /// In en, this message translates to:
  /// **'Target port'**
  String get firewall_forwardTargetPort;

  /// Port forwarding interface label.
  ///
  /// In en, this message translates to:
  /// **'Interface (optional)'**
  String get firewall_forwardInterface;

  /// Status label when port forwarding is enabled.
  ///
  /// In en, this message translates to:
  /// **'Forwarding enabled'**
  String get firewall_forwardEnabled;

  /// Action to enable port forwarding.
  ///
  /// In en, this message translates to:
  /// **'Enable forwarding'**
  String get firewall_enableForward;

  /// Docker port guard section title.
  ///
  /// In en, this message translates to:
  /// **'Docker port guard'**
  String get firewall_dockerGuard;

  /// Status label when the Docker port guard is active.
  ///
  /// In en, this message translates to:
  /// **'Guard active'**
  String get firewall_dockerGuardEnabled;

  /// Status label when the Docker port guard is inactive.
  ///
  /// In en, this message translates to:
  /// **'Guard inactive'**
  String get firewall_dockerGuardDisabled;

  /// Empty state for Docker published ports.
  ///
  /// In en, this message translates to:
  /// **'No published container ports'**
  String get firewall_dockerGuardEmpty;

  /// Docker container endpoint label.
  ///
  /// In en, this message translates to:
  /// **'Container endpoint'**
  String get firewall_dockerEndpoint;

  /// Firewall service information section title.
  ///
  /// In en, this message translates to:
  /// **'Service info'**
  String get firewall_settingsService;

  /// Firewall backend label.
  ///
  /// In en, this message translates to:
  /// **'Firewall backend'**
  String get firewall_settingsBackend;

  /// Firewall backend version label.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get firewall_settingsVersion;

  /// IPv6 firewall setting label.
  ///
  /// In en, this message translates to:
  /// **'IPv6'**
  String get firewall_settingsIpv6;

  /// IPv6 firewall setting description.
  ///
  /// In en, this message translates to:
  /// **'Allow the panel to manage IPv6 rules'**
  String get firewall_settingsIpv6Hint;

  /// Firewall port whitelist section title.
  ///
  /// In en, this message translates to:
  /// **'Port whitelist'**
  String get firewall_settingsWhitelist;

  /// Panel port label.
  ///
  /// In en, this message translates to:
  /// **'Panel port'**
  String get firewall_settingsPanelPort;

  /// SSH port label.
  ///
  /// In en, this message translates to:
  /// **'SSH port'**
  String get firewall_settingsSshPort;

  /// Action to add a firewall whitelist port.
  ///
  /// In en, this message translates to:
  /// **'Add whitelist port'**
  String get firewall_whitelistAdd;

  /// Whitelist port label.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get firewall_whitelistPort;

  /// Whitelist protocol label.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get firewall_whitelistProtocol;

  /// Whitelist allowed sources label.
  ///
  /// In en, this message translates to:
  /// **'Allowed sources'**
  String get firewall_whitelistSources;

  /// Whitelist allowed sources hint.
  ///
  /// In en, this message translates to:
  /// **'Comma separated, e.g. 0.0.0.0/0'**
  String get firewall_whitelistSourcesHint;

  /// Firewall rule source address label.
  ///
  /// In en, this message translates to:
  /// **'Source address'**
  String get firewall_ruleAddress;

  /// Firewall rule destination port label.
  ///
  /// In en, this message translates to:
  /// **'Destination port'**
  String get firewall_rulePort;

  /// Firewall rule protocol label.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get firewall_ruleProtocol;

  /// Firewall rule IP family label.
  ///
  /// In en, this message translates to:
  /// **'IP family'**
  String get firewall_ruleFamily;

  /// Firewall rule action label.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get firewall_ruleStrategy;

  /// Firewall rule note label.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get firewall_ruleRemark;

  /// Firewall rule interface label.
  ///
  /// In en, this message translates to:
  /// **'Interface'**
  String get firewall_ruleInterface;

  /// Firewall rule port input hint.
  ///
  /// In en, this message translates to:
  /// **'80, 8000-8100, or 80,443'**
  String get firewall_rulePortHint;

  /// Firewall rule source address input hint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for any address'**
  String get firewall_ruleAddressHint;

  /// Validation message for an invalid firewall port.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid port or port range'**
  String get firewall_ruleInvalidPort;

  /// Action to edit a firewall rule.
  ///
  /// In en, this message translates to:
  /// **'Edit rule'**
  String get firewall_editRule;

  /// Action to delete a firewall rule.
  ///
  /// In en, this message translates to:
  /// **'Delete rule'**
  String get firewall_deleteRule;

  /// Action to move a firewall rule up.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get firewall_moveUp;

  /// Action to move a firewall rule down.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get firewall_moveDown;

  /// Validation message for a port forwarding rule.
  ///
  /// In en, this message translates to:
  /// **'Fill in listen port, target IP and target port'**
  String get firewall_forwardRequired;

  /// Validation message for a firewall whitelist rule.
  ///
  /// In en, this message translates to:
  /// **'Fill in port and at least one source'**
  String get firewall_whitelistRequired;

  /// Action to start a website.
  ///
  /// In en, this message translates to:
  /// **'Start website'**
  String get websites_start;

  /// Action to stop a website.
  ///
  /// In en, this message translates to:
  /// **'Stop website'**
  String get websites_stop;

  /// Action to delete a website.
  ///
  /// In en, this message translates to:
  /// **'Delete website'**
  String get websites_delete;

  /// Action to copy a website domain.
  ///
  /// In en, this message translates to:
  /// **'Copy domain'**
  String get websites_copyDomain;

  /// Action to open a website in a browser.
  ///
  /// In en, this message translates to:
  /// **'Open website'**
  String get websites_open;

  /// Website deletion confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String websites_deleteTitle(String name);

  /// Website deletion warning.
  ///
  /// In en, this message translates to:
  /// **'Website files, Nginx configuration and SSL certificates will be deleted. This cannot be undone.'**
  String get websites_deleteMessage;

  /// Checkbox label to delete linked databases.
  ///
  /// In en, this message translates to:
  /// **'Also delete {count} linked database(s)'**
  String websites_deleteDatabaseCount(int count);

  /// Checkbox label to delete website backups.
  ///
  /// In en, this message translates to:
  /// **'Also delete website backups'**
  String get websites_deleteBackup;

  /// Checkbox label for forced website deletion.
  ///
  /// In en, this message translates to:
  /// **'Force delete and ignore errors'**
  String get websites_forceDelete;

  /// Toast shown after a website is deleted.
  ///
  /// In en, this message translates to:
  /// **'Website deleted'**
  String get websites_deleted;

  /// Toast shown after a website starts.
  ///
  /// In en, this message translates to:
  /// **'Website started'**
  String get websites_started;

  /// Title for the website actions sheet.
  ///
  /// In en, this message translates to:
  /// **'Website actions'**
  String get websites_actions;

  /// Title and action for creating a container.
  ///
  /// In en, this message translates to:
  /// **'Create container'**
  String get containers_create;

  /// Container image label.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get containers_image;

  /// Container name label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get containers_name;

  /// Container port mappings section.
  ///
  /// In en, this message translates to:
  /// **'Port mappings'**
  String get containers_ports;

  /// Storage volume entry
  ///
  /// In en, this message translates to:
  /// **'Storage volumes'**
  String get containers_storageVolumes;

  /// Container volume mappings section.
  ///
  /// In en, this message translates to:
  /// **'Volumes'**
  String get containers_volumes;

  /// Container environment variables section.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get containers_env;

  /// Container advanced settings section.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get containers_advanced;

  /// Action to add a form row.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get containers_add;

  /// Container host port label.
  ///
  /// In en, this message translates to:
  /// **'Host port'**
  String get containers_hostPort;

  /// Container port label.
  ///
  /// In en, this message translates to:
  /// **'Container port'**
  String get containers_containerPort;

  /// Container volume host path label.
  ///
  /// In en, this message translates to:
  /// **'Host path'**
  String get containers_sourceDir;

  /// Container volume container path label.
  ///
  /// In en, this message translates to:
  /// **'Container path'**
  String get containers_containerDir;

  /// Container environment variable hint.
  ///
  /// In en, this message translates to:
  /// **'KEY=VALUE'**
  String get containers_envHint;

  /// Submit button label for creating a container.
  ///
  /// In en, this message translates to:
  /// **'Create container'**
  String get containers_createSubmit;

  /// Validation message for an invalid container name.
  ///
  /// In en, this message translates to:
  /// **'Use letters, numbers, dots, dashes or underscores'**
  String get containers_nameInvalid;

  /// Validation message for a missing container image.
  ///
  /// In en, this message translates to:
  /// **'Select or enter an image'**
  String get containers_imageRequired;

  /// Validation message for a missing container name.
  ///
  /// In en, this message translates to:
  /// **'Enter a container name'**
  String get containers_nameRequired;

  /// Title for the local image picker sheet.
  ///
  /// In en, this message translates to:
  /// **'Select image'**
  String get containers_selectImage;

  /// Option to enter a container image manually.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get containers_manualInput;

  /// Empty state for local Docker images.
  ///
  /// In en, this message translates to:
  /// **'No local images'**
  String get containers_noImages;

  /// Toast shown after a container is created.
  ///
  /// In en, this message translates to:
  /// **'Container created'**
  String get containers_created;

  /// Action to remove a form row.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get containers_removeRow;

  /// Container CPU limit label.
  ///
  /// In en, this message translates to:
  /// **'CPU limit'**
  String get containers_cpuLimit;

  /// Container memory limit label.
  ///
  /// In en, this message translates to:
  /// **'Memory limit (MB)'**
  String get containers_memoryLimit;

  /// Container auto remove label.
  ///
  /// In en, this message translates to:
  /// **'Auto remove'**
  String get containers_autoRemove;

  /// Container privileged mode label.
  ///
  /// In en, this message translates to:
  /// **'Privileged'**
  String get containers_privileged;

  /// Container restart policy hint.
  ///
  /// In en, this message translates to:
  /// **'unless-stopped'**
  String get containers_restartPolicyHint;

  /// Container command hint.
  ///
  /// In en, this message translates to:
  /// **'Command, space separated'**
  String get containers_cmdHint;

  /// Container entrypoint hint.
  ///
  /// In en, this message translates to:
  /// **'Entrypoint, space separated'**
  String get containers_entrypointHint;

  /// Container working directory hint.
  ///
  /// In en, this message translates to:
  /// **'/usr/share/nginx/html'**
  String get containers_workingDirHint;

  /// Container network label.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get containers_network;

  /// Default Docker network used by the create form.
  ///
  /// In en, this message translates to:
  /// **'1panel-network'**
  String get containers_defaultNetwork;

  /// Container advanced settings summary.
  ///
  /// In en, this message translates to:
  /// **'Command, entrypoint, working directory, network and limits'**
  String get containers_advancedHint;

  /// Restart action label.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get action_restart;

  /// Restart the 1Panel service.
  ///
  /// In en, this message translates to:
  /// **'Restart panel'**
  String get system_restartPanel;

  /// Subtitle for restarting the panel service.
  ///
  /// In en, this message translates to:
  /// **'Only the panel service restarts'**
  String get system_restartPanelSubtitle;

  /// Confirmation message before restarting the panel.
  ///
  /// In en, this message translates to:
  /// **'The panel will restart in a few seconds. The connection may drop for 10 to 30 seconds.'**
  String get system_restartPanelMessage;

  /// Restart the whole server.
  ///
  /// In en, this message translates to:
  /// **'Restart server'**
  String get system_restartServer;

  /// Subtitle for restarting the server.
  ///
  /// In en, this message translates to:
  /// **'All services will be interrupted'**
  String get system_restartServerSubtitle;

  /// Confirmation message before restarting the server.
  ///
  /// In en, this message translates to:
  /// **'The server will reboot immediately. All services stop and the connection usually recovers in 10 to 30 seconds.'**
  String get system_restartServerMessage;

  /// Toast shown after a restart request is accepted.
  ///
  /// In en, this message translates to:
  /// **'Restart requested. The connection may drop briefly.'**
  String get system_restartSubmitted;

  /// Create database action.
  ///
  /// In en, this message translates to:
  /// **'Create database'**
  String get databases_create;

  /// Sheet title for selecting a database type.
  ///
  /// In en, this message translates to:
  /// **'Choose database type'**
  String get databases_createType;

  /// Database name field label.
  ///
  /// In en, this message translates to:
  /// **'Database name'**
  String get databases_databaseName;

  /// Database instance selector label.
  ///
  /// In en, this message translates to:
  /// **'Instance'**
  String get databases_instance;

  /// Shown when no database instance is available for the selected type.
  ///
  /// In en, this message translates to:
  /// **'No installed instance of this type. Install it from the app store first.'**
  String get databases_noInstance;

  /// MySQL character set field label.
  ///
  /// In en, this message translates to:
  /// **'Character set'**
  String get databases_charset;

  /// MySQL collation field label.
  ///
  /// In en, this message translates to:
  /// **'Collation'**
  String get databases_collation;

  /// PostgreSQL template/encoding field label.
  ///
  /// In en, this message translates to:
  /// **'Template database'**
  String get databases_template;

  /// Allowed source host for a database user.
  ///
  /// In en, this message translates to:
  /// **'Allowed host'**
  String get databases_host;

  /// Hint for the allowed host field.
  ///
  /// In en, this message translates to:
  /// **'% for any host, or a specific IP'**
  String get databases_hostHint;

  /// PostgreSQL superuser toggle.
  ///
  /// In en, this message translates to:
  /// **'Superuser'**
  String get databases_superUser;

  /// MongoDB permission field label.
  ///
  /// In en, this message translates to:
  /// **'Permission'**
  String get databases_permission;

  /// MongoDB read permission.
  ///
  /// In en, this message translates to:
  /// **'Read only'**
  String get databases_permissionRead;

  /// MongoDB readWrite permission.
  ///
  /// In en, this message translates to:
  /// **'Read and write'**
  String get databases_permissionReadWrite;

  /// MongoDB dbOwner permission.
  ///
  /// In en, this message translates to:
  /// **'Database owner'**
  String get databases_permissionDbOwner;

  /// MongoDB userAdmin permission.
  ///
  /// In en, this message translates to:
  /// **'User admin'**
  String get databases_permissionUserAdmin;

  /// Validation message for database name.
  ///
  /// In en, this message translates to:
  /// **'Enter a database name'**
  String get databases_nameRequired;

  /// Validation message for database username.
  ///
  /// In en, this message translates to:
  /// **'Enter a username'**
  String get databases_usernameRequired;

  /// Validation message for database password.
  ///
  /// In en, this message translates to:
  /// **'Enter a password'**
  String get databases_passwordRequired;

  /// Toast after creating a database.
  ///
  /// In en, this message translates to:
  /// **'Database created'**
  String get databases_created;

  /// Users and grants tab title.
  ///
  /// In en, this message translates to:
  /// **'Users and grants'**
  String get databases_usersGrants;

  /// Add user action.
  ///
  /// In en, this message translates to:
  /// **'Add user'**
  String get databases_addUser;

  /// Bind an existing database user.
  ///
  /// In en, this message translates to:
  /// **'Bind user'**
  String get databases_bindUser;

  /// Empty state for database users.
  ///
  /// In en, this message translates to:
  /// **'No users'**
  String get databases_noUsers;

  /// Host label for a database user.
  ///
  /// In en, this message translates to:
  /// **'Allowed from'**
  String get databases_userHost;

  /// Delete database user action.
  ///
  /// In en, this message translates to:
  /// **'Delete user'**
  String get databases_deleteUser;

  /// Grant database access action.
  ///
  /// In en, this message translates to:
  /// **'Grant access'**
  String get databases_grant;

  /// Database name field for granting access.
  ///
  /// In en, this message translates to:
  /// **'Database to grant'**
  String get databases_grantDatabase;

  /// Revoke database access action.
  ///
  /// In en, this message translates to:
  /// **'Revoke access'**
  String get databases_revoke;

  /// Toast after changing a database permission.
  ///
  /// In en, this message translates to:
  /// **'Permission updated'**
  String get databases_permissionUpdated;

  /// Title for creating a remote Redis connection.
  ///
  /// In en, this message translates to:
  /// **'Redis connection'**
  String get databases_redisRemote;

  /// Explains Redis creation behavior.
  ///
  /// In en, this message translates to:
  /// **'Local Redis is installed as an app. This form registers a remote Redis connection.'**
  String get databases_redisHint;

  /// Label for a non-superuser database account.
  ///
  /// In en, this message translates to:
  /// **'Normal user'**
  String get databases_normalUser;

  /// Description field label.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get databases_description;

  /// Description field for a database user.
  ///
  /// In en, this message translates to:
  /// **'User description'**
  String get databases_userDescription;

  /// Toast after creating a database user.
  ///
  /// In en, this message translates to:
  /// **'User created'**
  String get databases_userCreated;

  /// Title for the granted database list.
  ///
  /// In en, this message translates to:
  /// **'Granted databases'**
  String get databases_grantedDatabases;

  /// Empty state for database grants.
  ///
  /// In en, this message translates to:
  /// **'No granted databases'**
  String get databases_noGrants;

  /// File permission sheet title.
  ///
  /// In en, this message translates to:
  /// **'Permission'**
  String get files_permission;

  /// Owner permission row.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get files_permissionOwner;

  /// Group permission row.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get files_permissionGroup;

  /// Public permission row.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get files_permissionPublic;

  /// Read permission bit.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get files_permissionRead;

  /// Write permission bit.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get files_permissionWrite;

  /// Execute permission bit.
  ///
  /// In en, this message translates to:
  /// **'Execute'**
  String get files_permissionExecute;

  /// Numeric file mode field.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get files_permissionMode;

  /// File owner user field.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get files_permissionUser;

  /// File owner group field.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get files_permissionGroupName;

  /// Toast after updating file permission.
  ///
  /// In en, this message translates to:
  /// **'Permission updated'**
  String get files_permissionUpdated;

  /// Selection mode title.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String files_selectCount(int count);

  /// Select all files action.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get files_selectAll;

  /// Leave selection mode.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get files_cancelSelection;

  /// Batch delete action.
  ///
  /// In en, this message translates to:
  /// **'Delete selected'**
  String get files_batchDelete;

  /// Batch delete confirmation message.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} selected items?'**
  String files_batchDeleteMessage(int count);

  /// Calculate directory size action.
  ///
  /// In en, this message translates to:
  /// **'Calculate size'**
  String get files_calculateSize;

  /// Calculated directory size.
  ///
  /// In en, this message translates to:
  /// **'Size: {size}'**
  String files_sizeCalculated(String size);

  /// File history action.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get files_history;

  /// Empty state for file history.
  ///
  /// In en, this message translates to:
  /// **'No history versions'**
  String get files_historyEmpty;

  /// Restore a history version.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get files_historyRestore;

  /// Confirmation before restoring a file history version.
  ///
  /// In en, this message translates to:
  /// **'Restore this version? The current file content will be replaced.'**
  String get files_historyRestoreConfirm;

  /// Delete a history version.
  ///
  /// In en, this message translates to:
  /// **'Delete version'**
  String get files_historyDelete;

  /// Toast after restoring a file version.
  ///
  /// In en, this message translates to:
  /// **'Version restored'**
  String get files_historyRestored;

  /// Tooltip for opening the file action sheet.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get files_moreActions;

  /// Host tools page title.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get host_title;

  /// Monitoring tab title.
  ///
  /// In en, this message translates to:
  /// **'Monitoring'**
  String get host_monitor;

  /// SSH tab title.
  ///
  /// In en, this message translates to:
  /// **'SSH'**
  String get host_ssh;

  /// One hour monitor range.
  ///
  /// In en, this message translates to:
  /// **'1h'**
  String get host_range1h;

  /// Six hour monitor range.
  ///
  /// In en, this message translates to:
  /// **'6h'**
  String get host_range6h;

  /// Twenty four hour monitor range.
  ///
  /// In en, this message translates to:
  /// **'24h'**
  String get host_range24h;

  /// CPU chart title.
  ///
  /// In en, this message translates to:
  /// **'CPU'**
  String get host_cpu;

  /// Memory chart title.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get host_memory;

  /// Load chart title.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get host_load;

  /// SSH port label.
  ///
  /// In en, this message translates to:
  /// **'SSH port'**
  String get host_sshPort;

  /// SSH root login label.
  ///
  /// In en, this message translates to:
  /// **'Root login'**
  String get host_rootLogin;

  /// SSH password authentication label.
  ///
  /// In en, this message translates to:
  /// **'Password login'**
  String get host_passwordAuth;

  /// SSH public key authentication label.
  ///
  /// In en, this message translates to:
  /// **'Public key login'**
  String get host_pubkeyAuth;

  /// SSH service status label.
  ///
  /// In en, this message translates to:
  /// **'SSH service'**
  String get host_sshStatus;

  /// Toast after updating SSH configuration.
  ///
  /// In en, this message translates to:
  /// **'SSH configuration updated'**
  String get host_sshUpdated;

  /// Empty monitoring chart message.
  ///
  /// In en, this message translates to:
  /// **'No monitoring data yet'**
  String get host_monitorEmpty;

  /// Explains when host monitoring data becomes available.
  ///
  /// In en, this message translates to:
  /// **'Data appears after the first monitoring interval.'**
  String get host_monitorEmptyHint;

  /// Runtime detail page title.
  ///
  /// In en, this message translates to:
  /// **'Runtime'**
  String get runtime_detail;

  /// PHP extensions tab.
  ///
  /// In en, this message translates to:
  /// **'Extensions'**
  String get runtime_extensions;

  /// PHP configuration file tab.
  ///
  /// In en, this message translates to:
  /// **'php.ini'**
  String get runtime_phpIni;

  /// PHP FPM tab.
  ///
  /// In en, this message translates to:
  /// **'FPM'**
  String get runtime_fpm;

  /// Node modules tab.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get runtime_modules;

  /// Install extension action.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get runtime_install;

  /// Uninstall extension action.
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get runtime_uninstall;

  /// Update module action.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get runtime_update;

  /// Installed state label.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get runtime_installed;

  /// Not installed state label.
  ///
  /// In en, this message translates to:
  /// **'Not installed'**
  String get runtime_notInstalled;

  /// Node module package name hint.
  ///
  /// In en, this message translates to:
  /// **'Package name'**
  String get runtime_moduleHint;

  /// Hint after saving php.ini.
  ///
  /// In en, this message translates to:
  /// **'Restart PHP for changes to take effect.'**
  String get runtime_restartPhpHint;

  /// Toast after saving runtime configuration.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get runtime_saved;

  /// Toolbox system group.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get toolbox_group_system;

  /// Toolbox security group.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get toolbox_group_security;

  /// Toolbox service group.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get toolbox_group_service;

  /// Toolbox maintenance group.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get toolbox_group_maintenance;

  /// Time and timezone entry.
  ///
  /// In en, this message translates to:
  /// **'Time and timezone'**
  String get toolbox_time;

  /// Swap and DNS entry.
  ///
  /// In en, this message translates to:
  /// **'Swap and DNS'**
  String get toolbox_swapDns;

  /// ClamAV entry.
  ///
  /// In en, this message translates to:
  /// **'ClamAV'**
  String get toolbox_clam;

  /// Fail2ban entry.
  ///
  /// In en, this message translates to:
  /// **'Fail2ban'**
  String get toolbox_fail2ban;

  /// FTP accounts entry.
  ///
  /// In en, this message translates to:
  /// **'FTP accounts'**
  String get toolbox_ftp;

  /// Timezone field label.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get toolbox_timezone;

  /// DNS field label.
  ///
  /// In en, this message translates to:
  /// **'DNS'**
  String get toolbox_dns;

  /// Swap section label.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get toolbox_swap;

  /// Create swap action.
  ///
  /// In en, this message translates to:
  /// **'Add swap'**
  String get toolbox_addSwap;

  /// Swap file path field.
  ///
  /// In en, this message translates to:
  /// **'Swap file path'**
  String get toolbox_swapPath;

  /// Swap size field.
  ///
  /// In en, this message translates to:
  /// **'Size (MB)'**
  String get toolbox_swapSize;

  /// Fail2ban banned IP list title.
  ///
  /// In en, this message translates to:
  /// **'Banned IPs'**
  String get toolbox_sshBan;

  /// Unban action.
  ///
  /// In en, this message translates to:
  /// **'Unban'**
  String get toolbox_unban;

  /// Fail2ban sshd protection toggle.
  ///
  /// In en, this message translates to:
  /// **'SSH protection'**
  String get toolbox_sshProtection;

  /// Add FTP account action.
  ///
  /// In en, this message translates to:
  /// **'Add FTP account'**
  String get toolbox_ftpAdd;

  /// FTP user field.
  ///
  /// In en, this message translates to:
  /// **'FTP user'**
  String get toolbox_ftpUser;

  /// FTP password field.
  ///
  /// In en, this message translates to:
  /// **'FTP password'**
  String get toolbox_ftpPassword;

  /// FTP root path field.
  ///
  /// In en, this message translates to:
  /// **'FTP root path'**
  String get toolbox_ftpPath;

  /// ClamAV scan path field.
  ///
  /// In en, this message translates to:
  /// **'Scan path'**
  String get toolbox_scanPath;

  /// ClamAV scan task name.
  ///
  /// In en, this message translates to:
  /// **'Scan name'**
  String get toolbox_scanName;

  /// Start ClamAV scan.
  ///
  /// In en, this message translates to:
  /// **'Start scan'**
  String get toolbox_startScan;

  /// Stop ClamAV scan.
  ///
  /// In en, this message translates to:
  /// **'Stop scan'**
  String get toolbox_stopScan;

  /// ClamAV scan task list title.
  ///
  /// In en, this message translates to:
  /// **'Scan tasks'**
  String get toolbox_scanRecords;

  /// Empty ClamAV scan task list.
  ///
  /// In en, this message translates to:
  /// **'No scan tasks'**
  String get toolbox_noScans;

  /// Generic diagnosis failure detail.
  ///
  /// In en, this message translates to:
  /// **'Check failed'**
  String get server_edit_diag_failed;

  /// Monitor settings entry.
  ///
  /// In en, this message translates to:
  /// **'Monitor settings'**
  String get host_monitorSettings;

  /// Monitor sampling interval.
  ///
  /// In en, this message translates to:
  /// **'Interval (seconds)'**
  String get host_monitorInterval;

  /// Monitor data retention days.
  ///
  /// In en, this message translates to:
  /// **'Retention (days)'**
  String get host_monitorStoreDays;

  /// Monitor status toggle.
  ///
  /// In en, this message translates to:
  /// **'Monitoring enabled'**
  String get host_monitorEnabled;

  /// SSH key management section.
  ///
  /// In en, this message translates to:
  /// **'SSH keys'**
  String get host_sshKeys;

  /// Generate an SSH key action.
  ///
  /// In en, this message translates to:
  /// **'Generate key'**
  String get host_generateKey;

  /// SSH key name field.
  ///
  /// In en, this message translates to:
  /// **'Key name'**
  String get host_keyName;

  /// SSH key type field.
  ///
  /// In en, this message translates to:
  /// **'Key type'**
  String get host_keyType;

  /// SSH key passphrase field.
  ///
  /// In en, this message translates to:
  /// **'Passphrase'**
  String get host_keyPassphrase;

  /// Toast after generating an SSH key.
  ///
  /// In en, this message translates to:
  /// **'SSH key generated'**
  String get host_keyGenerated;

  /// Delete SSH key action.
  ///
  /// In en, this message translates to:
  /// **'Delete key'**
  String get host_deleteKey;

  /// SSH public key label.
  ///
  /// In en, this message translates to:
  /// **'Public key'**
  String get host_publicKey;

  /// ClamAV scan result list.
  ///
  /// In en, this message translates to:
  /// **'Scan results'**
  String get toolbox_clamRecords;

  /// Empty ClamAV scan result list.
  ///
  /// In en, this message translates to:
  /// **'No scan results'**
  String get toolbox_clamNoRecords;

  /// PHP FPM configuration section.
  ///
  /// In en, this message translates to:
  /// **'FPM configuration'**
  String get runtime_fpmConfig;

  /// PHP FPM pm setting.
  ///
  /// In en, this message translates to:
  /// **'Process manager'**
  String get runtime_pm;

  /// PHP FPM max_children setting.
  ///
  /// In en, this message translates to:
  /// **'Max children'**
  String get runtime_maxChildren;

  /// PHP FPM start_servers setting.
  ///
  /// In en, this message translates to:
  /// **'Start servers'**
  String get runtime_startServers;

  /// PHP FPM min_spare_servers setting.
  ///
  /// In en, this message translates to:
  /// **'Min spare servers'**
  String get runtime_minSpare;

  /// PHP FPM max_spare_servers setting.
  ///
  /// In en, this message translates to:
  /// **'Max spare servers'**
  String get runtime_maxSpare;

  /// Host disks tab label.
  ///
  /// In en, this message translates to:
  /// **'Disks'**
  String get host_disks;

  /// Host runtime diagnostics tab label.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get host_diagnostics;

  /// System disk section title.
  ///
  /// In en, this message translates to:
  /// **'System disks'**
  String get host_diskSystem;

  /// Unpartitioned disk section title.
  ///
  /// In en, this message translates to:
  /// **'Unpartitioned disks'**
  String get host_diskUnpartitioned;

  /// Data disk section title.
  ///
  /// In en, this message translates to:
  /// **'Data disks'**
  String get host_diskNormal;

  /// Partition count label.
  ///
  /// In en, this message translates to:
  /// **'Partitions'**
  String get host_diskPartitions;

  /// Disk filesystem label.
  ///
  /// In en, this message translates to:
  /// **'Filesystem'**
  String get host_diskFilesystem;

  /// Used disk space label.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get host_diskUsed;

  /// Available disk space label.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get host_diskAvail;

  /// Disk mount point label.
  ///
  /// In en, this message translates to:
  /// **'Mount point'**
  String get host_diskMountPoint;

  /// Disk is not mounted.
  ///
  /// In en, this message translates to:
  /// **'Not mounted'**
  String get host_diskUnmounted;

  /// Hint for system disks.
  ///
  /// In en, this message translates to:
  /// **'System disk partitions are read-only here.'**
  String get host_diskSystemHint;

  /// Partition disk action.
  ///
  /// In en, this message translates to:
  /// **'Partition'**
  String get host_diskPartition;

  /// Mount disk action.
  ///
  /// In en, this message translates to:
  /// **'Mount'**
  String get host_diskMount;

  /// Unmount disk action.
  ///
  /// In en, this message translates to:
  /// **'Unmount'**
  String get host_diskUnmount;

  /// Mount disk automatically on boot.
  ///
  /// In en, this message translates to:
  /// **'Mount on boot'**
  String get host_diskAutoMount;

  /// Allow boot when the disk is missing.
  ///
  /// In en, this message translates to:
  /// **'Allow boot without disk'**
  String get host_diskNoFail;

  /// Mount point path input label.
  ///
  /// In en, this message translates to:
  /// **'Mount point path'**
  String get host_diskMountPointField;

  /// Partition volume label input.
  ///
  /// In en, this message translates to:
  /// **'Volume label'**
  String get host_diskLabel;

  /// Disk operation success toast.
  ///
  /// In en, this message translates to:
  /// **'Disk operation completed'**
  String get host_diskActionDone;

  /// Warning before partitioning a disk.
  ///
  /// In en, this message translates to:
  /// **'Partitioning erases data on this disk. Continue only with a disk you can rebuild.'**
  String get host_diskPartitionWarning;

  /// Runtime diagnostics summary section.
  ///
  /// In en, this message translates to:
  /// **'Runtime summary'**
  String get host_diagSummary;

  /// Panel process resident memory.
  ///
  /// In en, this message translates to:
  /// **'Resident memory'**
  String get host_diagRss;

  /// Panel process heap usage.
  ///
  /// In en, this message translates to:
  /// **'Heap in use'**
  String get host_diagHeap;

  /// Panel process heap object count.
  ///
  /// In en, this message translates to:
  /// **'Heap objects'**
  String get host_diagObjects;

  /// Panel process goroutine count.
  ///
  /// In en, this message translates to:
  /// **'Goroutines'**
  String get host_diagGoroutines;

  /// Grouped goroutine snapshot section.
  ///
  /// In en, this message translates to:
  /// **'Goroutine snapshot'**
  String get host_diagSnapshot;

  /// Snapshot capture time label.
  ///
  /// In en, this message translates to:
  /// **'Captured at'**
  String get host_diagCapturedAt;

  /// Total goroutine count label.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get host_diagTotal;

  /// Goroutine group count label.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get host_diagGroups;

  /// Warning when goroutine snapshot is truncated.
  ///
  /// In en, this message translates to:
  /// **'Snapshot was truncated by the panel.'**
  String get host_diagTruncated;

  /// Goroutine call stack title.
  ///
  /// In en, this message translates to:
  /// **'Call stack'**
  String get host_diagStack;

  /// Fail2ban basic configuration section.
  ///
  /// In en, this message translates to:
  /// **'Basic rules'**
  String get toolbox_fail2banBase;

  /// Fail2ban max retry setting.
  ///
  /// In en, this message translates to:
  /// **'Max retries'**
  String get toolbox_maxRetry;

  /// Fail2ban ban time setting.
  ///
  /// In en, this message translates to:
  /// **'Ban duration'**
  String get toolbox_banTime;

  /// Fail2ban find time setting.
  ///
  /// In en, this message translates to:
  /// **'Detection window'**
  String get toolbox_findTime;

  /// Fail2ban ban action setting.
  ///
  /// In en, this message translates to:
  /// **'Ban action'**
  String get toolbox_banAction;

  /// Fail2ban log path setting.
  ///
  /// In en, this message translates to:
  /// **'Log path'**
  String get toolbox_logPath;

  /// Hint for Fail2ban duration values.
  ///
  /// In en, this message translates to:
  /// **'Use a value with unit, for example 300s, 10m, 1h or -1.'**
  String get toolbox_durationHint;

  /// Confirmation title for Fail2ban rule changes.
  ///
  /// In en, this message translates to:
  /// **'Update Fail2ban rule'**
  String get toolbox_fail2banChanged;

  /// Runtime profile capture section.
  ///
  /// In en, this message translates to:
  /// **'Manual capture'**
  String get host_diagCapture;

  /// Runtime profile type selector.
  ///
  /// In en, this message translates to:
  /// **'Profile type'**
  String get host_diagProfileType;

  /// CPU profile type.
  ///
  /// In en, this message translates to:
  /// **'CPU profile'**
  String get host_diagProfileCpu;

  /// Heap profile type.
  ///
  /// In en, this message translates to:
  /// **'Heap profile'**
  String get host_diagProfileHeap;

  /// Goroutine profile type.
  ///
  /// In en, this message translates to:
  /// **'Goroutine profile'**
  String get host_diagProfileGoroutine;

  /// Mutex profile type.
  ///
  /// In en, this message translates to:
  /// **'Mutex profile'**
  String get host_diagProfileMutex;

  /// Block profile type.
  ///
  /// In en, this message translates to:
  /// **'Block profile'**
  String get host_diagProfileBlock;

  /// Profile capture duration.
  ///
  /// In en, this message translates to:
  /// **'Duration (seconds)'**
  String get host_diagDuration;

  /// Start profile capture action.
  ///
  /// In en, this message translates to:
  /// **'Start capture'**
  String get host_diagStartCapture;

  /// Profile file saved toast.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get host_diagProfileSaved;

  /// Host component check section.
  ///
  /// In en, this message translates to:
  /// **'Component check'**
  String get host_diagComponent;

  /// Component executable name input.
  ///
  /// In en, this message translates to:
  /// **'Component name'**
  String get host_diagComponentName;

  /// Check component action.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get host_diagCheck;

  /// Component existence status label.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get host_diagComponentExists;

  /// Component executable path label.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get host_diagComponentPath;

  /// Component is not installed.
  ///
  /// In en, this message translates to:
  /// **'Executable not found'**
  String get host_diagComponentMissing;

  /// Website load balancing tab.
  ///
  /// In en, this message translates to:
  /// **'Load balancing'**
  String get websites_loadBalance;

  /// Create a load balancing upstream.
  ///
  /// In en, this message translates to:
  /// **'Add upstream'**
  String get websites_lbAdd;

  /// Empty load balancing list.
  ///
  /// In en, this message translates to:
  /// **'No upstreams yet'**
  String get websites_lbEmpty;

  /// Load balancing upstream name.
  ///
  /// In en, this message translates to:
  /// **'Upstream name'**
  String get websites_lbName;

  /// Load balancing algorithm.
  ///
  /// In en, this message translates to:
  /// **'Algorithm'**
  String get websites_lbAlgorithm;

  /// Default load balancing algorithm.
  ///
  /// In en, this message translates to:
  /// **'Default (round robin)'**
  String get websites_lbDefault;

  /// IP hash load balancing algorithm.
  ///
  /// In en, this message translates to:
  /// **'IP hash'**
  String get websites_lbIpHash;

  /// Least connections load balancing algorithm.
  ///
  /// In en, this message translates to:
  /// **'Least connections'**
  String get websites_lbLeastConn;

  /// Load balancing server list.
  ///
  /// In en, this message translates to:
  /// **'Servers'**
  String get websites_lbServers;

  /// Add a load balancing server.
  ///
  /// In en, this message translates to:
  /// **'Add server'**
  String get websites_lbAddServer;

  /// Load balancing server address.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get websites_lbServerAddress;

  /// Load balancing server weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get websites_lbWeight;

  /// Load balancing server status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get websites_lbFlag;

  /// Server is enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get websites_lbFlagNone;

  /// Server is marked down.
  ///
  /// In en, this message translates to:
  /// **'Down'**
  String get websites_lbFlagDown;

  /// Server is a backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get websites_lbFlagBackup;

  /// Maximum failed attempts.
  ///
  /// In en, this message translates to:
  /// **'Max failures'**
  String get websites_lbMaxFails;

  /// Server fail timeout.
  ///
  /// In en, this message translates to:
  /// **'Fail timeout'**
  String get websites_lbFailTimeout;

  /// Maximum connections per server.
  ///
  /// In en, this message translates to:
  /// **'Max connections'**
  String get websites_lbMaxConns;

  /// Delete load balancing upstream.
  ///
  /// In en, this message translates to:
  /// **'Delete upstream'**
  String get websites_lbDelete;

  /// Load balancing saved toast.
  ///
  /// In en, this message translates to:
  /// **'Load balancing saved'**
  String get websites_lbSaved;

  /// Website template list title.
  ///
  /// In en, this message translates to:
  /// **'Website templates'**
  String get websites_templates;

  /// Create a website template.
  ///
  /// In en, this message translates to:
  /// **'New template'**
  String get websites_templateAdd;

  /// Edit a website template.
  ///
  /// In en, this message translates to:
  /// **'Edit template'**
  String get websites_templateEdit;

  /// Empty website template list.
  ///
  /// In en, this message translates to:
  /// **'No templates yet'**
  String get websites_templateEmpty;

  /// Website template name.
  ///
  /// In en, this message translates to:
  /// **'Template name'**
  String get websites_templateName;

  /// Website template type.
  ///
  /// In en, this message translates to:
  /// **'Template type'**
  String get websites_templateType;

  /// Single page template type.
  ///
  /// In en, this message translates to:
  /// **'Single page'**
  String get websites_templateSingle;

  /// Multi-file template type.
  ///
  /// In en, this message translates to:
  /// **'Multi-file'**
  String get websites_templateMulti;

  /// Single template HTML content.
  ///
  /// In en, this message translates to:
  /// **'HTML content'**
  String get websites_templateContent;

  /// Upload a multi-file template ZIP.
  ///
  /// In en, this message translates to:
  /// **'Upload ZIP'**
  String get websites_templateUpload;

  /// Template ZIP upload success.
  ///
  /// In en, this message translates to:
  /// **'Template uploaded'**
  String get websites_templateUploaded;

  /// Uploaded template package path.
  ///
  /// In en, this message translates to:
  /// **'Template package'**
  String get websites_templateFilePath;

  /// Website template remark.
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get websites_templateRemark;

  /// Website template variables.
  ///
  /// In en, this message translates to:
  /// **'Variables'**
  String get websites_templateVariables;

  /// Add a template variable.
  ///
  /// In en, this message translates to:
  /// **'Add variable'**
  String get websites_templateAddVariable;

  /// Template variable key.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get websites_templateVariableKey;

  /// Template variable label.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get websites_templateVariableLabel;

  /// Template variable type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get websites_templateVariableType;

  /// Template variable default value.
  ///
  /// In en, this message translates to:
  /// **'Default value'**
  String get websites_templateVariableDefault;

  /// Select variable options, comma separated.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get websites_templateVariableOptions;

  /// Template variable is required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get websites_templateVariableRequired;

  /// Detect template variables from HTML.
  ///
  /// In en, this message translates to:
  /// **'Detect variables'**
  String get websites_templateAutoDetect;

  /// Website template saved toast.
  ///
  /// In en, this message translates to:
  /// **'Template saved'**
  String get websites_templateSaved;

  /// Delete website template.
  ///
  /// In en, this message translates to:
  /// **'Delete template'**
  String get websites_templateDelete;

  /// Generate a site from the template.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get websites_templateGenerate;

  /// Generated template site list.
  ///
  /// In en, this message translates to:
  /// **'Generated websites'**
  String get websites_templateOutputs;

  /// Generated site name.
  ///
  /// In en, this message translates to:
  /// **'Output name'**
  String get websites_templateOutputName;

  /// Empty generated site list.
  ///
  /// In en, this message translates to:
  /// **'No generated websites'**
  String get websites_templateOutputEmpty;

  /// Generated site success toast.
  ///
  /// In en, this message translates to:
  /// **'Website generated'**
  String get websites_templateOutputGenerated;

  /// Delete generated template site.
  ///
  /// In en, this message translates to:
  /// **'Delete generated website'**
  String get websites_templateOutputDelete;

  /// Template has no variables.
  ///
  /// In en, this message translates to:
  /// **'No variables'**
  String get websites_templateNoVariables;

  /// Text variable type.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get websites_templateVariableTypeText;

  /// Textarea variable type.
  ///
  /// In en, this message translates to:
  /// **'Long text'**
  String get websites_templateVariableTypeTextarea;

  /// Number variable type.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get websites_templateVariableTypeNumber;

  /// Select variable type.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get websites_templateVariableTypeSelect;

  /// Color variable type.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get websites_templateVariableTypeColor;

  /// File AI content search entry.
  ///
  /// In en, this message translates to:
  /// **'AI search'**
  String get files_aiSearch;

  /// File AI search query.
  ///
  /// In en, this message translates to:
  /// **'Search content'**
  String get files_aiQuery;

  /// File AI search query hint.
  ///
  /// In en, this message translates to:
  /// **'Text to find in file contents'**
  String get files_aiQueryHint;

  /// Search subdirectories recursively.
  ///
  /// In en, this message translates to:
  /// **'Include subdirectories'**
  String get files_aiContainSub;

  /// Case sensitive search.
  ///
  /// In en, this message translates to:
  /// **'Match case'**
  String get files_aiMatchCase;

  /// Match whole words only.
  ///
  /// In en, this message translates to:
  /// **'Whole word'**
  String get files_aiWholeWord;

  /// Treat the query as a regular expression.
  ///
  /// In en, this message translates to:
  /// **'Use regular expression'**
  String get files_aiUseRegex;

  /// Shown when the panel returns grep mode.
  ///
  /// In en, this message translates to:
  /// **'AI is not enabled on the panel. Showing content matches only.'**
  String get files_aiGrepMode;

  /// AI generated search summary.
  ///
  /// In en, this message translates to:
  /// **'AI summary'**
  String get files_aiSummary;

  /// Content search matches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get files_aiHits;

  /// Number of files scanned.
  ///
  /// In en, this message translates to:
  /// **'Files scanned'**
  String get files_aiScanned;

  /// AI token usage.
  ///
  /// In en, this message translates to:
  /// **'Tokens'**
  String get files_aiTokens;

  /// Search duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get files_aiDuration;

  /// Search results truncated warning.
  ///
  /// In en, this message translates to:
  /// **'Results were truncated by the panel.'**
  String get files_aiTruncated;

  /// Empty AI search result.
  ///
  /// In en, this message translates to:
  /// **'No matching content'**
  String get files_aiEmpty;

  /// Line number label.
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get files_aiLine;

  /// Terminal session list entry.
  ///
  /// In en, this message translates to:
  /// **'Terminal sessions'**
  String get terminal_sessions;

  /// Empty terminal session list.
  ///
  /// In en, this message translates to:
  /// **'No terminal sessions'**
  String get terminal_sessionsEmpty;

  /// Terminal session is attached.
  ///
  /// In en, this message translates to:
  /// **'Attached'**
  String get terminal_sessionAttached;

  /// Terminal session is detached.
  ///
  /// In en, this message translates to:
  /// **'Detached'**
  String get terminal_sessionDetached;

  /// Close a terminal session.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get terminal_closeSession;

  /// Close all terminal sessions.
  ///
  /// In en, this message translates to:
  /// **'Close all'**
  String get terminal_closeAllSessions;

  /// Confirmation for closing all terminal sessions.
  ///
  /// In en, this message translates to:
  /// **'All terminal sessions will be disconnected and cannot be recovered.'**
  String get terminal_closeAllConfirm;

  /// Local terminal session kind.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get terminal_kindLocal;

  /// SSH terminal session kind.
  ///
  /// In en, this message translates to:
  /// **'SSH'**
  String get terminal_kindSsh;

  /// Container terminal session kind.
  ///
  /// In en, this message translates to:
  /// **'Container'**
  String get terminal_kindContainer;

  /// Upload in progress.
  ///
  /// In en, this message translates to:
  /// **'Uploading'**
  String get files_uploading;

  /// Upload paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get files_uploadPaused;

  /// Pause upload.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get files_uploadPause;

  /// Resume upload.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get files_uploadResume;

  /// Upload failed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get files_uploadFailed;

  /// ClamAV infected file strategy.
  ///
  /// In en, this message translates to:
  /// **'Infected file handling'**
  String get toolbox_infectedStrategy;

  /// Keep infected files.
  ///
  /// In en, this message translates to:
  /// **'Take no action'**
  String get toolbox_infectedNone;

  /// Delete infected files.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get toolbox_infectedRemove;

  /// Move infected files.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get toolbox_infectedMove;

  /// Copy infected files.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get toolbox_infectedCopy;

  /// Directory for moved or copied infected files.
  ///
  /// In en, this message translates to:
  /// **'Infected directory'**
  String get toolbox_infectedDir;

  /// Infected directory is required.
  ///
  /// In en, this message translates to:
  /// **'Enter an infected directory'**
  String get toolbox_infectedDirRequired;

  /// Edit a port whitelist rule.
  ///
  /// In en, this message translates to:
  /// **'Edit whitelist rule'**
  String get firewall_whitelistEdit;

  /// No supported firewall backend is available.
  ///
  /// In en, this message translates to:
  /// **'No selectable backend'**
  String get firewall_backendUnavailable;

  /// Switch action.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get action_switch;

  /// Reset firewall rules.
  ///
  /// In en, this message translates to:
  /// **'Reset rules'**
  String get firewall_resetRules;

  /// Confirmation for resetting firewall rules.
  ///
  /// In en, this message translates to:
  /// **'Managed firewall rules will be reset. Continue?'**
  String get firewall_resetRulesMessage;

  /// Restore firewall rule backup.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get firewall_restoreBackup;

  /// Confirmation for restoring a firewall backup.
  ///
  /// In en, this message translates to:
  /// **'Restore rules from backup {name}?'**
  String firewall_restoreBackupMessage(String name);

  /// Show the native firewall rule text.
  ///
  /// In en, this message translates to:
  /// **'Native rule detail'**
  String get firewall_nativeDetail;

  /// Native rule detail description.
  ///
  /// In en, this message translates to:
  /// **'Read the native firewalld or ufw definition'**
  String get firewall_nativeDetailHint;

  /// Firewall rule backups.
  ///
  /// In en, this message translates to:
  /// **'Rule backups'**
  String get firewall_ruleBackups;

  /// Empty firewall backup list.
  ///
  /// In en, this message translates to:
  /// **'No rule backups'**
  String get firewall_noBackups;

  /// Native rule name is required.
  ///
  /// In en, this message translates to:
  /// **'Enter a native rule name'**
  String get firewall_nativeNameRequired;

  /// Native rule kind.
  ///
  /// In en, this message translates to:
  /// **'Native kind'**
  String get firewall_nativeKind;

  /// firewalld zone service.
  ///
  /// In en, this message translates to:
  /// **'Zone service'**
  String get firewall_nativeZoneService;

  /// ufw application profile.
  ///
  /// In en, this message translates to:
  /// **'UFW application'**
  String get firewall_nativeUfwApplication;

  /// Native rule or application name.
  ///
  /// In en, this message translates to:
  /// **'Native name'**
  String get firewall_nativeName;

  /// Whether the native rule is permanent.
  ///
  /// In en, this message translates to:
  /// **'Permanent'**
  String get firewall_nativePermanent;

  /// Load native firewall detail.
  ///
  /// In en, this message translates to:
  /// **'Load native detail'**
  String get firewall_nativeLoad;

  /// Firewall backend switch hint.
  ///
  /// In en, this message translates to:
  /// **'Tap to switch the managed backend'**
  String get firewall_settingsBackendHint;

  /// Shown when pre-save SSH connectivity check fails.
  ///
  /// In en, this message translates to:
  /// **'Local SSH connection check failed. Save cancelled.'**
  String get host_sshCheckFailed;

  /// Shown when post-save SSH connectivity check fails.
  ///
  /// In en, this message translates to:
  /// **'SSH port saved, but the local connection check still fails. Verify the new port.'**
  String get host_sshCheckAfterSave;

  /// Container creation progress label.
  ///
  /// In en, this message translates to:
  /// **'Creating container…'**
  String get containers_creating;

  /// SSH boolean option enabled.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get host_sshValueOn;

  /// SSH boolean option disabled.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get host_sshValueOff;

  /// SSH root login restricted to keys.
  ///
  /// In en, this message translates to:
  /// **'Key only'**
  String get host_sshValueKeyOnly;

  /// SSH password login forbidden.
  ///
  /// In en, this message translates to:
  /// **'Password disabled'**
  String get host_sshValuePasswordForbidden;

  /// Toolbox service installed but stopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get toolbox_stopped;

  /// Fail2ban not installed guidance.
  ///
  /// In en, this message translates to:
  /// **'Fail2ban is not installed. Install it from the panel app store first.'**
  String get toolbox_notInstalledHint;

  /// Network trend chart title.
  ///
  /// In en, this message translates to:
  /// **'Network trend (last 5 minutes)'**
  String get dashboard_networkTrend;

  /// Network chart sampling hint.
  ///
  /// In en, this message translates to:
  /// **'The curve appears after 3 samples are collected.'**
  String get dashboard_networkCollectHint;

  /// Shown when launching a website in the browser fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to open the website'**
  String get websites_openFailed;

  /// Title for a failed 1Panel background task.
  ///
  /// In en, this message translates to:
  /// **'Task failed'**
  String get task_failedTitle;

  /// Title for a background task that is still running.
  ///
  /// In en, this message translates to:
  /// **'Task timed out'**
  String get task_timeoutTitle;

  /// Fallback when a failed task has no log line.
  ///
  /// In en, this message translates to:
  /// **'Check the panel logs for details.'**
  String get task_failedNoDetail;

  /// Message for a background task that exceeded the wait time.
  ///
  /// In en, this message translates to:
  /// **'The task is still running. Refresh the list later.'**
  String get task_timeoutMessage;

  /// Label for a firewall whitelist rule.
  ///
  /// In en, this message translates to:
  /// **'Whitelist'**
  String get firewall_whitelist;

  /// Leave the create page while the container task keeps running.
  ///
  /// In en, this message translates to:
  /// **'Continue in background'**
  String get containers_continueInBackground;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get files_folder;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Running…'**
  String get task_runningHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get containers_groupMaintenance;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'View logs'**
  String get containers_viewLogs;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Live monitor'**
  String get containers_liveMonitor;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Lifecycle'**
  String get containers_groupLifecycle;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get containers_resume;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Force stop'**
  String get containers_kill;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get containers_groupConfig;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Edit container'**
  String get containers_edit;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Change image, ports, volumes and limits'**
  String get containers_editSubtitle;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Upgrade container'**
  String get containers_upgrade;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Recreate with a newer image'**
  String get containers_upgradeSubtitle;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Commit as image'**
  String get containers_commit;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Save the current container as an image'**
  String get containers_commitSubtitle;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get containers_groupDanger;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Delete container'**
  String get containers_remove;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Stop and remove this container'**
  String get containers_removeSubtitle;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Always pull the latest image'**
  String get containers_forcePull;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'New image name'**
  String get containers_newImageName;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get containers_commitComment;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get containers_commitAuthor;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Pause the container while committing'**
  String get containers_pauseDuringCommit;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'No log output in the last hour'**
  String get containers_logsEmpty;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get containers_cache;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Disk read'**
  String get containers_diskRead;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Disk write'**
  String get containers_diskWrite;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Network received'**
  String get containers_networkRX;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Network sent'**
  String get containers_networkTX;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Container updated'**
  String get containers_updated;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get containers_saving;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Prune unused containers'**
  String get containers_prune;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Unused stopped containers and build cache will be removed. Running containers stay intact.'**
  String get containers_pruneConfirm;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Delete container'**
  String get containers_removeTitle;

  /// Container name to delete.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes {name} and its writable layer. Mounted data remains on disk.'**
  String containers_removeMessage(String name);

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Create scheduled task'**
  String get cronjobs_create;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Edit scheduled task'**
  String get cronjobs_edit;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Scheduled task updated'**
  String get cronjobs_updated;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Scheduled task created'**
  String get cronjobs_created;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get cronjobs_saving;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Task name'**
  String get cronjobs_name;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Task type'**
  String get cronjobs_type;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Cron expression'**
  String get cronjobs_spec;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Five-field cron, or @every 10m'**
  String get cronjobs_specHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Basic information'**
  String get cronjobs_basic;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Task configuration'**
  String get cronjobs_taskConfig;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Execution policy'**
  String get cronjobs_execution;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Shell script'**
  String get cronjobs_script;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Log files'**
  String get cronjobs_logFiles;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Comma-separated absolute paths'**
  String get cronjobs_logFilesHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Request URL'**
  String get cronjobs_url;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get cronjobs_website;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Database type'**
  String get cronjobs_databaseType;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Database name'**
  String get cronjobs_databaseName;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Directory'**
  String get cronjobs_directory;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get cronjobs_files;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Back up a directory'**
  String get cronjobs_backupDirectory;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'App install ID'**
  String get cronjobs_app;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Include container images'**
  String get cronjobs_withImage;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Log scopes'**
  String get cronjobs_scopes;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Comma-separated, for example system,ssh'**
  String get cronjobs_scopesHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Synchronize the system clock with the configured time source.'**
  String get cronjobs_ntpHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Clean temporary files and caches created by the panel.'**
  String get cronjobs_cleanHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Retained copies'**
  String get cronjobs_retainCopies;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Retry times'**
  String get cronjobs_retryTimes;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Timeout (seconds)'**
  String get cronjobs_timeout;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'0 means no timeout'**
  String get cronjobs_timeoutHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Enter a task name'**
  String get cronjobs_nameRequired;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Enter a cron expression'**
  String get cronjobs_specRequired;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Enter a shell script'**
  String get cronjobs_scriptRequired;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Enter a request URL'**
  String get cronjobs_urlRequired;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get cronjobs_enabled;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get cronjobs_disabled;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Task actions'**
  String get cronjobs_actions;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Stop running task'**
  String get cronjobs_stopRunning;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Execution records'**
  String get cronjobs_records;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Clean records'**
  String get cronjobs_cleanRecords;

  /// Scheduled task name.
  ///
  /// In en, this message translates to:
  /// **'Delete every execution record of {name}?'**
  String cronjobs_cleanRecordsConfirm(String name);

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'No execution records'**
  String get cronjobs_noRecords;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Records appear after the task runs.'**
  String get cronjobs_noRecordsHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Execution log'**
  String get cronjobs_recordLog;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'This record has no log output.'**
  String get cronjobs_recordLogEmpty;

  /// Scheduled task name.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String cronjobs_deleteTitle(String name);

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'The scheduled task and its records will be removed.'**
  String get cronjobs_deleteMessage;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Shell script'**
  String get cronjobs_typeShell;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Split logs'**
  String get cronjobs_typeLog;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Access URL'**
  String get cronjobs_typeCurl;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Back up website'**
  String get cronjobs_typeWebsite;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Back up database'**
  String get cronjobs_typeDatabase;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Back up directory'**
  String get cronjobs_typeDirectory;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Back up app'**
  String get cronjobs_typeApp;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Snapshot'**
  String get cronjobs_typeSnapshot;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Clean panel logs'**
  String get cronjobs_typeCleanLog;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Clean garbage'**
  String get cronjobs_typeClean;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Sync time'**
  String get cronjobs_typeNtp;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Create alert rule'**
  String get alerts_create;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Edit alert rule'**
  String get alerts_edit;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Alert rule updated'**
  String get alerts_updated;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Alert rule created'**
  String get alerts_created;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get alerts_saving;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Rule'**
  String get alerts_rule;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Alert type'**
  String get alerts_type;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get alerts_title;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to use the type name'**
  String get alerts_titleHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get alerts_project;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Website ID, disk path, or all'**
  String get alerts_projectHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Threshold'**
  String get alerts_threshold;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Trigger value'**
  String get alerts_count;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'CPU, memory or load percentage'**
  String get alerts_countHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Cycle (days)'**
  String get alerts_cycle;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Send limit per day'**
  String get alerts_sendCount;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Range 1-30'**
  String get alerts_sendCountHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Advanced parameters'**
  String get alerts_advancedParams;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Optional JSON or trigger mode'**
  String get alerts_advancedParamsHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Notification method'**
  String get alerts_notification;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'No enabled notification config. Add one on the panel first.'**
  String get alerts_noConfigs;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Notification config IDs'**
  String get alerts_method;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Comma-separated config IDs'**
  String get alerts_methodHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Select at least one notification method'**
  String get alerts_methodRequired;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'CPU usage'**
  String get alerts_typeCpu;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Memory usage'**
  String get alerts_typeMemory;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Disk usage'**
  String get alerts_typeDisk;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Load average'**
  String get alerts_typeLoad;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'SSH login'**
  String get alerts_typeSshLogin;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Panel login'**
  String get alerts_typePanelLogin;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Certificate expiry'**
  String get alerts_typeSsl;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Website expiry'**
  String get alerts_typeSiteEndTime;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Panel update'**
  String get alerts_typePanelUpdate;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Images and networks'**
  String get containers_resources;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Pull image'**
  String get containers_pullImage;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Create network'**
  String get containers_createNetwork;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Tag image'**
  String get containers_tagImage;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'In use'**
  String get containers_inUse;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Unused'**
  String get containers_unused;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Delete containers using this image first'**
  String get containers_imageInUseHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Delete image'**
  String get containers_removeImage;

  /// Resource name.
  ///
  /// In en, this message translates to:
  /// **'Delete image {name}?'**
  String containers_removeImageConfirm(String name);

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Pull an image by name, or create a container to pull one.'**
  String get containers_pullImageHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'No networks'**
  String get containers_noNetworks;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Create a bridge network for your containers.'**
  String get containers_createNetworkHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Delete network'**
  String get containers_removeNetwork;

  /// Resource name.
  ///
  /// In en, this message translates to:
  /// **'Delete network {name}?'**
  String containers_removeNetworkConfirm(String name);

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get containers_system;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get containers_driver;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Subnet'**
  String get containers_subnet;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Gateway'**
  String get containers_gateway;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get containers_up;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Take down'**
  String get containers_down;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Rebuild'**
  String get containers_rebuild;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Create compose'**
  String get containers_createCompose;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Edit compose'**
  String get containers_updateCompose;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Compose logs'**
  String get containers_composeLogs;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Clear compose logs'**
  String get containers_cleanComposeLogs;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Delete compose'**
  String get containers_deleteCompose;

  /// Compose project name.
  ///
  /// In en, this message translates to:
  /// **'Delete compose project {name}?'**
  String containers_deleteComposeConfirm(String name);

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Validate compose file'**
  String get containers_testCompose;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Compose file is valid'**
  String get containers_composeValid;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Compose file is invalid'**
  String get containers_composeInvalid;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Enter the compose file content'**
  String get containers_composeContentRequired;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Docker settings'**
  String get containers_dockerSettings;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Docker service'**
  String get containers_dockerService;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Docker is running'**
  String get containers_dockerRunning;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Docker is stopped'**
  String get containers_dockerStopped;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Log rotation'**
  String get containers_logSettings;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Max size'**
  String get containers_logMaxSize;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Max files'**
  String get containers_logMaxFile;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'IPv6'**
  String get containers_ipv6;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Fixed CIDR'**
  String get containers_fixedCidrV6;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Manage ip6tables'**
  String get containers_ip6Tables;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Experimental'**
  String get containers_experimental;

  /// Shown when a scheduled task no longer exists.
  ///
  /// In en, this message translates to:
  /// **'Scheduled task not found'**
  String get cronjobs_notFound;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'File tools'**
  String get files_tools;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get files_favorites;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Recycle bin'**
  String get files_recycleBin;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Shared links'**
  String get files_shares;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Remote download'**
  String get files_remoteDownload;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'No favorites'**
  String get files_noFavorites;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Star a file or folder from its action sheet.'**
  String get files_noFavoritesHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Remove favorite'**
  String get files_removeFavorite;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get files_addFavorite;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get files_favoriteAdded;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Empty recycle bin'**
  String get files_clearRecycleBin;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'All recycled files will be permanently deleted.'**
  String get files_clearRecycleBinConfirm;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Recycle bin is empty'**
  String get files_recycleEmpty;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Deleted files will appear here.'**
  String get files_recycleEmptyHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get files_restore;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'No shared links'**
  String get files_noShares;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Create a share from a file action sheet.'**
  String get files_noSharesHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Permanent'**
  String get files_permanentShare;

  /// Dynamic file share text.
  ///
  /// In en, this message translates to:
  /// **'Code {code}'**
  String files_shareCode(String code);

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Cancel share'**
  String get files_cancelShare;

  /// Dynamic file share text.
  ///
  /// In en, this message translates to:
  /// **'Cancel the share for {name}?'**
  String files_cancelShareConfirm(String name);

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Share details'**
  String get files_shareDetail;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get files_name;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get files_path;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Share code'**
  String get files_shareCodeLabel;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get files_sharePassword;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get files_shareExpire;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Copy share code'**
  String get files_copyShareCode;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Remote download started'**
  String get files_remoteDownloadStarted;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'No active downloads'**
  String get files_noRemoteDownloads;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Active remote downloads appear here.'**
  String get files_noRemoteDownloadsHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get files_url;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Target directory'**
  String get files_targetDirectory;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Ignore certificate errors'**
  String get files_ignoreCertificate;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Start download'**
  String get files_startDownload;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Move or copy'**
  String get files_moveCopy;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Batch permissions'**
  String get files_batchPermission;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Copy instead of move'**
  String get files_copyMode;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Overwrite existing files'**
  String get files_overwrite;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get files_copy;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get files_move;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Apply to subdirectories'**
  String get files_recursive;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get action_stop;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Advanced settings'**
  String get websites_advanced;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get websites_security;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Rewrite'**
  String get websites_rewrite;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Redirects'**
  String get websites_redirect;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Edit website info'**
  String get websites_editInfo;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get websites_favorite;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Default documents'**
  String get websites_indexConfig;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Set the files served for directory requests'**
  String get websites_indexConfigHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Traffic limits'**
  String get websites_limitConfig;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Limit concurrent connections and rate'**
  String get websites_limitConfigHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Directory owner'**
  String get websites_dirPermission;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Change the runtime user and group'**
  String get websites_dirPermissionHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get websites_enabled;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get websites_disabled;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Index files'**
  String get websites_indexFiles;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Per-server connections'**
  String get websites_perServer;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Per-IP connections'**
  String get websites_perIp;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Rate limit (KB/s)'**
  String get websites_rateKb;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get websites_owner;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get websites_group;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Access authentication'**
  String get websites_accessAuth;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get websites_username;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get websites_password;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Allowed origins'**
  String get websites_allowOrigins;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Allowed methods'**
  String get websites_allowMethods;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Allowed headers'**
  String get websites_allowHeaders;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Allow credentials'**
  String get websites_allowCredentials;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Preflight cache'**
  String get websites_preflight;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Hotlink protection'**
  String get websites_leech;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Allowed extensions'**
  String get websites_allowedExtensions;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Blocked response code'**
  String get websites_returnCode;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Block hotlinking'**
  String get websites_blocked;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Log blocked requests'**
  String get websites_logEnabled;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Real IP'**
  String get websites_realIp;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Trusted proxy'**
  String get websites_ipFrom;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'IP header'**
  String get websites_ipHeader;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Other proxy'**
  String get websites_ipOther;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get websites_rewriteTemplates;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Rule name'**
  String get websites_rewriteName;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Rewrite rules'**
  String get websites_rewriteContent;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Add redirect'**
  String get websites_addRedirect;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Edit redirect'**
  String get websites_editRedirect;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get websites_redirectType;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Domain'**
  String get websites_redirectDomain;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get websites_redirectPath;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Target URL'**
  String get websites_redirectTarget;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Status code'**
  String get websites_redirectCode;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Keep path'**
  String get websites_keepPath;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Redirect root'**
  String get websites_redirectRoot;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'No redirects'**
  String get websites_noRedirects;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Add a redirect rule for this website.'**
  String get websites_noRedirectsHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Add reverse proxy'**
  String get websites_addProxy;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Edit reverse proxy'**
  String get websites_editProxy;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Proxy name'**
  String get websites_proxyName;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Match path'**
  String get websites_proxyMatch;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Upstream URL'**
  String get websites_proxyPass;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Proxy host header'**
  String get websites_proxyHost;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'SNI'**
  String get websites_sni;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Verify upstream certificate'**
  String get websites_sslVerify;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get action_saved;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get action_loading;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Certificate management'**
  String get websites_sslManage;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Apply, upload and delete certificates here. Bind one from the SSL tab.'**
  String get websites_sslManageHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Upload certificate'**
  String get websites_uploadSsl;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Apply certificate'**
  String get websites_applySsl;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Certificate PEM'**
  String get websites_certificatePem;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Private key PEM'**
  String get websites_privateKeyPem;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Certificate uploaded'**
  String get websites_sslUploaded;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Certificate request submitted'**
  String get websites_sslRequested;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Create an ACME account on the panel first'**
  String get websites_noAcmeAccount;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'ACME account'**
  String get websites_acmeAccount;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Auto renew'**
  String get websites_autoRenew;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Delete certificate'**
  String get websites_deleteSsl;

  /// Certificate domain.
  ///
  /// In en, this message translates to:
  /// **'Delete certificate for {name}?'**
  String websites_deleteSslConfirm(String name);

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get action_upload;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Change database'**
  String get websites_changeDatabase;

  /// Current linked database names.
  ///
  /// In en, this message translates to:
  /// **'Current: {names}'**
  String websites_currentDatabase(String names);

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get websites_database;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Unbind database'**
  String get websites_unbindDatabase;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get apps_upgrade;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Edit parameters'**
  String get apps_editParams;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Change port'**
  String get apps_changePort;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Connection info'**
  String get apps_connInfo;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Ignore update'**
  String get apps_ignoreUpdate;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get apps_uninstall;

  /// App name to uninstall.
  ///
  /// In en, this message translates to:
  /// **'Uninstall {name}? This stops and removes the app containers.'**
  String apps_uninstallHint(String name);

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Delete database'**
  String get apps_deleteDatabase;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Delete backups'**
  String get apps_deleteBackup;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Delete images'**
  String get apps_deleteImage;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Force delete'**
  String get apps_forceDelete;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Already on the latest version'**
  String get apps_latestVersion;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Back up before upgrading'**
  String get apps_backupBeforeUpgrade;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Pull latest image'**
  String get apps_pullImage;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Advanced parameters'**
  String get apps_advancedParams;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Container name'**
  String get apps_containerName;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get apps_port;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get databases_advanced;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Configuration file'**
  String get databases_configFile;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Read and edit the database configuration'**
  String get databases_configFileHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Slow query log'**
  String get databases_slowLog;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Read the latest slow query log lines'**
  String get databases_slowLogHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'No slow query log entries'**
  String get databases_slowLogEmpty;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Redis'**
  String get databases_redis;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Redis configuration'**
  String get databases_redisConfig;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Redis password'**
  String get databases_redisPassword;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Redis persistence'**
  String get databases_redisPersistence;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get backups_create;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Backup type'**
  String get backups_type;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Database password'**
  String get backups_dbPassword;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get backups_description;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Stop container before backup'**
  String get backups_stopBefore;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Start backup'**
  String get backups_startBackup;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Backup accounts'**
  String get backups_accounts;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Add backup account'**
  String get backups_addAccount;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Edit backup account'**
  String get backups_editAccount;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'No backup accounts'**
  String get backups_noAccounts;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Add an account to store backups remotely.'**
  String get backups_noAccountsHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get backups_testConnection;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get backups_accountName;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Account type'**
  String get backups_accountType;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Access key'**
  String get backups_accessKey;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Secret key'**
  String get backups_credential;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Bucket'**
  String get backups_bucket;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Backup path'**
  String get backups_backupPath;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Account variables'**
  String get backups_vars;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Remember credentials'**
  String get backups_rememberAuth;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Connection succeeded'**
  String get backups_connectionOk;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get backups_connectionFailed;

  /// Backup account name.
  ///
  /// In en, this message translates to:
  /// **'Delete backup account {name}?'**
  String backups_deleteAccountConfirm(String name);

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Sync runtimes'**
  String get runtimes_sync;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Delete runtime'**
  String get runtimes_delete;

  /// Runtime name.
  ///
  /// In en, this message translates to:
  /// **'Delete runtime {name}?'**
  String runtimes_deleteConfirm(String name);

  /// Sync panel SSH keys to authorized_keys.
  ///
  /// In en, this message translates to:
  /// **'Sync SSH keys'**
  String get host_syncKeys;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get panelSettings_oldPassword;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get panelSettings_newPassword;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get panelSettings_confirmPassword;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get panelSettings_passwordMismatch;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Changing the panel port disconnects the current session. Make sure the new port is open in the firewall.'**
  String get panelSettings_portChangeWarning;

  /// New panel port.
  ///
  /// In en, this message translates to:
  /// **'Panel port changed to {port}'**
  String panelSettings_portChanged(int port);

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'API key generated and copied'**
  String get panelSettings_apiKeyCopied;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Snapshots'**
  String get panelSettings_snapshots;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Create, recreate and delete panel snapshots'**
  String get panelSettings_snapshotsHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Create snapshot'**
  String get panelSettings_createSnapshot;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'No snapshots'**
  String get panelSettings_noSnapshots;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Create a snapshot to back up panel data.'**
  String get panelSettings_noSnapshotsHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Snapshot name'**
  String get panelSettings_snapshotName;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get panelSettings_snapshotDescription;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Recreate snapshot'**
  String get panelSettings_recreateSnapshot;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Recreate this snapshot with current panel data?'**
  String get panelSettings_recreateSnapshotHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Delete this snapshot and its files?'**
  String get panelSettings_deleteSnapshotHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Snapshot task submitted'**
  String get panelSettings_snapshotCreated;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Include Docker config'**
  String get panelSettings_withDockerConf;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Include monitoring data'**
  String get panelSettings_withMonitorData;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Include login logs'**
  String get panelSettings_withLoginLog;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Include operation logs'**
  String get panelSettings_withOperationLog;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Include system logs'**
  String get panelSettings_withSystemLog;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Include task logs'**
  String get panelSettings_withTaskLog;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'OpenResty performance'**
  String get websites_openRestyPerformance;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'OpenResty main config'**
  String get websites_openRestyConfig;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Load config'**
  String get websites_loadConfig;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Sync remote apps'**
  String get apps_syncRemote;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Sync local apps'**
  String get apps_syncLocal;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Path authentication'**
  String get websites_pathAuth;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'No path authentication'**
  String get websites_noPathAuth;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Add path authentication'**
  String get websites_addPathAuth;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Edit path authentication'**
  String get websites_editPathAuth;

  /// Path to delete.
  ///
  /// In en, this message translates to:
  /// **'Delete authentication for {path}?'**
  String websites_deletePathAuth(String path);

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Registries'**
  String get containers_imageRepos;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Add registry'**
  String get containers_addRepo;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Edit registry'**
  String get containers_editRepo;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'No registries'**
  String get containers_noRepos;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Add a registry to pull and push images.'**
  String get containers_noReposHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Registry URL'**
  String get containers_repoUrl;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get containers_protocol;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Requires authentication'**
  String get containers_repoAuth;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Registry ID'**
  String get containers_repoId;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Build image'**
  String get containers_buildImage;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Export image'**
  String get containers_exportImage;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Import image'**
  String get containers_importImage;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Push image'**
  String get containers_pushImage;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Base image'**
  String get containers_baseImage;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Image archive paths'**
  String get containers_imageArchive;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Performance variables'**
  String get databases_variables;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Read and update MySQL runtime variables'**
  String get databases_variablesHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Redis status'**
  String get databases_redisStatus;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Install Redis CLI'**
  String get databases_installRedisCli;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Terminal sessions'**
  String get host_terminalSessions;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Review and close active SSH sessions'**
  String get host_terminalSessionsHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Close all'**
  String get host_closeAllSessions;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Certificate accounts'**
  String get websites_certificateAccounts;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Add ACME account'**
  String get websites_addAcme;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get websites_email;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'ACME type'**
  String get websites_acmeType;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'CA directory URL'**
  String get websites_caDirUrl;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Use proxy'**
  String get websites_useProxy;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Use EAB'**
  String get websites_useEab;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'No ACME accounts'**
  String get websites_noAcme;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Add an ACME account to request certificates.'**
  String get websites_noAcmeHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Add DNS account'**
  String get websites_addDns;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'DNS provider'**
  String get websites_dnsType;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Authorization JSON'**
  String get websites_authorization;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'No DNS accounts'**
  String get websites_noDns;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Add a DNS account for DNS-01 validation.'**
  String get websites_noDnsHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Add CA'**
  String get websites_addCa;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Common name'**
  String get websites_commonName;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get websites_country;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get websites_organization;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'No CA certificates'**
  String get websites_noCa;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Create a self-signed CA and issue certificates from it.'**
  String get websites_noCaHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Issue certificate'**
  String get websites_obtainCa;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Renew'**
  String get websites_renewCa;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Cancel ignored update'**
  String get apps_cancelIgnore;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'This app is not ignored'**
  String get apps_notIgnored;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Calculate exact size'**
  String get files_exactSize;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Clear container logs'**
  String get containers_cleanLogs;

  /// Container name.
  ///
  /// In en, this message translates to:
  /// **'Clear logs for {name}?'**
  String containers_cleanLogsConfirm(String name);

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'List buckets'**
  String get backups_listBuckets;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Refresh token'**
  String get backups_refreshToken;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Buckets'**
  String get backups_buckets;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Switch PHP version'**
  String get websites_switchPhp;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Change the PHP runtime or serve as a static website'**
  String get websites_switchPhpHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Static website'**
  String get websites_staticSite;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Edit certificate'**
  String get websites_editSsl;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Clean logs'**
  String get logs_clean;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Clean operation logs'**
  String get logs_cleanOperation;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Clean login logs'**
  String get logs_cleanLogin;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'This permanently clears the selected logs.'**
  String get logs_cleanConfirm;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Export SSH logs'**
  String get logs_exportSsh;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Panel memo'**
  String get panelSettings_memo;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'No memo yet'**
  String get panelSettings_memoHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Write a memo for this panel'**
  String get panelSettings_memoContentHint;

  /// Toast shown after exporting a log file.
  ///
  /// In en, this message translates to:
  /// **'Exported to {path}'**
  String logs_exported(String path);

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Save as custom template'**
  String get websites_saveAsCustomRewrite;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Check DNS'**
  String get websites_checkDns;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Add notification method'**
  String get alerts_addNotification;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Edit notification method'**
  String get alerts_editNotification;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Send test notification'**
  String get alerts_testNotification;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Configuration (JSON)'**
  String get alerts_configContent;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Configuration is not valid JSON'**
  String get alerts_configInvalid;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent'**
  String get alerts_testSent;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Test notification failed'**
  String get alerts_testFailed;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Calculate backup sizes'**
  String get backups_calculateSizes;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get backups_recordCount;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Total size'**
  String get backups_totalSize;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Container name'**
  String get backups_containerHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Website root directory'**
  String get files_websiteRoot;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Pick user or group'**
  String get files_pickOwner;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Allow API access for this panel'**
  String get panelSettings_apiInterfaceToggleHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Restore snapshot'**
  String get panelSettings_restoreSnapshot;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Rollback snapshot'**
  String get panelSettings_rollbackSnapshot;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Backup password (optional)'**
  String get panelSettings_snapshotSecret;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Restore task submitted'**
  String get panelSettings_snapshotRestoreSubmitted;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get action_continue;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Import snapshot'**
  String get panelSettings_importSnapshot;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Snapshot JSON'**
  String get panelSettings_snapshotJson;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Snapshot JSON is invalid'**
  String get panelSettings_snapshotJsonInvalid;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get action_import;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Runtime status'**
  String get databases_status;

  /// File name.
  ///
  /// In en, this message translates to:
  /// **'{name} already exists'**
  String files_alreadyExists(String name);

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Extension presets'**
  String get runtime_extensionPresets;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Containers using this image'**
  String get containers_containersUsingImage;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Docker disk usage'**
  String get containers_diskUsage;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Containers'**
  String get containers_usageContainers;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get containers_usageImages;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Volumes'**
  String get containers_usageVolumes;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Build cache'**
  String get containers_usageBuildCache;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Remote instances'**
  String get databases_remoteInstances;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Add remote instance'**
  String get databases_addRemote;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Edit remote instance'**
  String get databases_editRemote;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Load databases'**
  String get databases_loadDatabases;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get databases_testConnection;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Connection succeeded'**
  String get databases_connectionOk;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get databases_connectionFailed;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Use SSL'**
  String get databases_ssl;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Verify existence'**
  String get files_checkExistence;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication'**
  String get panelSettings_mfa;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Bind an authenticator app'**
  String get panelSettings_mfaHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get panelSettings_mfaCode;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Bind'**
  String get panelSettings_bindMfa;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Passkeys'**
  String get panelSettings_passkeys;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Manage registered passkeys'**
  String get panelSettings_passkeysHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'No passkeys registered'**
  String get panelSettings_noPasskeys;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Download certificate'**
  String get websites_downloadSsl;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Download CA'**
  String get websites_downloadCa;

  /// Saved file path.
  ///
  /// In en, this message translates to:
  /// **'Saved to {path}'**
  String websites_downloaded(String path);

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'App store settings'**
  String get apps_storeSettings;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Delete image when uninstalling'**
  String get apps_uninstallDeleteImage;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Back up before upgrade'**
  String get apps_upgradeBackup;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Delete backup when uninstalling'**
  String get apps_uninstallDeleteBackup;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Check port availability on install'**
  String get apps_installAllowPort;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Container users'**
  String get containers_users;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'package.json scripts'**
  String get runtime_scripts;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Code directory'**
  String get runtime_codeDir;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Supervisor configuration'**
  String get supervisor_configFile;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Compose templates'**
  String get containers_composeTemplates;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Import templates'**
  String get containers_importTemplates;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Template JSON must be a list'**
  String get containers_templateJsonInvalid;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Daemon key-value'**
  String get containers_daemonKeyValue;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get containers_daemonKey;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get containers_daemonValue;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Runtime name'**
  String get runtime_name;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get runtime_port;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get runtime_remark;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'SSH configuration file'**
  String get host_sshConfigFile;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Edit sshd_config directly'**
  String get host_sshConfigFileHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'No SSH configuration file found'**
  String get host_sshConfigNotFound;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Saving an invalid configuration may break SSH access.'**
  String get host_sshConfigWarning;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'SSH configuration saved'**
  String get host_sshConfigSaved;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Test SSH connection'**
  String get host_testSsh;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Verify address, port and credentials'**
  String get host_testSshHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'View access log'**
  String get websites_viewAccessLog;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'View error log'**
  String get websites_viewErrorLog;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Read the latest lines in-app'**
  String get websites_liveLogHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Description and pin'**
  String get websites_descriptionPin;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Set the panel description and pin state'**
  String get websites_descriptionPinHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get websites_description;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Pin to top'**
  String get websites_pin;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Copy from existing website'**
  String get websites_copyFromExisting;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Panel HTTPS'**
  String get panelSettings_panelSsl;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Configure HTTPS for the panel entry'**
  String get panelSettings_panelSslHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Changing panel HTTPS may interrupt the current session.'**
  String get panelSettings_panelSslWarning;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'SSL mode'**
  String get panelSettings_panelSslMode;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Certificate source'**
  String get panelSettings_panelSslType;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Edit process config'**
  String get supervisor_editConfig;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'View stdout log'**
  String get supervisor_viewOutLog;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'View error log'**
  String get supervisor_viewErrLog;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Restore from server file'**
  String get backups_restoreFromFile;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Upload a backup file already present on the server, then restore it.'**
  String get backups_restoreFromFileHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Server file path'**
  String get backups_serverFilePath;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Edit source'**
  String get websites_editSource;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Create runtime'**
  String get runtime_create;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get runtime_typeLabel;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get runtime_image;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'App detail ID'**
  String get runtime_appDetailId;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Resource'**
  String get runtime_resource;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get runtime_version;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Parameters (JSON)'**
  String get runtime_paramsJson;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Parameters must be a JSON object'**
  String get runtime_paramsInvalid;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'This app is already installed. Manage it from the installed list.'**
  String get apps_alreadyInstalled;

  /// One-line error summary.
  ///
  /// In en, this message translates to:
  /// **'{title}: {message}'**
  String common_errorLine(String title, String message);

  /// SSL badge label.
  ///
  /// In en, this message translates to:
  /// **'SSL'**
  String get websites_ssl;

  /// Toast after deleting a reverse proxy.
  ///
  /// In en, this message translates to:
  /// **'Reverse proxy deleted'**
  String get websites_proxyDeleted;

  /// Validation message for proxy form.
  ///
  /// In en, this message translates to:
  /// **'Proxy name and upstream address are required.'**
  String get websites_proxyRequired;

  /// Validation message for path authentication.
  ///
  /// In en, this message translates to:
  /// **'Complete all required fields.'**
  String get websites_requiredFields;

  /// Validation message for access authentication.
  ///
  /// In en, this message translates to:
  /// **'Username is required when authentication is enabled.'**
  String get websites_usernameRequired;

  /// Menu item shown when updates are ignored.
  ///
  /// In en, this message translates to:
  /// **'Resume update reminders'**
  String get apps_cancelIgnoreUpdate;

  /// Runtime entry subtitle.
  ///
  /// In en, this message translates to:
  /// **'PHP / Node / Python'**
  String get more_runtimesSubtitle;

  /// Compose entry subtitle.
  ///
  /// In en, this message translates to:
  /// **'docker compose'**
  String get more_composeSubtitle;

  /// Empty firewall rules after filtering.
  ///
  /// In en, this message translates to:
  /// **'No matching rules'**
  String get firewall_noMatchingRules;

  /// Hint shown when firewall filters match nothing.
  ///
  /// In en, this message translates to:
  /// **'Adjust the keyword or clear the filters.'**
  String get firewall_clearFiltersHint;

  /// Row title for generating an API key.
  ///
  /// In en, this message translates to:
  /// **'API key'**
  String get panelSettings_apiKeyRow;

  /// Panel SSL mode.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get panelSettings_sslModeEnable;

  /// Panel SSL mode.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get panelSettings_sslModeDisable;

  /// Panel SSL mode.
  ///
  /// In en, this message translates to:
  /// **'Mux'**
  String get panelSettings_sslModeMux;

  /// Certificate source option.
  ///
  /// In en, this message translates to:
  /// **'Paste certificate'**
  String get panelSettings_sslPaste;

  /// Certificate source option.
  ///
  /// In en, this message translates to:
  /// **'Select existing'**
  String get panelSettings_sslSelectExisting;

  /// Certificate source option.
  ///
  /// In en, this message translates to:
  /// **'Self-signed'**
  String get panelSettings_sslSelfSigned;

  /// English language label.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get panelSettings_languageEn;

  /// Backup account type.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get backups_typeLocal;

  /// Backup account type.
  ///
  /// In en, this message translates to:
  /// **'SFTP'**
  String get backups_typeSftp;

  /// Backup account type.
  ///
  /// In en, this message translates to:
  /// **'S3'**
  String get backups_typeS3;

  /// Backup account type.
  ///
  /// In en, this message translates to:
  /// **'Alibaba Cloud OSS'**
  String get backups_typeOss;

  /// Backup account type.
  ///
  /// In en, this message translates to:
  /// **'Tencent Cloud COS'**
  String get backups_typeCos;

  /// Backup account type.
  ///
  /// In en, this message translates to:
  /// **'MinIO'**
  String get backups_typeMinio;

  /// Backup account type.
  ///
  /// In en, this message translates to:
  /// **'OneDrive'**
  String get backups_typeOneDrive;

  /// Backup account type.
  ///
  /// In en, this message translates to:
  /// **'WebDAV'**
  String get backups_typeWebdav;

  /// Backup account type.
  ///
  /// In en, this message translates to:
  /// **'Qiniu Kodo'**
  String get backups_typeKodo;

  /// Backup account type.
  ///
  /// In en, this message translates to:
  /// **'UPYUN'**
  String get backups_typeUpyun;

  /// Backup account type.
  ///
  /// In en, this message translates to:
  /// **'Aliyun Drive'**
  String get backups_typeAliyun;

  /// Backup account type.
  ///
  /// In en, this message translates to:
  /// **'Google Drive'**
  String get backups_typeGoogleDrive;

  /// Empty state title for runtimes.
  ///
  /// In en, this message translates to:
  /// **'No runtimes installed'**
  String get runtimes_emptyTitle;

  /// Empty state title for PHP extensions.
  ///
  /// In en, this message translates to:
  /// **'No extensions available'**
  String get runtime_extensionsEmptyTitle;

  /// Empty state title for Node modules.
  ///
  /// In en, this message translates to:
  /// **'No modules installed'**
  String get runtime_modulesEmptyTitle;

  /// Empty state title for website templates.
  ///
  /// In en, this message translates to:
  /// **'No templates yet'**
  String get websites_templatesEmptyTitle;

  /// Empty state title for template outputs.
  ///
  /// In en, this message translates to:
  /// **'No generated websites yet'**
  String get websites_templateOutputsEmptyTitle;

  /// Empty state title when SSH info is missing.
  ///
  /// In en, this message translates to:
  /// **'SSH service unavailable'**
  String get host_sshUnavailableTitle;

  /// Empty state title for disks.
  ///
  /// In en, this message translates to:
  /// **'No disks detected'**
  String get host_disksEmptyTitle;

  /// Empty state title for diagnostics.
  ///
  /// In en, this message translates to:
  /// **'No diagnostics yet'**
  String get host_diagnosticsEmptyTitle;

  /// Empty state title for diagnostics snapshots.
  ///
  /// In en, this message translates to:
  /// **'No snapshots yet'**
  String get host_diagSnapshotEmptyTitle;

  /// Empty state title for FTP accounts.
  ///
  /// In en, this message translates to:
  /// **'No FTP accounts yet'**
  String get toolbox_ftpEmptyTitle;

  /// Empty state title for banned IPs.
  ///
  /// In en, this message translates to:
  /// **'No banned IPs'**
  String get toolbox_sshBanEmptyTitle;

  /// Empty state title for antivirus scans.
  ///
  /// In en, this message translates to:
  /// **'No scan records yet'**
  String get toolbox_clamScanEmptyTitle;

  /// Empty state title for notification methods.
  ///
  /// In en, this message translates to:
  /// **'No notification methods configured'**
  String get panelSettings_notificationMethodsEmptyTitle;

  /// Empty state title for processes.
  ///
  /// In en, this message translates to:
  /// **'No processes'**
  String get process_emptyTitle;

  /// Empty state title for terminal sessions.
  ///
  /// In en, this message translates to:
  /// **'No terminal sessions'**
  String get terminal_emptySessionsTitle;

  /// Empty state title for file history.
  ///
  /// In en, this message translates to:
  /// **'No file history'**
  String get files_historyEmptyTitle;

  /// Empty state title for AI file search.
  ///
  /// In en, this message translates to:
  /// **'No matching files'**
  String get files_aiHitsEmptyTitle;

  /// Empty state title for load balance upstreams.
  ///
  /// In en, this message translates to:
  /// **'No upstream nodes'**
  String get websites_loadBalanceEmptyTitle;

  /// Connected panel count.
  ///
  /// In en, this message translates to:
  /// **'{count} panels'**
  String servers_count(int count);

  /// Section title for connected panels.
  ///
  /// In en, this message translates to:
  /// **'Connected panels'**
  String get servers_sectionConnected;

  /// Section title for supervisor processes.
  ///
  /// In en, this message translates to:
  /// **'Guarded processes'**
  String get supervisor_sectionProcesses;

  /// Section title for device time settings.
  ///
  /// In en, this message translates to:
  /// **'Time zone and time'**
  String get toolbox_timeSection;

  /// Installed app count.
  ///
  /// In en, this message translates to:
  /// **'{count} apps'**
  String more_appsCount(int count);

  /// Database count.
  ///
  /// In en, this message translates to:
  /// **'{count} databases'**
  String more_databasesCount(int count);

  /// Scheduled task count.
  ///
  /// In en, this message translates to:
  /// **'{count} scheduled tasks'**
  String more_cronjobsCount(int count);

  /// Template variable count.
  ///
  /// In en, this message translates to:
  /// **'{count} variables'**
  String websites_templateVariableCount(int count);

  /// No log entries in this category yet.
  ///
  /// In en, this message translates to:
  /// **'No log entries in this category yet.'**
  String get log_emptyMessage;

  /// No processes are available on this server.
  ///
  /// In en, this message translates to:
  /// **'No processes are available on this server.'**
  String get process_emptyMessage;

  /// Runtimes installed from the app store will appear here.
  ///
  /// In en, this message translates to:
  /// **'Runtimes installed from the app store will appear here.'**
  String get runtimes_emptyMessage;

  /// Filter the loaded log buffer by text.
  ///
  /// In en, this message translates to:
  /// **'Search log lines'**
  String get logs_searchHint;

  /// Show original log lines.
  ///
  /// In en, this message translates to:
  /// **'Raw'**
  String get logs_raw;

  /// Label for copying the original log line
  ///
  /// In en, this message translates to:
  /// **'Raw data'**
  String get logs_rawData;

  /// Parse time and level from log lines.
  ///
  /// In en, this message translates to:
  /// **'Structured'**
  String get logs_structured;

  /// No description provided for @logs_time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get logs_time;

  /// No description provided for @logs_startOfFile.
  ///
  /// In en, this message translates to:
  /// **'Start of file reached'**
  String get logs_startOfFile;

  /// No description provided for @logs_exportLoadedCount.
  ///
  /// In en, this message translates to:
  /// **'Export the {count} loaded lines'**
  String logs_exportLoadedCount(int count);

  /// No description provided for @logs_copyRaw.
  ///
  /// In en, this message translates to:
  /// **'Copy raw line'**
  String get logs_copyRaw;

  /// No description provided for @logs_copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get logs_copied;

  /// No description provided for @logs_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get logs_status;

  /// No description provided for @logs_method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get logs_method;

  /// No description provided for @logs_path.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get logs_path;

  /// No description provided for @logs_ip.
  ///
  /// In en, this message translates to:
  /// **'Client IP'**
  String get logs_ip;

  /// No description provided for @logs_userAgent.
  ///
  /// In en, this message translates to:
  /// **'User-Agent'**
  String get logs_userAgent;

  /// No description provided for @logs_referer.
  ///
  /// In en, this message translates to:
  /// **'Referer'**
  String get logs_referer;

  /// No description provided for @logs_bytes.
  ///
  /// In en, this message translates to:
  /// **'Bytes'**
  String get logs_bytes;

  /// No description provided for @logs_upstream.
  ///
  /// In en, this message translates to:
  /// **'Upstream'**
  String get logs_upstream;

  /// No description provided for @logs_duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get logs_duration;

  /// No description provided for @logs_request.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get logs_request;

  /// Keep refreshing the log while open.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get logs_follow;

  /// Stop automatic log refresh.
  ///
  /// In en, this message translates to:
  /// **'Stop follow'**
  String get logs_stopFollow;

  /// Reveal older lines from the loaded buffer.
  ///
  /// In en, this message translates to:
  /// **'Load earlier lines'**
  String get logs_loadEarlier;

  /// No log line matches the current search.
  ///
  /// In en, this message translates to:
  /// **'No matching lines'**
  String get logs_noMatches;

  /// Number of log lines currently loaded.
  ///
  /// In en, this message translates to:
  /// **'{count} lines'**
  String logs_lineCount(int count);

  /// Number of log lines matching the search.
  ///
  /// In en, this message translates to:
  /// **'{count} matches'**
  String logs_matchCount(int count);

  /// Log auto refresh is active.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get logs_following;

  /// Installed apps that have a newer version.
  ///
  /// In en, this message translates to:
  /// **'Updatable'**
  String get apps_upgradable;

  /// Catalog tab showing every app.
  ///
  /// In en, this message translates to:
  /// **'All apps'**
  String get apps_allApps;

  /// Empty state when no installed app can be upgraded.
  ///
  /// In en, this message translates to:
  /// **'No updates available'**
  String get apps_upgradableEmptyTitle;

  /// Empty state detail for the upgradable tab.
  ///
  /// In en, this message translates to:
  /// **'Every installed app is on its latest version.'**
  String get apps_upgradableEmptyMessage;

  /// Open the server system log files.
  ///
  /// In en, this message translates to:
  /// **'System logs'**
  String get logs_system;

  /// Certificate has been issued.
  ///
  /// In en, this message translates to:
  /// **'Issued'**
  String get websites_sslStatusReady;

  /// Certificate is deployed to the website.
  ///
  /// In en, this message translates to:
  /// **'Deployed'**
  String get websites_sslStatusApplied;

  /// Certificate is being issued or deployed.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get websites_sslStatusPending;

  /// Certificate issuance or deployment failed.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get websites_sslStatusError;

  /// OneDash UI string.
  ///
  /// In en, this message translates to:
  /// **'Architecture'**
  String get app_detail_arch;

  /// OneDash UI string.
  ///
  /// In en, this message translates to:
  /// **'GPU support'**
  String get app_detail_gpu;

  /// OneDash UI string.
  ///
  /// In en, this message translates to:
  /// **'Latest version'**
  String get app_detail_latestVersion;

  /// OneDash UI string.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get app_detail_website;

  /// OneDash UI string.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get app_detail_github;

  /// OneDash UI string.
  ///
  /// In en, this message translates to:
  /// **'Docs'**
  String get app_detail_docs;

  /// OneDash UI string.
  ///
  /// In en, this message translates to:
  /// **'About this app'**
  String get app_detail_intro;

  /// OneDash UI string.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get logs_cards;

  /// OneDash UI string.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get containers_overview_resources;

  /// OneDash UI string.
  ///
  /// In en, this message translates to:
  /// **'Disk usage'**
  String get containers_overview_disk;

  /// Reclaimable disk space.
  ///
  /// In en, this message translates to:
  /// **'Reclaimable {size}'**
  String containers_overview_reclaimable(String size);

  /// Running container count.
  ///
  /// In en, this message translates to:
  /// **'Running {count}'**
  String containers_overview_runningCount(int count);

  /// Rebuild an installed app.
  ///
  /// In en, this message translates to:
  /// **'Rebuild'**
  String get apps_rebuild;

  /// Reload an installed app.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get apps_reload;

  /// Confirmation message for rebuilding an installed app.
  ///
  /// In en, this message translates to:
  /// **'Rebuild recreates the container. Unsaved runtime data may be lost.'**
  String get apps_rebuildConfirm;

  /// Install log entry for an installed app.
  ///
  /// In en, this message translates to:
  /// **'Install log'**
  String get apps_installLog;

  /// Empty install log message.
  ///
  /// In en, this message translates to:
  /// **'No install log for this app yet.'**
  String get apps_installLogEmpty;

  /// Host page subtitle in the more menu.
  ///
  /// In en, this message translates to:
  /// **'SSH · Disk · Diagnostics'**
  String get host_subtitleOps;

  /// Combined toolbox entry for time, swap and DNS.
  ///
  /// In en, this message translates to:
  /// **'Time · Swap · DNS'**
  String get toolbox_timeSwapDns;

  /// Supervisor entry in the more menu.
  ///
  /// In en, this message translates to:
  /// **'Supervisor'**
  String get supervisor_titleLong;

  /// Empty volume list title.
  ///
  /// In en, this message translates to:
  /// **'No volumes'**
  String get containers_volumesEmpty;

  /// Empty volume list hint.
  ///
  /// In en, this message translates to:
  /// **'Volumes created by containers will appear here.'**
  String get containers_volumesEmptyHint;

  /// Confirmation message for deleting a volume.
  ///
  /// In en, this message translates to:
  /// **'Delete volume {name}? Data stored on it will be lost.'**
  String containers_volumeDeleteConfirm(String name);

  /// Recycle bin enabled status.
  ///
  /// In en, this message translates to:
  /// **'Recycle bin is on'**
  String get files_recycleEnabled;

  /// Recycle bin disabled status.
  ///
  /// In en, this message translates to:
  /// **'Recycle bin is off'**
  String get files_recycleDisabled;

  /// Title for monitor device selection.
  ///
  /// In en, this message translates to:
  /// **'Monitor devices'**
  String get dashboard_monitorOptions;

  /// Disk IO monitor option.
  ///
  /// In en, this message translates to:
  /// **'Disk IO'**
  String get dashboard_monitorDisk;

  /// Network interface monitor option.
  ///
  /// In en, this message translates to:
  /// **'Network interface'**
  String get dashboard_monitorNetwork;

  /// Host resource limit hint.
  ///
  /// In en, this message translates to:
  /// **'Host limit: {cpu} cores · {memory} MB'**
  String containers_limitAvailable(int cpu, int memory);

  /// Disk alert mount path.
  ///
  /// In en, this message translates to:
  /// **'Monitored disk'**
  String get alerts_disk;

  /// Disk alert mount path hint.
  ///
  /// In en, this message translates to:
  /// **'Choose the mount path to monitor'**
  String get alerts_diskHint;

  /// Local backup directory label.
  ///
  /// In en, this message translates to:
  /// **'Local directory'**
  String get backups_localDir;

  /// Panel bind interface address.
  ///
  /// In en, this message translates to:
  /// **'Interface address'**
  String get panelSettings_bindAddress;

  /// App tag filter label.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get apps_filterTags;

  /// All monitor devices
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get dashboard_monitorAll;

  /// Select a system user for FTP
  ///
  /// In en, this message translates to:
  /// **'System user'**
  String get toolbox_ftpSystemUser;

  /// Upload from file
  ///
  /// In en, this message translates to:
  /// **'Upload from file'**
  String get websites_uploadSslFile;

  /// Paste PEM
  ///
  /// In en, this message translates to:
  /// **'Paste PEM'**
  String get websites_uploadSslPaste;

  /// Select certificate file
  ///
  /// In en, this message translates to:
  /// **'Select certificate file'**
  String get websites_selectCertificateFile;

  /// Select private key file
  ///
  /// In en, this message translates to:
  /// **'Select private key file'**
  String get websites_selectPrivateKeyFile;

  /// OpenResty status
  ///
  /// In en, this message translates to:
  /// **'OpenResty status'**
  String get websites_openRestyStatus;

  /// Active connections
  ///
  /// In en, this message translates to:
  /// **'Active connections'**
  String get websites_openRestyActive;

  /// Requests
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get websites_openRestyRequests;

  /// Accepted / handled
  ///
  /// In en, this message translates to:
  /// **'Accepted / handled'**
  String get websites_openRestyAcceptsHandled;

  /// Preview
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get panelSettings_previewSnapshot;

  /// Snapshot content
  ///
  /// In en, this message translates to:
  /// **'Snapshot content'**
  String get panelSettings_snapshotContent;

  /// Reorder
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get servers_reorder;

  /// Drag to reorder servers
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder servers'**
  String get servers_reorderHint;

  /// Organization unit
  ///
  /// In en, this message translates to:
  /// **'Organization unit'**
  String get websites_organizationUnit;

  /// Province
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get websites_province;

  /// City
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get websites_city;

  /// Key type
  ///
  /// In en, this message translates to:
  /// **'Key type'**
  String get websites_keyType;

  /// Certificate path
  ///
  /// In en, this message translates to:
  /// **'Certificate path'**
  String get websites_certPath;

  /// Private key path
  ///
  /// In en, this message translates to:
  /// **'Private key path'**
  String get websites_privateKeyPath;

  /// Status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get websites_status;

  /// AI tools
  ///
  /// In en, this message translates to:
  /// **'AI tools'**
  String get ai_title;

  /// Models
  ///
  /// In en, this message translates to:
  /// **'Models'**
  String get ai_models;

  /// GPU
  ///
  /// In en, this message translates to:
  /// **'GPU'**
  String get ai_gpu;

  /// MCP servers
  ///
  /// In en, this message translates to:
  /// **'MCP servers'**
  String get ai_mcp;

  /// No models
  ///
  /// In en, this message translates to:
  /// **'No models'**
  String get ai_models_empty;

  /// Add an Ollama model to start.
  ///
  /// In en, this message translates to:
  /// **'Add an Ollama model to start.'**
  String get ai_models_empty_hint;

  /// No GPU detected
  ///
  /// In en, this message translates to:
  /// **'No GPU detected'**
  String get ai_gpu_empty;

  /// GPU information appears when a supported device is present.
  ///
  /// In en, this message translates to:
  /// **'GPU information appears when a supported device is present.'**
  String get ai_gpu_empty_hint;

  /// No MCP servers
  ///
  /// In en, this message translates to:
  /// **'No MCP servers'**
  String get ai_mcp_empty;

  /// Add an MCP server to expose tools.
  ///
  /// In en, this message translates to:
  /// **'Add an MCP server to expose tools.'**
  String get ai_mcp_empty_hint;

  /// Add model
  ///
  /// In en, this message translates to:
  /// **'Add model'**
  String get ai_model_add;

  /// Model name
  ///
  /// In en, this message translates to:
  /// **'Model name'**
  String get ai_model_name;

  /// Size
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get ai_model_size;

  /// Status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get ai_model_status;

  /// Source
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get ai_model_from;

  /// Load
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get ai_model_load;

  /// Unload
  ///
  /// In en, this message translates to:
  /// **'Unload'**
  String get ai_model_unload;

  /// Add MCP server
  ///
  /// In en, this message translates to:
  /// **'Add MCP server'**
  String get ai_mcp_add;

  /// Server name
  ///
  /// In en, this message translates to:
  /// **'Server name'**
  String get ai_mcp_name;

  /// Runtime
  ///
  /// In en, this message translates to:
  /// **'Runtime'**
  String get ai_mcp_type;

  /// Command
  ///
  /// In en, this message translates to:
  /// **'Command'**
  String get ai_mcp_command;

  /// Container name
  ///
  /// In en, this message translates to:
  /// **'Container name'**
  String get ai_mcp_container;

  /// Port
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get ai_mcp_port;

  /// SSE path
  ///
  /// In en, this message translates to:
  /// **'SSE path'**
  String get ai_mcp_sse_path;

  /// Base URL
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get ai_mcp_url;

  /// Output protocol
  ///
  /// In en, this message translates to:
  /// **'Output protocol'**
  String get ai_mcp_protocol;

  /// Transport
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get ai_mcp_transport;

  /// Running
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get ai_mcp_running;

  /// Stopped
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get ai_mcp_stopped;

  /// Start
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get ai_mcp_start;

  /// Stop
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get ai_mcp_stop;

  /// Restart
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get ai_mcp_restart;

  /// Test connection
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get ai_mcp_test;

  /// Delete MCP server {name}?
  ///
  /// In en, this message translates to:
  /// **'Delete MCP server {name}?'**
  String ai_mcp_delete_confirm(String name);

  /// Driver
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get ai_gpu_driver;

  /// CUDA
  ///
  /// In en, this message translates to:
  /// **'CUDA'**
  String get ai_gpu_cuda;

  /// Memory
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get ai_gpu_memory;

  /// Utilization
  ///
  /// In en, this message translates to:
  /// **'Utilization'**
  String get ai_gpu_utilization;

  /// Temperature
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get ai_gpu_temperature;

  /// Processes
  ///
  /// In en, this message translates to:
  /// **'Processes'**
  String get ai_gpu_processes;

  /// Connection OK
  ///
  /// In en, this message translates to:
  /// **'Connection OK'**
  String get ai_mcp_connection_ok;

  /// Connection failed
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get ai_mcp_connection_failed;

  /// Redis command line
  ///
  /// In en, this message translates to:
  /// **'Redis command line'**
  String get databases_redisCommand;

  /// Models · GPU · MCP
  ///
  /// In en, this message translates to:
  /// **'Models · GPU · MCP'**
  String get ai_subtitle;

  /// Details
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get ai_mcp_detail;

  /// Environment variables
  ///
  /// In en, this message translates to:
  /// **'Environment variables'**
  String get ai_mcp_environments;

  /// Volumes
  ///
  /// In en, this message translates to:
  /// **'Volumes'**
  String get ai_mcp_volumes;

  /// One KEY=VALUE per line
  ///
  /// In en, this message translates to:
  /// **'One KEY=VALUE per line'**
  String get ai_mcp_env_hint;

  /// One source:target per line
  ///
  /// In en, this message translates to:
  /// **'One source:target per line'**
  String get ai_mcp_volume_hint;

  /// MCP domain
  ///
  /// In en, this message translates to:
  /// **'MCP domain'**
  String get ai_mcp_domain;

  /// Bind domain
  ///
  /// In en, this message translates to:
  /// **'Bind domain'**
  String get ai_mcp_bind_domain;

  /// Update domain
  ///
  /// In en, this message translates to:
  /// **'Update domain'**
  String get ai_mcp_update_domain;

  /// SSL ID
  ///
  /// In en, this message translates to:
  /// **'SSL ID'**
  String get ai_mcp_ssl_id;

  /// Allowed IPs
  ///
  /// In en, this message translates to:
  /// **'Allowed IPs'**
  String get ai_mcp_ip_list;

  /// Connection URL
  ///
  /// In en, this message translates to:
  /// **'Connection URL'**
  String get ai_mcp_conn_url;

  /// Sync status
  ///
  /// In en, this message translates to:
  /// **'Sync status'**
  String get ai_mcp_sync_status;

  /// Model accounts
  ///
  /// In en, this message translates to:
  /// **'Model accounts'**
  String get ai_accounts;

  /// Agents
  ///
  /// In en, this message translates to:
  /// **'Agents'**
  String get ai_agents;

  /// No model accounts
  ///
  /// In en, this message translates to:
  /// **'No model accounts'**
  String get ai_accounts_empty;

  /// Add a provider account to use models.
  ///
  /// In en, this message translates to:
  /// **'Add a provider account to use models.'**
  String get ai_accounts_empty_hint;

  /// No agents
  ///
  /// In en, this message translates to:
  /// **'No agents'**
  String get ai_agents_empty;

  /// Installed agents will appear here.
  ///
  /// In en, this message translates to:
  /// **'Installed agents will appear here.'**
  String get ai_agents_empty_hint;

  /// Provider
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get ai_account_provider;

  /// Verified
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get ai_account_verified;

  /// Unverified
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get ai_account_unverified;

  /// Status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get ai_agent_status;

  /// Model
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get ai_agent_model;

  /// Website
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get ai_agent_website;

  /// Reset token
  ///
  /// In en, this message translates to:
  /// **'Reset token'**
  String get ai_agent_token_reset;

  /// Remark
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get ai_agent_remark;

  /// Delete agent {name}?
  ///
  /// In en, this message translates to:
  /// **'Delete agent {name}?'**
  String ai_agent_delete_confirm(String name);

  /// Upgrade available
  ///
  /// In en, this message translates to:
  /// **'Upgrade available'**
  String get ai_agent_upgradable;

  /// Add model account
  ///
  /// In en, this message translates to:
  /// **'Add model account'**
  String get ai_account_add;

  /// Edit model account
  ///
  /// In en, this message translates to:
  /// **'Edit model account'**
  String get ai_account_edit;

  /// Account name
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get ai_account_name;

  /// API key
  ///
  /// In en, this message translates to:
  /// **'API key'**
  String get ai_account_api_key;

  /// Base URL
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get ai_account_base_url;

  /// API type
  ///
  /// In en, this message translates to:
  /// **'API type'**
  String get ai_account_api_type;

  /// Verify model
  ///
  /// In en, this message translates to:
  /// **'Verify model'**
  String get ai_account_verify_model;

  /// Validate availability
  ///
  /// In en, this message translates to:
  /// **'Validate availability'**
  String get ai_account_validate;

  /// Remember API key
  ///
  /// In en, this message translates to:
  /// **'Remember API key'**
  String get ai_account_remember_key;

  /// Remark
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get ai_account_remark;

  /// Model configuration
  ///
  /// In en, this message translates to:
  /// **'Model configuration'**
  String get ai_agent_model_config;

  /// Fallback models
  ///
  /// In en, this message translates to:
  /// **'Fallback models'**
  String get ai_agent_fallbacks;

  /// Add agent
  ///
  /// In en, this message translates to:
  /// **'Add agent'**
  String get ai_agent_add;

  /// Agent type
  ///
  /// In en, this message translates to:
  /// **'Agent type'**
  String get ai_agent_type;

  /// Version
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get ai_agent_version;

  /// WebUI port
  ///
  /// In en, this message translates to:
  /// **'WebUI port'**
  String get ai_agent_port;

  /// Access host
  ///
  /// In en, this message translates to:
  /// **'Access host'**
  String get ai_agent_access_host;

  /// Dashboard username
  ///
  /// In en, this message translates to:
  /// **'Dashboard username'**
  String get ai_agent_username;

  /// Dashboard password
  ///
  /// In en, this message translates to:
  /// **'Dashboard password'**
  String get ai_agent_password;

  /// Bind website
  ///
  /// In en, this message translates to:
  /// **'Bind website'**
  String get ai_agent_bind_website;

  /// Unbind website
  ///
  /// In en, this message translates to:
  /// **'Unbind website'**
  String get ai_agent_unbind_website;

  /// Select website
  ///
  /// In en, this message translates to:
  /// **'Select website'**
  String get ai_agent_select_website;

  /// Roles
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get ai_agent_roles;

  /// Channels
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get ai_agent_channels;

  /// No roles
  ///
  /// In en, this message translates to:
  /// **'No roles'**
  String get ai_agent_roles_empty;

  /// No channels
  ///
  /// In en, this message translates to:
  /// **'No channels'**
  String get ai_agent_channels_empty;

  /// Delete role {name}?
  ///
  /// In en, this message translates to:
  /// **'Delete role {name}?'**
  String ai_agent_delete_role_confirm(String name);

  /// Bound
  ///
  /// In en, this message translates to:
  /// **'Bound'**
  String get ai_agent_bound;

  /// Unbound
  ///
  /// In en, this message translates to:
  /// **'Unbound'**
  String get ai_agent_unbound;

  /// Add role
  ///
  /// In en, this message translates to:
  /// **'Add role'**
  String get ai_agent_role_add;

  /// Channel
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get ai_agent_binding_channel;

  /// Account ID
  ///
  /// In en, this message translates to:
  /// **'Account ID'**
  String get ai_agent_account_id;

  /// Role name
  ///
  /// In en, this message translates to:
  /// **'Role name'**
  String get ai_agent_role_name;

  /// Bind channel
  ///
  /// In en, this message translates to:
  /// **'Bind channel'**
  String get ai_agent_bind_channel;

  /// Unbind channel
  ///
  /// In en, this message translates to:
  /// **'Unbind channel'**
  String get ai_agent_unbind_channel;

  /// Feishu channel
  ///
  /// In en, this message translates to:
  /// **'Feishu channel'**
  String get ai_agent_feishu;

  /// Enabled
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get ai_agent_channel_enabled;

  /// Group policy
  ///
  /// In en, this message translates to:
  /// **'Group policy'**
  String get ai_agent_group_policy;

  /// Require mention
  ///
  /// In en, this message translates to:
  /// **'Require mention'**
  String get ai_agent_require_mention;

  /// Streaming
  ///
  /// In en, this message translates to:
  /// **'Streaming'**
  String get ai_agent_streaming;

  /// Thread session
  ///
  /// In en, this message translates to:
  /// **'Thread session'**
  String get ai_agent_thread_session;

  /// Connection mode
  ///
  /// In en, this message translates to:
  /// **'Connection mode'**
  String get ai_agent_connection_mode;

  /// Bots
  ///
  /// In en, this message translates to:
  /// **'Bots'**
  String get ai_agent_bots;

  /// Channel settings saved
  ///
  /// In en, this message translates to:
  /// **'Channel settings saved'**
  String get ai_agent_channel_saved;

  /// Channel configuration
  ///
  /// In en, this message translates to:
  /// **'Channel configuration'**
  String get ai_agent_channel_config;

  /// Channel JSON
  ///
  /// In en, this message translates to:
  /// **'Channel JSON'**
  String get ai_agent_channel_json;

  /// Channel JSON is invalid
  ///
  /// In en, this message translates to:
  /// **'Channel JSON is invalid'**
  String get ai_agent_channel_json_invalid;

  /// Edit the JSON returned by the panel. agentId is added on save.
  ///
  /// In en, this message translates to:
  /// **'Edit the JSON returned by the panel. agentId is added on save.'**
  String get ai_agent_channel_json_hint;

  /// Remove channel config
  ///
  /// In en, this message translates to:
  /// **'Remove channel config'**
  String get ai_agent_channel_delete;

  /// Remove {channel} configuration for this agent?
  ///
  /// In en, this message translates to:
  /// **'Remove {channel} configuration for this agent?'**
  String ai_agent_channel_delete_confirm(String channel);

  /// Browse keys
  ///
  /// In en, this message translates to:
  /// **'Browse keys'**
  String get databases_redisKeys;

  /// Weixin QR login
  ///
  /// In en, this message translates to:
  /// **'Weixin QR login'**
  String get ai_agent_weixin_login;

  /// Scan the QR code shown in the task log to connect Weixin.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code shown in the task log to connect Weixin.'**
  String get ai_agent_weixin_login_hint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Domain, directory, port and index files'**
  String get websites_basicConfigHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Auth, CORS, hotlink protection and real IP'**
  String get websites_securityHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Rewrite rules'**
  String get websites_rewriteHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Redirect rules'**
  String get websites_redirectHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Forward a domain to an existing service'**
  String get websites_proxyHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Serve HTML / CSS / JS directly'**
  String get websites_staticHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'PHP / Java / Node.js / Go / Python / .NET'**
  String get websites_runtimeHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'TCP/UDP proxy'**
  String get websites_tunnel;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Layer 4 forwarding without HTTP'**
  String get websites_tunnelHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get websites_port;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get websites_protocol;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Enable SSL'**
  String get websites_enableSsl;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'IPv6'**
  String get websites_ipv6;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Relative to {path}'**
  String websites_relativeDir(Object path);

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Website created'**
  String get websites_createSuccess;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Select a certificate'**
  String get websites_sslRequired;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get websites_menu;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'OpenResty is not installed'**
  String get websites_openRestyNotInstalled;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'OpenResty is stopped'**
  String get websites_openRestyStopped;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Open the app store'**
  String get websites_openRestyInstall;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get websites_openRestyService;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get websites_openRestyStart;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get websites_openRestyStop;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get websites_openRestyRestart;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get websites_openRestyReload;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Server names hash bucket size'**
  String get websites_serverNamesHash;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Client header buffer size'**
  String get websites_clientHeaderBuffer;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Maximum upload size'**
  String get websites_maxBodySize;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Keepalive timeout'**
  String get websites_keepaliveTimeout;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Enable compression'**
  String get websites_gzip;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Minimum compressed size'**
  String get websites_gzipMinLength;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Compression level'**
  String get websites_gzipCompLevel;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'OpenResty logs'**
  String get websites_openRestyLogs;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Main configuration'**
  String get websites_openRestyConfigFile;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get websites_openRestyPerformanceTitle;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'New reverse proxy'**
  String get websites_createProxyTitle;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'New static site'**
  String get websites_createStaticTitle;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'New runtime site'**
  String get websites_createRuntimeTitle;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'New TCP-UDP proxy'**
  String get websites_createStreamTitle;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get websites_openRestyReading;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get websites_openRestyWriting;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get websites_openRestyWaiting;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Start OpenResty from the service menu first.'**
  String get websites_openRestyServiceHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Install OpenResty before changing global settings.'**
  String get websites_openRestyInstallHint;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Run \"{action}\" on OpenResty?'**
  String websites_openRestyServiceConfirm(Object action);

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Create database'**
  String get websites_createDb;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Database name'**
  String get websites_dbName;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'Create FTP'**
  String get websites_enableFtp;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'FTP user'**
  String get websites_ftpUser;

  /// OneDash UI text.
  ///
  /// In en, this message translates to:
  /// **'FTP password'**
  String get websites_ftpPassword;
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
