// S-1 보관함 (홈)
// │ S1-1 │ SearchBar                         │ 보관함 검색       │ P06 │
// │ S1-2 │ FilterChip 목록                    │ 태그 칩           │ P06 │
// │ S1-3 │ GridView + Card                    │ 레퍼런스 카드      │ P08 │
// │ S1-4 │ 길게 누르기 + 체크 표시             │ 선택 모드         │ P07 │
// │ S1-5 │ BottomAppBar                      │ 정리 액션바        │ P07 · P03 │
// │ S1-6 │ LoadingView · ErrorView · EmptyView │ 3상태            │ P01 · P09 │
// │ S1-7 │ FloatingActionButton              │ 레퍼런스 저장 (+)  │ — │
import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import '../widgets.dart';
import 'reference_detail.dart';
import 'save_sheet.dart';
import 'search_result_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  // STATE: 선택한 태그 → 레퍼런스 그리드(S1-3) 다시 불러오기 — 지금은 setState로 화면 표시만
  String? _tag;
  late Future<List<Reference>> _future = fetchReferences();
  late final Future<List<String>> _tags = fetchTags();

  // STATE: 선택 모드 · 선택 목록 → 정리 액션바(S1-5) — v2 이후 상태관리로 구현 (지금은 표시만)
  final Set<String> _selected = {};
  bool get _selecting => _selected.isNotEmpty;

  // STATE: 넓은 화면에서 오른쪽 2단에 보여 줄 레퍼런스
  Reference? _focused;

  final _searchController = TextEditingController();

  void _reload() => setState(() => _future = fetchReferences(tag: _tag));

  void _selectTag(String? tag) {
    setState(() {
      _tag = tag;
      _future = fetchReferences(tag: tag);
    });
  }

  void _toggle(Reference r) {
    setState(() {
      if (!_selected.remove(r.id)) _selected.add(r.id);
    });
  }

  void _openSearch(String keyword) {
    if (keyword.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchResultScreen(keyword: keyword.trim())),
    );
  }

  void _open(Reference r, bool wide) {
    if (_selecting) {
      _toggle(r);
      return;
    }
    if (wide) {
      setState(() => _focused = r);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ReferenceDetailScreen(reference: r)),
      );
    }
  }

  // S1-5 보드로 옮기기 — 보드 목록(GET /boards)에서 고르면 SnackBar로만 결과를 보여 준다 (임의 결과)
  Future<void> _moveToBoard() async {
    final count = _selected.length;
    final board = await showModalBottomSheet<Board>(
      context: context,
      showDragHandle: true,
      builder: (context) => FutureBuilder<List<Board>>(
        future: fetchBoards(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const SizedBox(height: 200, child: LoadingView(label: '보드를 불러오는 중…'));
          }
          if (snap.hasError) {
            return SizedBox(
              height: 240,
              child: ErrorView(onRetry: () => Navigator.pop(context)),
            );
          }
          final boards = snap.data!;
          return ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text('$count개를 옮길 보드',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              for (final b in boards)
                ListTile(
                  leading: const Icon(Icons.dashboard_outlined),
                  title: Text(b.name),
                  subtitle: Text(b.description),
                  onTap: () => Navigator.pop(context, b),
                ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
    if (!mounted || board == null) return;
    setState(_selected.clear);
    showDemoSnackBar(context, '$count개를 ‘${board.name}’ 보드로 옮겼어요 (데모 — 실제로 저장하지 않음)');
  }

  // S1-5 삭제 — 확인 대화상자 후 SnackBar로만 결과를 보여 준다 (P03 · P05)
  Future<void> _delete() async {
    final count = _selected.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('레퍼런스 $count개를 지울까요?'),
        content: const Text('지운 레퍼런스의 저장 이유와 태그도 함께 사라져요.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('지우기')),
        ],
      ),
    );
    if (!mounted || ok != true) return;
    setState(_selected.clear);
    showDemoSnackBar(context, '$count개를 지웠어요 (데모 — 실제로 지우지 않음)');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 720; // 넓은 화면: 목록 + 상세 2단
      final list = _buildList(wide);
      return Scaffold(
        appBar: _selecting
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: '선택 취소',
                  onPressed: () => setState(_selected.clear),
                ),
                title: Text('${_selected.length}개 선택'),
              )
            : AppBar(title: const Text('보관함')),
        body: wide
            ? Row(
                children: [
                  Expanded(flex: 3, child: list),
                  const VerticalDivider(width: 1),
                  Expanded(
                    flex: 2,
                    child: _focused == null
                        ? const EmptyView(
                            icon: Icons.touch_app_outlined,
                            title: '레퍼런스를 고르면 여기에 저장 이유가 보여요',
                          )
                        : ReferenceDetail(reference: _focused!),
                  ),
                ],
              )
            : list,
        // S1-7 레퍼런스 저장 (+) → S-3 저장 시트
        floatingActionButton: _selecting
            ? null
            : FloatingActionButton.extended(
                onPressed: () => showSaveSheet(context),
                icon: const Icon(Icons.add),
                label: const Text('저장'),
              ),
        // S1-5 정리 액션바
        bottomNavigationBar: _selecting
            ? BottomAppBar(
                child: Row(
                  children: [
                    Text('${_selected.length}개 선택됨'),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _moveToBoard,
                      icon: const Icon(Icons.drive_file_move_outline),
                      label: const Text('보드로 옮기기'),
                    ),
                    TextButton.icon(
                      onPressed: _delete,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('삭제'),
                    ),
                  ],
                ),
              )
            : null,
      );
    });
  }

  Widget _buildList(bool wide) {
    return Column(
      children: [
        // S1-1 보관함 검색 — P06 이미지 대신 이유 · 태그로 찾는다
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: SearchBar(
            controller: _searchController,
            hintText: '저장 이유나 태그로 찾기 (예: 여백, 그리드)',
            leading: const Icon(Icons.search),
            onSubmitted: _openSearch,
            trailing: [
              IconButton(
                tooltip: '검색',
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => _openSearch(_searchController.text),
              ),
            ],
          ),
        ),
        // S1-2 태그 칩 — P06 태그를 기억하지 않고 고른다
        SizedBox(
          height: 48,
          child: FutureBuilder<List<String>>(
            future: _tags,
            builder: (context, snap) {
              final tags = snap.data ?? const <String>[];
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('전체'),
                      selected: _tag == null,
                      onSelected: (_) => _selectTag(null),
                    ),
                  ),
                  for (final t in tags)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(t),
                        selected: _tag == t,
                        onSelected: (_) => _selectTag(_tag == t ? null : t),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Reference>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const LoadingView(label: '보관함을 불러오는 중…'); // S1-6 P01
              }
              if (snap.hasError) {
                return ErrorView(onRetry: _reload); // S1-6 P09
              }
              final items = snap.data!;
              if (items.isEmpty) {
                // S1-6 빈 상태 — P01 · P09
                return EmptyView(
                  icon: Icons.collections_bookmark_outlined,
                  title: _tag == null ? '아직 모은 레퍼런스가 없어요' : '‘$_tag’ 태그의 레퍼런스가 없어요',
                  message: '마음에 드는 디자인을 저장하면서 좋은 이유를 한 줄 남겨 보세요.',
                  actions: [
                    FilledButton.icon(
                      onPressed: () => showSaveSheet(context),
                      icon: const Icon(Icons.add),
                      label: const Text('첫 레퍼런스 저장'),
                    ),
                    if (_tag != null)
                      OutlinedButton(
                        onPressed: () => _selectTag(null),
                        child: const Text('전체 보기'),
                      ),
                  ],
                );
              }
              // S1-3 레퍼런스 카드 — P08 내가 저장한 것만 (추천 · 광고 없음)
              return ReferenceGrid(
                items: items,
                itemBuilder: (context, r) => ReferenceCard(
                  reference: r,
                  selectionMode: _selecting,
                  selected: _selected.contains(r.id),
                  highlighted: wide && _focused?.id == r.id,
                  onTap: () => _open(r, wide),
                  onLongPress: () => _toggle(r), // S1-4 선택 모드 — P07
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
