import 'package:flutter/material.dart';

import '../../app/l10n/l10n.dart';
import '../groups/groups_page.dart';
import '../home/home_page.dart';
import '../maps/maps_page.dart';
import '../record/map_record_page.dart';
import '../you/you_page.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomePage(),
    MapsPage(),
    MapRecordPage(showClose: false),
    GroupsPage(),
    YouPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == _currentIndex) return;
          setState(() => _currentIndex = i);
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            label: context.l10n.appBarHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_outlined),
            label: context.l10n.appBarMaps,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.radio_button_unchecked),
            label: context.l10n.appBarRecord,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.group_outlined),
            label: context.l10n.appBarGroups,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: context.l10n.appBarYou,
          ),
        ],
      ),
    );
  }
}
