import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations_zh.dart';
import 'package:onedash/core/theme/tokens.dart';
import 'package:onedash/presentation/common/formatters/status_labels.dart';

void main() {
  final l10n = AppLocalizationsZh();

  test('应用安装与容器中间态有中文映射', () {
    expect(appStatusLabel('Installing', l10n), '安装中');
    expect(appStatusLabel('Upgrading', l10n), '安装中');
    expect(appStatusLabel('Restarting', l10n), '重启中');
    expect(appStatusLabel('Paused', l10n), '已暂停');
    expect(appStatusLabel('Unhealthy', l10n), '异常');
    expect(appStatusLabel('error', l10n), '异常');
  });

  test('应用运行态与空状态保持原有语义', () {
    expect(appStatusLabel('Running', l10n), '运行中');
    expect(appStatusLabel('Exited', l10n), '已停止');
    expect(appStatusLabel('Created', l10n), '已停止');
    expect(appStatusLabel('', l10n), '未知');
  });

  test('未知开放状态保留原值，避免中文化吞信息', () {
    expect(appStatusLabel('Removing', l10n), 'Removing');
  });

  test('容器重启中、创建中、删除中不再误报异常', () {
    expect(containerStateLabel('restarting', l10n), '重启中');
    expect(containerStateLabel('created', l10n), '已停止');
    expect(containerStateLabel('removing', l10n), '删除中');
    expect(containerStateLabel('dead', l10n), '异常');
    expect(containerStateLabel('paused', l10n), '已暂停');
    expect(containerStateLabel('', l10n), '未知');
  });

  test('容器未知状态保留原值', () {
    expect(containerStateLabel('hibernating', l10n), 'hibernating');
  });

  test('应用与容器状态颜色覆盖异常与安装中', () {
    const colors = OneDashColors.light;
    expect(colors.status('error'), colors.danger);
    expect(colors.status('unhealthy'), colors.danger);
    expect(colors.status('installing'), colors.warning);
    expect(colors.status('upgrading'), colors.warning);
    expect(colors.status('running'), colors.success);
  });

  test('SSH 认证方式映射密码与公钥', () {
    expect(sshAuthModeLabel('password', l10n), '密码');
    expect(sshAuthModeLabel('publickey', l10n), '公钥');
    expect(sshAuthModeLabel('public_key', l10n), '公钥');
    expect(
      sshAuthModeLabel('keyboard-interactive', l10n),
      'keyboard-interactive',
    );
    expect(sshAuthModeLabel('', l10n), '');
  });
}
