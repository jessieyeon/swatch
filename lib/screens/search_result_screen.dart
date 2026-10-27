// S-6 검색 결과 (쌓기) — GET /references?q=
// │ S6-1 │ AppBar                     │ ‘검색어’ 검색 결과 제목 줄    │ P01 │
// │ S6-2 │ Text                       │ 찾은 개수                    │ P01 │
// │ S6-3 │ ListView + Card + ListTile │ 검색 결과 항목 (이유 · 태그)  │ P06 │
// │ S6-4 │ EmptyView + ActionChip     │ 결과 없음 + 대안 검색어       │ P09 │
// │ S6-5 │ CircularProgressIndicator · ErrorView │ 찾는 중 · 실패    │ P01 · P09 │
import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import '../widgets.dart';
import 'reference_detail.dart';

class SearchResultScreen extends StatefulWidget {
  const SearchResultScreen({super.key, required this.keyword});
  final String keyword;

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  late Future<List<Reference>> _future = searchReferences(widget.keyword);
  late final Future<List<String>> _tags = fetchTags();

  void _reload() => setState(() => _future = searchReferences(widget.keyword));

  void _searchAgain(String keyword) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SearchResultScreen(keyword: keyword)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text('‘${widget.keyword}’ 검색 결과')),
      body: FutureBuilder<List<Reference>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const LoadingView(label: '저장 이유와 태그에서 찾는 중…');
          }
          if (snap.hasError) {
            return ErrorView(onRetry: _reload);
          }
          final items = snap.data!;
          if (items.isEmpty) {
            // S6-4 결과 없음 + 대안 검색어 — P09 다음 행동을 알려 준다
            return FutureBuilder<List<String>>(
              future: _tags,
              builder: (context, tagSnap) => EmptyView(
                icon: Icons.search_off,
                title: '‘${widget.keyword}’와 맞는 레퍼런스가 없어요',
                message: '저장 이유에 쓴 단어나 아래 태그로 다시 찾아보세요.',
                actions: [
                  for (final tag in tagSnap.data ?? const <String>[])
                    ActionChip(label: Text('#$tag'), onPressed: () => _searchAgain(tag)),
                ],
              ),
            );
          }
          // S6-3 검색 결과 — 이유 문장을 함께 보여 줘서 왜 나왔는지 알 수 있다 (P06)
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              if (i == 0) {
                return Text('${items.length}개를 찾았어요', style: t.labelLarge);
              }
              final r = items[i - 1];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(r.imageUrl,
                        width: 56,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const SizedBox(width: 56, height: 72)),
                  ),
                  title: Text(r.title),
                  subtitle: Text('${r.reason}\n${r.tags.map((e) => '#$e').join(' ')}',
                      maxLines: 3, overflow: TextOverflow.ellipsis),
                  isThreeLine: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ReferenceDetailScreen(reference: r)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
