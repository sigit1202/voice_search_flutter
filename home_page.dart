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
