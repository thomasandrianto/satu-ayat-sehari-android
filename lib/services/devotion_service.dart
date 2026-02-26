import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/daily_verse.dart';

class DevotionService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<DailyVerse?> getDevotionByDate(DateTime date) async {
    final dateStr = date.toIso8601String().substring(0, 10);

    final data = await _client
        .from('daily_verses')
        .select()
        .eq('devotion_date', dateStr)
        .maybeSingle();

    if (data == null) return null;
    return DailyVerse.fromMap(data);
  }

  Future<List<DailyVerse>> getArchive() async {
    final data = await _client
        .from('daily_verses')
        .select()
        .order('devotion_date', ascending: false);

    return (data as List).map((e) => DailyVerse.fromMap(e)).toList();
  }

  Future<Map<DateTime, DailyVerse>> getArchiveMap() async {
    final data = await _client
        .from('daily_verses')
        .select()
        .order('devotion_date');

    final map = <DateTime, DailyVerse>{};

    for (final item in data) {
      final verse = DailyVerse.fromMap(item);
      final key = DateTime(
        verse.devotionDate.year,
        verse.devotionDate.month,
        verse.devotionDate.day,
      );
      map[key] = verse;
    }

    return map;
  }
}
