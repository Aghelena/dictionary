import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? _wordData;
  bool _isLoading = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _searchWord(String word) async {
    if (word.isEmpty) return;

    setState(() {
      _isLoading = true;
      _wordData = null;
    });

    final url =
        Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _wordData = data[0];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _wordData = {'error': 'Palavra não encontrada.'};
      });
    }
  }

  Widget _buildDefinitionCard() {
    if (_wordData == null) return const SizedBox();

    if (_wordData!.containsKey('error')) {
      return Center(
        child: Text(
          _wordData!['error'],
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    final word = _wordData!['word'];
    final phonetics = _wordData!['phonetics'];
    final meanings = _wordData!['meanings'];

    final audioUrl = (phonetics as List)
            .firstWhere((p) => p['audio'] != '', orElse: () => {})['audio'] ??
        '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F1FA),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  word,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (audioUrl != '')
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded,
                      color: Colors.deepPurple),
                  onPressed: () => _audioPlayer.play(UrlSource(audioUrl)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...meanings.map<Widget>((meaning) {
            final partOfSpeech = meaning['partOfSpeech'];
            final definitions = meaning['definitions'] as List;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("• $partOfSpeech",
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                ...definitions.take(2).map((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text("– ${d['definition']}"),
                    ))
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Dicionário Inglês',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.deepPurple),
            tooltip: 'Sair',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) => _searchWord(value.trim()),
                decoration: InputDecoration(
                  hintText: 'Digite uma palavra em inglês',
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: const TextStyle(color: Colors.black54),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.deepPurple.shade100),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide:
                        const BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.deepPurple),
                    onPressed: () => _searchWord(_controller.text.trim()),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: SingleChildScrollView(child: _buildDefinitionCard()),
              ),
          ],
        ),
      ),
    );
  }
}
