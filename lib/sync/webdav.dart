import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

// Client WebDAV minimal (docs/architecture.md §1) : les quelques verbes dont
// la synchronisation a besoin, avec la main sur les en-têtes de contrôle de
// version (`If-Match`, `If-None-Match`) qui évitent d'écraser le fichier
// d'un autre appareil.

/// Ce qui a empêché une requête WebDAV d'aboutir.
enum WebDavProblem {
  /// Pas de réseau, serveur éteint, adresse inconnue, délai dépassé…
  unreachable,

  /// Identifiant ou mot de passe refusé (401, 403).
  unauthorized,

  /// Le fichier a changé sur le serveur depuis la dernière lecture (412) :
  /// on n'écrase jamais, on recommence.
  preconditionFailed,

  /// Dossier ou fichier introuvable (404, 409 « dossier parent absent »).
  notFound,

  /// Plus de place sur le serveur (507).
  insufficientStorage,

  /// Toute autre réponse inattendue du serveur.
  server,
}

class WebDavException implements Exception {
  const WebDavException(this.problem, [this.detail]);

  final WebDavProblem problem;
  final String? detail;

  @override
  String toString() =>
      'WebDavException(${problem.name}${detail == null ? '' : ', $detail'})';
}

/// Résultat d'un téléchargement conditionnel.
enum DownloadStatus {
  /// Le fichier a été écrit à l'emplacement demandé.
  downloaded,

  /// Inchangé depuis l'ETag fourni (304) : rien n'a été écrit.
  notModified,

  /// Pas de fichier sur le serveur (404).
  absent,
}

class DownloadResult {
  const DownloadResult(this.status, [this.etag]);

  final DownloadStatus status;

  /// ETag du fichier téléchargé, s'il a été fourni par le serveur.
  final String? etag;
}

/// Client d'un dossier WebDAV : tous les noms de fichiers sont relatifs à
/// [folder].
class WebDavClient {
  WebDavClient({
    required Uri folder,
    required String user,
    required String password,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 60),
  }) : folder = folder.path.endsWith('/')
           ? folder
           : folder.replace(path: '${folder.path}/'),
       _auth = 'Basic ${base64.encode(utf8.encode('$user:$password'))}',
       _http = httpClient ?? http.Client();

  WebDavClient._child(WebDavClient parent, String name)
    : folder = parent._uri('$name/'),
      timeout = parent.timeout,
      _auth = parent._auth,
      _http = parent._http;

  /// Client du sous-dossier [name] (mêmes identifiants, même connexion).
  /// Ne pas le fermer : seul le client d'origine est fermé.
  WebDavClient child(String name) => WebDavClient._child(this, name);

  /// Adresse du dossier, toujours terminée par « / ».
  final Uri folder;

  /// Délai maximal d'une requête.
  final Duration timeout;

  final String _auth;
  final http.Client _http;

  Uri _uri(String name) {
    final slash = name.endsWith('/');
    final base = slash ? name.substring(0, name.length - 1) : name;
    return folder.resolve('${Uri.encodeComponent(base)}${slash ? '/' : ''}');
  }

  /// Télécharge [name] dans [target]. Avec [ifNoneMatch] (dernier ETag connu),
  /// le serveur répond « inchangé » sans renvoyer le fichier.
  Future<DownloadResult> download(
    String name,
    File target, {
    String? ifNoneMatch,
  }) async {
    final request = http.Request('GET', _uri(name));
    if (ifNoneMatch != null) request.headers['If-None-Match'] = ifNoneMatch;
    final response = await _send(request);
    switch (response.statusCode) {
      case 304:
        await response.stream.drain<void>();
        return const DownloadResult(DownloadStatus.notModified);
      case 404:
        await response.stream.drain<void>();
        return const DownloadResult(DownloadStatus.absent);
      case 200:
        // Écriture en flux : le fichier n'est jamais entièrement en mémoire.
        final sink = target.openWrite();
        try {
          await response.stream.timeout(timeout).pipe(sink);
        } on TimeoutException catch (e) {
          throw WebDavException(WebDavProblem.unreachable, '$e');
        } on IOException catch (e) {
          throw WebDavException(WebDavProblem.unreachable, '$e');
        }
        return DownloadResult(DownloadStatus.downloaded, _etagOf(response));
    }
    throw await _failure(response);
  }

  /// Envoie [source] sous le nom [name] et retourne le nouvel ETag (relu par
  /// [etag] si le serveur ne le renvoie pas).
  ///
  /// [ifMatch] : n'écrase que si le fichier du serveur a toujours cet ETag.
  /// Sans [ifMatch], le fichier ne doit pas exister (`If-None-Match: *`).
  /// Sinon : [WebDavProblem.preconditionFailed].
  Future<String?> upload(String name, File source, {String? ifMatch}) async {
    final request = http.Request('PUT', _uri(name))
      ..headers['Content-Type'] = 'application/octet-stream'
      ..bodyBytes = await source.readAsBytes();
    if (ifMatch != null) {
      request.headers['If-Match'] = ifMatch;
    } else {
      request.headers['If-None-Match'] = '*';
    }
    final response = await _send(request);
    if (!const {200, 201, 204}.contains(response.statusCode)) {
      throw await _failure(response);
    }
    await response.stream.drain<void>();
    return _etagOf(response) ?? await etag(name);
  }

  /// ETag actuel de [name] (PROPFIND), ou null si le fichier n'existe pas.
  Future<String?> etag(String name) async {
    final request = http.Request('PROPFIND', _uri(name))
      ..headers['Depth'] = '0'
      ..headers['Content-Type'] = 'application/xml; charset=utf-8'
      ..body =
          '<?xml version="1.0" encoding="utf-8"?>'
          '<d:propfind xmlns:d="DAV:"><d:prop><d:getetag/></d:prop>'
          '</d:propfind>';
    final response = await _send(request);
    if (response.statusCode == 404) {
      await response.stream.drain<void>();
      return null;
    }
    if (response.statusCode != 207) throw await _failure(response);
    final body = await response.stream.bytesToString();
    // Le préfixe de l'espace de noms varie d'un serveur à l'autre (d:, D:…).
    final match = RegExp(r'<(?:\w+:)?getetag[^>]*>([^<]*)</').firstMatch(body);
    if (match == null) return null;
    return match
        .group(1)!
        .trim()
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&');
  }

  /// Noms des fichiers du dossier (PROPFIND, profondeur 1), sans les
  /// sous-dossiers. Liste vide si le dossier n'existe pas.
  Future<List<String>> list() async {
    final request = http.Request('PROPFIND', folder)
      ..headers['Depth'] = '1'
      ..headers['Content-Type'] = 'application/xml; charset=utf-8'
      ..body =
          '<?xml version="1.0" encoding="utf-8"?>'
          '<d:propfind xmlns:d="DAV:"><d:prop><d:resourcetype/></d:prop>'
          '</d:propfind>';
    final response = await _send(request);
    if (response.statusCode == 404) {
      await response.stream.drain<void>();
      return const [];
    }
    if (response.statusCode != 207) throw await _failure(response);
    final body = await response.stream.bytesToString();
    final names = <String>[];
    final responses = RegExp(
      r'<(?:\w+:)?response[\s>].*?</(?:\w+:)?response>',
      dotAll: true,
    );
    final href = RegExp(r'<(?:\w+:)?href[^>]*>([^<]*)</');
    for (final match in responses.allMatches(body)) {
      final block = match.group(0)!;
      // Un dossier (le dossier lui-même, ou un sous-dossier) : ignoré.
      if (RegExp(r'<(?:\w+:)?collection\s*/?>').hasMatch(block)) continue;
      final path = href.firstMatch(block)?.group(1)?.trim();
      if (path == null || path.endsWith('/')) continue;
      final segments = Uri.parse(path.replaceAll('&amp;', '&')).pathSegments;
      if (segments.isNotEmpty) names.add(segments.last);
    }
    return names;
  }

  /// Supprime [name]. Sans effet s'il n'existe pas.
  Future<void> delete(String name) async {
    final response = await _send(http.Request('DELETE', _uri(name)));
    if (const {200, 204, 404}.contains(response.statusCode)) {
      await response.stream.drain<void>();
      return;
    }
    throw await _failure(response);
  }

  /// Renomme [from] en [to], dans le même dossier. Sans effet si [from]
  /// n'existe pas.
  Future<void> move(String from, String to) async {
    final request = http.Request('MOVE', _uri(from))
      ..headers['Destination'] = _uri(to).toString()
      ..headers['Overwrite'] = 'F';
    final response = await _send(request);
    if (const {201, 204, 404}.contains(response.statusCode)) {
      await response.stream.drain<void>();
      return;
    }
    throw await _failure(response);
  }

  /// Crée le dossier [folder] s'il n'existe pas (son parent doit exister).
  Future<void> createFolder() async {
    final response = await _send(http.Request('MKCOL', folder));
    // 405 : le dossier existe déjà.
    if (response.statusCode == 201 || response.statusCode == 405) {
      await response.stream.drain<void>();
      return;
    }
    throw await _failure(response);
  }

  void close() => _http.close();

  Future<http.StreamedResponse> _send(http.BaseRequest request) async {
    request.headers['Authorization'] = _auth;
    // Une redirection n'est jamais suivie : elle emporterait le mot de passe
    // vers une autre adresse, éventuellement en http:// (audit de sécurité
    // du 2026-10-17). Elle aboutit à une erreur « serveur ».
    request.followRedirects = false;
    try {
      return await _http.send(request).timeout(timeout);
    } on TimeoutException catch (e) {
      throw WebDavException(WebDavProblem.unreachable, '$e');
    } on SocketException catch (e) {
      throw WebDavException(WebDavProblem.unreachable, '$e');
    } on TlsException catch (e) {
      // Certificat refusé : le serveur n'est pas joignable de façon sûre.
      throw WebDavException(WebDavProblem.unreachable, '$e');
    } on http.ClientException catch (e) {
      throw WebDavException(WebDavProblem.unreachable, '$e');
    }
  }

  static String? _etagOf(http.BaseResponse response) =>
      response.headers['etag'] ?? response.headers['oc-etag'];

  static Future<WebDavException> _failure(
    http.StreamedResponse response,
  ) async {
    await response.stream.drain<void>();
    final status = response.statusCode;
    final detail = 'HTTP $status ${response.reasonPhrase ?? ''}'.trim();
    final problem = switch (status) {
      401 || 403 => WebDavProblem.unauthorized,
      404 || 409 => WebDavProblem.notFound,
      412 => WebDavProblem.preconditionFailed,
      507 => WebDavProblem.insufficientStorage,
      _ => WebDavProblem.server,
    };
    return WebDavException(problem, detail);
  }
}
