# 여기다 YeoGiDa (a Temporary Title)

시각 장애인을 위한 키오스크 어플리케이션


## Getting Started (어플리케이션에 간단한 소개 및 POS기와 서버 연동 보여주기)

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

## Overview

- 키오스크의 확장성이 증가함에 따라, 시각장애인이 현장주문이 힘들어지는 상황을 타개하기 위해 만들어진 Application
- 어플리케이션은 챗봇과 보이스오버를 이용하여 시각장애인으로 하여금 음성안내/음석인식으로 아이폰에서 주문이 가능하도록 구현
- 실제POS기와 유사한 기능을 가진 POS기를 제작함에 따라 시뮬레이션이 가능하게 함

## Prerequsites

### IOS
  ```
  Xcode
  APIAI - Google DialogFlow
  Alamofire - PHP Communication
  AWS - Server
  Mysql - Database  
  ```

### POS

  ```
  C#
  AWS - Server
  Mysql - Database  
  ```
  
## Sprint (Agile방법론)

 #### 4주간격을 주어 해당되는 코어 기능 및 회의를 통해 나온 기능을 구현하며, 그에 따른 문제점 및 보안점을 모색한다.
 
 ##### 12/23-1/17 
 * IOS 
  - Swift언어 학습 및, IOS APP을 구현 할 수 있는 맥북, 아이폰을 준비한다.
  - 기본적인 회원가입 및 로그인이 가능하도록 한다.
  - 구글 챗봇을 이용하여 기본적인 주문이 가능하며 이 주문을 토대로 서버로 데이터를 전송할 수 있게 한다.

 * POS
  - 토의를 거쳐 설정한 C#을 학습한다.
  - 시중에 나온 POS모델의 매뉴얼을 참조하여 기초적인 UI제작 및 관련 기능을 구현하도록 한다.
  - IOS App과 연동이 가능한 서버를 증설하며, 서버에 기초적인 DB 프레임을 구현한다.
 

## Versioning

### OOK : OutOfKiosk

#### IOS

##### IOS(1.1) 
   - 사용자는 회원가입 및 로그인을 할 수 있다.
   - Google DialogFlow를 이용한 주문 관련 모델을 생성하여 질의응답이 가능하다.
   - 사용자가 DialogFlow를 이용함에 있어서 음성인식/안내(STT, TTS)를 이식하여 직접 타이핑 없이 주문이 가능하다.
   - AWS Server와 PHP연동을 통해 주문한 정보를 MySql DB에 전송시키는 것이 가능하다.
   

##### POS

  POS(1.1)
   - POS기의 UI모델을 재현했으며 메뉴정보 담기 및 계산이 가능하다.
   - DB를 연동하여 선택된 메뉴 아이템을 DB로 보낼 수 있다.


## License

This project is licensed under the KPU_Studnets

#### IOS App제작 = 심영민, 박진서

#### POS, DB관리 = 임의주, 신영명

License - see the [LICENSE.md](LICENSE.md) file for details

