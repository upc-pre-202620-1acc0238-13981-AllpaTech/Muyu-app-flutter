import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muyu_app/core/designsystem/components/plot_photo.dart';
import 'package:muyu_app/features/plot_approval/domain/plot_status_label.dart';

// A 1x1 transparent PNG, as Kotlin uploads plot photos.
const _photo =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=';

void main() {
  test('backend statuses show in the farmer and merchant language', () {
    expect(plotStatusLabel('funded', es: true), 'Financiada');
    expect(plotStatusLabel('available', es: true), 'Disponible');
    expect(plotStatusLabel('published', es: false), 'Published');
    expect(plotStatusLabel('pending', es: true), 'Pendiente');
  });

  test('Kotlin stage titles are translated', () {
    expect(plotStageLabel('Irrigation', es: true), 'Riego');
    expect(plotStageLabel('Harvest', es: false), 'Harvest');
    expect(plotStageLabel('', es: true), '—');
  });

  testWidgets('a photo published from Kotlin as a data URL is shown', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlotPhoto(source: _photo, description: 'Esperanza'),
      ),
    );
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<MemoryImage>());
  });

  testWidgets('a phone-only photo path falls back to the placeholder', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlotPhoto(source: 'content://media/1', description: 'Esperanza'),
      ),
    );
    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
  });
}
