class Word {
  final String word;
  final String phonetic;
  final String audio;
  final List<String> definitions;
  final List<String> examples;

  Word({
    required this.word,
    required this.phonetic,
    required this.audio,
    required this.definitions,
    required this.examples,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    final meanings = json['meanings'] as List;
    final definitions = <String>[];
    final examples = <String>[];

    for (var meaning in meanings) {
      for (var def in meaning['definitions']) {
        definitions.add(def['definition']);
        if (def['example'] != null) {
          examples.add(def['example']);
        }
      }
    }

    return Word(
      word: json['word'],
      phonetic: json['phonetic'] ?? '',
      audio: (json['phonetics'] as List)
              .firstWhere((p) => p['audio'] != '', orElse: () => {})['audio'] ??
          '',
      definitions: definitions,
      examples: examples,
    );
  }
}
