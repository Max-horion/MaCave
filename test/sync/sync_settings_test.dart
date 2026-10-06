import 'package:cave/data/local_store.dart';
import 'package:cave/sync/sync_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String nextcloud(
    String server, {
    String user = 'max',
    String folder = 'Cave',
  }) => SyncSettings(
    kind: ServerKind.nextcloud,
    server: server,
    user: user,
    folder: folder,
  ).folderUri().toString();

  group('adresse Nextcloud', () {
    test('l\'appli complète le chemin', () {
      expect(
        nextcloud('cloud.exemple.fr'),
        'https://cloud.exemple.fr/remote.php/dav/files/max/Cave/',
      );
    });

    test('Nextcloud installé dans un sous-dossier, avec un port', () {
      expect(
        nextcloud('https://exemple.fr:8443/nextcloud/'),
        'https://exemple.fr:8443/nextcloud/remote.php/dav/files/max/Cave/',
      );
    });

    test('adresse d\'une page collée depuis le navigateur', () {
      expect(
        nextcloud('https://cloud.exemple.fr/index.php/apps/files/?dir=/'),
        'https://cloud.exemple.fr/remote.php/dav/files/max/Cave/',
      );
    });

    test('dossier en plusieurs niveaux, espaces et accents encodés', () {
      expect(
        nextcloud(' cloud.exemple.fr ', folder: 'Mes documents/Cave à vin/'),
        'https://cloud.exemple.fr/remote.php/dav/files/max/'
        'Mes%20documents/Cave%20%C3%A0%20vin/',
      );
    });

    test('adresse ou dossier vide : refusés', () {
      expect(() => nextcloud(''), throwsFormatException);
      expect(
        () => nextcloud('cloud.exemple.fr', folder: ' / '),
        throwsFormatException,
      );
      expect(() => nextcloud('ftp://cloud.exemple.fr'), throwsFormatException);
    });
  });

  test('autre serveur : adresse complète, « / » final ajouté', () {
    final uri = const SyncSettings(
      kind: ServerKind.other,
      server: 'http://nas.local:5005/webdav/cave',
      user: 'max',
    ).folderUri();
    expect(uri.toString(), 'http://nas.local:5005/webdav/cave/');
  });

  test('même cible : même adresse finale et même utilisateur', () {
    const a = SyncSettings(
      kind: ServerKind.nextcloud,
      server: 'cloud.exemple.fr',
      user: 'max',
    );
    const b = SyncSettings(
      kind: ServerKind.other,
      server: 'https://cloud.exemple.fr/remote.php/dav/files/max/Cave',
      user: 'max',
    );
    expect(a.sameTarget(b), isTrue);
    expect(
      a.sameTarget(
        const SyncSettings(
          kind: ServerKind.nextcloud,
          server: 'cloud.exemple.fr',
          user: 'max',
          folder: 'Autre',
        ),
      ),
      isFalse,
    );
  });

  group('enregistrement', () {
    late MemoryLocalStore store;
    late MemorySecretStore secrets;
    late SyncSettingsStore settings;

    setUp(() {
      store = MemoryLocalStore();
      secrets = MemorySecretStore();
      settings = SyncSettingsStore(store, secrets);
    });

    test(
      'paramètres dans les préférences, mot de passe dans le coffre',
      () async {
        await settings.save(
          const SyncSettings(
            kind: ServerKind.nextcloud,
            server: 'cloud.exemple.fr',
            user: 'max',
            folder: 'Cave',
          ),
          'mot-de-passe',
        );
        expect(store.values.values.join(), isNot(contains('mot-de-passe')));
        final loaded = await settings.load();
        expect(loaded!.settings.server, 'cloud.exemple.fr');
        expect(loaded.password, 'mot-de-passe');
      },
    );

    test('mot de passe absent du coffre : synchro désactivée', () async {
      await settings.save(
        const SyncSettings(kind: ServerKind.other, server: 'a.fr', user: 'u'),
        'x',
      );
      secrets.values.clear();
      expect(await settings.load(), isNull);
    });

    test('désactivation : tout est effacé', () async {
      await settings.save(
        const SyncSettings(kind: ServerKind.other, server: 'a.fr', user: 'u'),
        'x',
      );
      await settings.clear();
      expect(await settings.load(), isNull);
      expect(secrets.values, isEmpty);
    });
  });
}
