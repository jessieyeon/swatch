// JSON → 화면에 보일 데이터. 저장 · 수정 로직은 없다.
import 'api.dart' show imageUrlOf;

class Reference {
  const Reference({
    required this.id,
    required this.title,
    required this.source,
    required this.imageUrl,
    required this.types,
    required this.reason,
    required this.tags,
    required this.boardId,
    required this.savedAt,
  });

  final String id;
  final String title;
  final String source;
  final String imageUrl;

  /// 유형 — 저장할 때 AI 추천을 눌러 넣거나 직접 쓴 값 (셀프 논증 쟁점 4)
  final List<String> types;

  /// 저장 이유 — 스와치 v2의 핵심 데이터 (P06)
  final String reason;
  final List<String> tags;
  final String boardId;
  final String savedAt;

  factory Reference.fromJson(Map<String, dynamic> json) => Reference(
        id: json['id'] as String,
        title: json['title'] as String,
        source: json['source'] as String? ?? '',
        imageUrl: imageUrlOf(json['imageUrl'] as String? ?? ''),
        types: (json['types'] as List<dynamic>? ?? const []).cast<String>(),
        reason: json['reason'] as String? ?? '',
        tags: (json['tags'] as List<dynamic>? ?? const []).cast<String>(),
        boardId: json['boardId'] as String? ?? '',
        savedAt: json['savedAt'] as String? ?? '',
      );
}

class Board {
  const Board({
    required this.id,
    required this.name,
    required this.description,
    required this.coverUrl,
  });

  final String id;
  final String name;
  final String description;
  final String coverUrl;

  factory Board.fromJson(Map<String, dynamic> json) => Board(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        coverUrl: imageUrlOf(json['coverUrl'] as String? ?? ''),
      );
}
