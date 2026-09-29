import 'package:flutter/material.dart';

void main() {
  runApp(const ChannelMedManagerApp());
}

class ChannelMedManagerApp extends StatelessWidget {
  const ChannelMedManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChannelMed Manager',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF5F8F7),
      ),
      home: const ChannelMedHome(),
    );
  }
}

class ChannelMedHome extends StatelessWidget {
  const ChannelMedHome({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = <_MenuItem>[
      _MenuItem('භාණ්ඩ තොගය', 'ඖෂධ සහ අනෙකුත් භාණ්ඩ', Icons.inventory_2_outlined),
      _MenuItem('භාණ්ඩ එකතු කරන්න', 'අලුත් ඖෂධ/භාණ්ඩ ඇතුළත් කරන්න', Icons.add_box_outlined),
      _MenuItem('නව බිල්පත', 'ඉක්මනින් බිල්පත් සකසන්න', Icons.receipt_long_outlined),
      _MenuItem('බිල්පත් ඉතිහාසය', 'පැරණි බිල්පත් බලන්න', Icons.history),
      _MenuItem('අඩු තොග / කල් ඉකුත් වීම', 'අවධානය අවශ්‍ය භාණ්ඩ', Icons.warning_amber_outlined),
      _MenuItem('විකුණුම් වාර්තා', 'දෛනික සහ මාසික ආදායම', Icons.bar_chart_outlined),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ChannelMed Manager',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'සැකසුම්',
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [Colors.teal.shade700, Colors.teal.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.local_pharmacy_outlined, color: Colors.white, size: 42),
                  SizedBox(height: 12),
                  Text(
                    'ChannelMed Manager',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Pharmacy Management System',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _StatCard(title: 'මුළු භාණ්ඩ', value: '0', icon: Icons.inventory_2_outlined)),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(title: 'අඩු තොග', value: '0', icon: Icons.warning_amber_outlined)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _StatCard(title: 'අද විකුණුම්', value: 'Rs. 0', icon: Icons.payments_outlined)),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(title: 'අද බිල්පත්', value: '0', icon: Icons.receipt_long_outlined)),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              'ප්‍රධාන කාර්යයන්',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...cards.map((item) => _ActionCard(item: item)),
            const SizedBox(height: 18),
            const Center(
              child: Text(
                'Design by Srimal Harsha',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.teal.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final String subtitle;
  final IconData icon;

  _MenuItem(this.title, this.subtitle, this.icon);
}

class _ActionCard extends StatelessWidget {
  final _MenuItem item;

  const _ActionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(item.icon, color: Colors.teal.shade700),
        ),
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(item.subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
