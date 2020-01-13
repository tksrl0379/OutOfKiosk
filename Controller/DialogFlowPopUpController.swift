//
//  DialogFlowPopUpController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/03.
//  Copyright © 2020 OOK. All rights reserved.
//

/* 30초간 아무 말도 안하면 음성인식 기능 종료됨.*/

/*
 TTS기능을 위해서
 -ApiAI
 -AVFoundation
 import해 주어야 한다.
 
 STT기능을 위해
 -Speech해 주어야 한다.
 
 php통신으로 mysql로 보내기 위해
 Alamofire(JSON)을 이용한다.
 
 */


/*
 1. 가격 정보 띄우기 ( mysql DB테이블 '모카스무디 그란데' 형식으로 바꿔야 함)
 2. 음성 녹음 전, 녹음 중 이미지 띄우기
 3. 아주 가~끔 음성인식이 안먹을 때가 있는데 여러번 반복해서 테스트해서 원인 알아내기
 4. dialogflow 흐름 자연스럽게 변경 필요 및 context 횟수 늘릴 수 있는지 확인
 */


import ApiAI
import AVFoundation
import Speech
import UIKit
import Alamofire



class DialogFlowPopUpController: UIViewController{
    
    //var blurEffectView: UIView?
    var inputNode: AVAudioInputNode?
    /* ViewController 종료를 알리는 변수 */
    private var viewIsRunning : Bool = true
    
    /* startRecording()의 콜백함수들 종료 여부 체크 변수  */
    //var checkMain :Bool = false
    private var checkSttFinish : Bool = true
    private var checkSendCompleteToAI :Bool = true
    private var checkResponseFromAI :Bool = true
    private var checkGetPriceFromDB : Bool = true
    
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
     */
    private var speechRecognizer : SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    
    /* 녹음 시작, 중단 버튼 시 이벤트 처리 */
    func StartStopAct() {
        
        /* 한국어 설정 */
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
        
        
        /* startRecording() 내부의 콜백함수들 종료 여부 체크 후 startRecording() 재실행 */
        DispatchQueue.global().async {
            while(self.viewIsRunning){
                /* 과도한 CPU 점유 막기 위해 usleep */
                usleep(10)
                if(self.checkSttFinish == true && self.checkSendCompleteToAI == true && self.checkResponseFromAI == true && !self.speechSynthesizer.isSpeaking && self.checkGetPriceFromDB){
                    print("TTS 2", self.speechSynthesizer.isSpeaking)
                    self.checkSttFinish = false
                    self.checkSendCompleteToAI = false
                    self.checkResponseFromAI = false
                    //self.checkMain = false
                    
                    self.startRecording()
                }
            }
        }
        
        //recording_Btn.setTitle("녹음 중", for: .normal)
        
    }
    
    


    
    /* 가격 정보 출력 */
    /* php - mysql 서버로부터 가격 정보 가져와서 가격 출력 후 receivedMsg_Label에 Dialogflow message 출력 및 TTS */
    func getPriceInfo(_ textResponse: String, handler: @escaping (_ responseStrng : NSString?) -> Void){
        /* php 통신 */
        let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/price.php")! as URL)
        request.httpMethod = "POST"
        
        let postString = "name=\(self.name!)&count=\(self.count!)";
        
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
    
    /* 주문 정보 전송 */
    /* php - mysql 서버로 주문 정보 전송 후 receivedMsg_Label에 Dialogflow message 출력 및 TTS*/
    func sendOrder(_ textResponse: String){
        self.speechAndText(textResponse)
        
        
        /* 아래의 parameter 넣는 곳이 강제 unwrapping인 !이기 때문에 nil이 들어가면 안됨. 따라서 문자열 값 넣어줌 */
        if self.sugar == nil {
            self.sugar = "NULL"
        }
        
        if self.whippedcream == nil {
            self.whippedcream = "NULL"
        }
        
        //creating parameters for the post request
        let parameters: Parameters=[
            "name": self.name! ,
            "count": self.count!,
            "size": self.size!,
            "sugar": self.sugar!,
            "whippedcream": self.whippedcream!
        ]
        
        /* php 서버 위치 */
        let URL_ORDER = "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/order/api/order.php"
        //Sending http post request
        Alamofire.request(URL_ORDER, method: .post, parameters: parameters).responseString
            {
                response in
                
                print("응답",response)
                
                /* 재주문하는 경우를 대비하여 nil로 초기화 해줘야 함. 아니면 query가 여러번 날라감 */
                self.name = nil
                self.count = nil
                self.size = nil
                self.sugar = nil
                self.whippedcream = nil
        }
    }
    
    
    /* 응답 출력 및 읽기(TTS) */
    func speechAndText(_ textResponse: String) {
        
        DispatchQueue.main.async {
            /* Dialogflow로부터 받은 응답 출력 */
            self.receivedMsg_Label.text = textResponse
        }
        
        
        /* 응답 읽기(TTS) */
        let speechUtterance = AVSpeechUtterance(string: textResponse)
        
        /* 한글 설정 및 속도 조절 */
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        speechUtterance.rate = 0.6
        
        /* 음성 출력 */
        speechSynthesizer.speak(speechUtterance)
        print("TTS:", speechSynthesizer.isSpeaking)
        
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
            self.requestMsg_Label.text = " "
        }
        
        
        
        /* 새 쓰레드에서 돌아감 */
        /* 2. bus에 audio tap을 설치하여 inputnode의 output 감시: audioEngine이 start인 경우 계속해서 반복 */
        inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            
            self.recognitionRequest?.append(buffer)
            print("monitoring")
            /* 사용자의 무음 시간 체크 */
            monitorCount+=1
            if(recordingState){
                monitorCount %= 8 // monitorCount는 0~30
                if(monitorCount / 7 == 1){ // monitorCount가 30이 될 때마다 recordingCount 증가 여부 검사
                    
                    if(recordingCount == befRecordingCount){ // 사용자가 말을 끝마친 경우 전송
                        
                        print("EndOfConversation")
                        
                        /* STT 멈추기 */
                        self.audioEngine.stop()
                        recognitionRequest.endAudio()
                        
/*                        DispatchQueue.main.async{
                            self.recording_Btn.setTitle("녹음시작", for: .normal)
                        }*/
                        
                        recordingState = false
                        recordingCount = 0
                        monitorCount = 0
                        befRecordingCount = 0
                        
                        
                        
                        /* 2.1. Dialogflow에 requestMsg 전송: 이 전송이 완료 되면 아래의 전송완료 콜백함수 호출 */
                        let request = ApiAI.shared().textRequest()
                        
                        /* request query 만들고 전송*/
                        DispatchQueue.main.async{ // UILabel 때문에 Main 쓰레드 내부에서 실행
                            request?.query = self.requestMsg_Label?.text
                            ApiAI.shared().enqueue(request) // request.query를 받은 다음 실행해야 하기 때문에 Main 쓰레드 내부에서 같이 실행 (바깥에서 실행 시 비동기적 실행으로 오류 가능성 높음)
                            
                            self.requestMsg_Label?.text = " "
                            //self.checkMain = true
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
                                
                                self.checkSendCompleteToAI = true
                            }
                            
                            /* 2.2.2. Dialogflow 응답 받고 responseMsg_Label에 출력 및 TTS */
                            if let textResponse = response.result.fulfillment.speech {
                                print(textResponse)
                                
                                /* 선택 완료 후 가격정보 출력 */
                                if(textResponse.contains("선택하셨습니다.")){
                                    
                                    self.checkGetPriceFromDB = false
                                    
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
                                    
                                }else{
                                    self.speechAndText(textResponse)
                                }
                                print("success")
                                
                                self.checkResponseFromAI = true
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
                
                self.checkSttFinish = true
            }
        })
        
        
        
    } /* End of startRecording */
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        /*
         TTS 초기화를 하여 기능을 원활하게 할 수 있다.
         */
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)//.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.default)
            
        }catch{
            print("error")
        }
        
        
        
        
        viewIsRunning = true
        
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
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        /* DialogFlowPopUpController 가 종료될 때 CafeDetailController에 있는 blurEffectView 삭제 */
        //blurEffectView?.removeFromSuperview()
        
        viewIsRunning = false
        inputNode?.removeTap(onBus: 0)
        
    }
}
