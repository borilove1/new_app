# Frontend (Flutter)

## 로컬 실행

```bash
cd apps/frontend
flutter pub get
flutter run -d chrome
```

> Android 에뮬레이터에서 백엔드가 로컬일 경우 `http://10.0.2.2:3000`로 변경이 필요합니다.

## 화면 구성
- 로그인 화면
- 로그인 성공 후 홈 화면 이동
- 홈 화면에서 `백엔드 연결 테스트` 버튼으로 `/health` 호출
