import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/data/dto/host_tool/supervisor_dto.dart';

void main() {
  group('SupervisorToolStatus', () {
    test('reads nested config payload', () {
      final status = SupervisorToolStatus.fromJson({
        'config': {
          'isExist': true,
          'ctlExist': true,
          'init': false,
          'status': 'running',
          'version': '4.2.5',
          'serviceName': 'supervisord',
          'configPath': '/etc/supervisor/supervisord.conf',
        },
      });

      expect(status.isReady, isTrue);
      expect(status.isRunning, isTrue);
      expect(status.version, '4.2.5');
    });

    test('isReady requires install, ctl and initialized config', () {
      final status = SupervisorToolStatus.fromJson({
        'isExist': true,
        'ctlExist': true,
        'init': true,
      });

      expect(status.isReady, isFalse);
    });
  });

  group('supervisorGroupState', () {
    SupervisorProcessStatus status(String value) => SupervisorProcessStatus(
      name: 'worker',
      status: value,
      pid: '1',
      uptime: '1s',
      msg: '',
    );

    test('all running processes report running', () {
      expect(
        supervisorGroupState([status('RUNNING'), status('RUNNING')]),
        SupervisorGroupState.running,
      );
    });

    test('mixed states report warning', () {
      expect(
        supervisorGroupState([status('RUNNING'), status('STOPPED')]),
        SupervisorGroupState.warning,
      );
    });

    test('starting wins over running', () {
      expect(
        supervisorGroupState([status('RUNNING'), status('STARTING')]),
        SupervisorGroupState.starting,
      );
    });

    test('empty process list reports stopped', () {
      expect(supervisorGroupState(const []), SupervisorGroupState.stopped);
    });
  });
}
