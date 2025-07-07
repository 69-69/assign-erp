class TTSVoice {
  final String name;
  final String locale;

  TTSVoice({required this.name, required this.locale});

  factory TTSVoice.fromMap(Map<String, dynamic> data) {
    return TTSVoice(
      name: data['name'] as String,
      locale: data['locale'] as String,
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'locale': locale};

  bool get isEmpty => name.isEmpty;

  bool get isNotEmpty => name.isNotEmpty;
}
