import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/daily_verse.dart';
import '../services/devotion_service.dart';

enum ArchiveViewMode { calendar, list }

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  final DevotionService _service = DevotionService();

  bool isLoading = true;
  String? errorMessage;

  List<DailyVerse> allItems = [];
  ArchiveViewMode _mode = ArchiveViewMode.calendar;

  DateTime _activeMonth = DateTime.now();

  static const backgroundColor = Colors.white;
  static const primaryText = Color(0xFF1F2933);
  static const secondaryText = Color(0xFF4B5563);
  static const accent = Color(0xFF7AA6C2);
  static const softAccentBg = Color(0xFFF3F7FA);

  @override
  void initState() {
    super.initState();
    _loadArchive();
  }

  Future<void> _loadArchive() async {
    try {
      final data = await _service.getArchive();
      setState(() {
        allItems = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Map<String, List<DailyVerse>> get groupedByMonth {
    final map = <String, List<DailyVerse>>{};
    for (final item in allItems) {
      final key = DateFormat('MMMM yyyy', 'id_ID').format(item.devotionDate);
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  Map<int, DailyVerse> get calendarItems {
    final map = <int, DailyVerse>{};
    for (final item in allItems) {
      if (item.devotionDate.year == _activeMonth.year &&
          item.devotionDate.month == _activeMonth.month) {
        map[item.devotionDate.day] = item;
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Arsip Renungan'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: primaryText,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 12),

                _ViewToggle(
                  mode: _mode,
                  onChange: (m) => setState(() => _mode = m),
                ),

                const SizedBox(height: 14),

                if (_mode == ArchiveViewMode.calendar)
                  _MonthHeader(
                    activeMonth: _activeMonth,
                    onPick: _openMonthPicker,
                  ),

                const SizedBox(height: 12),

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _mode == ArchiveViewMode.calendar
                        ? _CalendarView(
                            items: calendarItems,
                            month: _activeMonth,
                            onSelect: (date) => Navigator.pop(context, date),
                          )
                        : _GroupedListView(
                            groups: groupedByMonth,
                            onSelect: (date) => Navigator.pop(context, date),
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  void _openMonthPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return SizedBox(
          height: 300,
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = DateTime(_activeMonth.year, index + 1);
              final isActive = month.month == _activeMonth.month;

              return InkWell(
                onTap: () {
                  setState(() => _activeMonth = month);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isActive ? accent : softAccentBg,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    DateFormat('MMM', 'id_ID').format(month),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : primaryText,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Supporting widgets

class _ViewToggle extends StatelessWidget {
  final ArchiveViewMode mode;
  final ValueChanged<ArchiveViewMode> onChange;

  const _ViewToggle({required this.mode, required this.onChange});

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, ArchiveViewMode m) {
      final active = mode == m;
      return InkWell(
        onTap: () => onChange(m),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: active ? _ArchivePageState.softAccentBg : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(
            icon,
            size: 22,
            color: active
                ? _ArchivePageState.accent
                : _ArchivePageState.secondaryText,
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        button(Icons.calendar_month, ArchiveViewMode.calendar),
        const SizedBox(width: 16),
        button(Icons.view_list_rounded, ArchiveViewMode.list),
      ],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final DateTime activeMonth;
  final VoidCallback onPick;

  const _MonthHeader({required this.activeMonth, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('MMMM yyyy', 'id_ID').format(activeMonth),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _ArchivePageState.primaryText,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.expand_more,
              color: _ArchivePageState.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarView extends StatelessWidget {
  final Map<int, DailyVerse> items;
  final DateTime month;
  final ValueChanged<DateTime> onSelect;

  const _CalendarView({
    required this.items,
    required this.month,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
      ),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        final day = index + 1;
        final verse = items[day];

        final today = DateTime.now();
        final isToday =
            today.year == month.year &&
            today.month == month.month &&
            today.day == day;

        return GestureDetector(
          onTap: verse == null
              ? null
              : () => onSelect(DateTime(month.year, month.month, day)),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isToday
                  ? const Color(0xFF2F6FA8) // versi lebih tua dari accent
                  : verse != null
                  ? _ArchivePageState.accent
                  : _ArchivePageState.softAccentBg, // EMPTY
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: verse != null || isToday
                    ? Colors.white
                    : _ArchivePageState.primaryText,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GroupedListView extends StatelessWidget {
  final Map<String, List<DailyVerse>> groups;
  final ValueChanged<DateTime> onSelect;

  const _GroupedListView({required this.groups, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: groups.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.key,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _ArchivePageState.primaryText,
              ),
            ),
            const SizedBox(height: 12),
            ...entry.value.map(
              (item) => Card(
                elevation: 0,
                color: _ArchivePageState.softAccentBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  title: Text(
                    item.devotionTitle,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(item.reference),
                  trailing: Text(
                    '${item.devotionDate.day}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () => onSelect(item.devotionDate),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        );
      }).toList(),
    );
  }
}
