
# 여기다(Yeogida)
![issue_badge](https://img.shields.io/badge/Team-ook-red?style=flat)
![issue_badge](https://img.shields.io/badge/Ver-Swift5-red?style=flat)
![GitHub stars](https://img.shields.io/github/stars/tksrl0379/OutOfKiosk?style=social)
![YouTube Video Views](https://img.shields.io/youtube/views/QPmVavaMwBk?style=social)
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

* 시각 장애인이 키오스크를 사용하여 주문을 한다면?
: https://www.youtube.com/watch?v=IaxXwVHHjXs
* 노년층, 장애인들에게 불편한 키오스크
: https://www.youtube.com/watch?v=hJEBDVeU6FU

챗봇, TTS, STT를 결합하여 시각 장애인이 음성으로 대화하여 주문을 할 수 있도록 함.

APP 전반에 시각 장애인을 위한 장애인 접근성 지침을 준수하여 VoiceOver를 이용해 모든 기능을 사용할 수 있음.                                




<img width="1845" alt="스크린샷 2020-04-13 오후 3 23 00" src="https://user-images.githubusercontent.com/20080283/79097410-b39bf700-7d9a-11ea-96cf-63320a08d3e8.png">

</br> </br>



![image](https://user-images.githubusercontent.com/20080283/79094920-f4444200-7d93-11ea-97ea-049f433675c8.png)

</br> </br>


## :calling: 2. 설명

### 2-1. 장애인 접근성

#### -1. 간편로그인 </br>

> <img src="https://user-images.githubusercontent.com/20080283/79095575-b1836980-7d95-11ea-941d-5179b3c374e2.gif" width="30%"> </br>
> #### Kakao Login API
> 시각 장애인분과 대면 인터뷰를 통해 피드백 받아 추가한 기능

</br>

#### -2. 장애인 접근성 지침 </br>

> VoiceOver 실행시 모든 View에 Touch Focus가 가고 각 View가 어떤 역할을 하는지 TTS로 안내함 </br>
> 이와 관련된 18개 지침 준수에 관한 사항은 https://github.com/tksrl0379/OutOfKiosk/issues/41 에 기재함

</br>
</br>
</br>

### 2-2. 핵심기능

#### -1. 음성주문(Dialogflow + TTS + STT)

* #### 구현 화면 </br>
> <img src="https://user-images.githubusercontent.com/20080283/82976729-ce5cbf00-a01a-11ea-9fdb-617617d82794.png" width="35%"> <img src="https://user-images.githubusercontent.com/20080283/82976762-edf3e780-a01a-11ea-9390-413560d97de8.png" width="35%">

</br>

* #### 구현 방법 </br>
> <img src="https://user-images.githubusercontent.com/20080283/82973739-27c0f000-a013-11ea-9b3b-f95c1dc392b9.png" width="55%"><img src="https://user-images.githubusercontent.com/20080283/82973818-5c34ac00-a013-11ea-84be-94a4e8cd2576.png" width="40%"> </br></br>
> Dialogflow(Chatbot)가 대화 흐름을 만들고,</br></br>
> <img src="https://user-images.githubusercontent.com/20080283/82974408-e7627180-a014-11ea-8fc2-9d7db4a9c460.png" width="30%"> </br></br>
> TTS, STT 및 PHP 서버를 더하여 Dialogflow<->PHP서버<->APP(TTS->STT) 구조를 만들어 음성주문 구현 </br></br>
#### Q. 왜 굳이 PHP서버를 두고 통신하는지? </br>
> Dialogflow V1은 APP과 REST API를 통해 직접 통신이 가능했으나,</br>
> V2부터 PHP서버에 Dialogflow API를 설치하고 PHP 서버를 매개로 사용해야 함</br>
> 번거롭지만 Authentication Key 를 외부에 노출하지 않아 보안성이 좋은 방법

</br>
</br>

#### -2. 유사 단어 추천

* #### 구현 화면 </br>
> <img src="https://user-images.githubusercontent.com/20080283/82977929-3f51a600-a01e-11ea-887d-a951ede5eb92.png" width="35%"> <img src="https://user-images.githubusercontent.com/20080283/82977451-d4ec3600-a01c-11ea-8690-d72aa224202a.png" width="35%"> </br></br>
> 사용자가 의도한 단어는 '모카'이나 '목화'로 인식하여 Dialogflow가 이해하지 못할 시 가장 유사한 단어인 '모카' 추천 </br></br>

</br>

* #### 구현 방법 </br>
> <img src="https://user-images.githubusercontent.com/20080283/82975040-5b514980-a016-11ea-83f2-827baf098c62.png" width="90%"> </br></br>
> 사용자가 잘못 말하거나, STT가 제대로 인식하지 못하여 Chatbot이 이해하지 못할 시,</br>
> 유사 단어 추천 기능 작동 </br></br>

</br>

* #### 음성주문 + 유사 단어 추천 실제 작동 영상 </br>
> <img src="https://user-images.githubusercontent.com/20080283/79096612-9fef9100-7d98-11ea-8eb6-fb7c77262f28.gif" width="35%">

</br>
</br>
</br>

#### -3. 알림기능
https://www.youtube.com/watch?v=eqi8PUJboFY

* 초기 화면
> <img src="https://user-images.githubusercontent.com/20080283/83137961-051efc00-a125-11ea-9fdd-a1fbac65391e.png" width="30%">

</br>

* 주문 확인 중 -> 메뉴 조리 중 -> 메뉴 완성 -> 메뉴 수령 완료
> <img src="https://user-images.githubusercontent.com/20080283/83134541-7a87ce00-a11f-11ea-8e5b-215bf2d6a727.gif" width="30%"> <img src="https://user-images.githubusercontent.com/20080283/83137878-dbfe6b80-a124-11ea-81fc-9a93cd9af0f8.gif" width="30%"> </br>
> ##### APNS, AWS EC2(PHP) 연동하여 실시간 주문 현황 알림 서비스 구현.
> 실시간으로 변하는 정보 또한 Accessibility 설정하여 VoiceOver에 의해 읽어짐

</br>

#### -4. 찜한 메뉴

> <img src="https://user-images.githubusercontent.com/20080283/83138519-dfdebd80-a125-11ea-80c6-37496dcdc241.png" width="30%"> </br></br>
> 각 가게에서 자주 먹는 메뉴를 찜하여 메인화면 - 찜한 메뉴에서 바로 간편하게 주문할 수 있게 해준다. </br></br>
> 총 6개의 과정(메인화면 -> 가게 목록 -> 가게 선택 -> 음성주문 -> 먹고 싶은 음식을 말하는 과정 -> 옵션)을 </br>
> 총 4개의 과정(메인화면 -> 찜한 메뉴 -> 음성주문 -> 옵션)으로 줄여줌

</br>

#### -5. 스마트 결제 시스템

* 즉시 결제 / 현장 결제 </br>
> 즉시 결제: 배달의 민족같이 모바일에서 바로 결제할 수 있는 기능</br>
> 현장 결제: 사용자가 메뉴를 장바구니에 담은 뒤 매장에 도착하면 매장의 Beacon이 인식하여 자동으로 결제되도록 함

</br>
</br>

## 3. 전체 시연 영상 (비콘 주문 기능 영상은 누락되어 추후 추가 예정)

* 주문
> [![Video Label](http://img.youtube.com/vi/QPmVavaMwBk/hqdefault.jpg)](https://www.youtube.com/watch?v=QPmVavaMwBk)

* 알림 기능
> > [![Video Label](http://img.youtube.com/vi/eqi8PUJboFY/hqdefault.jpg)](https://www.youtube.com/watch?v=eqi8PUJboFY)



</br>

## 4. 참고문헌
[1] 장애인 실태조사 (2017) </br>
https://www.data.go.kr/dataset/15004328/fileData.do(accessed Jan. 05. 2019) </br>
[2] 방송통신표준심의회 - 모바일 애플리케이션 콘텐츠 접근성 지침 2.0 (2016) </br>
https://rra.go.kr/ko/reference/kcsList_view.do?nb_seq=1930&cpage=1&nb_type=6&searchCon=&searchTxt=&sortOrder(accessed Jan. 05. 2019)
[3] 웹 와치 - 모바일 앱 접근성 소개 </br>
http://www.webwatch.or.kr/MA/020201.html?MenuCD=220(accessed Jan. 06. 2020) </br>
[4] 맹혜련. "인공지능 기반 자연어 처리 기술의 현황 및 서비스 연구" (2019) 호서대학교대학원 논문, p.13, 2019년 7월
[5] Google Dialogflow Conception </br>
https://cloud.google.com/dialogflow/docs/concepts?hl=ko(accessed Dec. 21. 2019) </br>
[6] 자카드 유사도 </br>
https://ko.wikipedia.org/wiki/%EC%9E%90%EC%B9%B4%EB%93%9C_%EC%A7%80%EC%88%98 (accessed Feb. 2. 2020)

