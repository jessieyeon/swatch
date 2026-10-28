# 스와치 v2

## 앱 소개

### 앱 이름
스와치 v2

### 부제
좋은 디자인을 모으고, 이유를 기록하다

### 카테고리
생산성

### 대상 사용자 / 사용 상황
- 대상 사용자: 디자이너 없이 UI를 직접 짜는 프론트엔드 개발자 — 포스터 · 앱 화면 · 타이포그래피를 참고용으로 모은다
- 사용 상황: 이동 중 폰으로 좋은 디자인을 발견하면 저장하고, 프로젝트를 시작할 때 노트북 · 태블릿에서 다시 꺼내 본다

### 스크린샷
왼쪽부터 v1(현행 Pinterest) → v2. 화면별 전체 캡처는 [docs/screenshots](docs/screenshots).

| v1 현행 | v2 화면 A | v2 화면 B | v2 화면 C | v2 넓은 화면 |
|---|---|---|---|---|
| <img src="docs/screenshots/01_v1_current.jpg" width="140" alt="v1 현행"> | <img src="docs/screenshots/02_v2_a.jpg" width="140" alt="v2 A"> | <img src="docs/screenshots/03_v2_b.jpg" width="140" alt="v2 B"> | <img src="docs/screenshots/04_v2_c.jpg" width="140" alt="v2 C"> | <img src="docs/screenshots/05_v2_wide.jpg" width="260" alt="v2 넓은 화면"> |
| Pinterest 내 보드 (현행) | S-1 보관함 | S-3 저장 시트 | S-6 검색 결과 | S-1 넓은 화면 2단 |

### 설명
1. 포스터 · 웹/앱 디자인 · 타이포그래피 레퍼런스를 모으면서, 어떤 점이 좋았는지 저장 이유를 함께 기록하는 앱이다.
2. 현행 Pinterest는 저장은 쉽지만 다시 찾기 어렵고(저니 감정 최저점 — “찾고 싶은 핀이 어디 있는지 잘 모르겠어요” 2026-08-14 ★5), 내 보드에 추천 · 광고가 끼어들며, 저장한 이유를 남길 곳이 없다.
3. v2의 핵심 가치: 모으고(저장하며 이유 · 태그를 남긴다) · 찾고(이유 · 태그로 다시 찾는다) · 묶는다(프로젝트별 보드로 한 번에 정리한다).

### 새로운 기능
v2에서 바뀐 것 3개 — 원칙 카드(`docs/원칙카드.md`)의 P번호와 연결합니다.

| P번호 | 바뀐 것 (화면 · 요소 번호) | 근거 (리뷰 · 원칙) |
|---|---|---|
| P06 | 저장 시트 S3-3 ‘저장 이유’ · 상세 S2-3 · 보관함 검색 S1-1 → 검색 결과 S6-3에 이유 문장 | “이 사진의 어떤 점이 좋았는지 사진마다 구체적으로 메모를 하고 싶습니다.” ★5 · 2026-01-16 — 기억보다 인식 |
| P08 | 보관함 S1-3 — 내가 저장한 것만 사진으로 (추천 · 광고 없음) | “내가 저장해놓은 사진들 보려고 들어갔는데 왜 more idaes가 먼저 나오는 거죠?” ★3 · 2025-12-08 — 미니멀 디자인 |
| P07 | 보관함 S1-4 선택 모드 · S1-5 정리 액션바 — 여러 개를 한 번에 옮기기 · 지우기 (결과는 화면 표시만) | “여러개 선택되서 지우기 같은 기능이 없는 건가요?” ★5 · 2026-02-15 — 유연성과 효율성 |

## 1. 실행 방법 — 터미널 2개

준비물: Flutter(Dart SDK 3.3 이상), Node.js 18 이상.

**터미널 1 — 목업 서버(json-server)**

```bash
cd mock_server
npm install && npm start                 # http://localhost:3000  (npm run mock 도 같음)
curl http://localhost:3000/references    # 확인: 레퍼런스 20개 JSON 배열이 나오면 성공
```

**터미널 2 — 앱**

```bash
flutter pub get && flutter run    # 저장소 루트(pubspec.yaml 있는 곳)에서
flutter run -d chrome             # 웹으로 볼 때
```

### 상태 화면 시연 — `DEMO_STATE`

```bash
flutter run -d chrome --dart-define=DEMO_STATE=loading   # 2초 로딩 (slow 도 같음)
flutter run -d chrome --dart-define=DEMO_STATE=error     # 오류 + 다시 시도
flutter run -d chrome --dart-define=DEMO_STATE=empty     # 빈 상태
```

## 2. 구조

```
swatch/
├── README.md                 # 실행 방법 [필수]
├── AGENTS.md                 # AI 가드레일 (UI만, GET만) — CLAUDE.md는 이 파일을 따른다는 한 줄
├── pubspec.yaml              # 추가 패키지는 http 하나 · 한글 폰트(Noto Sans KR) 번들
├── lib/
│   ├── main.dart             # 앱 뼈대 · 탭(NavigationBar/Rail) · 테마
│   ├── api.dart              # GET만 · API_BASE · DEMO_STATE
│   ├── models.dart           # JSON → 객체 (Reference · Board)
│   ├── widgets.dart          # LoadingView · ErrorView · EmptyView · 레퍼런스 카드
│   └── screens/
│       ├── library_screen.dart        # S-1 보관함 — GET /references, 3상태, 720 2단 · 840 Rail
│       ├── reference_detail.dart      # S-2 레퍼런스 상세 — 쌓기(push) · 넓은 화면은 오른쪽 2단
│       ├── save_sheet.dart            # S-3 저장 시트 — 덮기(modal), 결과는 SnackBar
│       ├── boards_screen.dart         # S-4 보드 목록 — 탭, 새 보드 대화상자
│       ├── board_detail_screen.dart   # S-5 보드 상세 — 쌓기(push), 빈 보드 안내
│       └── search_result_screen.dart  # S-6 검색 결과 — GET /references?q=
├── test/widget_test.dart     # 3상태 화면 조각(로딩 · 오류→다시 시도 · 빈) 위젯 테스트
├── mock_server/
│   ├── db.json               # [필수] GET 데이터 (references · boards · tags · aiTypeSuggestions)
│   ├── public/images/        # 레퍼런스 이미지 20장
│   ├── package.json          # json-server 0.17.4 고정 · npm start
│   ├── api/index.js · vercel.json   # (가산) 읽기 전용 배포
│   └── README.md
└── docs/
    ├── 디자인가이드.md       # 화면 목록 · 원칙 P01–P10 · 요소 분석 · 가이드 글 · 상태관리 포인트
    ├── 원칙카드.md           # 5칸 양식 (원칙 · 근거 · 적용 · 시연 · 판단) — P06
    ├── prompt-log.md         # 요청 · AI 결과 · 판단 · 이유
    ├── 셀프논증.md           # 셀프 논증 기록: 쟁점 7개
    ├── 자가평가.md           # 공개 배점 그대로 · 근거 위치
    ├── 메뉴구성도.png · 데모시나리오.md
    ├── 영상/                 # 데모 영상은 YouTube 링크(4장 데모 영상 · 배포)
    └── screenshots/          # README 스크린샷 (01_v1_current.jpg …) · 화면별 캡처
```

## 3. 화면 목록 ↔ 기획 문서 요소 번호

![메뉴 구성도](docs/메뉴구성도.png)

| 화면 | 이름 (비즈니스 명칭) | 파일 | 전환 | 요소 번호 |
|---|---|---|---|---|
| S-1 | 보관함 | `lib/screens/library_screen.dart` | 첫 화면 · 탭 | S1-1 ~ S1-12 · A-1 · A-2 |
| S-2 | 레퍼런스 상세 | `lib/screens/reference_detail.dart` | 쌓기(push) · 넓은 화면 2단 | S2-1 ~ S2-7 |
| S-3 | 저장 시트 | `lib/screens/save_sheet.dart` | 덮기(modal) | S3-1 ~ S3-7 |
| S-4 | 보드 목록 | `lib/screens/boards_screen.dart` | 옆으로(탭) | S4-1 ~ S4-4 |
| S-5 | 보드 상세 | `lib/screens/board_detail_screen.dart` | 쌓기(push) | S5-1 ~ S5-4 |
| S-6 | 검색 결과 | `lib/screens/search_result_screen.dart` | 쌓기(push) | S6-1 ~ S6-5 |

## 4. 데모 영상 · 배포

- 데모 영상 1분: https://youtu.be/gx2-YEAUiAY
- 배포 URL: 앱 https://swatch-app-kappa.vercel.app · 데이터(GET만) https://swatch-mockserver.vercel.app
