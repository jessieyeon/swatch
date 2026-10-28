// 3상태 화면 조각(로딩 · 오류 · 빈) 위젯 테스트 — 네트워크 없이 `flutter test`로 돈다.
// 화면 S-1 · S-4 · S-5 · S-6이 이 조각을 그대로 쓴다 (S1-6 · S4-3 · S5-3 · S5-4 · S6-4 · S6-5).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:swatch_v2/widgets.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('로딩: 진행 표시와 안내 문장 (P01)', (tester) async {
    await tester.pumpWidget(_wrap(const LoadingView()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('불러오는 중…'), findsOneWidget);
  });

  testWidgets('오류: 다시 시도를 누르면 다시 부른다 (P09)', (tester) async {
    var retried = 0;
    await tester.pumpWidget(_wrap(ErrorView(onRetry: () => retried++)));
    expect(find.text('불러오지 못했어요'), findsOneWidget);
    await tester.tap(find.text('다시 시도'));
    expect(retried, 1);
  });

  testWidgets('빈 상태: 제목 · 안내 · 다음 행동 버튼 (P01 · P09)', (tester) async {
    await tester.pumpWidget(_wrap(EmptyView(
      icon: Icons.inbox_outlined,
      title: '보드가 비어 있어요',
      message: '레퍼런스를 저장해 보세요.',
      actions: [FilledButton(onPressed: () {}, child: const Text('레퍼런스 저장'))],
    )));
    expect(find.text('보드가 비어 있어요'), findsOneWidget);
    expect(find.text('레퍼런스 저장'), findsOneWidget);
  });
}
