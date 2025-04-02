// File: lib/pages/home_page.dart
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Search & Table')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Cari data...',
                suffixIcon: IconButton(
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
              ),
              onSubmitted: _search,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text('Belum ada data'))
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
            )
          ],
        ),
      ),
    );
  }
}
