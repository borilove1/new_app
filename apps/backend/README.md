# Backend (NestJS)

## 로컬 실행

```bash
cd apps/backend
cp ../../.env.example .env
npm install
npx prisma generate
npx prisma migrate dev
npx prisma db seed
npm run start:dev
```

- 기본 포트: `http://localhost:3000`
- 헬스체크: `GET /health`
- 인증:
  - `POST /auth/register`
  - `POST /auth/login`

## 시드 계정
- 리더: `leader@company.com` / `password123`
- 멤버: `member@company.com` / `password123`

## 참고
- Prisma 기반 PostgreSQL 스키마
- Redis 연결은 서비스에만 설정되어 있으며 큐/워커는 stub 상태입니다.
