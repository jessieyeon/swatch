// S-2 레퍼런스 상세 — 좁은 화면은 쌓기(push), 넓은 화면은 보관함 오른쪽 2단
// │ S2-1 │ Image        │ 레퍼런스 이미지        │ —   │
// │ S2-2 │ Card         │ 저장 이유             │ P06 │
// │ S2-3 │ Wrap + Chip  │ 태그                  │ P06 │
// │ S2-4 │ ListTile     │ 출처 · 보드 · 저장일   │ P02 │
import 'package:flutter/material.dart';

import '../models.dart';

class ReferenceDetailScreen extends StatelessWidget {
  const ReferenceDetailScreen({super.key, required this.reference});
  final Reference reference;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(reference.title)),
      body: ReferenceDetail(reference: reference),
    );
  }
}

class ReferenceDetail extends StatelessWidget {
  const ReferenceDetail({super.key, required this.reference});
  final Reference reference;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // S2-1 레퍼런스 이미지
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Image.network(
                reference.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: scheme.surfaceContainerHighest,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(reference.title, style: t.titleLarge),
        const SizedBox(height: 12),
        // S2-2 저장 이유 — P06 왜 저장했는지 이미지 바로 아래에서 보인다
        Card(
          elevation: 0,
          color: scheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.edit_note, color: scheme.onPrimaryContainer),
                  const SizedBox(width: 6),
                  Text('저장 이유',
                      style: t.labelLarge?.copyWith(color: scheme.onPrimaryContainer)),
                ]),
                const SizedBox(height: 8),
                Text(
                  reference.reason.isEmpty ? '아직 남긴 이유가 없어요.' : reference.reason,
                  style: t.bodyLarge?.copyWith(color: scheme.onPrimaryContainer),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // S2-3 태그
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final tag in reference.tags) Chip(label: Text('#$tag'))],
        ),
        const SizedBox(height: 8),
        // S2-4 출처 · 보드 · 저장일
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.link),
          title: const Text('출처'),
          subtitle: Text(reference.source),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event_outlined),
          title: const Text('저장한 날'),
          subtitle: Text(reference.savedAt),
        ),
      ],
    );
  }
}
