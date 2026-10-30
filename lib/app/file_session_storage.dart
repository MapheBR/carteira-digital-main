import 'dart:convert';
import 'dart:io';

import 'package:carteira_core/carteira_core.dart';

/// [SessionStorage] do app: guarda a sessão como JSON num arquivo na pasta
/// do próprio app (no Android, o cache interno do app).
///
/// Dart puro (dart:io), sem plugin: funciona mesmo em PCs onde o Windows
/// não deixa ativar o Modo de Desenvolvedor.
class FileSessionStorage implements SessionStorage {
  FileSessionStorage({Directory? directory})
      : _file = File(
    '${(directory ?? Directory.systemTemp).path}'
        '${Platform.pathSeparator}carteira_session.json',
  );

  final File _file;

  @override
  Future<Session?> read() async {
    try {
      if (!await _file.exists()) return null;
      final raw = await _file.readAsString();
      return Session.fromJson(asJson(jsonDecode(raw)));
    } catch (_) {
      // Arquivo corrompido ou de outra versão: trata como "sem sessão".
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(Session session) async {
    await _file.writeAsString(jsonEncode(session.toJson()), flush: true);
  }

  @override
  Future<void> clear() async {
    try {
      if (await _file.exists()) await _file.delete();
    } catch (_) {
      // Nada a fazer: sem arquivo, sem sessão.
    }
  }
}