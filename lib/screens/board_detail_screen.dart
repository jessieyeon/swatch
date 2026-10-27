// S-5 보드 상세 (쌓기) — GET /references?boardId= · 로딩 · 오류 · 빈 상태
import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import '../widgets.dart';
import 'reference_detail.dart';
import 'save_sheet.dart';

class BoardDetailScreen extends StatefulWidget {
  const BoardDetailScreen({super.key, required this.board});
  final Board board;

  @override
  State<BoardDetailScreen> createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends State<BoardDetailScreen> {
  late Future<List<Reference>> _future = fetchBoardReferences(widget.board.id);

  void _reload() => setState(() => _future = fetchBoardReferences(widget.board.id));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.board.name)),
      body: FutureBuilder<List<Reference>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const LoadingView(label: '보드를 여는 중…');
          }
          if (snap.hasError) {
            return ErrorView(onRetry: _reload);
          }
          final items = snap.data!;
          if (items.isEmpty) {
            return EmptyView(
              icon: Icons.inbox_outlined,
              title: '‘${widget.board.name}’ 보드가 비어 있어요',
              message: '보관함에서 레퍼런스를 길게 눌러 이 보드로 옮기거나, 새로 저장해 보세요.',
              actions: [
                FilledButton.icon(
                  onPressed: () => showSaveSheet(context),
                  icon: const Icon(Icons.add),
                  label: const Text('레퍼런스 저장'),
                ),
              ],
            );
          }
          return ReferenceGrid(
            items: items,
            itemBuilder: (context, r) => ReferenceCard(
              reference: r,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ReferenceDetailScreen(reference: r)),
              ),
            ),
          );
        },
      ),
    );
  }
}
