import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/data/dto/ai/ai_account_dto.dart';
import 'package:onedash/data/dto/ai/ai_agent_dto.dart';
import 'package:onedash/data/dto/ai/ai_agent_model_config_dto.dart';
import 'package:onedash/data/dto/ai/ai_agent_role_dto.dart';
import 'package:onedash/data/dto/ai/ai_feishu_config_dto.dart';
import 'package:onedash/data/dto/ai/ai_provider_dto.dart';
import 'package:onedash/data/dto/ai/gpu_info_dto.dart';
import 'package:onedash/data/dto/ai/mcp_domain_dto.dart';
import 'package:onedash/data/dto/ai/mcp_server_dto.dart';
import 'package:onedash/data/dto/ai/ollama_model_dto.dart';

void main() {
  test('Ollama model parses fields and tolerates missing values', () {
    final model = OllamaModelDto.fromJson({
      'id': 7,
      'name': 'llama3',
      'size': '4.7 GB',
      'status': 'running',
      'logFileExist': true,
    });
    expect(model.name, 'llama3');
    expect(model.size, '4.7 GB');
    expect(model.logFileExist, isTrue);
    expect(model.from, isEmpty);
  });

  test('GPU info parses cuda driver and device list', () {
    final info = GpuInfoDto.fromJson({
      'type': 'nvidia',
      'cudaVersion': '12.4',
      'driverVersion': '550.54',
      'gpu': [
        {'productName': 'RTX 4090', 'memTotal': '24564 MiB'},
      ],
    });
    expect(info.type, 'nvidia');
    expect(info.driverVersion, '550.54');
    expect(info.devices, hasLength(1));
    expect(info.devices.first['productName'], 'RTX 4090');
  });

  test('MCP server parses transport and defaults', () {
    final server = McpServerDto.fromJson({
      'id': 3,
      'name': 'github',
      'status': 'running',
      'port': 8811,
      'outputTransport': 'sse',
      'environments': [
        {'key': 'TOKEN', 'value': 'x'},
      ],
    });
    expect(server.name, 'github');
    expect(server.port, 8811);
    expect(server.type, 'npx');
    expect(server.environments, hasLength(1));
  });

  test('MCP domain parses connection URL and allowed IPs', () {
    final domain = McpDomainDto.fromJson({
      'domain': 'mcp.example.com',
      'sslID': 12,
      'websiteID': 4,
      'allowIPs': ['10.0.0.1'],
      'connUrl': 'https://mcp.example.com/sse',
    });
    expect(domain.domain, 'mcp.example.com');
    expect(domain.sslID, 12);
    expect(domain.allowIPs, hasLength(1));
    expect(domain.connUrl, contains('/sse'));
  });
  test('AI account parses models and verification state', () {
    final account = AiAccountDto.fromJson({
      'id': 5,
      'provider': 'openai',
      'providerName': 'OpenAI',
      'name': 'main',
      'verified': true,
      'models': [
        {'id': 'gpt-4o', 'name': 'GPT-4o', 'isVerifyModel': true},
      ],
    });
    expect(account.providerName, 'OpenAI');
    expect(account.verified, isTrue);
    expect(account.models, hasLength(1));
    expect(account.models.first.name, 'GPT-4o');
  });

  test('AI agent parses status and upgrade flag', () {
    final agent = AiAgentDto.fromJson({
      'id': 2,
      'name': 'hermes',
      'status': 'running',
      'providerName': 'OpenAI',
      'model': 'gpt-4o',
      'webUIPort': 8080,
      'upgradable': true,
    });
    expect(agent.name, 'hermes');
    expect(agent.status, 'running');
    expect(agent.webUIPort, 8080);
    expect(agent.upgradable, isTrue);
  });
  test('AI provider parses API types and models', () {
    final provider = AiProviderDto.fromJson({
      'provider': 'openai',
      'displayName': 'OpenAI',
      'baseUrl': 'https://api.openai.com/v1',
      'defaultApiType': 'openai',
      'apiTypes': [
        {
          'apiType': 'openai',
          'baseUrl': 'https://api.openai.com/v1',
          'models': [
            {'id': 'gpt-4o', 'name': 'GPT-4o'},
          ],
        },
      ],
    });
    expect(provider.displayName, 'OpenAI');
    expect(provider.apiTypes, hasLength(1));
    expect(provider.apiTypes.first.models.first.id, 'gpt-4o');
  });
  test('Agent model config parses account, model and fallbacks', () {
    final config = AiAgentModelConfigDto.fromJson({
      'accountId': 9,
      'model': 'gpt-4o',
      'fallbacks': ['gpt-4o-mini', 'o3'],
    });
    expect(config.accountId, 9);
    expect(config.model, 'gpt-4o');
    expect(config.fallbacks, hasLength(2));
  });
  test('Agent role and channel parse bindings and bound state', () {
    final role = AiAgentRoleDto.fromJson({
      'id': 'r1',
      'name': 'ops',
      'workspace': '/data/ops',
      'model': 'gpt-4o',
      'bindings': [
        {'channel': 'feishu', 'accountId': 'a1'},
      ],
    });
    final channel = AiAgentChannelDto.fromJson({
      'name': 'feishu',
      'bound': true,
      'accountIds': ['a1'],
    });
    expect(role.bindings, hasLength(1));
    expect(role.bindings.first.channel, 'feishu');
    expect(channel.bound, isTrue);
    expect(channel.accountIds, hasLength(1));
  });
  test('Feishu config parses toggles and bots', () {
    final config = AiFeishuConfigDto.fromJson({
      'enabled': true,
      'threadSession': true,
      'streaming': false,
      'requireMention': 'true',
      'groupPolicy': 'allowlist',
      'connectionMode': 'websocket',
      'groupAllowFrom': ['g1'],
      'bots': [
        {'accountId': 'a1', 'name': 'bot', 'enabled': true, 'appId': 'cli_x'},
      ],
    });
    expect(config.enabled, isTrue);
    expect(config.groupPolicy, 'allowlist');
    expect(config.bots, hasLength(1));
    expect(config.bots.first.appId, 'cli_x');
  });
}
