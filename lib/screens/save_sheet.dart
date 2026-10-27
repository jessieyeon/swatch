// S-3 저장 시트 — 덮기(showModalBottomSheet). 실제 저장(POST · 영구 저장)은 하지 않는다.
// │ S3-1 │ OutlinedButton          │ 이미지 또는 링크 추가          │ P02 │
// │ S3-2 │ ActionChip + TextField  │ 유형 (AI 추천 + 입력칸)         │ P06 · P03 │
// │ S3-3 │ TextField               │ 저장 이유 (길이 제한 없음)      │ P06 │
// │ S3-4 │ FilterChip + ActionChip │ 태그 고르기 · 새 태그 (AlertDialog) │ P06 · P07 │
// │ S3-5 │ FilterChip + ActionChip │ 보드 고르기 (전체 목록) · 새 보드   │ P06 · P07 │
// │ S3-6 │ FilledButton            │ 저장 → SnackBar (임의 결과)    │ P01 │
// │ S3-7 │ CircularProgressIndicator · ErrorView │ 불러오는 중 · 실패 │ P01 · P09 │
// AI 추천은 실제 이미지 분석이 아니라 db.json에 미리 써 둔 가짜 응답을 GET으로 받아 보여 준다 (셀프 논증 쟁점 4).
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
  late Future<(List<Board>, List<String>, List<String>)> _future = _load();

  // STATE: 입력한 유형 · 이유 · 고른 태그 · 고른 보드 → 저장 버튼(S3-6) — v2 이후 상태관리로 구현 (지금은 표시만)
  final _type = TextEditingController();
  final _reason = TextEditingController();
  final Set<String> _tags = {};
  String? _boardId;

  // STATE: 저장 시트에서 새로 만든 태그 · 보드 → S3-4 · S3-5 칩 목록 — 화면에만 보이고 서버에 저장하지 않는다 (POST 없음)
  final List<String> _newTags = [];
  final List<Board> _newBoards = [];

  // 새 태그 · 새 보드 이름 입력 창 (AlertDialog)
  Future<String?> _askName(String title, String hint) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: hint),
          onSubmitted: (v) => Navigator.pop(context, v.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('만들기'),
          ),
        ],
      ),
    );
  }

  Future<void> _addTag() async {
    final name = await _askName('새 태그', '예) 랜딩, 카드 UI');
    if (!mounted || name == null || name.isEmpty) return;
    setState(() {
      if (!_newTags.contains(name)) _newTags.add(name);
      _tags.add(name);
    });
  }

  Future<void> _addBoard() async {
    final name = await _askName('새 보드', '예) 졸업 작품 포트폴리오');
    if (!mounted || name == null || name.isEmpty) return;
    final board = Board(id: 'new-${_newBoards.length + 1}', name: name, description: '', coverUrl: '');
    setState(() {
      _newBoards.add(board);
      _boardId = board.id;
    });
  }

  Future<(List<Board>, List<String>, List<String>)> _load() async {
    final boards = await fetchBoards();
    final tags = await fetchTags();
    // AI 추천 유형 — GET /aiTypeSuggestions (쟁점 4: AI는 제안만, 확정은 사용자)
    final suggestedTypes = await fetchTypeSuggestions();
    return (boards, tags, suggestedTypes);
  }

  @override
  void dispose() {
    _type.dispose();
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
      child: FutureBuilder<(List<Board>, List<String>, List<String>)>(
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
          final (boards, tags, suggestedTypes) = snap.data!;
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
                // S3-2 유형 — AI는 추천만 하고, 사용자가 눌러서 넣거나 직접 고친다 (P06 · P03)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('추천:', style: t.labelLarge),
                    for (final type in suggestedTypes)
                      ActionChip(
                        avatar: const Icon(Icons.auto_awesome, size: 16),
                        label: Text(type),
                        onPressed: () => setState(() {
                          final current = _type.text.trim();
                          if (current.split(', ').contains(type)) return;
                          _type.text = current.isEmpty ? type : '$current, $type';
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _type,
                  decoration: const InputDecoration(
                    labelText: '유형',
                    hintText: '예) 포스터, PPT, 타이포그래피',
                    helperText: '추천을 누르거나 직접 써 주세요',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // S3-3 저장 이유 — P06 저장하는 순간에 이유를 남긴다 (길이 제한 없이 여러 줄)
                TextField(
                  controller: _reason,
                  minLines: 2,
                  maxLines: 6,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    labelText: '저장 이유',
                    hintText: '예) 제목 하나만 크게 두고 여백을 과감히 비운 점',
                    helperText: '나중에 이 문장으로 다시 찾을 수 있어요',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                // S3-4 태그 고르기
                Text('태그', style: t.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in [...tags, ..._newTags])
                      FilterChip(
                        label: Text(tag),
                        selected: _tags.contains(tag),
                        onSelected: (v) => setState(() => v ? _tags.add(tag) : _tags.remove(tag)),
                      ),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: const Text('새 태그'),
                      onPressed: _addTag,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // S3-5 보드 고르기 — 최근 2개가 아니라 전체 목록 (P06)
                Text('보드', style: t.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final b in [...boards, ..._newBoards])
                      FilterChip(
                        label: Text(b.name),
                        selected: _boardId == b.id,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _boardId = b.id),
                      ),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: const Text('새 보드'),
                      onPressed: _addBoard,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // S3-6 저장 — 결과는 SnackBar로만 (P01)
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
