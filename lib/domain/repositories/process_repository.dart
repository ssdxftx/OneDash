import '../entities/process_info.dart';

abstract interface class ProcessRepository {
  Future<List<ProcessInfo>> listListening();

  Future<void> stopProcess(int pid);
}
