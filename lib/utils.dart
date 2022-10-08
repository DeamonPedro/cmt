import 'dart:io';

void errorMessage(String message) {
  stderr.writeln(message);
  exit(1);
}

Future<List<String>> loadScopes(String path) async {
  final file = File('$path/.scopes');
  if (!file.existsSync()) {
    return [];
  } else {
    return file.readAsLinesSync();
  }
}

Future<void> saveScope(String path, String scope) async {
  final file = File('$path/.scopes');
  if (!file.existsSync()) {
    file.createSync();
  }
  final scopes = await loadScopes(path);
  if (!scopes.contains(scope)) {
    scopes.add(scope);
    file.writeAsStringSync(scopes.join('\n'));
  }
}
