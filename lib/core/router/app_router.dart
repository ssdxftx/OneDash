import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/features/alerts/screens/alert_form_page.dart';
import '../../presentation/features/alerts/screens/alerts_page.dart';
import '../../presentation/features/app_store/screens/app_detail_page.dart';
import '../../presentation/features/app_store/screens/app_store_page.dart';
import '../../presentation/features/app_store/screens/installed_app_page.dart';
import '../../presentation/features/backups/screens/backup_accounts_page.dart';
import '../../presentation/features/ai/screens/ai_page.dart';
import '../../presentation/features/backups/screens/backups_page.dart';
import '../../data/dto/container/container_compose_dto.dart';
import '../../presentation/features/containers/screens/compose_form_page.dart';
import '../../presentation/features/containers/screens/compose_page.dart';
import '../../presentation/features/containers/screens/container_create_page.dart';
import '../../presentation/features/containers/screens/container_detail_page.dart';
import '../../presentation/features/containers/screens/container_resources_page.dart';
import '../../presentation/features/containers/screens/container_volumes_page.dart';
import '../../presentation/features/containers/screens/docker_settings_page.dart';
import '../../presentation/features/containers/screens/containers_page.dart';
import '../../presentation/features/containers/screens/docker_overview_page.dart';
import '../../presentation/features/cronjobs/screens/cronjob_form_page.dart';
import '../../presentation/features/cronjobs/screens/cronjobs_page.dart';
import '../../presentation/features/dashboard/screens/overview_page.dart';
import '../../presentation/features/databases/screens/database_detail_page.dart';
import '../../presentation/features/databases/screens/databases_page.dart';
import '../../presentation/features/files/screens/file_editor_page.dart';
import '../../presentation/features/files/screens/file_ai_search_page.dart';
import '../../presentation/features/files/screens/file_history_page.dart';
import '../../presentation/features/host/screens/host_page.dart';
import '../../presentation/features/files/screens/file_tools_page.dart';
import '../../presentation/features/files/screens/files_page.dart';
import '../../presentation/features/firewall/screens/firewall_page.dart';
import '../../presentation/features/log/screens/log_hub_page.dart';
import '../../presentation/features/more/screens/more_page.dart';
import '../../presentation/features/panel_settings/screens/panel_settings_page.dart';
import '../../presentation/features/panel_settings/screens/snapshot_page.dart';
import '../../presentation/features/process/screens/process_page.dart';
import '../../presentation/features/runtimes/screens/runtime_detail_page.dart';
import '../../presentation/features/runtimes/screens/runtimes_page.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../../presentation/features/servers/screens/server_edit_page.dart';
import '../../presentation/features/servers/screens/servers_page.dart';
import '../../presentation/features/settings/screens/app_settings_page.dart';
import '../../presentation/features/supervisor/screens/supervisor_page.dart';
import '../../presentation/features/toolbox/screens/toolbox_clam_page.dart';
import '../../presentation/features/toolbox/screens/toolbox_device_page.dart';
import '../../presentation/features/toolbox/screens/toolbox_fail2ban_page.dart';
import '../../presentation/features/toolbox/screens/toolbox_ftp_page.dart';
import '../../presentation/features/toolbox/screens/toolbox_page.dart';
import '../../presentation/features/terminal/screens/terminal_page.dart';
import '../../presentation/features/websites/screens/website_accounts_page.dart';
import '../../presentation/features/websites/screens/website_create_wizard.dart';
import '../../presentation/features/websites/screens/website_groups_page.dart';
import '../../presentation/features/websites/screens/website_templates_page.dart';
import '../../presentation/features/websites/screens/website_detail_page.dart';
import '../../presentation/features/websites/screens/websites_page.dart';
import '../../presentation/shell/server_shell.dart';
import 'route_observer.dart';
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
  observers: [appRouteObserver],
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
              redisName: state.uri.queryParameters['redis'],
              redisFrom: state.uri.queryParameters['redisFrom'],
              initialCommand: state.uri.queryParameters['redisCommand'],
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
          path: 'files/history',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => slidePage(
            state,
            FileHistoryPage(
              serverId: _serverId(state),
              path: state.uri.queryParameters['path'] ?? '/',
            ),
          ),
        ),
        GoRoute(
          path: 'files/ai-search',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => slidePage(
            state,
            FileAiSearchPage(
              serverId: _serverId(state),
              initialPath: state.uri.queryParameters['path'] ?? '/',
            ),
          ),
        ),
        GoRoute(
          path: 'websites/create',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => slidePage(
            state,
            WebsiteCreateWizard(
              serverId: _serverId(state),
              type: state.uri.queryParameters['type'] ?? 'static',
            ),
          ),
        ),
        GoRoute(
          path: 'websites/templates',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => slidePage(
            state,
            WebsiteTemplatesPage(serverId: _serverId(state)),
          ),
        ),
        GoRoute(
          path: 'containers/create',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) =>
              slidePage(state, ContainerCreatePage(serverId: _serverId(state))),
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
                      path: 'accounts',
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => slidePage(
                        state,
                        WebsiteAccountsPage(serverId: _serverId(state)),
                      ),
                    ),
                    GoRoute(
                      path: ':siteId',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        WebsiteDetailPage(
                          serverId: _serverId(state),
                          siteId: state.pathParameters['siteId'] ?? '',
                          initialTab:
                              int.tryParse(
                                state.uri.queryParameters['tab'] ?? '',
                              ) ??
                              0,
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
                  routes: [
                    GoRoute(
                      path: 'tools',
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => slidePage(
                        state,
                        FileToolsPage(serverId: _serverId(state)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: 'containers',
                  pageBuilder: (context, state) => noTransitionPage(
                    state,
                    DockerOverviewPage(serverId: _serverId(state)),
                  ),
                  routes: [
                    GoRoute(
                      path: 'list',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        ContainersPage(serverId: _serverId(state)),
                      ),
                    ),
                    GoRoute(
                      path: 'resources',
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => slidePage(
                        state,
                        ContainerResourcesPage(serverId: _serverId(state)),
                      ),
                    ),
                    GoRoute(
                      path: 'images',
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => slidePage(
                        state,
                        ContainerResourcesPage(
                          serverId: _serverId(state),
                          singleTab: true,
                        ),
                      ),
                    ),
                    GoRoute(
                      path: 'networks',
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => slidePage(
                        state,
                        ContainerResourcesPage(
                          serverId: _serverId(state),
                          initialTab: 1,
                          singleTab: true,
                        ),
                      ),
                    ),
                    GoRoute(
                      path: 'repos',
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => slidePage(
                        state,
                        ContainerResourcesPage(
                          serverId: _serverId(state),
                          initialTab: 2,
                          singleTab: true,
                        ),
                      ),
                    ),
                    GoRoute(
                      path: 'volumes',
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => slidePage(
                        state,
                        ContainerVolumesPage(serverId: _serverId(state)),
                      ),
                    ),
                    GoRoute(
                      path: 'docker',
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => slidePage(
                        state,
                        DockerSettingsPage(serverId: _serverId(state)),
                      ),
                    ),
                    GoRoute(
                      path: ':name',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        ContainerDetailPage(
                          serverId: _serverId(state),
                          containerName: state.pathParameters['name'] ?? '',
                        ),
                      ),
                      routes: [
                        GoRoute(
                          path: 'edit',
                          parentNavigatorKey: _rootNavigatorKey,
                          pageBuilder: (context, state) => slidePage(
                            state,
                            ContainerCreatePage(
                              serverId: _serverId(state),
                              containerName: state.pathParameters['name'] ?? '',
                            ),
                          ),
                        ),
                      ],
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
                      path: 'ai',
                      pageBuilder: (context, state) =>
                          slidePage(state, AiPage(serverId: _serverId(state))),
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
                              instance:
                                  state.uri.queryParameters['instance'] ?? '',
                              from:
                                  state.uri.queryParameters['from'] ?? 'local',
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
                      routes: [
                        GoRoute(
                          path: 'form',
                          parentNavigatorKey: _rootNavigatorKey,
                          pageBuilder: (context, state) => slidePage(
                            state,
                            CronjobFormPage(
                              serverId: _serverId(state),
                              cronjobId: int.tryParse(
                                state.uri.queryParameters['id'] ?? '',
                              ),
                            ),
                          ),
                        ),
                      ],
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
                        ComposePage(
                          serverId: _serverId(state),
                          openTemplates:
                              state.uri.queryParameters['templates'] == '1',
                        ),
                      ),
                      routes: [
                        GoRoute(
                          path: 'form',
                          parentNavigatorKey: _rootNavigatorKey,
                          pageBuilder: (context, state) => slidePage(
                            state,
                            ComposeFormPage(
                              serverId: _serverId(state),
                              compose: state.extra is ContainerComposeDto
                                  ? state.extra as ContainerComposeDto
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    GoRoute(
                      path: 'settings',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        PanelSettingsPage(serverId: _serverId(state)),
                      ),
                      routes: [
                        GoRoute(
                          path: 'snapshots',
                          parentNavigatorKey: _rootNavigatorKey,
                          pageBuilder: (context, state) => slidePage(
                            state,
                            SnapshotPage(serverId: _serverId(state)),
                          ),
                        ),
                      ],
                    ),
                    GoRoute(
                      path: 'alerts',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        AlertsPage(serverId: _serverId(state)),
                      ),
                      routes: [
                        GoRoute(
                          path: 'form',
                          parentNavigatorKey: _rootNavigatorKey,
                          pageBuilder: (context, state) => slidePage(
                            state,
                            AlertFormPage(
                              serverId: _serverId(state),
                              alertId: int.tryParse(
                                state.uri.queryParameters['id'] ?? '',
                              ),
                            ),
                          ),
                        ),
                      ],
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
                      routes: [
                        GoRoute(
                          path: 'accounts',
                          parentNavigatorKey: _rootNavigatorKey,
                          pageBuilder: (context, state) => slidePage(
                            state,
                            BackupAccountsPage(serverId: _serverId(state)),
                          ),
                        ),
                      ],
                    ),
                    GoRoute(
                      path: 'runtimes',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        RuntimesPage(serverId: _serverId(state)),
                      ),
                    ),
                    GoRoute(
                      path: 'host',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        HostPage(serverId: _serverId(state)),
                      ),
                    ),
                    GoRoute(
                      path: 'runtimes/:id',
                      pageBuilder: (context, state) => slidePage(
                        state,
                        RuntimeDetailPage(
                          serverId: _serverId(state),
                          id:
                              int.tryParse(state.pathParameters['id'] ?? '') ??
                              0,
                          type: state.uri.queryParameters['type'] ?? '',
                          name: state.uri.queryParameters['name'] ?? '',
                        ),
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
                      path: 'toolbox/device',
                      pageBuilder: (context, state) =>
                          slidePage(state, const ToolboxDevicePage()),
                    ),
                    GoRoute(
                      path: 'toolbox/clam',
                      pageBuilder: (context, state) =>
                          slidePage(state, const ToolboxClamPage()),
                    ),
                    GoRoute(
                      path: 'toolbox/fail2ban',
                      pageBuilder: (context, state) =>
                          slidePage(state, const ToolboxFail2banPage()),
                    ),
                    GoRoute(
                      path: 'toolbox/ftp',
                      pageBuilder: (context, state) =>
                          slidePage(state, const ToolboxFtpPage()),
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
