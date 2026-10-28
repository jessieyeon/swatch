// S-4 보드 목록 (탭) — GET /boards
// │ S4-1 │ AppBar          │ 보드 제목 줄    │ P04 │
// │ S4-2 │ GridView + Card │ 보드 카드 (2열 · 정사각형 커버) │ P02 · P06 │
// │ S4-3 │ CircularProgressIndicator · ErrorView · EmptyView │ 3상태 │ P01 · P09 │
// │ S4-4 │ FloatingActionButton + AlertDialog │ 새 보드 만들기 (화면에만, 저장 없음) │ P03 · P07 │
import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import '../widgets.dart';
import 'board_detail_screen.dart';

class BoardsScreen extends StatefulWidget {
  const BoardsScreen({super.key});

  @override
  State<BoardsScreen> createState() => _BoardsScreenState();
}

class _BoardsScreenState extends State<BoardsScreen> {
  late Future<List<Board>> _future = fetchBoards();

  // STATE: 새로 만든 보드 → S4-2 보드 카드 그리드 — 화면에만 보이고 서버에 저장하지 않는다 (POST 없음)
  // 저장 시트(S3-5)에서 만든 새 보드와는 공유되지 않는다 → v2 이후 상태관리로 한곳에 모을 것
  final List<Board> _newBoards = [];

  void _reload() => setState(() => _future = fetchBoards());

  // S4-4 새 보드 만들기 — 이름 · 설명을 입력하면 그리드 끝에 붙고 SnackBar로 알린다 (임의 결과)
  Future<void> _addBoard() async {
    final name = TextEditingController();
    final description = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 보드'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              autofocus: true,
              decoration: const InputDecoration(labelText: '보드 이름', hintText: '예) 졸업 작품 포트폴리오'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: description,
              decoration: const InputDecoration(labelText: '설명 (선택)', hintText: '예) 첫 화면 · 작품 카드 레이아웃'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('만들기')),
        ],
      ),
    );
    final boardName = name.text.trim();
    if (!mounted || ok != true || boardName.isEmpty) return;
    setState(() {
      _newBoards.add(Board(
        id: 'new-${_newBoards.length + 1}',
        name: boardName,
        description: description.text.trim(),
        coverUrl: '',
      ));
    });
    showDemoSnackBar(context, '‘$boardName’ 보드를 만들었어요 (데모 — 실제로 저장하지 않음)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('보드')),
      // S4-4 새 보드 만들기
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addBoard,
        icon: const Icon(Icons.add),
        label: const Text('새 보드'),
      ),
      body: FutureBuilder<List<Board>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const LoadingView(label: '보드를 불러오는 중…');
          }
          if (snap.hasError) {
            return ErrorView(onRetry: _reload);
          }
          final boards = [...snap.data!, ..._newBoards];
          if (boards.isEmpty) {
            return const EmptyView(
              icon: Icons.dashboard_outlined,
              title: '아직 만든 보드가 없어요',
              message: '프로젝트별로 보드를 만들어 레퍼런스를 묶어 보세요.',
            );
          }
          // S4-2 보드 카드 — 2열 고정, 커버는 정사각형
          return LayoutBuilder(builder: (context, c) {
            const gap = 12.0;
            final cardWidth = (c.maxWidth - 16 * 2 - gap) / 2;
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), // FAB에 가리지 않게
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: gap,
                mainAxisExtent: cardWidth + 68, // 정사각형 커버 + 이름 · 설명 두 줄
              ),
              itemCount: boards.length,
              itemBuilder: (context, i) => _BoardCard(board: boards[i]),
            );
          });
        },
      ),
    );
  }
}

class _BoardCard extends StatelessWidget {
  const _BoardCard({required this.board});
  final Board board;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BoardDetailScreen(board: board)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1, // 정사각형 커버
              child: board.coverUrl.isEmpty
                  ? ColoredBox(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.dashboard_outlined),
                    )
                  : Image.network(
                      board.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black12),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(board.name, style: t.titleSmall),
                  Text(board.description,
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: t.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
