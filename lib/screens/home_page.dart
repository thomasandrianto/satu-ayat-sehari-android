import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/daily_verse.dart';
import '../services/devotion_service.dart';
import '../services/favorite_service.dart';
import '../services/fcm_service.dart';
import 'archive_page.dart';
import 'favorite_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DevotionService _service = DevotionService();
  final FavoriteService _favoriteService = FavoriteService();

  DailyVerse? devotion;
  bool isLoading = true;
  String? errorMessage;
  bool isFavorite = false;

  DateTime currentDate = DateTime.now();

  static const backgroundColor = Colors.white;
  static const primaryText = Color(0xFF1F2933);
  static const secondaryText = Color(0xFF4B5563);
  static const accent = Color(0xFF7AA6C2);
  static const softAccentBg = Color(0xFFF3F7FA);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FcmService().initFCM();
    });

    _loadDevotion(currentDate);
  }

  Future<void> _loadDevotion(DateTime date) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await _service.getDevotionByDate(date);
      bool fav = false;
      if (result != null) {
        fav = await _favoriteService.isFavorite(result.id);
      }
      setState(() {
        devotion = result;
        currentDate = date;
        isFavorite = fav;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _toggleFavorite() async {
    if (devotion == null) return;
    final id = devotion!.id;
    if (isFavorite) {
      await _favoriteService.removeFavorite(id);
    } else {
      await _favoriteService.addFavorite(devotion!);
    }
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  void _goToPrevDay() {
    _loadDevotion(currentDate.subtract(const Duration(days: 1)));
  }

  void _goToNextDay() {
    final tomorrow = currentDate.add(const Duration(days: 1));
    if (tomorrow.isAfter(DateTime.now())) return;
    _loadDevotion(tomorrow);
  }

  String _formatDate(DateTime date) {
    const days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // =======================
  // INFO BOTTOM SHEET
  // =======================
  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(40, 0, 0, 0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              'Tentang Renungan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: primaryText,
              ),
            ),

            const SizedBox(height: 18),

            // Main description
            Text(
              'Renungan harian dalam aplikasi ini disusun dengan bantuan '
              'teknologi kecerdasan buatan sebagai alat bantu refleksi.\n\n'
              'Firman Tuhan tetap menjadi pusat, dan setiap pembaca diajak '
              'untuk merenung, berdoa, serta menimbangnya secara pribadi.\n\n'
              'Renungan ini bersifat non-institusional dan tidak mewakili '
              'pandangan resmi gereja, lembaga, atau denominasi mana pun.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.75,
                color: secondaryText,
              ),
            ),

            const SizedBox(height: 28),

            // Divider
            const Divider(color: Color.fromARGB(20, 0, 0, 0), height: 1),

            const SizedBox(height: 16),

            // Copyright
            Center(
              child: Text(
                '© 2026 Thomas Andrianto\n'
                'Disusun sebagai refleksi pribadi',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: const Color.fromARGB(165, 0, 0, 0),
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < -300) {
          _goToNextDay();
        } else if (details.primaryVelocity! > 300) {
          _goToPrevDay();
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: 'archive',
              backgroundColor: accent,
              child: const Icon(Icons.calendar_month),
              onPressed: () async {
                final pickedDate = await Navigator.push<DateTime>(
                  context,
                  MaterialPageRoute(builder: (_) => const ArchivePage()),
                );
                if (pickedDate != null) _loadDevotion(pickedDate);
              },
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'favorite',
              backgroundColor: accent,
              child: const Icon(Icons.favorite),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritePage()),
                );
                _loadDevotion(currentDate);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(theme),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red),
        ),
      );
    }

    if (devotion == null) {
      return const Center(child: Text('Ayat untuk tanggal ini belum tersedia'));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Stack(
        key: ValueKey(currentDate.toIso8601String()),
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  Center(
                    child: Image.asset(
                      'assets/images/logo_app.png',
                      width: 88,
                    ).animate().fade(duration: 600.ms),
                  ),

                  const SizedBox(height: 18),

                  Center(
                    child: Text(
                      'SATU AYAT SEHARI',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                        color: primaryText,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Center(
                    child: _DateIndicator(
                      date: currentDate,
                      formatter: _formatDate,
                    ),
                  ),

                  const SizedBox(height: 22),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _toggleFavorite,
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: accent,
                          size: 32,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Text(
                    devotion!.reference,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),

                  const SizedBox(height: 22),

                  _VerseCard(text: devotion!.verseTextEn),

                  const SizedBox(height: 52),

                  const _SectionTitle(title: 'Terjemahan'),

                  const SizedBox(height: 18),

                  Text(
                    devotion!.verseTextId,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 22,
                      height: 1.9,
                      color: primaryText,
                    ),
                  ),

                  const SizedBox(height: 60),

                  _SectionTitle(title: devotion!.devotionTitle),

                  const SizedBox(height: 18),

                  Text(
                    devotion!.devotionText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 21,
                      height: 2.0,
                      color: primaryText,
                    ),
                  ),

                  const SizedBox(height: 90),
                  const _SwipeHint(),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),

          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.info_sharp),
              color: accent.withAlpha(160),
              onPressed: () => _showAboutSheet(context),
            ),
          ),
        ],
      ),
    );
  }
}

// Supporting widgets
class _DateIndicator extends StatelessWidget {
  final DateTime date;
  final String Function(DateTime) formatter;

  const _DateIndicator({required this.date, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(date, DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: _HomePageState.softAccentBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isToday ? 'Hari ini • ${formatter(date)}' : formatter(date),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _HomePageState.secondaryText,
        ),
      ),
    );
  }
}

class _VerseCard extends StatelessWidget {
  final String text;
  const _VerseCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 23,
          height: 1.75,
          fontWeight: FontWeight.w500,
          color: _HomePageState.primaryText,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 34,
          decoration: BoxDecoration(
            color: _HomePageState.accent,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: _HomePageState.primaryText,
            ),
          ),
        ),
      ],
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: _HomePageState.softAccentBg,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.chevron_left, color: _HomePageState.accent),
            SizedBox(width: 8),
            Text(
              'Geser untuk hari lain',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _HomePageState.secondaryText,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.chevron_right, color: _HomePageState.accent),
          ],
        ),
      ).animate().fade(delay: 900.ms).slideY(begin: 0.2),
    );
  }
}
