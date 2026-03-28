# Hangul Clock Panel Maker (한글 시계 패널 생성기)

이 프로젝트는 한글 시계(Hangul Clock)의 전면 패널 이미지를 손쉽게 디자인하고 생성할 수 있는 웹 기반 도구입니다. 캔버스(Canvas API)를 활용하여 정밀 제어된 고해상도(300DPI) PNG 이미지를 브라우저에서 즉시 출력할 수 있습니다. 

실제 제작 환경(UV 인쇄, 시트지 커팅, 아크릴 투과 등)을 고려하여 밀리미터(mm) 단위 설정을 비롯한 다양한 편의 기능을 통합하였습니다.

> **Note:** 본 프로젝트의 기술 문서(README.md)와 AI 지침(AGENTS.md)은 AI 어시스턴트에 의해 자동 업데이트될 수 있습니다.

## 🚀 주요 기능

- **실시간 캔버스 렌더링**: 설정 값에 따라 6x6 배열의 한글 시계 패널을 즉각적으로 확인합니다.
- **자유로운 폰트 지원**: 
  - 웹폰트 URL(Google Fonts 등) 입력 지원
  - 시스템/로컬에 위치한 TTF, OTF 파일 직접 업로드 지원
- **물리적 크기 제어(mm)**: 
  - 패널의 실제 크기 길이(mm) 및 여백 용도의 패딩(mm) 설정
  - 300 DPI 기준으로 자동 계산하여 고해상도(px) 스케일링
- **정교한 레이아웃 보정**: px 단위의 기본 여백(Margin) 조정 및 텍스트의 상하 치우침을 보정하기 위한 Y-offset 조정 기능.
- **출력용 유틸리티**:
  - 색상 반전 (양각/음각, 시트지 재질용 최적화)
  - 좌우 반전 (투명 아크릴 배면 인쇄용)
- **손쉬운 다운로드**: 설정이 완료된 캔버스를 1-Click 스크립트로 투명/배경색이 적용된 PNG 포맷으로 다운로드.

## 🛠️ 기술 스택

- **Framework**: [Svelte 5](https://svelte.dev) (Runes API 기반 반응형 설계)
- **Build Tool**: [Vite](https://vitejs.dev)
- **Styling**: Vanilla CSS (Svelte 구문 사용)
- **Language**: JavaScript, HTML5 Canvas API

## 🚦 시작하기 (Getting Started)

의존성 패키지를 설치하고 개발 서버를 실행하세요. 최신 버전의 [Node.js](https://nodejs.org) 환경이 권장됩니다.

```bash
cd svelte-app
npm install
npm run dev
```

터미널에 표시되는 로컬 호스트 주소(일반적으로 `http://localhost:5173`)로 접속하여 애플리케이션을 실행하고 테스트할 수 있습니다.

## 📁 주요 디렉터리 및 코드 구조

- `/svelte-app/src/App.svelte`: 애플리케이션의 메인 동작 로직(캔버스 렌더링, 폰트 로드 등) 및 사용자 인터페이스(UI)가 단일 파일에 응집되어 있습니다.
- `/svelte-app/src/global.css`: 전체 앱 디자인 및 기본 스타일 초기화.
- `/AGENTS.md`: AI 기반 개발 에이전트를 위한 가이드라인 (에이전트 동작 원칙 및 개발 세부 지침).
