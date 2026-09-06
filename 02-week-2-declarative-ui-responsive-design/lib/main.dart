import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

const double kWideBreakpoint = 700;

void main() => runApp(const DashboardApp());

class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: DashboardPage(
        isDark: isDark,
        onDarkChanged: (value) => setState(() => isDark = value),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.isDark,
    required this.onDarkChanged,
    super.key,
  });
  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Student Dashboard',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          Row(
            children: [
              ExcludeSemantics(
                child: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 4),
              Semantics(
                label: 'Aktifkan mode gelap',
                child: CupertinoSwitch(
                  value: isDark,
                  onChanged: onDarkChanged,
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Menghitung area yang tersedia (lebar layar dikurangi padding kiri-kanan 16)
          final availableWidth = constraints.maxWidth - 32;

          // Logika responsif: Jika layar lebar (>= kWideBreakpoint), bagi ruang untuk 2 kolom
          // dikurangi 16 untuk spacing di tengah. Jika kecil, pakai full width.
          final isWideScreen = constraints.maxWidth >= kWideBreakpoint;
          final cardWidth = isWideScreen
              ? (availableWidth - 16) / 2
              : availableWidth;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 16, // Jarak horizontal antar kartu
              runSpacing: 16, // Jarak vertikal antar baris
              children: [
                InfoCard(title: 'Assignments', value: '8', width: cardWidth),
                InfoCard(title: 'Attendance', value: '92%', width: cardWidth),
                InfoCard(title: 'Portfolio', value: 'Ready', width: cardWidth),
                InfoCard(title: 'Current week', value: '02', width: cardWidth),
              ],
            ),
          );
        },
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.title,
    required this.value,
    this.width,
    super.key,
  });

  final String title;
  final String value;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SizedBox(
      width: width,
      child: Card(
        color: colorScheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                value,
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
