#!/usr/bin/env python3
"""扫描 UI 层硬编码英文文案。命中即退出码 1，用于 CI。"""
import pathlib
import re
import sys

SKIP_DIRS = (
    'localization',
    'l10n',
    'generated',
    # 开发用组件库页面，不进用户路径
    'features/gallery',
)
# 专有名词白名单：命中则跳过
WHITELIST = {
    'CPU', 'GPU', 'RAM', 'Docker', 'HTTPS', 'HTTP', 'SSH', 'SSL', 'TLS',
    'IPv4', 'IPv6', 'MySQL', 'PostgreSQL', 'MongoDB', 'Redis', 'MariaDB',
    'Nginx', 'OpenResty', 'PHP', 'Java', 'Node', 'Python', 'Go',
    'Telegram', 'Discord', 'Slack', "Let's Encrypt", 'ZeroSSL',
    'OneDash', '1Panel', 'API', 'URL', 'URI', 'ID', 'IP', 'DNS', 'CDN',
    'OK', 'JSON', 'YAML', 'TOML', 'CPU%', 'GB', 'MB', 'KB', 'ms', 's',
    'S3', 'OSS', 'SFTP', 'MINIO', 'COS', 'KODO', 'UPYUN', 'ALIYUN',
    'OneDrive', 'WebDAV', 'GoogleDrive', 'LOCAL',
    'unless-stopped',
    'always',
    'on-failure',
    'TCP',
    'UDP',
    'Dockerfile',
    'bridge',
    'overlay',
    'macvlan',
    'docker-compose.yml',
    'daemon.json',
    'http://',
    'https://',
    'Node.js',
    '.NET',
    '<html><body><h1>{{title}}</h1></body></html>',
    'CORS',
    'SCAN 0 COUNT 100',
    'timeout',
    'maxclients',
    'maxmemory',
    'AOF',
    'appendfsync',
    'RDB',
    'save',
    'UTF8',
    'Ctrl+C',
    'Ctrl+D',
    'Tab',
    'Esc',
    'GitHub',
    'ClamAV',
    'npm',
    'yarn',
    'pnpm',
    'ED25519',
    'RSA',
    'ext4',
    'xfs',
    'OpenClaw',
    'Hermes Agent',
    'QwenPaw',
    'DeepSeek Harness',
    'Octop',
    'true',
    'false',
    'open',
    'allowlist',
    'disabled',
    'websocket',
    'webhook',
    'npx',
    'uvx',
    'SSE',
    'Streamable HTTP',
    'firewalld',
    'ufw',
}
PATTERN = re.compile(
    r"""(?:Text|label|title|subtitle|hintText|tooltip|semanticLabel)\s*[:(]\s*'([^'\\\n]{3,60})'"""
)
CJK = re.compile(r'[\u4e00-\u9fff]')
WORD = re.compile(r'[A-Za-z]{2,}')


def main():
    root = pathlib.Path('lib')
    hits = []
    for path in root.rglob('*.dart'):
        if any(skip in str(path) for skip in SKIP_DIRS):
            continue
        for number, line in enumerate(path.read_text(encoding='utf-8').splitlines(), 1):
            stripped = line.strip()
            if stripped.startswith('//'):
                continue
            for match in PATTERN.finditer(line):
                value = match.group(1)
                if CJK.search(value) or '$' in value or not WORD.search(value):
                    continue
                if value in WHITELIST:
                    continue
                hits.append(f'{path}:{number}  {value!r}')
    if hits:
        print(f'发现 {len(hits)} 处硬编码英文文案：')
        print('\n'.join(hits))
        return 1
    print('OK: 未发现硬编码英文文案')
    return 0


if __name__ == '__main__':
    sys.exit(main())
