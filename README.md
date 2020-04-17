
# 여기다(Yeogida)
### 시각 장애인을 위한 음성주문 기반 키오스크 어플리케이션
### Kiosk Application for visually impaired people using voice order

한국산업기술대학교 컴퓨터 공학과 졸업작품

</br>

* #### :family: 개발자
  * 심영민, 박진서, 임의주, 신영명

* #### :pushpin: 협업도구
  * #### Git & Agile(Scrum)
  * 방학 중 2주 간격 스프린트. 개강 후엔 자유롭게 issue 발행 및 해결

* #### :iphone: APP
  * Language & Environment: Swift, Xcode, iOS 13
  * Frameworks: KaKaoLoginSDK, AVFoundation, Speech, CoreLocation,  Lottie, VoiceOver
  * Developers: 심영민, 박진서

* #### :computer: POS
  * Language & Environment: C#, Visual Studio
  * Developers: 임의주, 신영명
  * https://github.com/skadkwld/pos_program
  
* #### :file_folder: Server
  * AWS EC2: PHP 서버. 심영민, 박진서
  * AWS RDS: DB 서버. 임의주, 신영명

* #### :speech_balloon: Google Dialogflow
  * Version: V2
  * 가게, 메뉴 모델링하여 챗봇 제작
  * Google cloud dialogflow PHP client library 사용

<hr/>

</br>

## 1. 개요
챗봇, TTS, STT를 결합하여 시각 장애인이 음성으로 주문을 할 수 있도록 함.

APP 전반에 시각 장애인을 위한 장애인 접근성 지침을 준수하여 VoiceOver를 이용해 모든 기능을 사용할 수 있음.                                



<img width="1845" alt="스크린샷 2020-04-13 오후 3 23 00" src="https://user-images.githubusercontent.com/20080283/79097410-b39bf700-7d9a-11ea-96cf-63320a08d3e8.png">

</br> </br>



![image](https://user-images.githubusercontent.com/20080283/79094920-f4444200-7d93-11ea-97ea-049f433675c8.png)

</br> </br>


## :calling: 2. 기능

### 1. 카카오 간편 로그인
<img src="https://user-images.githubusercontent.com/20080283/79095575-b1836980-7d95-11ea-941d-5179b3c374e2.gif" width="40%">

</br>

### 2. 음성주문
<img src="https://user-images.githubusercontent.com/20080283/79096612-9fef9100-7d98-11ea-8eb6-fb7c77262f28.gif" width="40%">

</br>

#### Google Dialogflow, AWS EC2 Server(PHP), RDS Server(DB), Lottie

음성주문, 유사도 추천 기능 제공

</br>

### 3. 알림기능
https://www.youtube.com/watch?v=eqi8PUJboFY

#### APNS, AWS EC2(PHP)

</br>

### 4. 전체 시연 영상
https://www.youtube.com/watch?v=QPmVavaMwBk

</br>

### 기타: 비콘 주문 기능 (추후 영상 추가 예정)

</br>
