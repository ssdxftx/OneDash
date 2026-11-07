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
