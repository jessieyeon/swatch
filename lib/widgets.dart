import 'package:flutter/material.dart';

import 'models.dart';

/// S1-6 불러오는 중 — P01 시스템 상태의 가시성
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.label = '불러오는 중…'});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// S1-6 불러오기 실패 + 다시 시도 — P09 오류를 알아보고 복구하도록
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.title = '불러오지 못했어요',
    this.message = '서버(json-server)가 켜져 있는지 확인한 뒤 다시 시도해 주세요.',
    required this.onRetry,
  });
  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(title, style: t.titleMedium),
            const SizedBox(height: 4),
            Text(message, style: t.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}

/// S1-6 · S6-2 빈 상태 — 비어 있다는 사실과 다음 행동을 함께 보여 준다 (P01 · P09)
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actions = const [],
  });
  final IconData icon;
  final String title;
  final String? message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(title, style: t.titleMedium, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: 4),
              Text(message!, style: t.bodyMedium, textAlign: TextAlign.center),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: actions,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// S1-3 레퍼런스 카드 — 이미지 → 저장 이유 한 줄 → 태그 (정보 전달 기준)
/// P08 내가 저장한 것만 보인다(추천 · 광고 없음) · P06 이미지 대신 이유로 기억한다
class ReferenceCard extends StatelessWidget {
  const ReferenceCard({
    super.key,
    required this.reference,
    required this.onTap,
    this.onLongPress,
    this.selectionMode = false,
    this.selected = false,
    this.highlighted = false,
  });

  final Reference reference;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool selectionMode;
  final bool selected;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected || highlighted ? scheme.primary : scheme.outlineVariant,
          width: selected || highlighted ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                      reference.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: scheme.surfaceContainerHighest,
                        child: const Icon(Icons.image_not_supported_outlined),
                      ),
                  ),
                  // S1-4 선택 모드 — 체크 표시
                  if (selectionMode)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: selected ? scheme.primary : scheme.surface,
                        child: Icon(
                          selected ? Icons.check : Icons.circle_outlined,
                          size: 18,
                          color: selected ? scheme.onPrimary : scheme.outline,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reference.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.titleSmall),
                  const SizedBox(height: 2),
                  // 저장 이유 한 줄 미리보기 (P06)
                  Text(reference.reason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodySmall),
                  const SizedBox(height: 6),
                  Text(reference.tags.map((e) => '#$e').join(' '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.labelSmall?.copyWith(color: scheme.primary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 레퍼런스 그리드 — 창 너비에 맞춰 열 개수를 바꾼다 (적응형)
class ReferenceGrid extends StatelessWidget {
  const ReferenceGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
  });
  final List<Reference> items;
  final Widget Function(BuildContext, Reference) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final columns = (c.maxWidth / 220).floor().clamp(2, 5);
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.62,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) => itemBuilder(context, items[i]),
      );
    });
  }
}

void showDemoSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ));
}
