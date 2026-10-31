/// 监听端口对应的进程信息。
class ProcessInfo {
  const ProcessInfo({
    required this.pid,
    required this.name,
    required this.user,
    required this.command,
    required this.port,
    required this.protocol,
    required this.address,
  });

  final int pid;
  final String name;
  final String user;
  final String command;
  final String port;
  final String protocol;
  final String address;
}
