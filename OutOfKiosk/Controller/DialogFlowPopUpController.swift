//
//  DialogFlowPopUpController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/03.
//  Copyright © 2020 OOK. All rights reserved.
//

import AVFoundation
import Speech
import UIKit
import Lottie


class DialogFlowPopUpController: UIViewController {
    
    // MARK: - Propery
    // MARK: 유사 단어 추천
    @IBOutlet weak var similarSelect_Btn: UIButton!
    var befResponse: String?
    var similarEntity: NSString?
    var similarEntityIsOn: Bool = false // 사용자가 유사 단어 선택 여부
    
    // MARK: 세마포어
    let semaphore = DispatchSemaphore(value: 0)
    
    // MARK: 즐겨찾기
    var favoriteMenuName : String? = nil // 즐겨찾기 주문 시 사용 됨
    
    // MARK: Lottie
    @IBOutlet weak var animationView: UIView!
    var animation: AnimationView?
    
    // MARK: Dialogflow Parameter
    private var name: String?
    private var count: Int?
    private var size: String?
    private var sugar: String?
    private var whippedcream: String?
    
    // MARK: 가게 이름
    var storeKorName : String?
    
    // MARK: Voiceover 혼선 제어
    @IBOutlet weak var popUp_Label: UILabel!
    var popUpFlag : Bool = false
    
    // MARK: View
    @IBOutlet weak var receivedMsg_Label: UILabel!
    @IBOutlet weak var requestMsg_Label: UITextView!
    
    // MARK: TTS
    let speechSynthesizer = AVSpeechSynthesizer()
    
    // MARK: STT
    private var speechRecognizer : SFSpeechRecognizer?                     // 음성인식 지역 지원
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest? // 음성인식 요청 처리
    private var recognitionTask: SFSpeechRecognitionTask?                  // 음성인식 결과 제공
    private var audioEngine: AVAudioEngine?                                // 순수 소리 인식
    private var inputNode: AVAudioInputNode?
    
    
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.speechSynthesizer.delegate = self
        self.audioEngine = AVAudioEngine()
        
        self.initializeView()
        
        self.initializeBackBtn()
        
        self.initializeLottie()
        
        self.initializeAudioSetting()
        
        self.initializeOrder()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    
        self.inputNode?.removeTap(onBus: 0)
        
        // Context Delete
        CustomHttpRequest().phpCommunication(url: "vendor/context_deleteAll.php", postString: "") {
            responseString in
            
        }
    }
    
    
    
    // MARK: - Method
    // MARK: Custom Method
    
    func initializeView() {
        
        // navigationbar title 동적 변경 ( 이 경우엔 navigationbar 안보이게 하려고 설정함)
        self.navigationController?.navigationBar.prefersLargeTitles = true
       
        self.similarSelect_Btn.isHidden = true
        
        // 즐겨찾기에서 들어왔을 시 뒤로가기 accessibility 설정
        if favoriteMenuName != nil {
            self.navigationItem.leftBarButtonItem?.accessibilityLabel = "찜한 목록 뒤로가기"
        }else{
            self.navigationItem.leftBarButtonItem?.accessibilityLabel = self.storeKorName! + " 뒤로가기"
        }
        
        // 실행과 동시에 보이스오버가 포커싱이 뒤로가기로 가지않기 위함
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: self.popUp_Label)
    }
    
    func initializeBackBtn() {
        
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
    }
    
    func initializeLottie() {
        
        animation = AnimationView(name:"loading")
        animation!.frame = CGRect(x:0, y:0, width:400, height:400)
        
        animation!.center = self.view.center
        
        animation!.contentMode = .top
        animation!.loopMode = .loop
        animationView.addSubview(animation!)
    }
    
    func initializeAudioSetting() {
        
        // 실제 디바이스에서 TTS가 정상적으로 작동하게 함
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)
            try audioSession.setMode(AVAudioSession.Mode.default)
            
        }catch{
            print("error")
        }
    }
    
    func initializeOrder() {
        
        // 해당 가게 Intent 로 시작하도록 설정 Ex) 스타벅스, 역전우동
        CustomHttpRequest().phpCommunication(url: "vendor/intent_query.php", postString: "query=\(self.storeKorName!)") {
            responseString in
            
            print(responseString)
            
            var dict = CustomConvert().convertStringToDictionary(text: responseString )
            
            let responseMessage = dict!["response"] as! String
            
            // 1. 즐겨찾기 시
            if self.favoriteMenuName != nil {
                
                print(self.favoriteMenuName!)
                
                CustomHttpRequest().phpCommunication(url: "vendor/intent_query.php", postString: "query=\(self.favoriteMenuName!)") {
                    responseString in
                    
                    print("즐겨찾기 들어왔음")
                    
                    var dict = CustomConvert().convertStringToDictionary(text: responseString)
                    let responseMessage = dict!["response"] as! String
                    
                    self.startTTS(responseMessage){ self.controlAsyncTask() }
                }
                // 2. 일반 주문 시
            } else {
                
                self.startTTS(responseMessage){ self.controlAsyncTask() }
            }
        }
        
    }
    
    // 비동기 작업 제어
    func controlAsyncTask() {
        
        // 한국어 설정
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
        
        
        // startSTT() 내부의 콜백함수들 종료 여부 체크 후 startSTT 재실행
        DispatchQueue.global().async { [weak self] in
            
            while true {

                if self?.semaphore.wait(timeout: .now() + 10) == .success && self != nil {
                    
                    self?.inputNode?.removeTap(onBus: 0) // STT 시작 전 removeTap 필요
                    self?.startSTT() // STT 시작
                    
                } else if self == nil {
                    break
                }
                
            }
        }
    }
    
    func startTTS(_ textResponse: String, handler: @escaping ()->Void) {
        
        // selectBtn이 클릭되었을 경우, 보이스오버 혼선기능을 막기위해 2초 이후(보이스오버가 '확인' 메시지를 읽는데까지 걸리는 시간) 실행
        if popUpFlag {
            sleep(2)
            popUpFlag = false
        }
        
        DispatchQueue.main.async {
            
            // Dialogflow로부터 받은 응답 출력
            self.animation?.pause()
            
            self.receivedMsg_Label.text = textResponse
            
            // fade in 효과
            self.receivedMsg_Label.alpha = 0
            UIView.animate(withDuration: 1.5) {
                self.receivedMsg_Label.alpha = 1.0
                
            }
        }
        
        // 응답 읽기(TTS)
        let speechUtterance = AVSpeechUtterance(string: textResponse)
        
        // 한글 설정 및 속도 조절
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        
        if let rate = UserDefaults.standard.string(forKey: "speechSpeedRate"){
            speechUtterance.rate = Float(rate)!
        }else{
            
            // 초기 설정 시
            speechUtterance.rate = 0.5
        }
        
        // 대화가 모두 끝난 이후에는 TTS 방지
            
        speechSynthesizer.speak(speechUtterance)
        
        
        handler()
    }
    
    func processMsg() {
        
        // Dialogflow에 requestMsg 전송하는 부분
        var request: String?
        
        DispatchQueue.main.async{ // UILabel 때문에 Main 쓰레드 내부에서 실행
            if self.similarEntityIsOn {
                
                request = self.similarEntity as String?
                self.similarEntityIsOn = false
            } else {
                request = self.requestMsg_Label?.text
                
            }
            
            self.requestMsg_Label?.text = " "
            
            // DialogFlow 서버에 requestMsg 전송 후 handler 호출
            CustomHttpRequest().phpCommunication(url: "vendor/intent_query.php", postString: "query=\(request!)"){
                responseString in
                
                var dict = CustomConvert().convertStringToDictionary(text: responseString as! String)
                
                let responseMessage = dict!["response"] as! String
                let intentName = dict!["intentName"] as! String
                let parameter = dict!["parameters"] as? NSDictionary
                
                print("1.\n",responseMessage)
                print("2.\n",intentName)
                
                // CONTEXT DELETE
                CustomHttpRequest().phpCommunication(url: "vendor/context_delete.php", postString: ""){
                     responseString in
                }
                
                
                // Dialogflow의 파라미터 값 받기
                let parameter_name = intentName + "_NAME"
                if let name = parameter?[parameter_name] {
                    
                    self.name = name as? String
                    print("이름: \(String(describing: self.name))")
                }
                if let count = parameter?["number"] {
                    
                    self.count = Int(count as! String)
                    print("개수: \(String(describing: self.count))")
                }
                if let size = parameter?["SIZE_NAME"] {
                    
                    self.size = size as? String
                    print("사이즈: \(String(describing: self.size))")
                }
                if let sugar = parameter?["SUGAR"] {
                    
                    self.sugar = sugar as? String
                    print("당도: \(String(describing: self.sugar))")
                }
                if let whippedcream = parameter?["WHIPPEDCREAM"] {
                    
                    self.whippedcream = whippedcream as? String
                    print("휘핑크림: \(String(describing: self.whippedcream))")
                }
                
                
                // Dialogflow의 response message 분석
                // 1. Dialogflow가 질문자의 발화를 이해하지 못한 경우 (2가지로 판단 가능)
                if responseMessage.contains("정확한 메뉴 이름을 말씀해주시겠어요 ?") { // 1-1. fallback intents 로 들어간 경우 혹은,
                    
                    CustomHttpRequest().phpCommunication(url: "similarity/measureSimilarity.php", postString: "word=\(request!)&category=MENU") {
                        responseString in
                        
                        self.getSimilarEntityHandler(responseString as NSString, responseMessage, "")
                    }
                } else if self.befResponse == responseMessage { // 1-2. 같은 질문 반복 (메뉴 질문에 대해서만)
                    if responseMessage.contains("어떤") { // 1-2-1. 메뉴 이름에 대해
                        
                        CustomHttpRequest().phpCommunication(url: "similarity/measureSimilarity.php", postString: "word=\(request!)&category=\(intentName)") {
                            responseString in
                                                                        
                            self.getSimilarEntityHandler(responseString as NSString, responseMessage, "")
                        }
                        
                    } else if (responseMessage.contains("사이즈")) { // 1-2-2. 사이즈에 대해
                        
                        CustomHttpRequest().phpCommunication(url: "similarity/measureSimilarity.php", postString: "word=\(request!)&category=SIZE") {
                            responseString in
                                                                        
                            self.getSimilarEntityHandler(responseString as NSString, responseMessage, "")
                        }
                        
                    } else { // 1-2-3. 유사도 추천이 없는 질문의 경우
                        
                        DispatchQueue.main.async {
                            self.similarSelect_Btn.isHidden = true
                            self.startTTS(responseMessage){}

                            // 질문이 반복되는지 감지하기 위해
                            self.befResponse = responseMessage
                        }
                        
                    }
                    
                // 2. 장바구니에 담은 경우
                } else if responseMessage.contains("담았습니다.") {
                    
                    // 가격정보 받은 후 장바구니(ShoppingListViewController)로 전송하고,
                    CustomHttpRequest().phpCommunication(url: "price.php", postString: "name=\(self.name!)&size=\(self.size!)&count=\(self.count!)") {
                        price in
                                                            
                        DispatchQueue.main.async {
                            
                            let ad = UIApplication.shared.delegate as? AppDelegate
                            
                            // 장바구니 개수 갱신
                            ad?.numOfProducts += 1
                            
                            if let name = self.name {
                                ad?.menuNameArray.append(name)
                            }
                            
                            if let size = self.size {
                                ad?.menuSizeArray.append(size)
                            }
                            
                            if let count = self.count {
                                ad?.menuCountArray.append(count)
                            }
                            
                            if let price = price as? NSString {
                                ad?.menuEachPriceArray.append(Int(price.intValue))
                            }
                    
                            if self.sugar == nil {
                                ad?.menuSugarContent.append("NULL")
                            } else {
                                
                                if let sugar = self.sugar {
                                    ad?.menuSugarContent.append(sugar)
                                }
                            }
                            
                            if self.whippedcream == nil {
                                ad?.menuIsWhippedCream.append("NULL")
                            } else {
                                
                                if let whippedcream = self.whippedcream {
                                    ad?.menuIsWhippedCream.append(whippedcream)
                                }
                            }
                            
                            ad?.menuStoreName = self.storeKorName!
                            
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    
                // 3. 장바구니에 담지 않고 끝내는 경우
                } else if responseMessage.contains("필요하실때 다시 불러주세요.") {
                    
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                // 4. 일반적인 경우
                } else {
                    print("일반")

                    DispatchQueue.main.async {
                        self.similarSelect_Btn.isHidden = true
                    }
                    self.startTTS(responseMessage){}
                    
                    // 질문이 반복되는지 감지하기 위해
                    self.befResponse = responseMessage
                }
                
            }
        }
    }
    
    func startSTT(){
        
        // 사용자의 발화 마무리 시점을 파악하기 위한 변수들
        var recordingState: Bool = false
        var recordingCount: Int = 0
        var monitorCount: Int = 0
        var befRecordingCount: Int = 0
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        // 사용자의 부분적인 발화도 모두 인식하도록 설정
        recognitionRequest.shouldReportPartialResults = true
        
        // 소리 input을 받기 위해 input node 생성
        inputNode = audioEngine?.inputNode
        
        // 특정 bus의 outputformat 반환: 보통 0번이 outputformat, 1번이 inputformat ( https://liveupdate.tistory.com/400 )
        let recordingFormat = inputNode?.outputFormat(forBus: 0)
        
        
        // 1. 음성인식 준비 및 시작
        audioEngine?.prepare()
        print("record ready")
        do {
            try audioEngine?.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        DispatchQueue.main.async {
            self.animation?.play()
            self.requestMsg_Label.text = " "
        }
        
        // 새 쓰레드 생성
        // 2. bus에 audio tap을 설치하여 inputnode의 output 감시: audioEngine이 start인 경우 계속해서 반복
        inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, when) in
            
            self?.recognitionRequest?.append(buffer)
            
            
            // 사용자의 무음 시간 체크
            print("monitoring")
            monitorCount+=1
            
            // 사용자가 유사도 높은 단어 사용 선택 시
            if self?.similarEntityIsOn ?? false {
                
                recordingState = true
                monitorCount = 12
                recordingCount = befRecordingCount
            }
            
            if recordingState { // 사용자가 말을 하기 시작하면 recordingState가 true 가 됨
                monitorCount %= 13 // monitorCount는 0~12
                
                if(monitorCount / 12 == 1){ // monitorCount가 12이 될 때마다 recordingCount 증가 여부 검사
                    if(recordingCount == befRecordingCount){ // 사용자가 말을 끝마친 경우 전송
                        
                        print("EndOfConversation")
                                
                        // STT 멈추기
                        self?.audioEngine?.stop()
                        recognitionRequest.endAudio()
                        
                        recordingState = false
                        recordingCount = 0
                        monitorCount = 0
                        befRecordingCount = 0
                        
                        // Dialogflow 메시지 처리
                        self?.processMsg()
                        
                    } else {
                        
                        befRecordingCount = recordingCount
                    }
                }
            }
            
            print("\(recordingCount), \(befRecordingCount), \(monitorCount)")
        }
        
        
        // 3. inputnode의 output이 감지될 때마다 resultHandler callback 함수 호출
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { [weak self] (result, error) in
            print("recording")
            
            // recording 상태 기록
            recordingState = true
            recordingCount += 1
            
            var isFinal = false
            
            if result != nil {
                
                self?.requestMsg_Label.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            /* 오류가 없거나 최종 결과가 나오면 audioEngine (오디오 입력)을 중지하고 인식 요청 및 인식 작업을 중지 */
            if error != nil || isFinal {
                
                self?.audioEngine?.stop() // 이미 앞에서 stop해서 필요 없는 거같은데 일단 보류
                self?.inputNode?.removeTap(onBus: 0)
                
                self?.recognitionRequest = nil
                self?.recognitionTask = nil
                
            }
        })
    } // End of startSTT
    
    // 유사한 단어 유무를 구별하여 처리: 유사한 단어를 찾았는데 유사한 단어가 아예 없는 경우 추천해주지 않고 일반적인 안내가 나오도록함
    func getSimilarEntityHandler(_ recommendedWord: NSString, _ responseMsg: String, _ helpText: String) {
        
        // 유사한 단어가 없을 경우
        if(recommendedWord == ""){
            self.startTTS(responseMsg) {}
            
        // 있을 경우
        }else{
            self.startTTS("\(recommendedWord)\(helpText)가 맞다면 화면을 더블탭, 아니면 다시 말씀해주세요.") {}
            self.similarEntity = recommendedWord
            
            DispatchQueue.main.async {
                self.similarSelect_Btn.isHidden = false
            }
            
            // Voiceover 포커스를 select_Btn으로 바꿈
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: self.similarSelect_Btn)
        }
    }
    
    // BackButton 클릭 시 수행할 action 지정
    @objc func buttonAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: IBAction
    @IBAction func select_Btn(_ sender: Any) {
        
        self.similarEntityIsOn = true
        self.similarSelect_Btn.isHidden = true
        
        self.popUp_Label.text = "확인"
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: self.popUp_Label)
        popUpFlag = true
    }
    
}


extension DialogFlowPopUpController: AVSpeechSynthesizerDelegate {
    
    // TTS 끝날 시 호출
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        
        self.semaphore.signal()
    }
}
