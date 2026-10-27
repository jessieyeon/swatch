// JSON → 화면에 보일 데이터. 저장 · 수정 로직은 없다.

class Reference {
  const Reference({
    required this.id,
    required this.title,
    required this.source,
    required this.imageUrl,
    required this.reason,
    required this.tags,
    required this.boardId,
    required this.savedAt,
  });

  final String id;
  final String title;
  final String source;
  final String imageUrl;

  /// 저장 이유 — 스와치 v2의 핵심 데이터 (P06)
  final String reason;
  final List<String> tags;
  final String boardId;
  final String savedAt;

  factory Reference.fromJson(Map<String, dynamic> json) => Reference(
        id: json['id'] as String,
        title: json['title'] as String,
        source: json['source'] as String? ?? '',
        imageUrl: json['imageUrl'] as String,
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
        coverUrl: json['coverUrl'] as String? ?? '',
      );
}
