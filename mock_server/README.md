# 목업 서버 (json-server) — 스와치 v2

`db.json`의 데이터를 **GET으로만** 앱에 내려 주는 로컬 서버입니다.
중간고사 안내 5장: json-server에서 `GET`은 **허용**, `POST`/`PUT`/`DELETE` · 저장은 **감점**입니다.

```
mock_server/
├── db.json          # [필수] references 20 · boards 4 · tags 8 · aiTypeSuggestions 2 (개인정보 없음)
├── public/images/   # 레퍼런스 이미지 r01–r20 — json-server가 /images/r01.jpg 로 내려 준다
├── package.json     # json-server 0.17.4 고정 · "npm start" (= "npm run mock")
├── api/index.js     # (가산) Vercel 서버리스 함수 — 읽기 전용 GET
└── vercel.json      # (가산) 모든 경로 → api/index.js
```

## 1. 설치 → 실행 → 확인

Node.js(18 이상)가 필요합니다.

```bash
cd mock_server
npm install      # json-server 0.17.4 (node_modules/는 git에 올리지 않음)
npm start        # = json-server --watch db.json --port 3000 --host 0.0.0.0
```

다른 터미널에서:

```bash
curl http://localhost:3000/references                 # 레퍼런스 20개 — S-1 보관함
curl "http://localhost:3000/references?tags_like=레이아웃" # 태그 칩 — S1-2
curl "http://localhost:3000/references?q=미니멀"          # 검색 — S-6 (제목 · 이유 · 태그에서 찾음)
curl "http://localhost:3000/references?boardId=b3"     # 보드 상세 — S-5
curl http://localhost:3000/boards                     # 보드 4개 — S-4 · S-3
curl http://localhost:3000/aiTypeSuggestions          # 유형 AI 추천(미리 쓴 가짜 응답) — S3-2
```

- 검색 · 태그 필터 · 보드별 목록은 앱이 아니라 json-server의 GET 쿼리(`q` · `tags_like` · `boardId`)가 처리합니다(앱에 검색 로직 없음).
- 쓰기 요청을 아예 막고 싶으면 `npx json-server --watch db.json --port 3000 --host 0.0.0.0 --read-only`.

## 2. `db.json` 바꾸기

- 최상위 키 하나 = 주소 하나 (`"references": [...]` → `/references`).
- 필드를 바꾸면 `lib/models.dart`의 `fromJson`도 같이 바꿉니다.
- 이미지 경로는 `images/r01.jpg`처럼 상대 경로로 쓰고, 앱의 `imageUrlOf()`가 서버 주소를 붙입니다.

## 3. Flutter 앱에서 쓸 주소

| 실행 대상 | 주소 | 앱 설정 |
|---|---|---|
| Chrome(웹) · macOS · iOS 시뮬레이터 | `http://localhost:3000` | 기본값 |
| Android 에뮬레이터 | `http://10.0.2.2:3000` | 기본값 — `lib/api.dart`가 Android면 자동으로 바꾼다 |
| 실기기(폰) | 같은 Wi-Fi PC의 IP | `--dart-define=API_BASE=http://192.168.0.10:3000` |

## 4. CORS (Flutter 웹)

json-server 0.17.4는 기본으로 CORS를 허용합니다(`--no-cors`를 붙이지 마세요).

## 5. (가산) Vercel 배포 — 읽기 전용

`api/index.js`가 `db.json`을 메모리로만 읽고(`jsonServer.router(객체)`), `readOnly: true`로 **GET 외 요청은 403**으로 거절합니다. 이미지(`public/`)도 같은 함수가 내려 줍니다.

1. GitHub 저장소를 vercel.com에서 **Add New → Project**로 Import
2. **Root Directory**를 `mock_server`, Framework Preset은 **Other** → Deploy
3. 확인: https://swatch-mockserver.vercel.app/references
4. 앱 웹 빌드 (저장소 루트에서):

```bash
flutter build web --release --dart-define=API_BASE=https://swatch-mockserver.vercel.app
cd build/web && npx vercel --prod      # → https://swatch-app-kappa.vercel.app
```
