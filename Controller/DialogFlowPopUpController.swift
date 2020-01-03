//
//  DialogFlowPopUpController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/03.
//  Copyright © 2020 OOK. All rights reserved.
//

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
import ApiAI
import AVFoundation
import Speech
import UIKit
import Alamofire



class DialogFlowPopUpController: UIViewController{
    
    var blurEffectView: UIView?
    
    override func viewWillDisappear(_ animated: Bool) {
        blurEffectView?.removeFromSuperview()
    }
    
    /* Btn 관련 변수
     1. receivedMsg_Label: 챗봇을 통하여 답장을 받는 label(라벨)
     2. requestMsg_Label: 사용자의 목소리를 텍스트하여 보여지는 TextView
     3. recording_Btn: 사용자의 목소리를 녹음 시작/정지 할 수 있는 Button(버튼)
     */
    @IBOutlet weak var receivedMsg_Label: UILabel!
    @IBOutlet weak var requestMsg_Label: UITextView!
    @IBOutlet weak var recording_Btn: UIButton!
    
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
    
    
    /* 응답 출력 및 읽기(TTS) */
    func speechAndText(_ textResponse: String) {
        
        /* Dialogflow로부터 받은 응답 출력 */
        self.receivedMsg_Label.text = textResponse
        
        /* 응답 읽기(TTS) */
        let speechUtterance = AVSpeechUtterance(string: textResponse)
        
        /* 한글 설정 및 속도 조절 */
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        speechUtterance.rate = 0.6
        
        /* 음성 출력 */
        speechSynthesizer.speak(speechUtterance)
        
    }
    
    
    
    /*
     STT관련 함수
     1. func startStopAct() -> (Void): audioEngine의 running에 따라, 음성인식기능(startRecording)의 시작 여부 결정하는 함수
     2. func startRecording(): 음성인식 시작
     */
    
    
    /* 녹음 시작, 중단 버튼 시 이벤트 처리 */
    @IBAction func startStopAct(_ sender: Any) {
        
        /* 한국어 설정 */
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
        
        /* 1. 음성인식이 진행중일시 */
        if audioEngine.isRunning {
            
            /* 오디오 입력 및 음성인식 중단 */
            audioEngine.stop()
            recognitionRequest?.endAudio()
            
            /* Dialogflow에 requestMsg 전송 */
            let request = ApiAI.shared().textRequest()
            
            if self.requestMsg_Label.text != "" {
                request?.query = self.requestMsg_Label.text
            } else {
                return
            }
            
            /* Dialogflow에게 requestMsg 전송: 이 전송이 완료 되면 아래의 전송완료 콜백함수 호출*/
            ApiAI.shared().enqueue(request)
            requestMsg_Label.text = " "
            
            recording_Btn.setTitle("녹음 시작", for: .normal)
            
            /* requestMsg 전송완료 시 콜백함수 호출 */
            request?.setMappedCompletionBlockSuccess({ (request, response) in
                
                /* 성공 시 */
                let response = response as! AIResponse

                
                //if response.result.action == "HereTogo"{ //이 공간이 실행이 되질 않는다.
                //response.result.action은 Intents를 가르키지 못하고 ""표시 되며
                //response.result.parameters를 통해서 바로 $color값을 받을 수 있다.
                
                
                /* 후에 php통신을 하는 곳.
                 
                 /*파라미터 값을 실제로 받는 공간*/
                 if let parameter = response.result.parameters as? [String : AIResponseParameter]{
                 if let burger = parameter["Burger"]?.stringValue{
                 //print(burger)
                 self.burger = burger
                 //print(self.burger) //optional binding
                 
                 };
                 if let soda = parameter["Drink"]?.stringValue{
                 //print(soda)
                 self.soda = soda
                 
                 };
                 if let num = parameter["number"]?.numberValue{
                 print("num??")
                 self.num = num as? Int
                 //print(self.num)
                 //self.num = (num as NSString).integerValue
                 //print(self.num)
                 };
                 
                 }
                 
                 /*
                 mysql에 전송할 모든 파라미터 값이 저장되었을때 실행
                 dialogflow에서 파라미터 값을 모두 받아 Alamofire란 api를 사용하여
                 localhost서버의 Mysql로 전송한다.
                 */
                 
                 if(self.burger != nil && self.soda != nil && self.num != nil){
                 /*let burger = self.burger;
                 let soda = self.soda;
                 let num = self.num;
                 */
                 //creating parameters for the post request
                 let parameters: Parameters=[
                 "burger":self.burger!,
                 "soda":self.soda!,
                 "num":self.num!
                 //"email":textFieldEmail.text!,
                 //"phone":textFieldPhone.text!
                 ]
                 
                 let URL_ORDER = "http://localhost:8080/mcdonald/api/order.php"
                 //Sending http post request
                 Alamofire.request(URL_ORDER, method: .post, parameters: parameters).responseString
                 {
                 response in
                 //printing response
                 print("응답",response)
                 
                 //getting the json value from the server
                 /*if let result = response.result.value {
                 
                 
                 //결과값을 받는 변수와 출력내용이다.
                 
                 //converting it as NSDictionary
                 let jsonData = result as! NSDictionary
                 
                 //displaying the message in label
                 self.input_Msg.text = jsonData.value(forKey: "message") as! String?
                 }*/
                 }
                 
                 }
                 
                 */
                
                /* 응답 받고 responseMsg_Label에 출력 */
                if let textResponse = response.result.fulfillment.speech {
                    print(textResponse)
                    self.speechAndText(textResponse)
                }
                
                /* 실패 시 */
            }, failure: { (request, error) in
                print(error!)
            }) // End of request complete call back
        
        /* 2. 음성인식이 중단상태일시 */
        } else {
            startRecording()
            
            recording_Btn.setTitle("녹음 중", for: .normal)
        }
    }
    
    
    /* STT 시작 */
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        /*
         오디오 녹음을 준비 할 AVAudioSession을 만듭니다. 여기서 우리는
         세션의 범주를 녹음, 측정 모드로 설정하고 활성화합니다. 이러한 속성을
         설정하면 예외가 발생할 수 있으므로 try catch 절에 넣어야합니다.
         */
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            //Error 이유는 모르겠음.
            //try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        
        /*
         recognitionRequest 객체가 인스턴스화되고 nil이 아닌지 확인합니다.
         */
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        /* 사용자의 부분적인 발화도 모두 인식하도록 설정 */
        recognitionRequest.shouldReportPartialResults = true
        
        
        
        /* 소리 input을 받기 위해 input node 생성 */
        let inputNode = audioEngine.inputNode
        
        /* 특정 bus의 outputformat 반환: 보통 0번이 outputformat, 1번이 inputformat ( https://liveupdate.tistory.com/400 ) */
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        /* 1. 음성인식 준비 및 시작 */
        audioEngine.prepare()
        print("record ready")
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        requestMsg_Label.text = " "
        
        
        
        /* 2. bus에 audio tap을 설치하여 inputnode의 output 감시: audioEngine이 start인 경우 계속해서 반복 */
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            
            self.recognitionRequest?.append(buffer)
            print("monitoring")
        }
        
        
        /* 3. inputnode의 output이 감지될 때마다 수행되는 음성인식 callback 함수 */
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            print("recording")
            /*
             부울을 정의하여 인식이 최종인지 확인한다.
             */
            var isFinal = false
            
            if result != nil {
                /*
                 결과가 nil이 아닌 경우 textView.text 속성을 결과의 최상의 텍스트(inputMsg)로 설정합니다.
                 결과가 최종 결과이면 isFinal을 true로 설정된다.
                 */
                self.requestMsg_Label.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            /*
             오류가 없거나 최종 결과가 나오면 audioEngine (오디오 입력)을 중지하고 인식 요청 및 인식 작업을 중지합니다.
             */
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                //self.startStopBtn.isEnabled = true
            }
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
