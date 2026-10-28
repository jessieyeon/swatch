// Vercel 배포용 목업 서버 — 로컬 json-server와 같은 db.json을 GET으로만 내려 준다.
// readOnly: true → POST · PUT · PATCH · DELETE는 json-server가 403으로 막는다 (영구 저장 없음).
const path = require('path');
const fs = require('fs');
const jsonServer = require('json-server');

const root = path.join(__dirname, '..');
const db = JSON.parse(fs.readFileSync(path.join(root, 'db.json'), 'utf8'));

const server = jsonServer.create();
server.use(jsonServer.defaults({ readOnly: true, static: path.join(root, 'public') }));
server.use(jsonServer.router(db)); // 메모리에서만 읽음, 파일에 쓰지 않음

module.exports = server;
