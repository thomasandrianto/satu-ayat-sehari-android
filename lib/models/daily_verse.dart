class DailyVerse {
  final String id;
  final DateTime devotionDate;
  final String book;
  final int chapter;
  final int verseStart;
  final int? verseEnd;
  final String verseTextEn;
  final String verseTextId;
  final String devotionTitle;
  final String devotionText;
  final String theme;

  DailyVerse({
    required this.id,
    required this.devotionDate,
    required this.book,
    required this.chapter,
    required this.verseStart,
    this.verseEnd,
    required this.verseTextEn,
    required this.verseTextId,
    required this.devotionTitle,
    required this.devotionText,
    required this.theme,
  });

  factory DailyVerse.fromMap(Map<String, dynamic> map) {
    return DailyVerse(
      id: map['id'],
      devotionDate: DateTime.parse(map['devotion_date']),
      book: map['book'],
      chapter: map['chapter'],
      verseStart: map['verse_start'],
      verseEnd: map['verse_end'],
      verseTextEn: map['verse_text_en'],
      verseTextId: map['verse_text_id'],
      devotionTitle: map['devotion_title'] ?? '',
      devotionText: map['devotion_text'],
      theme: map['theme'],
    );
  }

  String get reference {
    if (verseEnd != null && verseEnd != verseStart) {
      return '$book $chapter:$verseStart-$verseEnd';
    }
    return '$book $chapter:$verseStart';
  }
}
