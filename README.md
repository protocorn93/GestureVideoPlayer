# GestureVideoPlayer
---
### 구현 진행 상황

- 재생(버튼) / 정지(버튼) : **구현**
- Seeking(슬라이더) / 10초전(버튼) : **구현**
- 제스처
  - 탭 (탭할때 마다 컨트롤뷰 토글) : `UIViewPropertyAnimator` 사용하여 **구현**
  - 더블 탭 (영상 확대 및 원본 비율 토글) :  미구현 `.videoGravity`로 구현하려하였으나 **실패**
  - 좌우 팬 (Seeking) : `UIPanGestureRecognizer`을 사용하여 **구현**
  - 우측 상하 (볼륨 조절) : `UIPanGestureRecognizer`을 사용하여 **구현**
    - `UIPanGestureRecognizer`
      - `translation`과 `velocity`를 사용하여 `좌/우`인지 `상/하`인지 구분
      - 열거형 타입 `PanDirection`을 만들어 방향의 중첩을 방지
---
### 참고자료
1. [Media Playback Programming Guide](https://developer.apple.com/library/content/documentation/AudioVideo/Conceptual/MediaPlaybackGuide/Contents/Resources/en.lproj/ExploringAVFoundation/ExploringAVFoundation.html#//apple_ref/doc/uid/TP40016757-CH4-SW1)
