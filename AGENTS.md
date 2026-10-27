# AGENTS.md — 스와치 v2 UI 프로토타입 규칙

목적: 실제 앱 v2의 UI 프로토타입 — 보이기는 동작하는 것처럼, 실제 동작은 구현하지 않는다.
Claude Code · Cursor · Copilot이 함께 읽는다. 규칙 파일은 참고일 뿐이므로 제출 전 grep 점검은 사람이 한다.

## MUST
- 화면 전환은 Navigator.push / pop · NavigationBar(Rail) · showModalBottomSheet · showDialog
- 데이터는 로컬 json-server의 GET만 (`lib/api.dart` 한 파일). 주소는 `--dart-define=API_BASE`로 넘긴다
- GET 화면은 로딩 · 오류 · 빈 상태를 모두 그린다 (FutureBuilder)
- 창 너비로 레이아웃 분기 (LayoutBuilder): 720↑ 목록+상세 2단, 840↑ NavigationRail
- 화면 안 변화(탭 · 칩 선택 · 선택 모드)는 setState만
- 이름은 기획 노트 5단계 · 디자인 가이드의 비즈니스 명칭과 요소 번호(S1-3 등)에 맞춘다
- 저장 · 옮기기 · 삭제 버튼은 SnackBar로 결과만 보여 준다 (임의 결과)
- 상태가 바뀌는 곳은 `// STATE:` 주석만 남긴다

## MUST NOT (감점)
- http.post / put / patch / delete
- 로그인 · 회원가입 · 결제 · 인증 로직
- shared_preferences · sqflite · hive · 파일 쓰기 (영구 저장)
- provider · riverpod · flutter_bloc 등 상태관리 패키지
- 실제 계산 · 추천 알고리즘 · 앱 안의 검색 로직 (검색은 json-server `?q=`로)
- 기획 노트에 없는 화면
- 외부 유료 API · LLM API · 실제 개인정보

## 작업 방식
- 한 번에 화면 하나 · 위젯 트리를 먼저 보여 준다
- 패키지를 추가하기 전에 이유를 말하고 사람에게 확인한다
