# 일정관리 프로그램 개요 (Flutter + 백엔드)

## 목표
- **Flutter 기반 프론트엔드**로 모바일(iOS/Android)과 웹을 동시에 지원합니다.
- **사내 시스템 연동 없이** 자체 ID/PW 인증 및 조직(부서/직급) 관리가 가능한 구조를 전제로 합니다.

## 권장 백엔드 스택
- **NestJS (TypeScript) + PostgreSQL + Redis**
  - 이유: 역할/권한, 스케줄 반복 규칙, 알림 큐 처리 등 복잡한 도메인 로직에 적합하며, TypeScript로 Flutter/Dart와의 타입 연계도 용이합니다.
  - 알림 처리: Redis 기반 큐(BullMQ) + 워커로 지연 알림 및 마감 임박 알림을 안정적으로 전송합니다.

## 핵심 기능 요구사항 요약
- 부서/직급 기반 사용자 관리 (ID/PW)
- 일정 등록 시 상위 직급에게 자동 알림
- 일정 완료(해소) 처리 및 상위 직급에게 해소 알림
- 해소되지 않은 일정은 굵은 글자/빨간색 등으로 강조 표시
- 일정 유형: 일일/주간/월간/분기/반기/연간
- 반복 일정 개별 등록 지원
- 마감 임박 알림: 3시간/2시간/1시간 전 등 다중 알림
- 마감 알림은 등록자와 **사전 설정된 상급자**에게 동시 발송

## 데이터 모델(초안)

### 사용자/조직
- **Department**: `id`, `name`, `parent_department_id?`
- **Role**: `id`, `title`, `rank_level` (높을수록 상위 직급)
- **User**: `id`, `email`, `password_hash`, `name`, `department_id`, `role_id`, `status`

### 일정
- **Schedule**
  - `id`, `title`, `description`, `owner_id`, `department_id`
  - `type` (daily/weekly/monthly/quarterly/halfyearly/yearly)
  - `start_at`, `end_at`, `due_at`, `status` (open/resolved/overdue)
  - `importance` (normal/critical)
- **ScheduleRecurrence**
  - `id`, `schedule_id`, `rule` (RRULE 또는 커스텀 규칙), `exceptions`
- **ScheduleAssignment**
  - 일정의 **알림 수신자**(등록자/상급자) 설정을 명시
  - `schedule_id`, `user_id`, `notify_on_create`, `notify_on_due`, `notify_on_resolve`

### 알림
- **Notification**
  - `id`, `user_id`, `schedule_id`, `type` (created/due_3h/due_2h/due_1h/resolved)
  - `sent_at`, `channel` (push/email/in-app)

## 주요 동작 흐름

### 1) 일정 등록
1. 사용자가 일정 등록
2. **상위 직급 사용자 자동 탐색** (같은 부서 기준)
3. 등록 알림을 등록자 + 상급자에게 발송

### 2) 일정 해소(완료)
1. 등록자가 완료 처리
2. 상태 `resolved`로 변경
3. 등록자 + 상급자에게 해소 알림 발송

### 3) 마감 임박 알림
- 일정의 `due_at` 기준으로 **3시간/2시간/1시간 전** 알림 예약
- 등록자 + 사전에 정해진 상급자에게 동시 발송

### 4) 미해소 일정 강조 표시
- `status=open` 상태에서 `due_at` 경과 시 `overdue`로 업데이트
- 프론트에서 **굵은 글자/빨간색** 등으로 강조

## 백엔드 구현 포인트
- **상위 직급 탐색**: `rank_level`이 더 높은 사용자 중 같은 부서의 리더를 선택
- **알림 예약/발송**: Redis 큐 + 워커로 지연 전송
- **반복 일정**: RRULE 기반(또는 주기 타입)으로 인스턴스 생성
- **권한**: 일정 등록자/부서 관리자/상급자에 따른 접근 제어

## Flutter 프론트 구현 포인트
- 일정 리스트는 `status`/`due_at`/`type` 필터 지원
- 미해소 일정은 **빨간색/굵은 텍스트 강조**
- 알림 수신 설정 UI (상급자 지정)
- 일정 완료(해소) 체크 UI 제공

## 향후 확장 가능 영역
- 사내 SSO/그룹웨어 연동
- 캘린더 외부 연동(Outlook/Google)
- 감사 로그 및 변경 이력
