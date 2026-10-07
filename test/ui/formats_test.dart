import 'package:cave/l10n/app_localizations.dart';
import 'package:cave/ui/formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('volumes proposés, dont le fût de 6 l', (tester) async {
    late Formats formats;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            formats = Formats.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(standardVolumesMl, contains(6000));
    expect(standardVolumesMl, orderedEquals([...standardVolumesMl]..sort()));
    expect(formats.volume(6000), '6 l');
    expect(formats.volume(1500), '1,5 l');
    expect(formats.volume(750), '75 cl');
  });
}
