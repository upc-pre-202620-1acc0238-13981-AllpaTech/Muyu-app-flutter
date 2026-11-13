import 'dart:convert';
import 'dart:typed_data';

/// Minimal one-page PDF matching Kotlin `writeReceiptPdf`.
Uint8List buildFundingReceiptPdf({
  required String title,
  required String plotName,
  required String amount,
  required String paymentMethod,
  required String status,
}) {
  String esc(String value) =>
      value.replaceAll(r'\', r'\\').replaceAll('(', r'\(').replaceAll(')', r'\)');

  final stream = StringBuffer()
    ..writeln('BT')
    ..writeln('/F1 28 Tf')
    ..writeln('48 772 Td')
    ..writeln('(MUYU) Tj')
    ..writeln('0 -50 Td')
    ..writeln('(${esc(title)}) Tj')
    ..writeln('/F1 18 Tf')
    ..writeln('0 -70 Td')
    ..writeln('(Plot: ${esc(plotName)}) Tj')
    ..writeln('0 -40 Td')
    ..writeln('(Amount: ${esc(amount)}) Tj')
    ..writeln('0 -40 Td')
    ..writeln('(Payment method: ${esc(paymentMethod)}) Tj')
    ..writeln('0 -40 Td')
    ..writeln('(Status: ${esc(status)}) Tj')
    ..writeln('0 -60 Td')
    ..writeln('(Funds are held in Escrow and released by approved milestones.) Tj')
    ..writeln('ET');
  final content = stream.toString();
  final contentBytes = utf8.encode(content);

  final objects = <String>[
    '1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj',
    '2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj',
    '3 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >> endobj',
    '4 0 obj << /Length ${contentBytes.length} >> stream\n$content\nendstream endobj',
    '5 0 obj << /Type /Font /Subtype /Type1 /BaseFont /Helvetica >> endobj',
  ];

  final buffer = StringBuffer('%PDF-1.4\n');
  final offsets = <int>[];
  var cursor = buffer.length;
  for (final object in objects) {
    offsets.add(cursor);
    buffer
      ..write(object)
      ..write('\n');
    cursor = buffer.length;
  }
  final xref = cursor;
  buffer
    ..writeln('xref')
    ..writeln('0 ${objects.length + 1}')
    ..writeln('0000000000 65535 f ');
  for (final offset in offsets) {
    buffer.writeln('${offset.toString().padLeft(10, '0')} 00000 n ');
  }
  buffer
    ..writeln('trailer << /Size ${objects.length + 1} /Root 1 0 R >>')
    ..writeln('startxref')
    ..writeln(xref)
    ..write('%%EOF');
  return Uint8List.fromList(utf8.encode(buffer.toString()));
}
