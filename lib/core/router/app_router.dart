import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/features/alerts/screens/alerts_page.dart';
import '../../presentation/features/app_store/screens/app_detail_page.dart';
import '../../presentation/features/app_store/screens/app_store_page.dart';
import '../../presentation/features/app_store/screens/installed_app_page.dart';
import '../../presentation/features/backups/screens/backups_page.dart';
import '../../presentation/features/containers/screens/compose_page.dart';
import '../../presentation/features/containers/screens/container_detail_page.dart';
import '../../presentation/features/containers/screens/containers_page.dart';
import '../../presentation/features/cronjobs/screens/cronjobs_page.dart';
import '../../presentation/features/dashboard/screens/overview_page.dart';
import '../../presentation/features/databases/screens/database_detail_page.dart';
import '../../presentation/features/databases/screens/databases_page.dart';
import '../../presentation/features/files/screens/file_editor_page.dart';
import '../../presentation/features/files/screens/files_page.dart';
import '../../presentation/features/firewall/screens/firewall_page.dart';
import '../../presentation/features/gallery/screens/gallery_page.dart';
import '../../presentation/features/log/screens/log_hub_page.dart';
import '../../presentation/features/more/screens/more_page.dart';
import '../../presentation/features/panel_settings/screens/panel_settings_page.dart';
import '../../presentation/features/process/screens/process_page.dart';
import '../../presentation/features/runtimes/screens/runtimes_page.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../../presentation/features/servers/screens/server_edit_page.dart';
import '../../presentation/features/servers/screens/servers_page.dart';
import '../../presentation/features/settings/screens/app_settings_page.dart';
import '../../presentation/features/supervisor/screens/supervisor_page.dart';
import '../../presentation/features/toolbox/screens/toolbox_page.dart';
import '../../presentation/features/terminal/screens/terminal_page.dart';
import '../../presentation/features/websites/screens/website_create_wizard.dart';
import '../../presentation/features/websites/screens/website_groups_page.dart';
import '../../presentation/features/websites/screens/website_detail_page.dart';
import '../../presentation/features/websites/screens/websites_page.dart';
import '../../presentation/shell/server_shell.dart';
import 'transitions.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// 由 main.dart 赋值；测试里也用它，保证 router 与 UI 共用同一个 container。
late final ProviderContainer appContainer;

int _serverId(GoRouterState state) =>
    int.tryParse(state.pathParameters['id'] ?? '') ?? 0;

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  debugLogDiagnostics: false,
  redirect: (context, state) {
    final id = int.tryParse(state.pathParameters['id'] ?? '');
    if (id != null) {
      final notifier = appContainer.read(activeServerIdStateProvider.notifier);
      if (notifier.state != id) notifier.state = id;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => fadePage(state, const ServersPage()),
    ),
    GoRoute(
      path: '/servers/add',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slidePage(state, const ServerEditPage()),
    ),
    GoRoute(
      path: '/servers/:id/edit',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slidePage(
        state,
        ServerEditPage(
          serverId: int.tryParse(state.pathParameters['id'] ?? ''),
        ),
      ),
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) =>
          slidePage(state, const AppSettingsPage()),
    ),
    GoRoute(
      path: '/dev/gallery',
      parentNavigatorKey: _rootNavigatorKey,
      redirect: (context, state) => kDebugMode ? null : '/',
      pageBuilder: (context, state) => fadePage(state, const GalleryPage()),
    ),
    GoRoute(
      path: '/s/:id',
      redirect: (context, state) {
        final id = state.pathParameters['id'];
        // 只有访问 /s/1 这种裸路径时才跳到概览
        if (state.uri.path == '/s/$id') return '/s/$id/overview';
        return null;
      },
      routes: [
        GoRoute(
          path: 'terminal',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => fadePage(
            state,
            TerminalPage(
              serverId: _serverId(state),
              containerName: state.uri.queryParameters['container'],
            ),
          ),
        ),
        GoRoute(
          path: 'files/edit',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => slidePage(
            state,
            FileEditorPage(
              serverId: _serverId(state),
              path: state.uri.queryParameters['path'] ?? '/',
            ),
          ),
        ),
        GoRoute(
          path: 'websites/create',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) =>
              slidePage(state, WebsiteCreateWizard(serverId: _serverId(state))),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return ServerShell(
              serverId: _serverId(state),
              navigationShell: navigationShell,
            );
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: 'overview',
                  pageBuilder: (context, state) => noTransitionPage(
                    state,
                    OverviewPage(serverId: _serverId(state)),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: 'websites',
                  pageBuilder: (context, state) => noTransitionPage(
                    state,
                    WebsitesPage(serverId: _serverId(state)),
                  ),
                  routes: [
                    GoRoute(
                      path: ':siteId',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        WebsiteDetailPage(
                          serverId: _serverId(state),
                          siteId: state.pathParameters['siteId'] ?? '',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: 'files',
                  pageBuilder: (context, state) => noTransitionPage(
                    state,
                    FilesPage(
                      serverId: _serverId(state),
                      initialPath: state.uri.queryParameters['path'] ?? '/',
                    ),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: 'containers',
                  pageBuilder: (context, state) => noTransitionPage(
                    state,
                    ContainersPage(serverId: _serverId(state)),
                  ),
                  routes: [
                    GoRoute(
                      path: ':name',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        ContainerDetailPage(
                          serverId: _serverId(state),
                          containerName: state.pathParameters['name'] ?? '',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: 'more',
                  pageBuilder: (context, state) => noTransitionPage(
                    state,
                    MorePage(serverId: _serverId(state)),
                  ),
                  routes: [
                    GoRoute(
                      path: 'apps',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        AppStorePage(
                          serverId: _serverId(state),
                          initialTab:
                              state.uri.queryParameters['tab'] == 'installed'
                              ? 1
                              : 0,
                        ),
                      ),
                      routes: [
                        GoRoute(
                          path: 'installed/:installId',
                          pageBuilder: (context, state) => slidePage(
                            state,
                            InstalledAppPage(
                              serverId: _serverId(state),
                              installId:
                                  state.pathParameters['installId'] ?? '',
                              detailId: int.tryParse(
                                state.uri.queryParameters['detailId'] ?? '',
                              ),
                            ),
                          ),
                        ),
                        GoRoute(
                          path: ':appId',
                          pageBuilder: (context, state) => slidePage(
                            state,
                            AppDetailPage(
                              serverId: _serverId(state),
                              appId: state.pathParameters['appId'] ?? '',
                            ),
                          ),
                        ),
                      ],
                    ),
                    GoRoute(
                      path: 'databases',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        DatabasesPage(serverId: _serverId(state)),
                      ),
                      routes: [
                        GoRoute(
                          path: ':name',
                          pageBuilder: (context, state) => slidePage(
                            state,
                            DatabaseDetailPage(
                              serverId: _serverId(state),
                              databaseName: state.pathParameters['name'] ?? '',
                              type: state.uri.queryParameters['type'] ?? '',
                            ),
                          ),
                        ),
                      ],
                    ),
                    GoRoute(
                      path: 'cronjobs',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        CronjobsPage(serverId: _serverId(state)),
                      ),
                    ),
                    GoRoute(
                      path: 'firewall',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        FirewallPage(serverId: _serverId(state)),
                      ),
                    ),
                    GoRoute(
                      path: 'logs',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        LogHubPage(serverId: _serverId(state)),
                      ),
                    ),
                    GoRoute(
                      path: 'compose',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        ComposePage(serverId: _serverId(state)),
                      ),
                    ),
                    GoRoute(
                      path: 'settings',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        PanelSettingsPage(serverId: _serverId(state)),
                      ),
                    ),
                    GoRoute(
                      path: 'alerts',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        AlertsPage(serverId: _serverId(state)),
                      ),
                    ),
                    GoRoute(
                      path: 'process',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        ProcessPage(serverId: _serverId(state)),
                      ),
                    ),
                    GoRoute(
                      path: 'backups',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        BackupsPage(serverId: _serverId(state)),
                      ),
                    ),
                    GoRoute(
                      path: 'runtimes',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        RuntimesPage(serverId: _serverId(state)),
                      ),
                    ),
                    GoRoute(
                      path: 'host-tools',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        SupervisorPage(serverId: _serverId(state)),
                      ),
                    ),
                    GoRoute(
                      path: 'toolbox',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        ToolboxPage(serverId: _serverId(state)),
                      ),
                    ),
                    GoRoute(
                      path: 'groups',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        WebsiteGroupsPage(serverId: _serverId(state)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
