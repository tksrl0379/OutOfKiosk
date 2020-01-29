//
//  DialogFlowPopUpController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/03.
//  Copyright © 2020 OOK. All rights reserved.
//

/* 30초간 아무 말도 안하면 음성인식 기능 종료됨.*/



/*
 고칠 것들.
 
 1. 아주 가~끔 음성인식이 안먹을 때가 있는데 여러번 반복해서 테스트해서 원인 알아내기
 -> usleep쪽일 것으로 추측되는데 이런 방식 말고 thread block / wait 방법 찾아보기
 --> 세마포어를 이용하여 STT중에는 cpu 점유유을 10%대까지 낮추는데 성공했으나 TTS 중에는 아직 방법 찾는 중. 추후 고칠 예정.
 
 
 */


import ApiAI
import AVFoundation
import Speech
import UIKit
import Alamofire
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
    
    /* 뒷배경 blur 처리위한 함수 */
    //var blurEffectView: UIView?
    
    /* ViewController 종료를 알리는 변수 */
    private var viewIsRunning : Bool = true
    
    /* startRecording()의 콜백함수들 종료 여부 체크 변수 (STT / TTS 타이밍을 맞추기 위한 변수들)  */
    //var checkMain :Bool = false
    //private var checkSttFinish : Bool = true
    //private var checkSendCompleteToAI :Bool = true
    private var checkResponseFromAI :Bool = true
    //private var checkGetPriceFromDB : Bool = true
    
    // checkSimilarEntityIsGet은 1. 유사한 단어 정보를 DB로부터 받고 -> 2. TTS를 수행하고 나서 3. startStopAct()의 쓰레드의 if문으로 들어가 STT(startRecording)를 수행하기 위한 변수. 이 변수가 없으면 DB로부터 아직 유사 단어 추천을 받지 못했는데 STT가 시작된다. (STT-> DB순서가 되버리기 때문에 이 순서를 맞춰주기 위함)
    var checkSimilarEntityIsGet: Bool = true
    
    /* Dialogflow parameter 변수 */
    private var name: String?
    private var count: Int?
    private var size: String?
    private var sugar: String?
    private var whippedcream: String?
    
    /* Btn 관련 변수
     1. receivedMsg_Label: 챗봇을 통하여 답장을 받는 label(라벨)
     2. requestMsg_Label: 사용자의 목소리를 텍스트하여 보여지는 TextView
     3. recording_Btn: 사용자의 목소리를 녹음 시작/정지 할 수 있는 Button(버튼)
     */
    @IBOutlet weak var receivedMsg_Label: UILabel!
    @IBOutlet weak var requestMsg_Label: UITextView!
    //@IBOutlet weak var recording_Btn: UIButton!
    
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
                //print (self.checkSttFinish, self.checkSendCompleteToAI, self.checkResponseFromAI, !self.speechSynthesizer.isSpeaking)
                
                if(self.checkResponseFromAI == true && !self.speechSynthesizer.isSpeaking && self.checkSimilarEntityIsGet){ //} && self.checkGetPriceFromDB){
                    print("TTS 2", self.speechSynthesizer.isSpeaking)
                    
                    self.checkResponseFromAI = false
                    //self.checkSttFinish = false
                    //self.checkSendCompleteToAI = false
                    //self.checkMain = false
                    
                    // startRecording에서 STT를 다시 시작하는데 Tap이 remove되지 않는 경우가 아주 가끔 존재하여 removeTap을 확실히 한 번 또 해줌
                    self.inputNode?.removeTap(onBus: 0)
                    // STT 시작
                    self.startRecording()
                    self.semaphore.wait()
                }
            }
        }
       
    }
    
    
    
    
    
    /* 가격 정보 출력 */
    /* php - mysql 서버로부터 가격 정보 가져와서 가격 출력 후 receivedMsg_Label에 Dialogflow message 출력 및 TTS */
    func getPriceInfo(handler: @escaping (_ responseStrng : NSString?) -> Void){
        /* php 통신 */
        let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/price.php")! as URL)
        request.httpMethod = "POST"
        
        let postString = "name=\(self.name!)&size=\(self.size!)&count=\(self.count!)";
        print(self.size!)
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        
        /* URLSession: HTTP 요청을 보내고 받는 핵심 객체 */
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            print("response = \(response!)")
            
            /* php server에서 echo한 내용들이 담김 */
            var responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            /* php서버와 통신 시 NSString에 생기는 개행 제거 */
            responseString = responseString?.trimmingCharacters(in: .newlines) as NSString?
            
            print("responseString = \(responseString!)")
            
            /* UI 변경은 메인쓰레드에서만 가능 */
            
            //self.speechAndText(textResponse + " 총 \(responseString!)원입니다. 주문하시겠습니까 ?")
            handler(responseString)
            
        }
        task.resume()
    }
    
    /* Dialogflow가 이해하지 못한 단어와 가장 유사도가 높은 Entity를 DB로부터 추천받음 */
    func getSimilarEntity(_ undefinedString: String?, _ FullWord: String?, handler: @escaping (_ responseStr : NSString?)-> Void ){
        let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/similarity/measureSimilarity\(FullWord!).php")! as URL)
        request.httpMethod = "POST"
        
        let postString = "word=\(undefinedString!)"
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        /* URLSession: HTTP 요청을 보내고 받는 핵심 객체 */
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            
            
            var responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            /* php서버와 통신 시 NSString에 생기는 개행 제거 */
            responseString = responseString?.trimmingCharacters(in: .newlines) as NSString?
            //print("responseString = \(responseString!)")
            print("유사도 높은 단어:", responseString)
            handler(responseString)
        }
        //실행
        task.resume()
    }
    
    
    
    
    
    /* 응답 출력 및 읽기(TTS) */
    func speechAndText(_ textResponse: String) {
        
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
                        
                        
                        
                        /* 2.1. Dialogflow에 requestMsg 전송: 이 전송이 완료 되면 아래의 전송완료 콜백함수 호출 */
                        let request = ApiAI.shared().textRequest()
                        
                        /* request query 만들고 전송*/
                        DispatchQueue.main.async{ // UILabel 때문에 Main 쓰레드 내부에서 실행
                            if(self.similarEntityIsOn){
                                print("들어왔음", self.similarEntity)
                                request?.query = self.similarEntity
                                self.similarEntityIsOn = false
                            }else{
                                request?.query = self.requestMsg_Label?.text
                            }
                            ApiAI.shared().enqueue(request) // request.query를 받은 다음 실행해야 하기 때문에 Main 쓰레드 내부에서 같이 실행 (바깥에서 실행 시 비동기적 실행으로 오류 가능성 높음)
                            
                            self.requestMsg_Label?.text = " "
                           
                        }
                        
                        /* 2.2. requestMsg 전송완료 시 호출되는 콜백함수 */
                        request?.setMappedCompletionBlockSuccess({ (request, response) in
                            
                            let response = response as! AIResponse
                            
                            /* 2.2.1. Dialogflow의 파라미터 값 받는 공간 */
                            if let parameter = response.result.parameters as? [String : AIResponseParameter]{
                                
                                let parameter_name = response.result.metadata.intentName + "_NAME"
                                if let name = parameter[parameter_name]?.stringValue{
                                    
                                    self.name = name
                                    print("이름: \(String(describing: self.name))")
                                };
                                if let count = parameter["number"]?.numberValue{
                                    
                                    self.count = count as? Int
                                    print("개수: \(String(describing: self.count))")
                                };
                                if let size = parameter["SIZE_NAME"]?.stringValue{
                                    
                                    self.size = size
                                    print("사이즈: \(String(describing: self.size))")
                                };
                                if let sugar = parameter["SUGAR"]?.stringValue{
                                    
                                    self.sugar = sugar
                                    print("당도: \(String(describing: self.sugar))")
                                };
                                if let whippedcream = parameter["WHIPPEDCREAM"]?.stringValue{
                                    
                                    self.whippedcream = whippedcream
                                    print("휘핑크림: \(String(describing: self.whippedcream))")
                                };
                                
                                //self.checkSendCompleteToAI = true
                            }
                            
                            /* 2.2.2. Dialogflow 응답 받고 responseMsg_Label에 출력 및 TTS */
                            if let textResponse = response.result.fulfillment.speech {
                                print(textResponse)
                                
                                /*
                                 /* 선택 완료 후 가격정보 출력 */
                                 if(textResponse.contains("선택하셨습니다.")){
                                 
                                 //self.checkGetPriceFromDB = false
                                 
                                 /* php - mysql 서버로부터 가격 정보 가져와서 receivedMsg_Label에 'Dialogflow message + 가격정보' 출력 및 TTS */
                                 self.getPriceInfo(textResponse){
                                 responseString in
                                 
                                 self.speechAndText(textResponse + " 총 \(responseString!)원입니다. 주문하시겠습니까 ?")
                                 self.checkGetPriceFromDB = true
                                 }
                                 
                                 /* 주문 정보 전송 */
                                 } else if(textResponse.contains("주문 완료되었습니다.")){
                                 
                                 /* php - mysql 서버로 주문 정보 전송 후 receivedMsg_Label에 Dialogflow message 출력 및 TTS*/
                                 self.sendOrder(textResponse)
                                 */
                                
                                
                                /* Dialogflow가 질문자의 발화를 이해하지 못한 경우 (2가지로 판단 가능) */
                                if(textResponse.contains("정확한 메뉴 이름을 말씀해주시겠어요 ?")){ // 1. fallback intents 로 들어간 경우 혹은,
                                    self.checkSimilarEntityIsGet = false
                                    self.getSimilarEntity(self.requestMsg_Label.text, "FullWord"){
                                        response in
                                        print(response)
                                        
                                        /* 유사한 단어가 없을 경우 */
                                        if(response == ""){
                                            self.speechAndText(textResponse)
                                            self.checkSimilarEntityIsGet = true
                                        /* 있을 경우 */
                                        }else{
                                            self.speechAndText("\(response!)가 맞다면 화면을 더블탭, 아니면 다시 말씀해주세요.")
                                            self.checkSimilarEntityIsGet = true
                                            self.similarEntity = response
                                            DispatchQueue.main.async{
                                                self.select_Btn.isHidden = false
                                            }
                                            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: self.select_Btn)
                                        }
                                        
                                        
                                    }
                                    
                                }else if(self.befResponse == textResponse){ // 2. 같은 질문 반복
                                    print("same response")
                                    self.checkSimilarEntityIsGet = false
                                    self.getSimilarEntity(self.requestMsg_Label.text, ""){
                                        response in
                                        print(response)
                                        
                                        /* 유사한 단어가 없을 경우 */
                                        if(response == ""){
                                            self.speechAndText(textResponse)
                                            self.checkSimilarEntityIsGet = true
                                        /* 있을 경우 */
                                        }else{
                                            self.speechAndText("\(response!)가 맞다면 화면을 더블탭, 아니면 다시 말씀해주세요.")
                                            self.checkSimilarEntityIsGet = true
                                            self.similarEntity = response
                                            DispatchQueue.main.async{
                                                self.select_Btn.isHidden = false
                                            }
                                            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: self.select_Btn)
                                        }
                                        
                                    }
                                    
                                    
                                    /* 마지막 단계 (데이터 전송 및 종료) - 2가지 시나리오 */
                                    // 1. 장바구니에 담고 끝내는 시나리오 혹은,
                                }else if(textResponse.contains("담았습니다.")){
                                    // Db - php 서버로부터 가격정보 받은 후 장바구니(ShoppingListViewController)로 전송하고,
                                    self.getPriceInfo(){
                                        price in
                                        
                                        
                                        print("가격", price)
                                        
                                        
                                        /*
                                         AppDelegate.swift를 이용하기.
                                         모든 View에서 참조 가능하며 앱을 종료하지않는한 지속된다.
                                         혹시 모를 뒤로가기버튼으로 인해 CafeDetailController를 나가더래도
                                         AppDelegeate에 저장될 것이다. Main쓰레드에서만 가능하므로
                                         DispatchQueue를 이용한다.
                                         */
                                        DispatchQueue.main.async {
                                            
                                            let ad = UIApplication.shared.delegate as? AppDelegate
                                            
                                            /* 주문이 완료됨에 따라 장바구니 옆에 현재 몇개의 아이템이 있는지 알려준다.*/
                                            ad?.numOfProducts += 1
                                            
                                            //self.willGetShoppingBasket_Btn.setTitle("장바구니 : " + String(ad!.numOfProducts) + " 개", for: .normal)
                                            
                                            if let name = self.name{
                                                ad?.menuNameArray.append(name)
                                            }
                                            if let size = self.size{
                                                ad?.menuSizeArray.append(size)
                                            }
                                            if let count = self.count{
                                                ad?.menuCountArray.append(count)
                                            }
                                            if let price = price{
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
                                            
                                            
                                        }
                                        
                                    }
                                    /* 대화가 모두 끝난 이후에도 TTS가 나와서 이를 막기 위함 */
                                    self.viewIsRunning = false
                                    //종료
                                    self.navigationController?.popViewController(animated: true)
                                    
                                    /* 2. 장바구니에 담지 않고 끝내는 시나리오 */
                                }else if(textResponse.contains("필요하실때 다시 불러주세요.")){                                    
                                    self.viewIsRunning = false
                                    self.navigationController?.popViewController(animated: true)
                                    
                                    /* 일반적인 경우 */
                                }else{
                                    self.select_Btn.isHidden = true
                                    self.speechAndText(textResponse)
                                    
                                    // 질문이 반복되는지 감지하기 위해
                                    self.befResponse = textResponse
                                }
                                print("success")
                                
                                DispatchQueue.main.async {
                                    
                                    self.checkResponseFromAI = true
                                    self.semaphore.signal()
                                    print("signal")
                                }
                            }
                            
                            
                            /* 실패 시 */
                        }, failure: { (request, error) in
                            print("error")
                            print(error!)
                        }) // End of 2.2 setMappedCompletionBlockSuccess
                        
                    }else{
                        
                        befRecordingCount = recordingCount
                    }
                }
            }
            
            print("\(recordingCount), \(befRecordingCount), \(monitorCount)")
            
            
            
        } // End of 2.inputNode.installTap
        
        
        
        
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
                
                //self.checkSttFinish = true
            }
        })
        
        
        
    } /* End of startRecording */
    
    
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
        let addButton = UIBarButtonItem(image:UIImage(named:"left"), style:.plain, target:self, action:#selector(DialogFlowPopUpController.buttonAction(_:)))
        addButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = addButton
        //self.navigationItem.leftBarButtonItem?.isAccessibilityElement = true
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "뒤로가기"
        //self.navigationItem.leftBarButtonItem?.accessibilityTraits = .none
        
        /* Lottie animation 설정 */
        animation = AnimationView(name:"loading")
        animation!.frame = CGRect(x:0, y:0, width:400, height:400)
        
        animation!.center = self.view.center
        
        animation!.contentMode = .top
        animation!.loopMode = .loop
        animationView.addSubview(animation!)
        //self.animation!.play()
        
        
        /* 오디오 설정: 이 코드를 넣어줘야 실제 디바이스에서 TTS가 정상적으로 작동 */
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)//.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.default)
            
        }catch{
            print("error")
        }
        
        
        
        /* Dialogflow에 requestMsg 전송 */
        let request = ApiAI.shared().textRequest()
        
        request?.query = "스타벅스"
        
        /* Dialogflow 전송 부분 */
        ApiAI.shared().enqueue(request)
        
        /* requestMsg 전송완료 시 콜백함수 호출 */
        request?.setMappedCompletionBlockSuccess({ (request, response) in
            
            /* 성공 시 */
            let response = response as! AIResponse
            
            /* 응답 받고 responseMsg_Label에 출력 */
            if let textResponse = response.result.fulfillment.speech {
                print(textResponse)
                print("success")
                
                /*
                 스타벅스 가게로 들어온 상황, 이곳에서 favoriteMenuName이 nil인지 아닌지 확인
                 favoriteMenuName != nil <-FavoriteMenuController에서 주문이 들어온 상황
                 favoriteMenuName == nil <-CafeDetailControlelr에서 음성주문 시작
                 */
                
                if (self.favoriteMenuName != nil) { //값이 들어있을때 예) 초콜렛 스무디 <-다시한번 다이얼로그챗봇 대화한다.
                    
                    let request = ApiAI.shared().textRequest()
                    request?.query = self.favoriteMenuName!
                    ApiAI.shared().enqueue(request)
                    
                    request?.setMappedCompletionBlockSuccess({ (request, response) in
                        /* 성공 시 */
                        let response = response as! AIResponse
                        /* 응답 받고 responseMsg_Label에 출력 */
                        if let textResponse = response.result.fulfillment.speech {
                            print(textResponse)
                            print("success")
                            self.speechAndText(textResponse)
                            /*매장의 request.query에 대한 값을 성공적으로 받으면 StartStopAct()를 시작하도록 한다.
                             VoiceOver 특성상 '뒤로' 버튼이 읽히므
                             */
                            self.StartStopAct()
                        }
                        /* 실패 시 (즐겨찾기)*/
                    }, failure: { (request, error) in
                        print("error")
                        print(error!)
                    })
                }else{
                    /* 즐겨찾기 주문이 아닌 일반 주문*/
                    self.speechAndText(textResponse)
                    self.StartStopAct()
                }
            }
            
            
            
            /* 실패 시 */
        }, failure: { (request, error) in
            print("error")
            print(error!)
        }) // End of request complete call back
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        /* DialogFlowPopUpController 가 종료될 때 CafeDetailController에 있는 blurEffectView 삭제 */
        //blurEffectView?.removeFromSuperview()
        
        
        viewIsRunning = false
        inputNode?.removeTap(onBus: 0)
        
        /* Dialogflow에 requestMsg 전송: Dialogflow의 context를 초기화 시켜줘야 함 */
        let request = ApiAI.shared().textRequest()
        
        request?.query = "취소"
        
        /* Dialogflow 전송 부분 */
        ApiAI.shared().enqueue(request)
        
        /* requestMsg 전송완료 시 콜백함수 호출 */
        request?.setMappedCompletionBlockSuccess({ (request, response) in
            
            /* 성공 시 */
            let response = response as! AIResponse
            
            /* 응답 받고 responseMsg_Label에 출력 */
            if let textResponse = response.result.fulfillment.speech {
                print(textResponse)
                print("success")
                self.speechAndText(textResponse)
                
                /*매장의 request.query에 대한 값을 성공적으로 받으면 StartStopAct()를 시작하도록 한다.
                 VoiceOver 특성상 '뒤로' 버튼이 읽히므
                 */
                self.StartStopAct()
            }
            
            
            
            /* 실패 시 */
        }, failure: { (request, error) in
            print("error")
            print(error!)
        }) // End of request complete call back
        
    }
    
    
}
