// 스와치 v2 — 서버 연결은 이 파일 한 곳에 모은다.
// 규칙: 로컬 json-server에서 GET만 보낸다. POST·PUT·DELETE·영구 저장 없음.
// 검색 · 태그 필터 · 보드별 목록은 json-server의 GET 쿼리(q, tags_like, boardId)로 처리한다.
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

/// 주소는 실행할 때 넘긴다.
/// Chrome · macOS: 기본값 http://localhost:3000
/// Android 에뮬레이터: --dart-define=API_BASE=http://10.0.2.2:3000
const apiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://localhost:3000',
);

/// 발표 데모용 상태 스위치: slow(2초 로딩) · error(오류) · empty(빈 상태)
/// 예) flutter run -d chrome --dart-define=DEMO_STATE=error
const demoState = String.fromEnvironment('DEMO_STATE');

Future<List<dynamic>> _getList(String path) async {
  if (demoState == 'slow') {
    await Future.delayed(const Duration(seconds: 2));
  }
  if (demoState == 'error') {
    throw Exception('DEMO_STATE=error');
  }
  if (demoState == 'empty') {
    return const [];
  }
  final res = await http
      .get(Uri.parse('$apiBase/$path'))
      .timeout(const Duration(seconds: 3));
  if (res.statusCode != 200) {
    throw Exception('HTTP ${res.statusCode}');
  }
  // 한글이 깨지지 않도록 bytes를 UTF-8로 직접 디코딩한다.
  final decoded = jsonDecode(utf8.decode(res.bodyBytes));
  if (decoded is! List) {
    throw const FormatException('배열이 아닙니다');
  }
  return decoded;
}

/// S-1 보관함: 전체 또는 태그 하나로 거른 레퍼런스 (GET /references?tags_like=)
Future<List<Reference>> fetchReferences({String? tag}) async {
  final query = tag == null
      ? 'references?_sort=savedAt&_order=desc'
      : 'references?tags_like=${Uri.encodeQueryComponent(tag)}&_sort=savedAt&_order=desc';
  final list = await _getList(query);
  return list.map((e) => Reference.fromJson(e as Map<String, dynamic>)).toList();
}

/// S-6 검색 결과: 제목 · 저장 이유 · 태그에서 찾는다 (GET /references?q=)
Future<List<Reference>> searchReferences(String keyword) async {
  final list = await _getList(
      'references?q=${Uri.encodeQueryComponent(keyword)}&_sort=savedAt&_order=desc');
  return list.map((e) => Reference.fromJson(e as Map<String, dynamic>)).toList();
}

/// S-5 보드 상세 (GET /references?boardId=)
Future<List<Reference>> fetchBoardReferences(String boardId) async {
  final list = await _getList(
      'references?boardId=${Uri.encodeQueryComponent(boardId)}&_sort=savedAt&_order=desc');
  return list.map((e) => Reference.fromJson(e as Map<String, dynamic>)).toList();
}

/// S-3 저장 시트 · S-4 보드 목록 (GET /boards)
Future<List<Board>> fetchBoards() async {
  final list = await _getList('boards');
  return list.map((e) => Board.fromJson(e as Map<String, dynamic>)).toList();
}

/// S-1 태그 칩 · S-3 태그 고르기 (GET /tags)
Future<List<String>> fetchTags() async {
  final list = await _getList('tags');
  return list.map((e) => (e as Map<String, dynamic>)['name'] as String).toList();
}
