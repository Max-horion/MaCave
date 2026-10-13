import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/layout.dart';
import '../../ui/widgets.dart';

/// Version de l'appli (« 0.1.0 ») ; remplacée dans les tests.
final appVersionProvider = FutureProvider<String>(
  (ref) async => (await PackageInfo.fromPlatform()).version,
);

/// Dépôt du code source et adresse de retour (diffusion 1.0.0, lot 10).
const sourceUrl = 'https://github.com/Max-horion/MaCave';
const issuesUrl = '$sourceUrl/issues';
const feedbackEmail = 'maxence@bouthon.fr';

/// Ouvre un lien dans le navigateur ou la messagerie de l'appareil ; rend
/// faux si aucune appli ne sait l'ouvrir. Remplacé dans les tests.
final linkLauncherProvider = Provider<Future<bool> Function(Uri)>(
  (ref) => (uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on PlatformException {
      return false;
    }
  },
);

/// Écran « À propos » : version, licence, sources à citer (INAO, Open Food
/// Facts, Tesseract et ses bibliothèques, ZXing, icône) et licences des
/// bibliothèques (page standard de Flutter, complétée par licenses.dart).
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final version = ref.watch(appVersionProvider).value;

    Widget section(String title) => Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
    Widget paragraph(String text) =>
        Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text));
    // Lien ouvert dans le navigateur ou la messagerie ; à défaut (aucune
    // appli pour l'ouvrir), l'adresse est copiée.
    Widget link(IconData icon, String title, String shown, Uri uri) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(shown),
      onTap: () async {
        if (await ref.read(linkLauncherProvider)(uri)) return;
        await Clipboard.setData(ClipboardData(text: shown));
        if (context.mounted) showMessage(context, l10n.aboutLinkCopied);
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ReadableWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Center(
              child: Image.asset(
                'assets/icon.png',
                width: 96,
                height: 96,
                excludeFromSemantics: true,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.appTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            if (version != null)
              Text(
                l10n.aboutVersion(version),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            const SizedBox(height: 16),
            paragraph(l10n.aboutDescription),
            paragraph(l10n.aboutCopyright),
            paragraph(l10n.aboutLicense),
            section(l10n.aboutContact),
            paragraph(l10n.aboutContactText),
            link(
              Icons.mail_outline,
              l10n.aboutEmail,
              feedbackEmail,
              Uri(
                scheme: 'mailto',
                path: feedbackEmail,
                query:
                    'subject=${Uri.encodeComponent([l10n.appTitle, ?version].join(' '))}',
              ),
            ),
            link(
              Icons.bug_report_outlined,
              l10n.aboutIssues,
              issuesUrl,
              Uri.parse(issuesUrl),
            ),
            link(Icons.code, l10n.aboutSource, sourceUrl, Uri.parse(sourceUrl)),
            section(l10n.aboutData),
            paragraph(l10n.aboutInao),
            paragraph(l10n.aboutOff),
            section(l10n.aboutRecognition),
            paragraph(l10n.aboutTesseract),
            paragraph(l10n.aboutZxing),
            const SizedBox(height: 8),
            paragraph(l10n.aboutIcon),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: l10n.appTitle,
                applicationVersion: version,
                applicationLegalese:
                    '${l10n.aboutCopyright}\n${l10n.aboutLicense}',
              ),
              icon: const Icon(Icons.gavel),
              label: Text(l10n.aboutLicenses),
            ),
          ],
        ),
      ),
    );
  }
}
