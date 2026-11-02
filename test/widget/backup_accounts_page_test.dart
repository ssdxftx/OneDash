import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/data/repositories_impl/backup_account_repository_impl.dart';
import 'package:onedash/domain/repositories/backup_account_repository.dart';
import 'package:onedash/presentation/common/formatters/enum_labels.dart';
import 'package:onedash/presentation/features/backups/screens/backup_accounts_page.dart';

class _FakeBackupAccountRepository implements BackupAccountRepository {
  _FakeBackupAccountRepository(this.accounts);

  final List<Map<String, dynamic>> accounts;
  Map<String, dynamic>? createdPayload;
  Map<String, dynamic>? updatedPayload;

  @override
  Future<Map<String, dynamic>> searchAccounts({
    required int page,
    required int pageSize,
    String type = '',
    String name = '',
  }) async => {'items': accounts};

  @override
  Future<void> createAccount(Map<String, dynamic> data) async {
    createdPayload = data;
  }

  @override
  Future<void> updateAccount(Map<String, dynamic> data) async {
    updatedPayload = data;
  }

  @override
  Future<void> deleteAccount(int id) async {}

  @override
  Future<Map<String, dynamic>> checkConnection(
    Map<String, dynamic> data,
  ) async => const {'status': 'ok'};

  @override
  Future<List<dynamic>> listBuckets(Map<String, dynamic> data) async =>
      const [];

  @override
  Future<void> refreshToken(int id) async {}

  @override
  Future<String> getLocalDir() async => '/backup';
}

void main() {
  const accounts = [
    {'id': 1, 'name': 'my-local', 'type': 'LOCAL', 'backupPath': '/opt/backup'},
    {
      'id': 2,
      'name': 'cold-storage',
      'type': 'OSS',
      'backupPath': 'cn-hangzhou',
    },
  ];

  Widget wrap(_FakeBackupAccountRepository repository) {
    return ProviderScope(
      overrides: [
        backupAccountRepositoryProvider.overrideWith((ref) async => repository),
      ],
      child: const MaterialApp(
        locale: Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BackupAccountsPage(serverId: 1),
      ),
    );
  }

  testWidgets('editing a LOCAL account opens without a dropdown assertion', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(_FakeBackupAccountRepository(accounts)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('my-local'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    expect(find.text('本地'), findsWidgets);
  });

  testWidgets('creating an account submits a contract type', (tester) async {
    final repository = _FakeBackupAccountRepository(accounts);
    await tester.pumpWidget(wrap(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('新建备份账号'));
    await tester.pumpAndSettle();

    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    expect(find.text('本地'), findsNothing);

    await tester.ensureVisible(find.text('保存'));
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));

    final payload = repository.createdPayload;
    expect(payload, isNotNull);
    expect(backupAccountTypes, contains(payload!['type']));
    expect(payload['type'], isNot(backupAccountLocal));
  });
}
