import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ccpocket/services/bridge_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BridgeService file list decoding', () {
    test('decodes git-quoted utf8 paths before publishing fileList', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final sockets = <WebSocket>[];
      final fileListReady = Completer<void>();

      server.transform(WebSocketTransformer()).listen((socket) {
        sockets.add(socket);
        socket.add(
          jsonEncode({
            'type': 'file_list',
            'files': [
              r'"docs/dev/prepare/\344\270\255\346\226\207.md"',
              'apps/mobile/lib/main.dart',
            ],
          }),
        );
      });

      final bridge = BridgeService();
      final emittedLists = <List<String>>[];
      final sub = bridge.fileList.listen((files) {
        emittedLists.add(files);
        if (!fileListReady.isCompleted) {
          fileListReady.complete();
        }
      });

      bridge.connect('ws://127.0.0.1:${server.port}');

      await fileListReady.future.timeout(const Duration(seconds: 2));

      expect(
        emittedLists.single,
        equals(['docs/dev/prepare/中文.md', 'apps/mobile/lib/main.dart']),
      );

      await sub.cancel();
      bridge.disconnect();
      bridge.dispose();
      for (final socket in sockets) {
        await socket.close();
      }
      await server.close(force: true);
    });
  });
}
