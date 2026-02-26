import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/daily_verse.dart';
import '../services/favorite_service.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final FavoriteService _service = FavoriteService();

  bool isLoading = true;
  List<DailyVerse> favorites = [];

  static const bg = Color(0xFFF2F6FA);
  static const dark = Color(0xFF2E3A44);
  static const muted = Color(0xFF6B7C8A);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _service.getAllFavorites();
    setState(() {
      favorites = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Ayat Favorit'),
        centerTitle: true,
        backgroundColor: bg,
        foregroundColor: dark,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favorites.isEmpty
          ? const Center(
              child: Text(
                'Belum ada ayat favorit.',
                style: TextStyle(fontSize: 16, color: muted),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, i) {
                return _FavoriteCard(
                  verse: favorites[i],
                  onTap: () =>
                      Navigator.pop(context, favorites[i].devotionDate),
                );
              },
            ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final DailyVerse verse;
  final VoidCallback onTap;

  const _FavoriteCard({required this.verse, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat(
      'EEEE, dd MMM yyyy',
      'id_ID',
    ).format(verse.devotionDate);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(14),
              blurRadius: 22,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7C8A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              verse.reference,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E3A44),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              verse.devotionTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF2E3A44),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF99B6CC).withAlpha(46),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                verse.theme,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E3A44),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
