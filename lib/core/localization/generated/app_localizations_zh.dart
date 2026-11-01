// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get app_title => 'OneDash';

  @override
  String get common_delete => '删除';

  @override
  String get common_systemDefault => '跟随系统';

  @override
  String get common_saved => '保存成功';

  @override
  String get common_retry => '重试';

  @override
  String get common_search => '搜索';

  @override
  String get common_yes => '是';

  @override
  String get common_no => '否';

  @override
  String get format_relativeUnknown => '未知';

  @override
  String get format_relativeSoon => '即将';

  @override
  String get format_relativeJustNow => '刚刚';

  @override
  String format_relativeMinutesLater(int n) {
    return '$n 分钟后';
  }

  @override
  String format_relativeHoursLater(int n) {
    return '$n 小时后';
  }

  @override
  String format_relativeDaysLater(int n) {
    return '$n 天后';
  }

  @override
  String format_relativeMinutesAgo(int n) {
    return '$n 分钟前';
  }

  @override
  String format_relativeHoursAgo(int n) {
    return '$n 小时前';
  }

  @override
  String format_relativeDaysAgo(int n) {
    return '$n 天前';
  }

  @override
  String get format_timeAgoPrefixBackup => '备份于 ';

  @override
  String get terminal_disconnected => '已断开';

  @override
  String get terminal_connecting => '连接中';

  @override
  String get nav_overview => '概览';

  @override
  String get nav_websites => '网站';

  @override
  String get nav_files => '文件';

  @override
  String get nav_containers => '容器';

  @override
  String get nav_more => '更多';

  @override
  String get nav_network => '网络';

  @override
  String get dashboard_system => '系统';

  @override
  String get dashboard_kernel => '内核';

  @override
  String get dashboard_cpuCores => '核心';

  @override
  String get dashboard_uptime => '运行时长';

  @override
  String get dashboard_load => '负载';

  @override
  String get dashboard_processes => '进程数';

  @override
  String get dashboard_arch => '架构';

  @override
  String get dashboard_memory => '内存';

  @override
  String get dashboard_disk => '磁盘';

  @override
  String get dashboard_download => '下载';

  @override
  String get dashboard_upload => '上传';

  @override
  String dashboard_uptimeMinutes(int minutes) {
    return '$minutes分钟';
  }

  @override
  String dashboard_uptimeHoursMinutes(int hours, int minutes) {
    return '$hours小时 $minutes分钟';
  }

  @override
  String dashboard_uptimeDaysHours(int days, int hours) {
    return '$days天 $hours小时';
  }

  @override
  String get files_sortName => '名称';

  @override
  String get files_sortSize => '大小';

  @override
  String get files_sortModifiedTime => '修改时间';

  @override
  String get files_rootDirectory => '根目录';

  @override
  String get files_actionPreviewImage => '预览图片';

  @override
  String get files_actionDecompress => '解压';

  @override
  String get process_serverMissing => '服务器不存在';

  @override
  String get process_stopTitle => '停止进程';

  @override
  String process_stopContent(int pid) {
    return '确认停止 PID $pid？';
  }

  @override
  String get process_stopAction => '停止';

  @override
  String get more_appStoreSubtitle => '管理已安装应用、升级与应用设置';

  @override
  String get servers_host => '主机地址';

  @override
  String get servers_online => '在线';

  @override
  String get settings_title => '设置';

  @override
  String get settings_appearance_modeLight => '浅色';

  @override
  String get settings_appearance_modeDark => '暗色';

  @override
  String get firewall_title => '防火墙';

  @override
  String get firewall_port => '端口';

  @override
  String get firewall_portPlaceholder => '80、8080-8090 或 80,443';

  @override
  String get firewall_strategy => '策略';

  @override
  String get firewall_ipAddress => 'IP 地址';

  @override
  String get firewall_ipAddressPlaceholder => '192.168.1.100 或 10.0.0.0/8';

  @override
  String get firewall_protocolLabel => '协议';

  @override
  String get firewall_descriptionLabel => '描述';

  @override
  String get panelSettings_alerts => '告警通知';

  @override
  String get panelSettings_basicInfo => '基本信息';

  @override
  String get panelSettings_defaultAccessAddress => '默认访问地址';

  @override
  String get panelSettings_notSet => '未设置';

  @override
  String get panelSettings_defaultAccessAddressPlaceholder => '请输入默认访问地址';

  @override
  String get panelSettings_panelUsername => '面板用户名';

  @override
  String get panelSettings_panelLoginPassword => '面板登录密码';

  @override
  String get panelSettings_changePanelLoginPassword => '修改面板登录密码';

  @override
  String get panelSettings_displaySettingsWebOnly => '显示设置（仅影响 Web 界面）';

  @override
  String get panelSettings_theme => '主题';

  @override
  String get panelSettings_themeLight => '浅色';

  @override
  String get panelSettings_themeDark => '深色';

  @override
  String get panelSettings_language => '语言';

  @override
  String get panelSettings_languageZh => '中文';

  @override
  String get panelSettings_languageZhHant => '繁體中文';

  @override
  String get panelSettings_languageJa => '日本語';

  @override
  String get panelSettings_languageMs => 'Bahasa Melayu';

  @override
  String get panelSettings_languagePtBr => 'Português (Brasil)';

  @override
  String get panelSettings_tabNavigation => '标签页导航';

  @override
  String get panelSettings_tabNavigationSubtitle => '在顶栏显示页面标签';

  @override
  String get panelSettings_securitySettings => '安全设置';

  @override
  String get panelSettings_sessionTimeout => '会话超时';

  @override
  String get panelSettings_neverTimeout => '永不超时';

  @override
  String panelSettings_secondsValue(String seconds) {
    return '$seconds 秒';
  }

  @override
  String get panelSettings_sessionTimeoutPlaceholder => '0 = 永不超时';

  @override
  String get panelSettings_sessionTimeoutDescription =>
      '设置面板登录会话的超时时间（秒）。设为 0 表示永不超时。';

  @override
  String get panelSettings_advancedSettings => '高级设置';

  @override
  String get panelSettings_apiInterface => 'API 接口';

  @override
  String get panelSettings_webPanelRequired => '请在 1Panel 网页面板中操作';

  @override
  String get panelSettings_localApiKey => '此 App 保存的连接密钥';

  @override
  String get panelSettings_enabled => '已启用';

  @override
  String get panelSettings_disabled => '未启用';

  @override
  String get panelSettings_settingUpdated => '设置已更新';

  @override
  String get panelSettings_updateFailed => '更新失败';

  @override
  String get panelSettings_panelPort => '面板端口';

  @override
  String get panelSettings_securityEntrance => '安全入口';

  @override
  String get panelSettings_bindDomain => '绑定域名';

  @override
  String get panelSettings_operationFailed => '操作失败';

  @override
  String get panelSettings_alertList => '告警列表';

  @override
  String get panelSettings_alertLogs => '告警日志';

  @override
  String get panelSettings_noAlertRules => '暂无告警规则';

  @override
  String panelSettings_alertCardMeta(String type, String method) {
    return '类型: $type  方式: $method';
  }

  @override
  String get panelSettings_deleted => '已删除';

  @override
  String get panelSettings_deleteFailed => '删除失败';

  @override
  String get panelSettings_logsCleared => '日志已清空';

  @override
  String get panelSettings_clearFailed => '清空失败';

  @override
  String get panelSettings_clearLogs => '清空日志';

  @override
  String get panelSettings_noLogs => '暂无日志';

  @override
  String get panelSettings_notificationMethods => '通知方式';

  @override
  String get panelSettings_emailNotification => '邮件通知';

  @override
  String get panelSettings_smtpSubtitle => '配置 SMTP 邮件发送';

  @override
  String get panelSettings_webhookSubtitle => '配置 Webhook';

  @override
  String get panelSettings_weCom => '企业微信';

  @override
  String get panelSettings_dingTalk => '钉钉';

  @override
  String get panelSettings_feishu => '飞书';

  @override
  String get panelSettings_type => '类型';

  @override
  String get panelSettings_credentials => '身份凭证';

  @override
  String get cronjobs_title => '计划任务';

  @override
  String get cronjobs_enable => '启用';

  @override
  String get cronjobs_disable => '禁用';

  @override
  String get cronjobs_runOnce => '立即执行';

  @override
  String cronjobs_everyMinutes(String n) {
    return '每隔 $n 分钟';
  }

  @override
  String cronjobs_everySeconds(String n) {
    return '每隔 $n 秒';
  }

  @override
  String cronjobs_everyHourAtMinute(String minute) {
    return '每小时第 $minute 分钟';
  }

  @override
  String cronjobs_dailyAt(String time) {
    return '每天 $time';
  }

  @override
  String cronjobs_everyHours(String n) {
    return '每隔 $n 小时';
  }

  @override
  String cronjobs_weeklyAt(String weekday, String time) {
    return '每$weekday $time';
  }

  @override
  String cronjobs_monthlyAt(String day, String time) {
    return '每月 $day 日 $time';
  }

  @override
  String cronjobs_everyDaysAt(String n, String time) {
    return '每隔 $n 天 $time';
  }

  @override
  String get cronjobs_weekdaySun => '周日';

  @override
  String get cronjobs_weekdayMon => '周一';

  @override
  String get cronjobs_weekdayTue => '周二';

  @override
  String get cronjobs_weekdayWed => '周三';

  @override
  String get cronjobs_weekdayThu => '周四';

  @override
  String get cronjobs_weekdayFri => '周五';

  @override
  String get cronjobs_weekdaySat => '周六';

  @override
  String cronjobs_weekdayFallback(String day) {
    return '周$day';
  }

  @override
  String get appStore_installed => '已安装';

  @override
  String get appStore_appKey => '应用标识';

  @override
  String get websites_basicConfig => '基本配置';

  @override
  String get websites_alias => '代号';

  @override
  String get websites_runtime => '运行环境';

  @override
  String get websites_proxySettings => '反向代理设置';

  @override
  String get websites_website => '网站';

  @override
  String get websites_sslCertificate => 'SSL 证书';

  @override
  String get websites_noReverseProxy => '暂无反向代理';

  @override
  String get websites_websiteAlias => '网站代号';

  @override
  String get websites_rootDirectory => '根目录';

  @override
  String get websites_domains => '域名';

  @override
  String get websites_remark => '备注';

  @override
  String get websites_optional => '选填';

  @override
  String get websites_domain => '域名';

  @override
  String get websites_removeDomain => '移除域名';

  @override
  String get websites_noDomains => '暂无域名';

  @override
  String get websites_siteDirectory => '网站目录';

  @override
  String get websites_deleteReverseProxy => '删除反向代理';

  @override
  String get websites_targetAddress => '目标地址';

  @override
  String get websites_logs => '日志';

  @override
  String get websites_configFile => '配置文件';

  @override
  String get websites_accessLog => '访问日志';

  @override
  String get websites_errorLog => '错误日志';

  @override
  String get websites_path => '路径';

  @override
  String get containers_privilegedMode => '特权模式';

  @override
  String get containers_hostname => '主机名';

  @override
  String get containers_mountedVolumes => '挂载卷';

  @override
  String get containers_workingDir => '工作目录';

  @override
  String get containers_command => '命令';

  @override
  String get containers_entrypoint => '入口';

  @override
  String get containers_envVars => '环境变量';

  @override
  String get containers_restartPolicy => '重启策略';

  @override
  String get containers_start => '启动';

  @override
  String get containers_stop => '停止';

  @override
  String get containers_restart => '重启';

  @override
  String get containers_running => '运行中';

  @override
  String get containers_stopped => '已停止';

  @override
  String get containers_compose => 'Compose';

  @override
  String get containers_logs => '日志';

  @override
  String get containers_all => '全部';

  @override
  String get containers_terminal => '终端';

  @override
  String get containers_images => '镜像';

  @override
  String get containers_pause => '暂停';

  @override
  String get containers_memory => '内存';

  @override
  String get databases_changePassword => '改密';

  @override
  String get databases_changePasswordSubtitle => '修改数据库密码';

  @override
  String get databases_address => '地址';

  @override
  String get databases_port => '端口';

  @override
  String get databases_username => '用户名';

  @override
  String get databases_password => '密码';

  @override
  String get databases_remoteAccess => '远程访问';

  @override
  String get databases_enabled => '已开启';

  @override
  String get databases_disabled => '已关闭';

  @override
  String get databases_deleteDatabase => '删除数据库';

  @override
  String get databases_passwordChanged => '密码修改成功';

  @override
  String get databases_newPassword => '新密码';

  @override
  String get common_empty_title => '这里还没有内容';

  @override
  String get common_empty_message => '暂无数据可显示。';

  @override
  String get error_details => '详情';

  @override
  String get error_auth_title => 'API Key 无效';

  @override
  String get error_auth_message => 'API Key 无效或已过期，请在 1Panel 面板设置中重新生成。';

  @override
  String get error_network_title => '无法连接到面板';

  @override
  String get error_network_message => '请检查网络与面板地址后重试。';

  @override
  String get error_cert_title => '证书不受信任';

  @override
  String get error_cert_message => '面板使用了自签名证书。若你信任该主机，可在服务器设置中允许。';

  @override
  String get error_server_title => '面板内部错误';

  @override
  String error_server_message(int statusCode) {
    return '面板返回 HTTP $statusCode。';
  }

  @override
  String get error_not_found_title => '当前版本不支持';

  @override
  String get error_not_found_message => '该面板版本未提供此接口，入口已自动隐藏。';

  @override
  String get error_request_title => '请求被拒绝';

  @override
  String get error_business_title => '操作失败';

  @override
  String get error_format_title => '数据格式不兼容';

  @override
  String get error_format_message => '面板响应格式与应用版本不兼容。';

  @override
  String get error_unknown_title => '出现了一点问题';

  @override
  String get error_unknown_message => '请重试；若持续出现，请查看面板日志。';

  @override
  String get servers_title => '面板';

  @override
  String get servers_empty_title => '还没有连接任何面板';

  @override
  String get servers_empty_message => '在 1Panel 的「面板设置 → API 接口」中生成密钥。';

  @override
  String get servers_add => '添加面板';

  @override
  String get servers_current => '当前';

  @override
  String get servers_offline => '离线';

  @override
  String servers_last_seen(String time) {
    return '最后连接 $time';
  }

  @override
  String get servers_delete => '删除面板';

  @override
  String get servers_delete_message => '仅从本机移除该面板，不会影响面板本身。';

  @override
  String get server_edit_add_title => '添加面板';

  @override
  String get server_edit_edit_title => '编辑面板';

  @override
  String get server_edit_address => '地址';

  @override
  String get server_edit_name => '名称';

  @override
  String get server_edit_name_hint => '我的服务器';

  @override
  String get server_edit_host => '主机';

  @override
  String get server_edit_port => '端口';

  @override
  String get server_edit_https => 'HTTPS';

  @override
  String get server_edit_api_key => 'API 密钥';

  @override
  String get server_edit_api_key_hint => '粘贴 1Panel 生成的密钥';

  @override
  String get server_edit_allow_insecure => '允许自签名证书';

  @override
  String get server_edit_allow_insecure_hint => '仅对该主机生效，将跳过证书校验。';

  @override
  String get server_edit_test => '测试连接';

  @override
  String get server_edit_save => '保存并进入';

  @override
  String get server_edit_diag_network => '网络可达';

  @override
  String get server_edit_diag_tls => '证书信任';

  @override
  String get server_edit_diag_auth => '鉴权通过';

  @override
  String get server_edit_diag_capability => '端点能力';

  @override
  String get server_edit_host_hint => '例如 192.168.1.10';

  @override
  String get server_edit_key_guide => '1Panel → 面板设置 → API 接口 → 生成密钥';

  @override
  String get dashboard_health => '健康分';

  @override
  String get dashboard_health_excellent => '优';

  @override
  String get dashboard_health_good => '良';

  @override
  String get dashboard_health_fair => '一般';

  @override
  String get dashboard_health_poor => '差';

  @override
  String get dashboard_cpu => 'CPU';

  @override
  String get dashboard_network => '网络';

  @override
  String get dashboard_system_info => '系统信息';

  @override
  String get dashboard_sites_containers => '站点与容器';

  @override
  String get dashboard_quick_actions => '快捷操作';

  @override
  String get dashboard_clear_cache => '清理缓存';

  @override
  String get dashboard_view_logs => '查看日志';

  @override
  String get dashboard_terminal => '终端';

  @override
  String get dashboard_firewall => '防火墙';

  @override
  String dashboard_cores(int count) {
    return '$count 核';
  }

  @override
  String dashboard_used_of(String used, String total) {
    return '$used / $total';
  }

  @override
  String get dashboard_offline_banner => '连接中断，正在重试';

  @override
  String get files_empty_title => '这个文件夹是空的';

  @override
  String get files_empty_message => '上传文件或新建文件夹开始使用。';

  @override
  String get files_upload => '上传';

  @override
  String get files_new_folder => '新建文件夹';

  @override
  String get files_new_file => '新建文件';

  @override
  String get files_download => '下载';

  @override
  String get files_delete => '删除';

  @override
  String get files_rename => '重命名';

  @override
  String get files_compress => '压缩';

  @override
  String get files_share => '分享';

  @override
  String get files_sort => '排序';

  @override
  String get files_parent => '上一级';

  @override
  String get websites_title => '网站';

  @override
  String get websites_empty_title => '还没有网站';

  @override
  String get websites_empty_message => '创建一个静态站点或反向代理来开始。';

  @override
  String get websites_create => '创建网站';

  @override
  String get websites_all => '全部';

  @override
  String get websites_running => '运行中';

  @override
  String get websites_stopped => '站点已停止';

  @override
  String get websites_static => '静态';

  @override
  String get websites_proxy => '反向代理';

  @override
  String get websites_php => 'PHP';

  @override
  String websites_expire_days(int days) {
    return '剩余 $days 天';
  }

  @override
  String get containers_title => '容器';

  @override
  String get containers_empty_title => '还没有容器';

  @override
  String get containers_empty_message => '面板上创建的容器会显示在这里。';

  @override
  String get containers_abnormal => '异常';

  @override
  String get containers_config => '配置';

  @override
  String get more_title => '更多';

  @override
  String get more_group_apps => '应用与服务';

  @override
  String get more_group_web => 'Web 服务';

  @override
  String get more_group_ops => '运维';

  @override
  String get more_group_system => '系统';

  @override
  String get more_app_store => '应用商店';

  @override
  String get more_installed_apps => '已安装应用';

  @override
  String get more_databases => '数据库';

  @override
  String get more_cronjobs => '计划任务';

  @override
  String get more_firewall => '防火墙';

  @override
  String get more_logs => '日志中心';

  @override
  String get more_terminal => '终端';

  @override
  String get more_panel_settings => '面板设置';

  @override
  String get more_app_settings => '应用设置';

  @override
  String get more_process => '进程';

  @override
  String get more_backups => '备份';

  @override
  String get more_runtimes => '运行环境';

  @override
  String get settings_appearance => '外观';

  @override
  String get settings_theme_mode => '主题模式';

  @override
  String get settings_accent => '强调色';

  @override
  String get settings_dynamic_color => '动态取色';

  @override
  String get settings_dynamic_color_hint => '使用 Android 12+ 壁纸取色';

  @override
  String get settings_oled => 'OLED 纯黑';

  @override
  String get settings_text_scale => '字号缩放';

  @override
  String get settings_interaction => '交互';

  @override
  String get settings_haptics => '触觉反馈';

  @override
  String get settings_list_animations => '列表动画';

  @override
  String get settings_about => '关于';

  @override
  String get settings_version => '版本';

  @override
  String get settings_licenses => '开源许可';

  @override
  String get settings_privacy => '隐私';

  @override
  String get settings_security => '安全';

  @override
  String get settings_secure_screen => '禁止截屏';

  @override
  String get action_retry => '重试';

  @override
  String get action_edit => '编辑';

  @override
  String get action_delete => '删除';

  @override
  String get action_cancel => '取消';

  @override
  String get action_confirm => '确认';

  @override
  String get action_save => '保存';

  @override
  String get action_close => '关闭';

  @override
  String get action_search => '搜索';

  @override
  String get action_refresh => '刷新';

  @override
  String get action_copy => '复制';

  @override
  String get action_more => '更多';

  @override
  String get action_create => '创建';

  @override
  String get action_done => '完成';

  @override
  String get state_empty => '暂无数据';

  @override
  String get terminal_title => '终端';

  @override
  String get terminal_connected => '已连接';

  @override
  String get terminal_disconnect_confirm => '断开当前会话？';

  @override
  String get logs_title => '日志';

  @override
  String get logs_operation => '操作';

  @override
  String get logs_login => '登录';

  @override
  String get logs_ssh => 'SSH';

  @override
  String get logs_task => '任务';

  @override
  String get apps_title => '应用商店';

  @override
  String get apps_search_hint => '搜索应用';

  @override
  String get apps_install => '安装';

  @override
  String get apps_installed => '已安装';

  @override
  String get apps_update_available => '可更新';

  @override
  String get databases_title => '数据库';

  @override
  String get databases_empty_title => '还没有数据库';

  @override
  String get databases_empty_message => '创建数据库后在这里管理。';

  @override
  String get cronjobs_empty_title => '还没有计划任务';

  @override
  String get cronjobs_empty_message => '创建任务按周期执行脚本。';

  @override
  String get firewall_status => '防火墙状态';

  @override
  String get firewall_ports => '端口规则';

  @override
  String get firewall_ips => 'IP 规则';

  @override
  String get firewall_add_rule => '添加规则';

  @override
  String get firewall_allow => '允许';

  @override
  String get firewall_deny => '拒绝';

  @override
  String get backups_title => '备份';

  @override
  String get backups_empty_title => '还没有备份';

  @override
  String get backups_empty_message => '配置备份账号来保护你的数据。';

  @override
  String get panel_settings_title => '面板设置';

  @override
  String get panel_settings_base => '基础';

  @override
  String get gallery_title => '组件画廊';

  @override
  String get common_show => '显示';

  @override
  String get common_hide => '隐藏';

  @override
  String common_copiedLabel(String label) {
    return '$label 已复制';
  }

  @override
  String get websites_addDomain => '添加域名';

  @override
  String get websites_addDomainAction => '添加';

  @override
  String get websites_domainAdded => '已添加';

  @override
  String get websites_removeDomainMessage => '删除后该域名将不再指向此站点。';

  @override
  String get websites_domainDeleted => '已删除';

  @override
  String get websites_noSslCertificate => '未配置 SSL 证书';

  @override
  String get websites_bindExistingCertificate => '绑定已有证书';

  @override
  String get websites_changeCertificate => '更换/绑定证书';

  @override
  String get websites_noReverseProxyHint => '在面板中为站点添加反向代理规则后会显示在这里。';

  @override
  String websites_deleteProxyMessage(String name, String match) {
    return '将删除规则 $name（$match）。';
  }

  @override
  String get backups_tabApps => '应用';

  @override
  String get backups_tabDatabases => '数据库';

  @override
  String get backups_tabWebsites => '网站';

  @override
  String get backups_tabDirectories => '目录';

  @override
  String get backups_downloadUrl => '获取下载地址';

  @override
  String get backups_restoreThis => '恢复此备份';

  @override
  String get backups_restoreTitle => '恢复备份';

  @override
  String get backups_resourceName => '资源名称';

  @override
  String get backups_appNameHint => '应用名称';

  @override
  String get backups_databaseInstanceHint => '数据库实例名称';

  @override
  String get backups_detailName => '详情名称';

  @override
  String get backups_appDetailHint => '应用详情名称';

  @override
  String get backups_databaseNameHint => '数据库名称';

  @override
  String get backups_databaseType => '数据库类型';

  @override
  String get backups_restoreSecret => '恢复密钥';

  @override
  String get backups_confirmRestore => '确认恢复';

  @override
  String get backups_restoreParamsRequired => '请填写完整恢复参数';

  @override
  String get backups_restoreSubmitted => '恢复任务已提交';

  @override
  String get server_edit_validation_host_required => '请输入主机地址';

  @override
  String get server_edit_validation_host_protocol => '只填写主机名或 IP，不要包含协议';

  @override
  String get server_edit_validation_host_space => '主机地址不能包含空格';

  @override
  String get server_edit_validation_port_range => '端口需在 1-65535 之间';

  @override
  String get server_edit_validation_key_length => 'API Key 长度至少 16 位';

  @override
  String get server_edit_validation_key_space => 'API Key 不能包含空格';

  @override
  String get server_edit_not_found => '服务器不存在';

  @override
  String get server_edit_self_signed_allowed => '自签名证书已允许';

  @override
  String server_edit_clock_drift(int seconds) {
    return '设备时间与面板相差 $seconds 秒';
  }

  @override
  String get files_nameHint => '名称';

  @override
  String get files_archiveName => '压缩包名称';

  @override
  String get files_extractTitle => '解压文件';

  @override
  String files_extractMessage(String name) {
    return '将 $name 解压到当前目录。';
  }

  @override
  String get files_extractToCurrent => '解压到当前目录';

  @override
  String get files_imageTooLarge => '图片超过 30MB，请下载后查看';

  @override
  String get files_downloadTooLarge => '文件超过 50MB，请使用网页版下载';

  @override
  String files_savedTo(String path) {
    return '已保存到 $path';
  }

  @override
  String files_itemCount(int count) {
    return '$count 项';
  }

  @override
  String get databases_deleteMessage => '该数据库将被永久删除。';

  @override
  String databases_deleteRelatedMessage(int count) {
    return '检测到 $count 个关联资源。删除数据库会同时影响它们。';
  }

  @override
  String get websites_logsFileHint => '日志将以文件形式打开，支持搜索与下载。';

  @override
  String get common_running => '运行中';

  @override
  String get common_stopped => '已停止';

  @override
  String common_typeToContinue(String value) {
    return '输入「$value」以继续';
  }

  @override
  String get common_resourceName => '资源名称';

  @override
  String get websites_type => '类型';

  @override
  String get websites_invalidDomainFormat => '域名格式不正确';

  @override
  String get websites_domainAtLeastOne => '请至少填写一个域名';

  @override
  String get websites_proxyTargetRequired => '请填写反向代理目标地址';

  @override
  String get firewall_addIpRule => '添加 IP 规则';

  @override
  String get terminal_sensitivePasteTitle => '粘贴敏感内容？';

  @override
  String get terminal_sensitivePasteMessage => '剪贴板内容可能包含密码或令牌。';

  @override
  String get terminal_paste => '粘贴';

  @override
  String get terminal_fontSize => '字号';

  @override
  String get log_empty => '暂无日志';

  @override
  String get log_jumpLatest => '回到最新';

  @override
  String get log_pause => '暂停';

  @override
  String get log_resume => '继续';

  @override
  String get log_clear => '清屏';

  @override
  String get log_export => '导出';

  @override
  String get ssl_selectCertificate => '请选择证书';

  @override
  String get ssl_bindTitle => '绑定 SSL 证书';

  @override
  String get ssl_acmeAccount => 'ACME 账户';

  @override
  String get ssl_certificate => '证书';

  @override
  String get ssl_noCertificates => '该账户下暂无证书，请先在面板中申请';

  @override
  String apps_requiredMissing(String fields) {
    return '请填写：$fields';
  }

  @override
  String get apps_version => '版本';

  @override
  String get apps_installParams => '安装参数';

  @override
  String get apps_required => '必填';

  @override
  String get cronjobs_neverRun => '从未执行';

  @override
  String get file_editor_unsavedLeave => '有未保存的修改，确定离开？';

  @override
  String get settings_localOnly => '数据仅存本地';

  @override
  String get action_clear => '清空';

  @override
  String get dashboard_coreUsage => '每核心使用率';

  @override
  String get dashboard_noCoreData => '面板未返回每核心数据';

  @override
  String get containers_dockerNotRunningShort => 'Docker 服务未运行';

  @override
  String get apps_detailMissing => '缺少应用详情 ID，无法执行操作';

  @override
  String get panelSettings_openWeb => '打开网页版';

  @override
  String get containers_unlimited => '不限制';

  @override
  String get websites_createdAt => '创建时间';

  @override
  String get websites_sslProvider => '服务商';

  @override
  String get websites_sslExpire => '到期时间';

  @override
  String panelSettings_deleteAlertConfirm(String title) {
    return '确定要删除告警「$title」吗？';
  }

  @override
  String get panelSettings_clearLogsConfirm => '确定要清空全部告警日志吗？该操作无法撤销。';

  @override
  String get server_edit_port_default => '9999';

  @override
  String websites_count(int count) {
    return '$count 个网站';
  }

  @override
  String containers_count(int count) {
    return '$count 个容器';
  }

  @override
  String dashboard_trafficTotal(String value) {
    return '累计 $value';
  }

  @override
  String get error_request_message => '面板拒绝了该请求，请稍后重试。';

  @override
  String get supervisor_title => '进程守护';

  @override
  String get supervisor_serviceStart => '启动 Supervisor';

  @override
  String get supervisor_serviceStop => '停止 Supervisor';

  @override
  String get supervisor_serviceRestart => '重启 Supervisor';

  @override
  String get supervisor_initSupervisor => '初始化 Supervisor';

  @override
  String supervisor_serviceOperateConfirm(String operation) {
    return '确认对 Supervisor 服务执行“$operation”？';
  }

  @override
  String supervisor_processOperateConfirm(String operation, String name) {
    return '确认对 $name 执行“$operation”？';
  }

  @override
  String get supervisor_operationSuccess => '操作成功';

  @override
  String get supervisor_operationFailed => '操作失败';

  @override
  String get supervisor_notInstalledTitle => '未检测到 supervisord';

  @override
  String get supervisor_notInstalledSubtitle =>
      '请先在服务器上安装 Supervisor，并确认 systemd 服务存在。';

  @override
  String get supervisor_ctlMissingTitle => '未检测到 supervisorctl';

  @override
  String get supervisor_ctlMissingSubtitle => '进程列表和进程操作依赖 supervisorctl。';

  @override
  String get supervisor_needInitTitle => '需要初始化';

  @override
  String get supervisor_needInitSubtitle =>
      '初始化会改写主配置 [include] 的 files 参数，并重启 Supervisor 服务。';

  @override
  String get supervisor_initTitle => '初始化 Supervisor';

  @override
  String get supervisor_initWarning =>
      '初始化会修改主配置文件 [include] 的 files 参数，并重启对应 systemd 服务。';

  @override
  String get supervisor_primaryConfig => '主配置文件';

  @override
  String get supervisor_serviceName => '服务名称';

  @override
  String get supervisor_configPathAndServiceRequired => '请填写主配置路径和服务名';

  @override
  String get supervisor_initSuccess => '初始化成功';

  @override
  String get supervisor_initFailed => '初始化失败';

  @override
  String get supervisor_emptyTitle => '暂无守护进程';

  @override
  String get supervisor_emptySubtitle =>
      '创建进程后会生成对应的 ini 配置和 stdout/stderr 日志路径。';

  @override
  String get supervisor_serviceStoppedWarn =>
      'Supervisor 服务未启动，进程状态可能不可用。可在右上角菜单中启动服务。';

  @override
  String get supervisor_createProcess => '创建守护进程';

  @override
  String get supervisor_name => '名称';

  @override
  String get supervisor_user => '执行用户';

  @override
  String get supervisor_command => '启动命令';

  @override
  String get supervisor_numprocs => '进程数';

  @override
  String get supervisor_environment => '环境变量';

  @override
  String get supervisor_autoRestart => '自动重启';

  @override
  String get supervisor_autoRestartSubtitle => '进程异常退出后由 Supervisor 自动拉起';

  @override
  String get supervisor_autoStart => '自动启动';

  @override
  String get supervisor_autoStartSubtitle => 'Supervisor 启动后自动启动该进程';

  @override
  String get supervisor_requiredFields => '请填写必填项';

  @override
  String get supervisor_nameRule => '名称支持英文、数字、- 和 _，且不能以特殊字符开头';

  @override
  String get supervisor_numprocsRule => '进程数需要在 1 到 9999 之间';

  @override
  String get supervisor_updateSuccess => '更新成功';

  @override
  String get supervisor_createSuccess => '创建成功';

  @override
  String get supervisor_saveFailed => '保存失败';

  @override
  String get supervisor_processStartSubtitle => '启动该进程组';

  @override
  String get supervisor_processStopSubtitle => '停止该进程组';

  @override
  String get supervisor_processRestartSubtitle => '重新启动该进程组';

  @override
  String get supervisor_deleteSubtitle => '删除该进程配置并更新 Supervisor';

  @override
  String get supervisor_workDir => '工作目录';

  @override
  String get toolbox_title => '工具箱';

  @override
  String get toolbox_hostname => '主机名';

  @override
  String get toolbox_systemUser => '系统用户';

  @override
  String get toolbox_timeZone => '时区';

  @override
  String get toolbox_localTime => '本地时间';

  @override
  String get toolbox_cacheClean => '缓存清理';

  @override
  String get toolbox_scan => '扫描';

  @override
  String get toolbox_scanFailed => '扫描失败';

  @override
  String get toolbox_installed => '安装';

  @override
  String get toolbox_running => '运行';

  @override
  String get toolbox_enabled => '启用';

  @override
  String get toolbox_version => '版本';

  @override
  String get toolbox_port => '端口';

  @override
  String get toolbox_virusScan => '病毒扫描';

  @override
  String get toolbox_clamAvRunning => 'ClamAV 运行';

  @override
  String get toolbox_freshClamRunning => 'FreshClam 运行';

  @override
  String get toolbox_virusDatabase => '病毒库';

  @override
  String get toolbox_noCleanItems => '没有可清理项目';

  @override
  String get toolbox_cleanGroupSystem => '系统缓存';

  @override
  String get toolbox_cleanGroupBackup => '备份缓存';

  @override
  String get toolbox_cleanGroupUpload => '上传缓存';

  @override
  String get toolbox_cleanGroupDownload => '下载缓存';

  @override
  String get toolbox_cleanGroupSystemLog => '系统日志';

  @override
  String get toolbox_cleanGroupContainer => '容器缓存';

  @override
  String get websites_groupCreated => '分组已创建';

  @override
  String get websites_groupUpdated => '分组已更新';

  @override
  String get websites_groupDeleted => '分组已删除';

  @override
  String get websites_groupNameRequired => '请输入分组名称';

  @override
  String get common_edit => '编辑';

  @override
  String get websites_groupManagement => '分组管理';

  @override
  String get websites_groupName => '分组名称';

  @override
  String get websites_groupSetDefault => '设为默认';

  @override
  String websites_groupDeleteConfirm(String name) {
    return '删除分组「$name」？该分组下的网站将回退到默认分组。';
  }

  @override
  String get websites_groupEmpty => '暂无分组';

  @override
  String supervisor_deleteConfirm(String name) {
    return '确定要删除守护进程「$name」？';
  }

  @override
  String get supervisor_editProcess => '编辑守护进程';

  @override
  String get supervisor_stateStarting => '启动中';

  @override
  String get websites_groupSystemReserved => '系统保留，不可删除';

  @override
  String get panelSettings_webOnlyTag => '网页版配置';

  @override
  String get alert_type_cpu => 'CPU';

  @override
  String get alert_type_memory => '内存';

  @override
  String get alert_type_disk => '磁盘';

  @override
  String get alert_type_load => '负载';

  @override
  String get alert_type_network => '网络';

  @override
  String get alert_type_smart => 'SMART';

  @override
  String get alert_type_log => '日志';

  @override
  String get alert_method_email => '邮件';

  @override
  String get alert_method_telegram => 'Telegram';

  @override
  String get alert_method_wecom => '企业微信';

  @override
  String get alert_method_dingtalk => '钉钉';

  @override
  String get alert_method_feishu => '飞书';

  @override
  String get alert_method_bark => 'Bark';

  @override
  String get alert_method_webhook => 'Webhook';

  @override
  String get alert_method_sms => '短信';

  @override
  String get alert_status_success => '成功';

  @override
  String get alert_status_failed => '失败';

  @override
  String get alert_status_pending => '待发送';

  @override
  String get dashboard_collecting => '正在采集…';

  @override
  String get toolbox_device_info => '设备信息';

  @override
  String get toolbox_actions => '可执行操作';

  @override
  String get toolbox_readOnlyHint => '以下信息来自面板，修改请到 1Panel 网页';

  @override
  String get app_detail_key => '应用标识';

  @override
  String get app_detail_container => '容器';

  @override
  String get app_detail_compose => 'Compose 文件';

  @override
  String get app_detail_message => '说明';

  @override
  String get server_edit_savedConnecting => '已保存，正在连接…';

  @override
  String get action_add => '添加';

  @override
  String get firewall_tabRules => '规则';

  @override
  String get firewall_tabForward => '转发';

  @override
  String get firewall_tabDocker => 'Docker';

  @override
  String get firewall_tabSettings => '设置';

  @override
  String firewall_rulesCount(int count) {
    return '规则 $count 条';
  }

  @override
  String get firewall_searchHint => '搜索地址、端口或备注';

  @override
  String get firewall_filterAll => '全部';

  @override
  String get firewall_filterIpv4 => 'IPv4';

  @override
  String get firewall_filterIpv6 => 'IPv6';

  @override
  String get firewall_filterAllow => '允许';

  @override
  String get firewall_filterDeny => '拒绝';

  @override
  String get firewall_anyAddress => '所有地址';

  @override
  String get firewall_anyPort => '所有端口';

  @override
  String firewall_ruleDeleteTitle(String name) {
    return '删除规则 $name？';
  }

  @override
  String get firewall_ruleDeleteMessage => '该规则将从面板防火墙中移除。';

  @override
  String get firewall_addForward => '添加转发规则';

  @override
  String get firewall_editForward => '编辑转发规则';

  @override
  String get firewall_forwardEmptyTitle => '暂无转发规则';

  @override
  String get firewall_forwardEmptyMessage => '创建规则把主机端口转发到内部服务。';

  @override
  String get firewall_forwardPort => '监听端口';

  @override
  String get firewall_forwardTargetIp => '目标 IP';

  @override
  String get firewall_forwardTargetPort => '目标端口';

  @override
  String get firewall_forwardInterface => '网卡（可选）';

  @override
  String get firewall_forwardEnabled => '转发已启用';

  @override
  String get firewall_enableForward => '启用转发';

  @override
  String get firewall_dockerGuard => 'Docker 端口守卫';

  @override
  String get firewall_dockerGuardEnabled => '守卫已生效';

  @override
  String get firewall_dockerGuardDisabled => '守卫未生效';

  @override
  String get firewall_dockerGuardEmpty => '暂无已发布的容器端口';

  @override
  String get firewall_dockerEndpoint => '容器端口';

  @override
  String get firewall_settingsBackend => '防火墙后端';

  @override
  String get firewall_settingsVersion => '版本';

  @override
  String get firewall_settingsIpv6 => 'IPv6';

  @override
  String get firewall_settingsIpv6Hint => '允许面板管理 IPv6 规则';

  @override
  String get firewall_settingsWhitelist => '端口白名单';

  @override
  String get firewall_settingsPanelPort => '面板端口';

  @override
  String get firewall_settingsSshPort => 'SSH 端口';

  @override
  String get firewall_whitelistAdd => '添加白名单端口';

  @override
  String get firewall_whitelistPort => '端口';

  @override
  String get firewall_whitelistProtocol => '协议';

  @override
  String get firewall_whitelistSources => '允许来源';

  @override
  String get firewall_whitelistSourcesHint => '逗号分隔，例如 0.0.0.0/0';

  @override
  String get firewall_ruleAddress => '来源地址';

  @override
  String get firewall_rulePort => '目标端口';

  @override
  String get firewall_ruleProtocol => '协议';

  @override
  String get firewall_ruleFamily => 'IP 协议族';

  @override
  String get firewall_ruleStrategy => '动作';

  @override
  String get firewall_ruleRemark => '备注';

  @override
  String get firewall_ruleInterface => '网卡';

  @override
  String get firewall_rulePortHint => '80、8000-8100 或 80,443';

  @override
  String get firewall_ruleAddressHint => '留空表示所有地址';

  @override
  String get firewall_ruleInvalidPort => '请输入有效端口或端口范围';

  @override
  String get firewall_editRule => '编辑规则';

  @override
  String get firewall_deleteRule => '删除规则';

  @override
  String get firewall_moveUp => '上移';

  @override
  String get firewall_moveDown => '下移';

  @override
  String get firewall_forwardRequired => '请填写监听端口、目标 IP 和目标端口';

  @override
  String get firewall_whitelistRequired => '请填写端口和至少一个来源';

  @override
  String get websites_start => '启动站点';

  @override
  String get websites_stop => '停止站点';

  @override
  String get websites_delete => '删除站点';

  @override
  String get websites_copyDomain => '复制域名';

  @override
  String get websites_open => '打开网页';

  @override
  String websites_deleteTitle(String name) {
    return '删除 $name？';
  }

  @override
  String get websites_deleteMessage => '站点文件、Nginx 配置和 SSL 证书将一并删除，且不可恢复。';

  @override
  String websites_deleteDatabaseCount(int count) {
    return '同时删除关联数据库（$count 个）';
  }

  @override
  String get websites_deleteBackup => '同时删除站点备份';

  @override
  String get websites_forceDelete => '强制删除（忽略错误）';

  @override
  String get websites_deleted => '站点已删除';

  @override
  String get websites_started => '站点已启动';

  @override
  String get websites_actions => '站点操作';

  @override
  String get containers_create => '新建容器';

  @override
  String get containers_image => '镜像';

  @override
  String get containers_name => '名称';

  @override
  String get containers_ports => '端口映射';

  @override
  String get containers_volumes => '目录挂载';

  @override
  String get containers_env => '环境变量';

  @override
  String get containers_advanced => '高级';

  @override
  String get containers_add => '添加';

  @override
  String get containers_hostPort => '主机端口';

  @override
  String get containers_containerPort => '容器端口';

  @override
  String get containers_sourceDir => '主机路径';

  @override
  String get containers_containerDir => '容器路径';

  @override
  String get containers_envHint => 'KEY=VALUE';

  @override
  String get containers_createSubmit => '创建容器';

  @override
  String get containers_nameInvalid => '仅支持字母、数字、点、横线和下划线';

  @override
  String get containers_imageRequired => '请选择或输入镜像';

  @override
  String get containers_nameRequired => '请输入容器名称';

  @override
  String get containers_selectImage => '选择镜像';

  @override
  String get containers_manualInput => '手动输入';

  @override
  String get containers_noImages => '暂无本地镜像';

  @override
  String get containers_created => '容器已创建';

  @override
  String get containers_removeRow => '移除';

  @override
  String get containers_cpuLimit => 'CPU 限制';

  @override
  String get containers_memoryLimit => '内存限制（MB）';

  @override
  String get containers_autoRemove => '自动删除';

  @override
  String get containers_privileged => '特权模式';

  @override
  String get containers_restartPolicyHint => 'unless-stopped';

  @override
  String get containers_cmdHint => '启动命令，空格分隔';

  @override
  String get containers_entrypointHint => '入口，空格分隔';

  @override
  String get containers_workingDirHint => '/usr/share/nginx/html';

  @override
  String get containers_network => '网络';

  @override
  String get containers_defaultNetwork => '1panel-network';

  @override
  String get containers_advancedHint => '命令、入口、工作目录、网络与资源限制';

  @override
  String get action_restart => '重启';

  @override
  String get system_restartPanel => '重启面板';

  @override
  String get system_restartPanelSubtitle => '仅重启面板服务';

  @override
  String get system_restartPanelMessage => '面板将在几秒内重启，连接可能中断 10 到 30 秒。';

  @override
  String get system_restartServer => '重启服务器';

  @override
  String get system_restartServerSubtitle => '所有服务都会中断';

  @override
  String get system_restartServerMessage =>
      '服务器将立即重启，所有服务会停止，连接通常需要 10 到 30 秒恢复。';

  @override
  String get system_restartSubmitted => '已提交重启，连接可能短暂中断。';

  @override
  String get databases_create => '创建数据库';

  @override
  String get databases_createType => '选择数据库类型';

  @override
  String get databases_databaseName => '数据库名';

  @override
  String get databases_instance => '实例';

  @override
  String get databases_noInstance => '该类型还没有已安装的实例，请先在应用商店安装。';

  @override
  String get databases_charset => '字符集';

  @override
  String get databases_collation => '排序规则';

  @override
  String get databases_template => '模板库';

  @override
  String get databases_host => '允许来源';

  @override
  String get databases_hostHint => '% 表示任意主机，也可以填写指定 IP';

  @override
  String get databases_superUser => '超级用户';

  @override
  String get databases_permission => '权限';

  @override
  String get databases_permissionRead => '只读';

  @override
  String get databases_permissionReadWrite => '读写';

  @override
  String get databases_permissionDbOwner => '库所有者';

  @override
  String get databases_permissionUserAdmin => '用户管理';

  @override
  String get databases_nameRequired => '请输入数据库名';

  @override
  String get databases_usernameRequired => '请输入用户名';

  @override
  String get databases_passwordRequired => '请输入密码';

  @override
  String get databases_created => '数据库已创建';

  @override
  String get databases_usersGrants => '用户与授权';

  @override
  String get databases_addUser => '添加用户';

  @override
  String get databases_bindUser => '绑定用户';

  @override
  String get databases_noUsers => '暂无用户';

  @override
  String get databases_userHost => '允许来源';

  @override
  String get databases_deleteUser => '删除用户';

  @override
  String get databases_grant => '授权';

  @override
  String get databases_grantDatabase => '授权数据库';

  @override
  String get databases_revoke => '取消授权';

  @override
  String get databases_permissionUpdated => '权限已更新';

  @override
  String get databases_redisRemote => 'Redis 连接';

  @override
  String get databases_redisHint => '本地 Redis 通过应用安装。此表单用于登记远程 Redis 连接。';

  @override
  String get databases_normalUser => '普通用户';

  @override
  String get databases_description => '描述';

  @override
  String get databases_userDescription => '用户描述';

  @override
  String get databases_userCreated => '用户已创建';

  @override
  String get databases_grantedDatabases => '已授权数据库';

  @override
  String get databases_noGrants => '暂无授权';

  @override
  String get files_permission => '权限';

  @override
  String get files_permissionOwner => '所有者';

  @override
  String get files_permissionGroup => '用户组';

  @override
  String get files_permissionPublic => '公共';

  @override
  String get files_permissionRead => '读';

  @override
  String get files_permissionWrite => '写';

  @override
  String get files_permissionExecute => '执行';

  @override
  String get files_permissionMode => '权限值';

  @override
  String get files_permissionUser => '用户';

  @override
  String get files_permissionGroupName => '用户组';

  @override
  String get files_permissionUpdated => '权限已更新';

  @override
  String files_selectCount(int count) {
    return '已选 $count 项';
  }

  @override
  String get files_selectAll => '全选';

  @override
  String get files_cancelSelection => '取消';

  @override
  String get files_batchDelete => '删除所选';

  @override
  String files_batchDeleteMessage(int count) {
    return '确定删除选中的 $count 项？';
  }

  @override
  String get files_calculateSize => '计算体积';

  @override
  String files_sizeCalculated(String size) {
    return '体积：$size';
  }

  @override
  String get files_history => '历史';

  @override
  String get files_historyEmpty => '暂无历史版本';

  @override
  String get files_historyRestore => '回滚';

  @override
  String get files_historyRestoreConfirm => '回滚到这个版本？当前文件内容会被替换。';

  @override
  String get files_historyDelete => '删除版本';

  @override
  String get files_historyRestored => '版本已回滚';

  @override
  String get files_moreActions => '更多操作';

  @override
  String get host_title => '主机';

  @override
  String get host_monitor => '监控';

  @override
  String get host_ssh => 'SSH';

  @override
  String get host_range1h => '1 小时';

  @override
  String get host_range6h => '6 小时';

  @override
  String get host_range24h => '24 小时';

  @override
  String get host_cpu => 'CPU';

  @override
  String get host_memory => '内存';

  @override
  String get host_load => '负载';

  @override
  String get host_sshPort => 'SSH 端口';

  @override
  String get host_rootLogin => '允许 root 登录';

  @override
  String get host_passwordAuth => '密码登录';

  @override
  String get host_pubkeyAuth => '公钥登录';

  @override
  String get host_sshStatus => 'SSH 服务';

  @override
  String get host_sshUpdated => 'SSH 配置已更新';

  @override
  String get host_monitorEmpty => '暂无监控数据';

  @override
  String get runtime_detail => '运行环境';

  @override
  String get runtime_extensions => '扩展';

  @override
  String get runtime_phpIni => 'php.ini';

  @override
  String get runtime_fpm => 'FPM';

  @override
  String get runtime_modules => '模块';

  @override
  String get runtime_install => '安装';

  @override
  String get runtime_uninstall => '卸载';

  @override
  String get runtime_update => '更新';

  @override
  String get runtime_installed => '已安装';

  @override
  String get runtime_notInstalled => '未安装';

  @override
  String get runtime_moduleHint => '包名';

  @override
  String get runtime_restartPhpHint => '修改后需要重启 PHP 才会生效。';

  @override
  String get runtime_saved => '已保存';

  @override
  String get toolbox_group_system => '系统';

  @override
  String get toolbox_group_security => '安全';

  @override
  String get toolbox_group_service => '服务';

  @override
  String get toolbox_group_maintenance => '维护';

  @override
  String get toolbox_time => '时区与时间';

  @override
  String get toolbox_swapDns => 'Swap 与 DNS';

  @override
  String get toolbox_clam => 'ClamAV 病毒扫描';

  @override
  String get toolbox_fail2ban => 'Fail2ban';

  @override
  String get toolbox_ftp => 'FTP 账户';

  @override
  String get toolbox_timezone => '时区';

  @override
  String get toolbox_dns => 'DNS';

  @override
  String get toolbox_swap => 'Swap';

  @override
  String get toolbox_addSwap => '添加 Swap';

  @override
  String get toolbox_swapPath => 'Swap 文件路径';

  @override
  String get toolbox_swapSize => '大小（MB）';

  @override
  String get toolbox_sshBan => '封禁 IP';

  @override
  String get toolbox_unban => '解封';

  @override
  String get toolbox_sshProtection => 'SSH 防护';

  @override
  String get toolbox_ftpAdd => '添加 FTP 账户';

  @override
  String get toolbox_ftpUser => 'FTP 用户';

  @override
  String get toolbox_ftpPassword => 'FTP 密码';

  @override
  String get toolbox_ftpPath => 'FTP 根目录';

  @override
  String get toolbox_scanPath => '扫描路径';

  @override
  String get toolbox_scanName => '扫描名称';

  @override
  String get toolbox_startScan => '开始扫描';

  @override
  String get toolbox_stopScan => '停止扫描';

  @override
  String get toolbox_scanRecords => '扫描任务';

  @override
  String get toolbox_noScans => '暂无扫描任务';

  @override
  String get server_edit_diag_failed => '检查失败';

  @override
  String get host_monitorSettings => '监控设置';

  @override
  String get host_monitorInterval => '采集间隔（秒）';

  @override
  String get host_monitorStoreDays => '保留天数';

  @override
  String get host_monitorEnabled => '启用监控';

  @override
  String get host_sshKeys => 'SSH 密钥';

  @override
  String get host_generateKey => '生成密钥';

  @override
  String get host_keyName => '密钥名称';

  @override
  String get host_keyType => '密钥类型';

  @override
  String get host_keyPassphrase => '口令';

  @override
  String get host_keyGenerated => 'SSH 密钥已生成';

  @override
  String get host_deleteKey => '删除密钥';

  @override
  String get host_publicKey => '公钥';

  @override
  String get toolbox_clamRecords => '扫描结果';

  @override
  String get toolbox_clamNoRecords => '暂无扫描结果';

  @override
  String get runtime_fpmConfig => 'FPM 配置';

  @override
  String get runtime_pm => '进程管理模式';

  @override
  String get runtime_maxChildren => '最大子进程';

  @override
  String get runtime_startServers => '启动进程数';

  @override
  String get runtime_minSpare => '最小空闲进程';

  @override
  String get runtime_maxSpare => '最大空闲进程';

  @override
  String get host_disks => '磁盘';

  @override
  String get host_diagnostics => '诊断';

  @override
  String get host_diskSystem => '系统磁盘';

  @override
  String get host_diskUnpartitioned => '未分区磁盘';

  @override
  String get host_diskNormal => '数据磁盘';

  @override
  String get host_diskPartitions => '分区';

  @override
  String get host_diskFilesystem => '文件系统';

  @override
  String get host_diskUsed => '已用';

  @override
  String get host_diskAvail => '可用';

  @override
  String get host_diskMountPoint => '挂载点';

  @override
  String get host_diskUnmounted => '未挂载';

  @override
  String get host_diskSystemHint => '系统磁盘分区在此只读。';

  @override
  String get host_diskPartition => '分区';

  @override
  String get host_diskMount => '挂载';

  @override
  String get host_diskUnmount => '卸载';

  @override
  String get host_diskAutoMount => '开机自动挂载';

  @override
  String get host_diskNoFail => '磁盘缺失时允许开机';

  @override
  String get host_diskMountPointField => '挂载点路径';

  @override
  String get host_diskLabel => '卷标';

  @override
  String get host_diskActionDone => '磁盘操作已完成';

  @override
  String get host_diskPartitionWarning => '分区会清除该磁盘上的数据，请只对可重建的磁盘继续。';

  @override
  String get host_diagSummary => '运行时概览';

  @override
  String get host_diagRss => '常驻内存';

  @override
  String get host_diagHeap => '堆内存占用';

  @override
  String get host_diagObjects => '堆对象数';

  @override
  String get host_diagGoroutines => '协程数';

  @override
  String get host_diagSnapshot => '协程快照';

  @override
  String get host_diagCapturedAt => '抓取时间';

  @override
  String get host_diagTotal => '总数';

  @override
  String get host_diagGroups => '分组';

  @override
  String get host_diagTruncated => '快照已被面板截断。';

  @override
  String get host_diagStack => '调用栈';

  @override
  String get toolbox_fail2banBase => '基础规则';

  @override
  String get toolbox_maxRetry => '最大重试次数';

  @override
  String get toolbox_banTime => '封禁时长';

  @override
  String get toolbox_findTime => '检测窗口';

  @override
  String get toolbox_banAction => '封禁动作';

  @override
  String get toolbox_logPath => '日志路径';

  @override
  String get toolbox_durationHint => '请带单位，例如 300s、10m、1h 或 -1。';

  @override
  String get toolbox_fail2banChanged => '更新 Fail2ban 规则';

  @override
  String get host_diagCapture => '手动抓取';

  @override
  String get host_diagProfileType => '分析类型';

  @override
  String get host_diagProfileCpu => 'CPU 分析';

  @override
  String get host_diagProfileHeap => '堆分析';

  @override
  String get host_diagProfileGoroutine => '协程分析';

  @override
  String get host_diagProfileMutex => '互斥锁分析';

  @override
  String get host_diagProfileBlock => '阻塞分析';

  @override
  String get host_diagDuration => '持续时长（秒）';

  @override
  String get host_diagStartCapture => '开始抓取';

  @override
  String get host_diagProfileSaved => '分析文件已保存';

  @override
  String get host_diagComponent => '组件检测';

  @override
  String get host_diagComponentName => '组件名称';

  @override
  String get host_diagCheck => '检测';

  @override
  String get host_diagComponentExists => '状态';

  @override
  String get host_diagComponentPath => '路径';

  @override
  String get host_diagComponentMissing => '未找到可执行文件';

  @override
  String get websites_loadBalance => '负载均衡';

  @override
  String get websites_lbAdd => '添加上游';

  @override
  String get websites_lbEmpty => '暂无上游';

  @override
  String get websites_lbName => '上游名称';

  @override
  String get websites_lbAlgorithm => '算法';

  @override
  String get websites_lbDefault => '默认（轮询）';

  @override
  String get websites_lbIpHash => 'IP 哈希';

  @override
  String get websites_lbLeastConn => '最少连接';

  @override
  String get websites_lbServers => '服务器';

  @override
  String get websites_lbAddServer => '添加服务器';

  @override
  String get websites_lbServerAddress => '服务器地址';

  @override
  String get websites_lbWeight => '权重';

  @override
  String get websites_lbFlag => '状态';

  @override
  String get websites_lbFlagNone => '启用';

  @override
  String get websites_lbFlagDown => '下线';

  @override
  String get websites_lbFlagBackup => '备用';

  @override
  String get websites_lbMaxFails => '最大失败次数';

  @override
  String get websites_lbFailTimeout => '失败超时';

  @override
  String get websites_lbMaxConns => '最大连接数';

  @override
  String get websites_lbDelete => '删除上游';

  @override
  String get websites_lbSaved => '负载均衡已保存';

  @override
  String get websites_templates => '网站模板';

  @override
  String get websites_templateAdd => '新建模板';

  @override
  String get websites_templateEdit => '编辑模板';

  @override
  String get websites_templateEmpty => '暂无模板';

  @override
  String get websites_templateName => '模板名称';

  @override
  String get websites_templateType => '模板类型';

  @override
  String get websites_templateSingle => '单页模板';

  @override
  String get websites_templateMulti => '多文件模板';

  @override
  String get websites_templateContent => 'HTML 内容';

  @override
  String get websites_templateUpload => '上传 ZIP';

  @override
  String get websites_templateUploaded => '模板已上传';

  @override
  String get websites_templateFilePath => '模板包';

  @override
  String get websites_templateRemark => '备注';

  @override
  String get websites_templateVariables => '变量';

  @override
  String get websites_templateAddVariable => '添加变量';

  @override
  String get websites_templateVariableKey => '变量键';

  @override
  String get websites_templateVariableLabel => '显示名称';

  @override
  String get websites_templateVariableType => '类型';

  @override
  String get websites_templateVariableDefault => '默认值';

  @override
  String get websites_templateVariableOptions => '可选项';

  @override
  String get websites_templateVariableRequired => '必填';

  @override
  String get websites_templateAutoDetect => '识别变量';

  @override
  String get websites_templateSaved => '模板已保存';

  @override
  String get websites_templateDelete => '删除模板';

  @override
  String get websites_templateGenerate => '生成';

  @override
  String get websites_templateOutputs => '已生成站点';

  @override
  String get websites_templateOutputName => '输出名称';

  @override
  String get websites_templateOutputEmpty => '暂无生成站点';

  @override
  String get websites_templateOutputGenerated => '站点已生成';

  @override
  String get websites_templateOutputDelete => '删除生成站点';

  @override
  String get websites_templateNoVariables => '无变量';

  @override
  String get websites_templateVariableTypeText => '文本';

  @override
  String get websites_templateVariableTypeTextarea => '长文本';

  @override
  String get websites_templateVariableTypeNumber => '数字';

  @override
  String get websites_templateVariableTypeSelect => '下拉选择';

  @override
  String get websites_templateVariableTypeColor => '颜色';

  @override
  String get files_aiSearch => 'AI 搜索';

  @override
  String get files_aiQuery => '搜索内容';

  @override
  String get files_aiQueryHint => '要查找的文件内容';

  @override
  String get files_aiContainSub => '包含子目录';

  @override
  String get files_aiMatchCase => '区分大小写';

  @override
  String get files_aiWholeWord => '全字匹配';

  @override
  String get files_aiUseRegex => '使用正则表达式';

  @override
  String get files_aiGrepMode => '面板未启用 AI，当前仅显示内容匹配结果。';

  @override
  String get files_aiSummary => 'AI 摘要';

  @override
  String get files_aiHits => '匹配结果';

  @override
  String get files_aiScanned => '扫描文件数';

  @override
  String get files_aiTokens => 'Token 用量';

  @override
  String get files_aiDuration => '耗时';

  @override
  String get files_aiTruncated => '结果已被面板截断。';

  @override
  String get files_aiEmpty => '没有匹配内容';

  @override
  String get files_aiLine => '行';

  @override
  String get terminal_sessions => '终端会话';

  @override
  String get terminal_sessionsEmpty => '暂无终端会话';

  @override
  String get terminal_sessionAttached => '已连接';

  @override
  String get terminal_sessionDetached => '已断开';

  @override
  String get terminal_closeSession => '关闭';

  @override
  String get terminal_closeAllSessions => '全部关闭';

  @override
  String get terminal_closeAllConfirm => '将断开全部终端会话且无法恢复。';

  @override
  String get terminal_kindLocal => '本地';

  @override
  String get terminal_kindSsh => 'SSH';

  @override
  String get terminal_kindContainer => '容器';

  @override
  String get files_uploading => '上传中';

  @override
  String get files_uploadPaused => '已暂停';

  @override
  String get files_uploadPause => '暂停';

  @override
  String get files_uploadResume => '继续';

  @override
  String get files_uploadFailed => '上传失败';

  @override
  String get toolbox_infectedStrategy => '感染文件处理';

  @override
  String get toolbox_infectedNone => '不处理';

  @override
  String get toolbox_infectedRemove => '删除';

  @override
  String get toolbox_infectedMove => '移动';

  @override
  String get toolbox_infectedCopy => '复制';

  @override
  String get toolbox_infectedDir => '感染文件目录';

  @override
  String get toolbox_infectedDirRequired => '请输入感染文件目录';

  @override
  String get firewall_whitelistEdit => '编辑白名单规则';

  @override
  String get firewall_backendUnavailable => '没有可切换的后端';

  @override
  String get action_switch => '切换';

  @override
  String get firewall_resetRules => '重置规则';

  @override
  String get firewall_resetRulesMessage => '将重置面板管理的防火墙规则，是否继续？';

  @override
  String get firewall_restoreBackup => '恢复备份';

  @override
  String firewall_restoreBackupMessage(String name) {
    return '将从备份 $name 恢复规则，是否继续？';
  }

  @override
  String get firewall_nativeDetail => '原生规则详情';

  @override
  String get firewall_nativeDetailHint => '读取 firewalld 或 ufw 的原生规则定义';

  @override
  String get firewall_ruleBackups => '规则备份';

  @override
  String get firewall_noBackups => '暂无规则备份';

  @override
  String get firewall_nativeNameRequired => '请输入原生规则名称';

  @override
  String get firewall_nativeKind => '原生类型';

  @override
  String get firewall_nativeZoneService => '区域服务';

  @override
  String get firewall_nativeUfwApplication => 'UFW 应用';

  @override
  String get firewall_nativeName => '原生名称';

  @override
  String get firewall_nativePermanent => '永久生效';

  @override
  String get firewall_nativeLoad => '读取原生详情';

  @override
  String get firewall_settingsBackendHint => '点击切换面板管理的防火墙后端';

  @override
  String get host_sshCheckFailed => '本地 SSH 连通性检查失败，已取消保存。';

  @override
  String get host_sshCheckAfterSave => 'SSH 端口已保存，但本地连通性检查仍未通过，请确认新端口。';
}
