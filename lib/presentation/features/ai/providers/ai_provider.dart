import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/dto/ai/ai_account_dto.dart';
import '../../../../data/dto/ai/ai_agent_dto.dart';
import '../../../../data/dto/ai/ai_provider_dto.dart';
import '../../../../data/dto/ai/gpu_info_dto.dart';
import '../../../../data/dto/ai/mcp_server_dto.dart';
import '../../../../data/dto/ai/ollama_model_dto.dart';
import '../../../../data/dto/common/page_result.dart';
import '../../../../data/repositories_impl/ai_repository_impl.dart';

final ollamaModelsProvider =
    FutureProvider.autoDispose<PageResult<OllamaModelDto>>((ref) async {
      final repository = await ref.watch(aiRepositoryProvider.future);
      return repository.searchOllamaModels();
    }, name: 'ollamaModelsProvider');

final gpuInfoProvider = FutureProvider.autoDispose<GpuInfoDto>((ref) async {
  final repository = await ref.watch(aiRepositoryProvider.future);
  return repository.loadGpuInfo();
}, name: 'gpuInfoProvider');

final modelGpuDevicesProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
      final repository = await ref.watch(aiRepositoryProvider.future);
      return repository.getModelGpuDevices();
    }, name: 'modelGpuDevicesProvider');

final gpuGroupsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final repository = await ref.watch(aiRepositoryProvider.future);
      return repository.listGpuGroups();
    }, name: 'gpuGroupsProvider');

final mcpServersProvider = FutureProvider.autoDispose<PageResult<McpServerDto>>(
  (ref) async {
    final repository = await ref.watch(aiRepositoryProvider.future);
    return repository.searchMcpServers();
  },
  name: 'mcpServersProvider',
);

final aiAccountsProvider = FutureProvider.autoDispose<PageResult<AiAccountDto>>(
  (ref) async {
    final repository = await ref.watch(aiRepositoryProvider.future);
    return repository.searchAccounts();
  },
  name: 'aiAccountsProvider',
);

final aiAgentsProvider = FutureProvider.autoDispose<PageResult<AiAgentDto>>((
  ref,
) async {
  final repository = await ref.watch(aiRepositoryProvider.future);
  return repository.searchAgents();
}, name: 'aiAgentsProvider');

final aiProvidersProvider = FutureProvider.autoDispose<List<AiProviderDto>>((
  ref,
) async {
  final repository = await ref.watch(aiRepositoryProvider.future);
  return repository.getProviders();
}, name: 'aiProvidersProvider');

final aiAccountCountsProvider = FutureProvider.autoDispose<Map<String, int>>((
  ref,
) async {
  final repository = await ref.watch(aiRepositoryProvider.future);
  final providers = await repository.getProviders();
  return repository.countAccountsByProviders(
    providers.map((item) => item.provider).toList(growable: false),
  );
}, name: 'aiAccountCountsProvider');
