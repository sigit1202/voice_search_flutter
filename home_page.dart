// File: lib/pages/home_page.dart (UI Baru dengan Dropdown & Validasi)

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../utils/csv_export.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

enum SearchType { performance, revenue }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _cityFromController = TextEditingController();
  final TextEditingController _cityToController = TextEditingController();

  SearchType _selectedSearchType = SearchType.performance;
  List<dynamic> _results = [];

  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _voiceForFrom = false;

  @override
  void initState() {
    super.initState();
    if (!kReleaseMode) {
      _speech = stt.SpeechToText();
    }
  }

  void _startListening(bool forFrom) async {
    _voiceForFrom = forFrom;
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          if (_voiceForFrom) {
            _cityFromController.text = result.recognizedWords;
          } else {
            _cityToController.text = result.recognizedWords;
          }
          _isListening = false;
        });
      });
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _search() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (_selectedSearchType == SearchType.performance) {
        final data = await ApiService.searchByCityToAndPerformance(
          cityTo: _cityToController.text.trim(),
          performance: '1',
        );
        setState(() => _results = data);
      } else {
        final data = await ApiService.searchByCityFromToAndRevenue(
          cityFrom: _cityFromController.text.trim(),
          cityTo: _cityToController.text.trim(),
          revenue: '1',
        );
        setState(() => _results = data);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildInputField(String label, TextEditingController controller, {required bool voiceForFrom}) {
    return TextFormField(
      controller: controller,
      validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: !kReleaseMode
            ? IconButton(
                icon: Icon(_isListening && _voiceForFrom == voiceForFrom ? Icons.mic_off : Icons.mic),
                onPressed: _isListening
                    ? _stopListening
                    : () => _startListening(voiceForFrom),
              )
            : null,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pencarian Data')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Pilih Jenis Pencarian',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<SearchType>(
                value: _selectedSearchType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Jenis Pencarian',
                ),
                items: const [
                  DropdownMenuItem(
                    value: SearchType.performance,
                    child: Text('Performance (Kota Tujuan)'),
                  ),
                  DropdownMenuItem(
                    value: SearchType.revenue,
                    child: Text('Revenue (Kota Asal dan Tujuan)'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedSearchType = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_selectedSearchType == SearchType.revenue)
                _buildInputField('Kota Asal', _cityFromController, voiceForFrom: true),
              if (_selectedSearchType == SearchType.revenue)
                const SizedBox(height: 16),
              _buildInputField('Kota Tujuan', _cityToController, voiceForFrom: false),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _search,
                child: const Text('Cari'),
              ),
              const SizedBox(height: 24),
              _results.isEmpty
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
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Download CSV'),
                onPressed: _results.isEmpty ? null : () => downloadCsv(_results),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
