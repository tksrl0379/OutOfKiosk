//
//  DialogFlowPopUpController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/03.
//  Copyright © 2020 OOK. All rights reserved.
//

/* 30초간 아무 말도 안하면 음성인식 기능 종료됨.*/

import AVFoundation
import Speech
import UIKit
import Lottie


class DialogFlowPopUpController: UIViewController{
    
    /* 유사한 단어 추천 관련 변수 */
    
    // 1. 유사도 높은 단어 선택 버튼
    @IBOutlet weak var select_Btn: UIButton!
    // 2. 사용자의 이전 발화 기록용
    var befResponse: String?
    // 3. 유사도 높은 Entity (DB로부터 가져옴)
    var similarEntity: NSString?
    // 4. 사용자가 유사한 단어를 사용하기 위해 선택한 경우
    var similarEntityIsOn: Bool = false
    
    
    /* STT 동기화를 위한 세마포어 선언: STT가 끝나면 wait로 블록시키고, TTS가 끝나면 signal 전송하여 다시 STT 시작. CPU점유율을 낮추는 역할도 함  */
    let semaphore = DispatchSemaphore(value: 0)
    
    /* 즐겨찾기를 통해서 주문이 들어왔을 때의 값이 저장되는 곳*/
    var favoriteMenuName : String? = nil
    
    /* 장바구니 갯수가 증가함에 따라 CafeDetailController에 있는 장바구니 버튼에 개수를 표현하기 위해*/
    var willGetShoppingBasket_Btn : UIButton!
    //var getFromViewController : UIButton!
    
    /* Lottie animation을 위한 View 변수 */
    @IBOutlet weak var animationView: UIView!
    var animation: AnimationView?
    
    
    /* ViewController 종료를 알리는 변수 */
    private var viewIsRunning : Bool = true
    
    /* startRecording()의 콜백함수들 종료 여부 체크 변수 (STT / TTS 타이밍을 맞추기 위한 변수) */
    private var checkResponseFromAI :Bool = true
    
    /* checkSimilarEntityIsGet: 1. 유사한 단어 정보를 DB로부터 받고 -> 2. TTS를 수행하고 나서 3. startStopAct()의 쓰레드의 if문으로 들어가 STT(startRecording)를 수행하기 위한 변수. 이 변수가 없으면 DB로부터 아직 유사 단어 추천을 받지 못했는데 STT가 시작된다. (STT-> DB순서가 되버리기 때문에 이 순서를 맞춰주기 위함) */
    var checkSimilarEntityIsGet: Bool = true
    
    /* Dialogflow parameter 변수 */
    private var name: String?
    private var count: Int?
    private var size: String?
    private var sugar: String?
    private var whippedcream: String?
    
    /* 가게 한글 이름 */
    var storeKorName : String?
    
    /* VoiceOver와 TTS 혼선 제어 변수들
     1. popUp_Label : 맨 처음 보이스 오버 포커싱이 뒤로가기로 가지 않기위해 만든 라벨
     
     2. popUpFlag : 유사도 확인용 플래그
     유사도 질문에 대한 답으로 selectBtn을 누를 시, 보이스오버 기능 특성 상 읽을 수 있는 라벨에 자동으로 포커싱이 가기때문에
     popUpMSG로 포커싱이 가는 시나리오에선 speechAndText에서 sleep을 1.5초를 지연시켜 TTS와 보이스오버의 중복이 없게 만든다.
     */
    @IBOutlet weak var popUp_Label: UILabel!
    var popUpFlag : Bool = false
    
    
    /* Btn 관련 변수
     1. receivedMsg_Label: 챗봇을 통하여 답장을 받는 label(라벨)
     2. requestMsg_Label: 사용자의 목소리를 텍스트하여 보여지는 TextView
     3. recording_Btn: 사용자의 목소리를 녹음 시작/정지 할 수 있는 Button(버튼)
     */
    @IBOutlet weak var receivedMsg_Label: UILabel!
    @IBOutlet weak var requestMsg_Label: UITextView!
    
    /* TTS 관련 변수 */
    let speechSynthesizer = AVSpeechSynthesizer()
    
    /* STT 관련 변수
     1. speechRecognizer: 음성인식 지역 지원
     2. recognitionRequest: 음성인식 요청 처리
     3. recognitionTask: 음성인식 요청 결과 제공
     4. audioEngine: 순수 소리 인식
     5. inputNode
     */
    private var speechRecognizer : SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    private var inputNode: AVAudioInputNode?
    
    
    
    @IBAction func select_Btn(_ sender: Any) {
        
        self.similarEntityIsOn = true
        self.select_Btn.isHidden = true

        /* 포커싱을 다시 popUp_Label로 보내주며 보이스오버가 읽을 때 자연스럽게 이어지기 위해
         유사도 체크가 됨을 확인했다는 표시로 "확인"이라고 text를 바꿈*/
        
        self.popUp_Label.text = "확인"
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: self.popUp_Label)
        popUpFlag = true
                
    }
    
    /* 녹음 시작, 중단 버튼 시 이벤트 처리 */
    func StartStopAct() {
        
        /* 한국어 설정 */
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
        
        
        /* startRecording() 내부의 콜백함수들 종료 여부 체크 후 startRecording() 재실행 */
        DispatchQueue.global().async {
            
            
            while(self.viewIsRunning){
                
                /* 과도한 CPU 점유 막기 위해 usleep */
                //usleep(1)
                
                if(self.checkResponseFromAI == true && !self.speechSynthesizer.isSpeaking && self.checkSimilarEntityIsGet){ //} && self.checkGetPriceFromDB){
                    print("TTS 2", self.speechSynthesizer.isSpeaking)
                    
                    // 챗봇으로부터 응답 받았는지 확인
                    self.checkResponseFromAI = false
            
                    // startRecording에서 STT를 다시 시작하는데 Tap이 remove되지 않는 경우가 아주 가끔 존재하여 removeTap을 확실히 한 번 또 해줌
                    self.inputNode?.removeTap(onBus: 0)
                    
                    // STT 시작
                    self.startRecording()
                    self.semaphore.wait()
                }
            }
        }
        
    }
    

    
    /* 응답 출력 및 읽기(TTS) */
    func speechAndText(_ textResponse: String) {
        
        /* selectBtn이 클릭되었을 경우, 보이스오버 혼선기능을 막기위해 2초 이후(보이스오버가 "확인"메시지를 읽는데까지 걸리는 시간) 함수기능 수행*/
        if (popUpFlag == true){
            sleep(2)
            popUpFlag = false
        }
        
        DispatchQueue.main.async {
            /* Dialogflow로부터 받은 응답 출력 */
            self.animation?.pause()
            
            self.receivedMsg_Label.text = textResponse
            /* fade in 효과 */
            self.receivedMsg_Label.alpha = 0
            UIView.animate(withDuration: 1.5) {
                self.receivedMsg_Label.alpha = 1.0
                
            }
        }
        
        
        /* 응답 읽기(TTS) */
        let speechUtterance = AVSpeechUtterance(string: textResponse)
        
        /* 한글 설정 및 속도 조절 */
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        speechUtterance.rate = 0.65
        
        
        /* if문 -> 대화가 모두 끝난 이후에도 TTS가 나와서 이를 막기 위함 */
        if(self.viewIsRunning){
            /* 음성 출력 */
            speechSynthesizer.speak(speechUtterance)
            print("TTS:", speechSynthesizer.isSpeaking)
        }
        
    }
    
    
    
    
    /*
     STT관련 함수
     1. func startStopAct() -> (Void): audioEngine의 running에 따라, 음성인식기능(startRecording)의 시작 여부 결정하는 함수
     2. func startRecording(): 음성인식 시작
     */
    
    /* STT 시작 */
    func startRecording(){
        
        /* 사용자의 문장 끝을 파악하기 위한 변수들 */
        var recordingState : Bool = false
        var recordingCount : Int = 0
        var monitorCount : Int = 0
        var befRecordingCount: Int = 0
        
        
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        /* recognitionRequest 객체가 인스턴스화되고 nil이 아닌지 확인 */
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        /* 사용자의 부분적인 발화도 모두 인식하도록 설정 */
        recognitionRequest.shouldReportPartialResults = true
        
        /* 소리 input을 받기 위해 input node 생성 */
        inputNode = audioEngine.inputNode
        
        /* 특정 bus의 outputformat 반환: 보통 0번이 outputformat, 1번이 inputformat ( https://liveupdate.tistory.com/400 ) */
        let recordingFormat = inputNode?.outputFormat(forBus: 0)
        
        
        
        
        
        /* 1. 음성인식 준비 및 시작 */
        audioEngine.prepare()
        print("record ready")
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        DispatchQueue.main.async {
            self.animation?.play()
            self.requestMsg_Label.text = " "
        }
        
        
        
        /* 새 쓰레드에서 돌아감 */
        /* 2. bus에 audio tap을 설치하여 inputnode의 output 감시: audioEngine이 start인 경우 계속해서 반복 */
        inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            
            self.recognitionRequest?.append(buffer)
            print("monitoring")
            /* 사용자의 무음 시간 체크 */
            monitorCount+=1
            
            /* 사용자가 유사도 높은 단어 사용 선택 시 */
            if(self.similarEntityIsOn){
                
                recordingState = true
                monitorCount = 12
                recordingCount = befRecordingCount
                
            }
            
            /* 사용자가 말을 하기 시작하면 recordingState가 true가 됨*/
            if(recordingState){
                monitorCount %= 13 // monitorCount는 0~12
                if(monitorCount / 12 == 1){ // monitorCount가 12이 될 때마다 recordingCount 증가 여부 검사
                    
                    if(recordingCount == befRecordingCount){ // 사용자가 말을 끝마친 경우 전송
                        
                        print("EndOfConversation")
                        
                        /* STT 멈추기 */
                        self.audioEngine.stop()
                        recognitionRequest.endAudio()
                        
                        recordingState = false
                        recordingCount = 0
                        monitorCount = 0
                        befRecordingCount = 0
                        
                        /* Dialogflow에 requestMsg 전송하는 부분 */
                        var request: String?
                        
                        DispatchQueue.main.async{ // UILabel 때문에 Main 쓰레드 내부에서 실행
                            if(self.similarEntityIsOn){
                                print("들어왔음", self.similarEntity)
                                request = self.similarEntity as String?
                                self.similarEntityIsOn = false
                            }else{
                                request = self.requestMsg_Label?.text
                                
                            }
                            self.requestMsg_Label?.text = " "
                            
                            
                            /* DialogFlow 서버에 requestMsg 전송 후 handler 호출 */
                            CustomHttpRequest().phpCommunication(url: "vendor/intent_query.php", postString: "query=\(request!)"){
                                responseString in
                            
                                var dict = CustomConvert().convertStringToDictionary(text: responseString as! String)
                                
                                let responseMessage = dict!["response"] as! String
                                let intentName = dict!["intentName"] as! String
                                let parameter = dict!["parameters"] as? NSDictionary
                                
                                
                                print("1.\n",responseMessage)
                                print("2.\n",intentName)
                                //print("3.\n",parameters["SMOOTHIE_NAME"])
                                
                                /* CONTEXT DELETE */
                                CustomHttpRequest().phpCommunication(url: "vendor/context_delete.php", postString: ""){
                                    responseString in
                                }
                            
                    
                                // 2-1. Dialogflow의 파라미터 값 받기
                                let parameter_name = intentName + "_NAME"
                                if let name = parameter?[parameter_name]{
                                    
                                    self.name = name as? String
                                    print("이름: \(String(describing: self.name))")
                                };
                                if let count = parameter?["number"]{
                                    
                                    self.count = Int(count as! String)
                                    print("개수: \(String(describing: self.count))")
                                };
                                if let size = parameter?["SIZE_NAME"]{
                                    
                                    self.size = size as? String
                                    print("사이즈: \(String(describing: self.size))")
                                };
                                if let sugar = parameter?["SUGAR"]{
                                    
                                    self.sugar = sugar as? String
                                    print("당도: \(String(describing: self.sugar))")
                                };
                                if let whippedcream = parameter?["WHIPPEDCREAM"]{
                                    
                                    self.whippedcream = whippedcream as? String
                                    print("휘핑크림: \(String(describing: self.whippedcream))")
                                };
                                
                                
                                /* 2-2. Dialogflow의 response message 유사도 분석 */
                                
                                /* 2-2-1 Dialogflow가 질문자의 발화를 이해하지 못한 경우 (2가지로 판단 가능) */
                                if(responseMessage.contains("정확한 메뉴 이름을 말씀해주시겠어요 ?")){ // 1. fallback intents 로 들어간 경우 혹은,
                                    
                                    
                                    self.checkSimilarEntityIsGet = false
                                    
                                    CustomHttpRequest().phpCommunication(url: "similarity/measureSimilarity.php", postString: "word=\(request!)&category=MENU"){
                                        responseString in
                                        print(responseString)
                                        
                                        self.getSimilarEntityHandler(responseString as NSString, responseMessage, "")
                                        
                                    }
                                    
                                }else if(self.befResponse == responseMessage){ // 2. 같은 질문 반복 (메뉴 질문에 대해서만)
                                    if(responseMessage.contains("어떤") ){ // 2-1. 메뉴 이름에 대해
//                                        print("메뉴 이름 same response")
                                        self.checkSimilarEntityIsGet = false
//                                        print("request",request)
//                                        print("intentName",intentName)
                                        
                                        CustomHttpRequest().phpCommunication(url: "similarity/measureSimilarity.php", postString: "word=\(request!)&category=\(intentName)"){
                                            responseString in
                                        
                                            print(responseString)
                                            
                                            self.getSimilarEntityHandler(responseString as NSString, responseMessage, "")
                                        }
                                        
                                    }else if (responseMessage.contains("사이즈")){ // 2-2. 사이즈에 대해
                                        print("사이즈 same response")
                                        self.checkSimilarEntityIsGet = false
                                        print("request",request)
                                        
                                        CustomHttpRequest().phpCommunication(url: "similarity/measureSimilarity.php", postString: "word=\(request!)&category=SIZE"){
                                            responseString in
                                        
                                            print(responseString)
                                            
                                            self.getSimilarEntityHandler(responseString as NSString, responseMessage, "")
                                        }
                            
                                    }else{ // 유사도 추천이 없는 질문의 경우
                                        DispatchQueue.main.async {
                                            self.select_Btn.isHidden = true
                                            self.speechAndText(responseMessage)
                                            print("일반")
                                            // 질문이 반복되는지 감지하기 위해
                                            self.befResponse = responseMessage
                                        }
                                        
                                    }
                                    
                                    // 2-2-2 장바구니에 담은 경우
                                }else if(responseMessage.contains("담았습니다.")){
                                    
                                    // Db - php 서버로부터 가격정보 받은 후 장바구니(ShoppingListViewController)로 전송하고,
                                    CustomHttpRequest().phpCommunication(url: "price.php", postString: "name=\(self.name!)&size=\(self.size!)&count=\(self.count!)"){
                                        price in
                                        
                                        
                                        print("가격", price)
                                        
                                        DispatchQueue.main.async {
                                            
                                            let ad = UIApplication.shared.delegate as? AppDelegate
                                            
                                            /* 주문이 완료됨에 따라 장바구니 옆에 현재 몇개의 아이템이 있는지 알려준다.*/
                                            ad?.numOfProducts += 1
                                            
                                            if let name = self.name{
                                                ad?.menuNameArray.append(name)
                                            }
                                            if let size = self.size{
                                                ad?.menuSizeArray.append(size)
                                            }
                                            if let count = self.count{
                                                ad?.menuCountArray.append(count)
                                            }
                                            if let price = price as? NSString{
                                                ad?.menuEachPriceArray.append(Int(price.intValue))
                                            }

                                            if self.sugar == nil{
                                                ad?.menuSugarContent.append("NULL")
                                            }else{
                                                if let sugar = self.sugar{
                                                    ad?.menuSugarContent.append(sugar)
                                                }
                                            }
                                            
                                            if self.whippedcream == nil{
                                                ad?.menuIsWhippedCream.append("NULL")
                                            }else{
                                                if let whippedcream = self.whippedcream{
                                                    ad?.menuIsWhippedCream.append(whippedcream)
                                                }
                                            }
                                            
                                            ad?.menuStoreName = self.storeKorName!
                                            print("가게이름:", self.storeKorName!)
                                            
                                            /* 가게 체크?: 추후에 넣기 */
                                            
                                            
                                        }
                                        
                                    }
                                    /* 대화가 모두 끝난 이후에도 TTS가 나와서 이를 막기 위함 */
                                    self.viewIsRunning = false
                                    
                                    DispatchQueue.main.async {
                                        //종료
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                    
                                    
                                    /* 2-2-3. 장바구니에 담지 않고 끝내는 시나리오 */
                                }else if(responseMessage.contains("필요하실때 다시 불러주세요.")){
                                    self.viewIsRunning = false
                                    DispatchQueue.main.async {
                                        //종료
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                    
                                    /* 2-2-4 일반적인 경우 */
                                }else{
                                    DispatchQueue.main.async {
                                        self.select_Btn.isHidden = true
                                    }
                                    self.speechAndText(responseMessage)
                                    print("일반")
                                    // 질문이 반복되는지 감지하기 위해
                                    self.befResponse = responseMessage
                                }
                                print("success")
                                
                                DispatchQueue.main.async {
                                    /* STT 타이밍을 제어하는 global thread 동기화 */
                                    self.checkResponseFromAI = true
                                    self.semaphore.signal()
                                    print("signal")
                                }
                                
                            }//End of sendMessage
                        }// End of Dispatch.main.async
                    }else{
                        
                        befRecordingCount = recordingCount
                    }
                }
            }
            
            print("\(recordingCount), \(befRecordingCount), \(monitorCount)")
            
            
        } // End of 2. inputNode.installTap
        
        
        
        
        /* 3. inputnode의 output이 감지될 때마다 resultHandler callback 함수 호출 */
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            print("recording")
            
            /* recording 상태 기록 */
            recordingState = true
            recordingCount += 1
            
            var isFinal = false
            
            if result != nil {
                self.requestMsg_Label.text = result?.bestTranscription.formattedString
                print(self.requestMsg_Label.text)
                isFinal = (result?.isFinal)!
            }
            
            /* 오류가 없거나 최종 결과가 나오면 audioEngine (오디오 입력)을 중지하고 인식 요청 및 인식 작업을 중지 */
            if error != nil || isFinal {
                
                self.audioEngine.stop() // 이미 앞에서 stop해서 필요 없는 거같은데 일단 보류
                self.inputNode?.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
            }
        })
        
    } /* End of startRecording */
    
    /* 유사한 단어 유무를 구별하여 처리: 유사한 단어를 찾았는데 유사한 단어가 아예 없는 경우 추천해주지 않고 일반적인 안내가 나오도록함 */
    func getSimilarEntityHandler(_ recommendedWord: NSString, _ responseMsg: String, _ helpText: String){
        
        /* 유사한 단어가 없을 경우 */
        if(recommendedWord == ""){
            self.speechAndText(responseMsg)
            self.checkSimilarEntityIsGet = true
            
        /* 있을 경우 */
        }else{
            self.speechAndText("\(recommendedWord)\(helpText)가 맞다면 화면을 더블탭, 아니면 다시 말씀해주세요.")
            self.checkSimilarEntityIsGet = true
            self.similarEntity = recommendedWord
            
            DispatchQueue.main.async{
                self.select_Btn.isHidden = false
            }
            
            // Voiceover 포커스를 select_Btn으로 바꿈
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: self.select_Btn)
        }
        
    }
    
    
    
    /* BackButton 클릭 시 수행할 action 지정 */
    @objc func buttonAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        /* ViewController가 작동중임을 표시*/
        viewIsRunning = true
        
        self.select_Btn.isHidden = true
        
        
        /* backButton 커스터마이징 */
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0.0, y: 0.0, width: 24, height: 24)
        backBtn.setImage(UIImage(named:"left_image"), for: .normal)
        backBtn.addTarget(self, action: #selector(FavoriteMenuController.buttonAction(_:)), for: UIControl.Event.touchUpInside)
        
        let addButton = UIBarButtonItem(customView: backBtn)
        let currWidth = addButton.customView?.widthAnchor.constraint(equalToConstant: 24)
        let currHeight = addButton.customView?.heightAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        currHeight?.isActive = true
        
        self.navigationItem.leftBarButtonItem = addButton
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "뒤로가기"
        
        
        
        /* Lottie animation 설정 */
        animation = AnimationView(name:"loading")
        animation!.frame = CGRect(x:0, y:0, width:400, height:400)
        
        animation!.center = self.view.center
        
        animation!.contentMode = .top
        animation!.loopMode = .loop
        animationView.addSubview(animation!)
        
        
        /* 오디오 설정: 이 코드를 넣어줘야 실제 디바이스에서 TTS가 정상적으로 작동 */
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)//.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.default)
            
        }catch{
            print("error")
        }
        
        
        /* 해당 가게 Intent 로 시작하도록 설정 Ex) 스타벅스, 역전우동 */
        CustomHttpRequest().phpCommunication(url: "vendor/intent_query.php", postString: "query=\(self.storeKorName!)"){
            responseString in
        
            print(responseString)
            
            var dict = CustomConvert().convertStringToDictionary(text: responseString as! String)
            
            let responseMessage = dict!["response"] as! String
            
            /* 1. 즐겨찾기 시*/
            if (self.favoriteMenuName != nil) { //값이 들어있을때 예) 초콜렛 스무디 <-다시한번 다이얼로그챗봇 대화한다.
                print(self.favoriteMenuName!)
                CustomHttpRequest().phpCommunication(url: "vendor/intent_query.php", postString: "query=\(self.favoriteMenuName!)"){
                    responseString in
                    
                    print("즐겨찾기 들어왔음")
                
                    var dict = CustomConvert().convertStringToDictionary(text: responseString as! String)
                    let responseMessage = dict!["response"] as! String
                    
                    self.speechAndText(responseMessage)
                    self.StartStopAct()
                }
                /* 2. 일반 주문 시 */
            }else{
                //유사도 분석을 위함
                //self.categoryOfSimilarity = "메뉴"
                
                self.speechAndText(responseMessage)
                self.StartStopAct()
            }
        }
        
        /* 실행과 동시에 보이스오버가 포커싱이 뒤로가기로 가지않기 위함 */
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: self.popUp_Label)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        /* navigationbar 투명 설정 */
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        
    }
    
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        
        /* 종료 시 확실하게 하기 위해 */
        viewIsRunning = false
        inputNode?.removeTap(onBus: 0)
        
        /* Context Delete */
        CustomHttpRequest().phpCommunication(url: "vendor/context_deleteAll.php", postString: ""){
            responseString in
            
        }
        
        
    }
    

    
}
