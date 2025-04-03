// File: lib/pages/home_page.dart (Simplified Input: 'jakarta performance')

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../utils/csv_export.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _queryController = TextEditingController();

  List<dynamic> _results = [];
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    if (!kReleaseMode) {
      _speech = stt.SpeechToText();
    }
  }

  Future<void> _search() async {
    try {
      final query = _queryController.text.trim().toLowerCase();
      if (query.isEmpty) {
        throw 'Input tidak boleh kosong';
      }

      List<String> parts = query.split(' ');
      if (parts.length == 2) {
        // Format: jakarta performance
        final cityTo = parts[0];
        final performance = parts[1] == 'performance' ? '1' : '0';

        final data = await ApiService.searchByCityToAndPerformance(
          cityTo: cityTo,
          performance: performance,
        );
        setState(() => _results = data);
      } else if (parts.length == 3) {
        // Format: jakarta surabaya revenue
        final cityFrom = parts[0];
        final cityTo = parts[1];
        final revenue = parts[2] == 'revenue' ? '1' : '0';

        final data = await ApiService.searchByCityFromToAndRevenue(
          cityFrom: cityFrom,
          cityTo: cityTo,
          revenue: revenue,
        );
        setState(() => _results = data);
      } else {
        throw Exception('Format input tidak dikenali');
      }
    } catch (e) {
      debugPrint('Error saat fetch data: $e');
    }
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _queryController.text = result.recognizedWords;
          _isListening = false;
        });
        _search();
      });
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pencarian Data')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _queryController,
              decoration: InputDecoration(
                labelText: 'Contoh: jakarta performance atau jakarta surabaya revenue',
                suffixIcon: !kReleaseMode
                    ? IconButton(
                        icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                        onPressed: _isListening ? _stopListening : _startListening,
                      )
                    : null,
              ),
              onSubmitted: (_) => _search(),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _search,
              child: const Text('Cari'),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text('Belum ada hasil'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Bulan')),
                          DataColumn(label: Text('Total Tahun')),
                          DataColumn(label: Text('STT')),
                          DataColumn(label: Text('Berat')),
                          DataColumn(label: Text('Revenue')),
                        ],
                        rows: _results.map<DataRow>((row) {
                          return DataRow(cells: [
                            DataCell(Text(row['bulan'].toString())),
                            DataCell(Text(row['total_tahun'].toString())),
                            DataCell(Text(row['stt'].toString())),
                            DataCell(Text(row['berat'].toString())),
                            DataCell(Text(row['revenue'].toString())),
                          ]);
                        }).toList(),
                      ),
                    ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Download CSV'),
              onPressed: _results.isEmpty ? null : () => downloadCsv(_results),
            ),
          ],
        ),
      ),
    );
  }
}
