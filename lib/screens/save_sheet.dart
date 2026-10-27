// S-3 저장 시트 — 덮기(showModalBottomSheet). 실제 저장(POST · 영구 저장)은 하지 않는다.
// │ S3-1 │ OutlinedButton │ 이미지 또는 링크 추가     │ P02 │
// │ S3-2 │ TextField      │ 저장 이유 한 줄          │ P06 │
// │ S3-3 │ FilterChip     │ 태그 고르기              │ P06 │
// │ S3-4 │ FilterChip     │ 보드 고르기 (전체 목록)   │ P06 │
// │ S3-5 │ FilledButton   │ 저장 → SnackBar (임의 결과) │ P01 │
// │ S3-6 │ CircularProgressIndicator · ErrorView │ 불러오는 중 · 실패 │ P01 · P09 │
import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import '../widgets.dart';

Future<void> showSaveSheet(BuildContext context) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const SaveSheet(),
  );
  if (saved == true && context.mounted) {
    showDemoSnackBar(context, '보관함에 저장했어요 (데모 — 실제로 저장하지 않음)');
  }
}

class SaveSheet extends StatefulWidget {
  const SaveSheet({super.key});

  @override
  State<SaveSheet> createState() => _SaveSheetState();
}

class _SaveSheetState extends State<SaveSheet> {
  late Future<(List<Board>, List<String>)> _future = _load();

  // STATE: 입력한 이유 · 고른 태그 · 고른 보드 → 저장 버튼(S3-5) — v2 이후 상태관리로 구현 (지금은 표시만)
  final _reason = TextEditingController();
  final Set<String> _tags = {};
  String? _boardId;

  Future<(List<Board>, List<String>)> _load() async {
    final boards = await fetchBoards();
    final tags = await fetchTags();
    return (boards, tags);
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: FutureBuilder<(List<Board>, List<String>)>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const SizedBox(height: 240, child: LoadingView(label: '보드를 불러오는 중…'));
          }
          if (snap.hasError) {
            return SizedBox(
              height: 280,
              child: ErrorView(onRetry: () => setState(() => _future = _load())),
            );
          }
          final (boards, tags) = snap.data!;
          _boardId ??= boards.isNotEmpty ? boards.first.id : null;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('레퍼런스 저장', style: t.titleLarge),
                const SizedBox(height: 16),
                // S3-1 이미지 또는 링크 추가 — 사진 선택은 화면만 (실제 업로드 없음)
                OutlinedButton.icon(
                  onPressed: () => showDemoSnackBar(context, '사진 고르기는 데모에서 화면만 보여 줘요'),
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('이미지 또는 링크 추가'),
                ),
                const SizedBox(height: 16),
                // S3-2 저장 이유 한 줄 — P06 저장하는 순간에 이유를 남긴다
                TextField(
                  controller: _reason,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: '저장 이유 한 줄',
                    hintText: '예) 제목 하나만 크게 두고 여백을 과감히 비운 점',
                    helperText: '나중에 이 문장으로 다시 찾을 수 있어요',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                // S3-3 태그 고르기
                Text('태그', style: t.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in tags)
                      FilterChip(
                        label: Text(tag),
                        selected: _tags.contains(tag),
                        onSelected: (v) => setState(() => v ? _tags.add(tag) : _tags.remove(tag)),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // S3-4 보드 고르기 — 최근 2개가 아니라 전체 목록 (P06)
                Text('보드', style: t.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final b in boards)
                      FilterChip(
                        label: Text(b.name),
                        selected: _boardId == b.id,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _boardId = b.id),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                // S3-5 저장 — 결과는 SnackBar로만 (P01)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('저장'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
