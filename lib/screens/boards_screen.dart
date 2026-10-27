// S-4 보드 목록 (탭) — GET /boards · 로딩 · 오류 · 빈 상태
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

  void _reload() => setState(() => _future = fetchBoards());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('보드')),
      body: FutureBuilder<List<Board>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const LoadingView(label: '보드를 불러오는 중…');
          }
          if (snap.hasError) {
            return ErrorView(onRetry: _reload);
          }
          final boards = snap.data!;
          if (boards.isEmpty) {
            return const EmptyView(
              icon: Icons.dashboard_outlined,
              title: '아직 만든 보드가 없어요',
              message: '프로젝트별로 보드를 만들어 레퍼런스를 묶어 보세요.',
            );
          }
          return LayoutBuilder(builder: (context, c) {
            final columns = (c.maxWidth / 280).floor().clamp(1, 4);
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
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
            Expanded(
              child: Image.network(
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
