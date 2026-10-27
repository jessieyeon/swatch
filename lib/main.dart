// 스와치 v2 — 실제 앱 v2의 UI 프로토타입.
// 보이기는 동작하는 것처럼, 실제 동작(저장 · 로그인 · 결제)은 구현하지 않는다.
//
// 화면 목록 (디자인 가이드 · 기획 노트 5단계와 같은 번호)
// │ S-1 │ LibraryScreen      │ 보관함 (홈, 탭)            │
// │ S-2 │ ReferenceDetail    │ 레퍼런스 상세 (쌓기/2단)    │
// │ S-3 │ SaveSheet          │ 저장 시트 (덮기)            │
// │ S-4 │ BoardsScreen       │ 보드 목록 (탭)              │
// │ S-5 │ BoardDetailScreen  │ 보드 상세 (쌓기)            │
// │ S-6 │ SearchResultScreen │ 검색 결과 (쌓기)            │
import 'package:flutter/material.dart';

import 'screens/boards_screen.dart';
import 'screens/library_screen.dart';

void main() => runApp(const SwatchApp());

class SwatchApp extends StatelessWidget {
  const SwatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '스와치',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2F5BD3),
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}

/// 탭 뼈대 — A-1 NavigationBar(폰) · A-2 NavigationRail(창 너비 840 이상) (적응형, P04)
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // 화면 안 표시만 바꾸는 setState (허용) — 선택된 탭
  int _index = 0;

  static const _destinations = [
    (icon: Icons.collections_bookmark_outlined, selected: Icons.collections_bookmark, label: '보관함'),
    (icon: Icons.dashboard_outlined, selected: Icons.dashboard, label: '보드'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = const [LibraryScreen(), BoardsScreen()];
    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 840;
      if (wide) {
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                labelType: NavigationRailLabelType.all,
                leading: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('스와치', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                destinations: [
                  for (final d in _destinations)
                    NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selected),
                      label: Text(d.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: IndexedStack(index: _index, children: pages)),
            ],
          ),
        );
      }
      return Scaffold(
        body: IndexedStack(index: _index, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            for (final d in _destinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selected),
                label: d.label,
              ),
          ],
        ),
      );
    });
  }
}
