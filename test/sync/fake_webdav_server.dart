import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Faux serveur WebDAV pour les tests : un vrai serveur HTTP local, qui
/// applique les règles utiles à la synchronisation comme Nextcloud (ETag,
/// `If-Match`, `If-None-Match`, dossier parent obligatoire, authentification).
class FakeWebDavServer {
  FakeWebDavServer._(this._server) {
    _server.listen(_handle);
  }

  static Future<FakeWebDavServer> start() async => FakeWebDavServer._(
    await HttpServer.bind(InternetAddress.loopbackIPv4, 0),
  );

  final HttpServer _server;

  static const user = 'max';
  static const password = 'secret';

  /// Fichiers, par chemin (« /cave/cave.sqlite »).
  final files = <String, Uint8List>{};
  final _etags = <String, String>{};
  var _version = 0;

  /// Dossiers existants (sans « / » final).
  final folders = <String>{'/cave'};

  /// Requêtes reçues (« GET /cave/cave.sqlite »), pour vérifier les envois.
  final requests = <String>[];

  /// Code renvoyé à toutes les requêtes à la place du fonctionnement normal.
  int? forcedStatus;

  /// Si faux, PUT ne renvoie pas d'ETag (il faut le relire par PROPFIND).
  bool etagOnPut = true;

  /// Appelé juste avant de traiter un PUT : simule l'envoi d'un autre
  /// appareil au même moment.
  void Function()? beforePut;

  /// Adresse du dossier de la cave.
  Uri get folderUri => Uri.parse('http://127.0.0.1:${_server.port}/cave/');

  int count(String method) =>
      requests.where((r) => r.startsWith('$method ')).length;

  /// Dépose un fichier directement (comme un autre appareil).
  void put(String path, List<int> bytes) {
    files[path] = Uint8List.fromList(bytes);
    _etags[path] = '"v${++_version}"';
  }

  String? etagOf(String path) => _etags[path];

  Future<void> close() => _server.close(force: true);

  Future<void> _handle(HttpRequest request) async {
    final path = Uri.decodeComponent(request.uri.path);
    requests.add('${request.method} $path');
    final body = await request.fold<BytesBuilder>(
      BytesBuilder(),
      (b, chunk) => b..add(chunk),
    );
    final response = request.response;

    final expected = 'Basic ${_basic(user, password)}';
    if (request.headers.value('authorization') != expected) {
      return _end(response, 401);
    }
    if (forcedStatus != null) return _end(response, forcedStatus!);

    switch (request.method) {
      case 'GET':
        final data = files[path];
        if (data == null) return _end(response, 404);
        response.headers.set('ETag', _etags[path]!);
        if (request.headers.value('if-none-match') == _etags[path]) {
          return _end(response, 304);
        }
        return _end(response, 200, data);

      case 'PUT':
        beforePut?.call();
        final parent = path.substring(0, path.lastIndexOf('/'));
        if (!folders.contains(parent)) return _end(response, 409);
        final ifMatch = request.headers.value('if-match');
        final ifNoneMatch = request.headers.value('if-none-match');
        if (ifMatch != null && ifMatch != _etags[path]) {
          return _end(response, 412);
        }
        if (ifNoneMatch == '*' && files.containsKey(path)) {
          return _end(response, 412);
        }
        final existed = files.containsKey(path);
        put(path, body.takeBytes());
        if (etagOnPut) response.headers.set('ETag', _etags[path]!);
        return _end(response, existed ? 204 : 201);

      case 'PROPFIND':
        final dir = path.endsWith('/')
            ? path.substring(0, path.length - 1)
            : path;
        if (folders.contains(dir)) {
          // Liste du dossier (profondeur 1) : le dossier, puis ses fichiers.
          final entries = StringBuffer(
            '<d:response><d:href>$dir/</d:href><d:propstat><d:prop>'
            '<d:resourcetype><d:collection/></d:resourcetype>'
            '</d:prop></d:propstat></d:response>',
          );
          for (final file in files.keys.where(
            (f) => f.substring(0, f.lastIndexOf('/')) == dir,
          )) {
            entries.write(
              '<d:response><d:href>${Uri.encodeFull(file)}</d:href>'
              '<d:propstat><d:prop><d:resourcetype/></d:prop></d:propstat>'
              '</d:response>',
            );
          }
          response.headers.contentType = ContentType('application', 'xml');
          return _end(
            response,
            207,
            utf8.encode(
              '<?xml version="1.0"?><d:multistatus xmlns:d="DAV:">'
              '$entries</d:multistatus>',
            ),
          );
        }
        final etag = _etags[path];
        if (etag == null) return _end(response, 404);
        response.headers.contentType = ContentType('application', 'xml');
        return _end(
          response,
          207,
          utf8.encode(
            '<?xml version="1.0"?><d:multistatus xmlns:d="DAV:"><d:response>'
            '<d:href>$path</d:href><d:propstat><d:prop>'
            '<d:getetag>${etag.replaceAll('"', '&quot;')}</d:getetag>'
            '</d:prop></d:propstat></d:response></d:multistatus>',
          ),
        );

      case 'DELETE':
        if (files.remove(path) == null) return _end(response, 404);
        _etags.remove(path);
        return _end(response, 204);

      case 'MOVE':
        final data = files.remove(path);
        if (data == null) return _end(response, 404);
        _etags.remove(path);
        final target = Uri.decodeComponent(
          Uri.parse(request.headers.value('destination')!).path,
        );
        put(target, data);
        return _end(response, 201);

      case 'MKCOL':
        final folder = path.endsWith('/')
            ? path.substring(0, path.length - 1)
            : path;
        if (folders.contains(folder)) return _end(response, 405);
        folders.add(folder);
        return _end(response, 201);
    }
    return _end(response, 405);
  }

  static String _basic(String user, String password) =>
      base64.encode(utf8.encode('$user:$password'));

  static Future<void> _end(
    HttpResponse response,
    int status, [
    List<int>? body,
  ]) async {
    // Le code d'abord : écrire le contenu envoie les en-têtes.
    response.statusCode = status;
    if (body != null) response.add(body);
    await response.close();
  }
}
