// File: lib/utils/csv_export.dart
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';

Future<void> downloadCsv(List<dynamic> data) async {
  List<List<dynamic>> rows = [
    ['Bulan', 'Total Tahun', 'STT', 'Berat', 'Revenue'],
    ...data.map((e) => [
      e['bulan'],
      e['total_tahun'],
      e['stt'],
      e['berat'],
      e['revenue']
    ])
  ];

  String csvData = const ListToCsvConverter().convert(rows);
  final bytes = utf8.encode(csvData);
  await FileSaver.instance.saveFile(
    name: 'hasil_pencarian',
    bytes: bytes,
    ext: 'csv',
    mimeType: MimeType.csv,
  );
}
