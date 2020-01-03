//
//  DialogueFlowPopUpController.swift
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


/*
 recieve_MSG = 챗봇을 통하여 답장을 받는 변수.
 input_Msg = 사용자의 목소리를 텍스트하여 보여지는 곳
 recording_Btn = 사용자의 목소리를 녹음 시작/정지 할 수 있는 버튼
 */
class DialogueFlowPopUpController: UIViewController{
    
    /*
    recieve_MSG = 챗봇을 통하여 답장을 받는 label(라벨).
    input_Msg = 사용자의 목소리를 텍스트하여 보여지는 TextView
    recording_Btn = 사용자의 목소리를 녹음 시작/정지 할 수 있는 Button(버튼)
    */
    @IBOutlet weak var recieve_Msg: UILabel!
        
    @IBOutlet weak var input_Msg: UITextView!
    
    @IBOutlet weak var recording_Btn: UIButton!
        
    
    /*speechSynthesizer = TTS가능하게 하는 변수.*/
    let speechSynthesizer = AVSpeechSynthesizer()
    
    
    /*STT관련 Speech 변수들*/
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    
    
    /*
     TTS관련 함수들
     func speechAndText(text: String)
     Text를 음성으로 바꾸어주는 함수이다. Button의 action이벤트를통하여 출력된 결과문의 text를 받아서 음성으로 바꿔준다. language=한국말
     */
    func speechAndText(text: String) {
        let speechUtterance = AVSpeechUtterance(string: text)
        //한글말로 말하기.
        let utterance = AVSpeechUtterance(string: recieve_Msg.text!)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        utterance.rate = 0.4
        
        /*
         text가 이곳에서 APIAI를통한 챗봇의 응답을 저장하는 공간이다.
         */
        speechSynthesizer.speak(speechUtterance)
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
            self.recieve_Msg.text = text
        }, completion: nil)
        
    }
    
    
    
    /*
     STT관련 함수
    1. func startStopAct() -> (Void)
    2. func startRecording()
    
    1. audioEngine의 running에 따라, 음성인식기능(startRecording)
    시작할지 말지에 대한 함수이다.
    2. 음성인식 기록시작
    
    */
    
    
    
    @IBAction func startStopAct(_ sender: Any) {
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            
            //sendMessage()
            let request = ApiAI.shared().textRequest()
            
            //            if let text = self.recieve_Msg.text, text != "" {
            if self.input_Msg.text != "" {
                request?.query = self.input_Msg.text
            } else {
                return
            }
            
            request?.setMappedCompletionBlockSuccess({ (request, response) in
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
                
                
                
                
                
                
                
                
                
                if let textResponse = response.result.fulfillment.speech {
                    print(textResponse)
                    self.speechAndText(text: textResponse)
                }
            }, failure: { (request, error) in
                print(error!)
            })
            
            ApiAI.shared().enqueue(request)
            input_Msg.text = " "
            
            recording_Btn.setTitle("녹음 시작", for: .normal)
        } else {
            startRecording()
            
            recording_Btn.setTitle("녹음 중", for: .normal)
            
        }
    }
    
    
    /*인식 작업이 실행 중인지 확인합니다. 이 경우 작업과 인식을 취소합니다.*/
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
         audioEngine (장치)에 녹음 할 오디오 입력이 있는지 확인하십시오.
         그렇지 않은 경우 치명적 오류가 발생합니다.
         inputNode를 통해 오디오입력이 수행
         guard let 하지 않는 이유는 inputNode는 Nil인 순간 실행 자체가 안되기에 Nil자체를 받지 않는다.
         */
        let inputNode = audioEngine.inputNode
        /*
         recognitionRequest 객체가 인스턴스화되고 nil이 아닌지 확인합니다.
         */
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        /*
         사용자가 말할 때의 인식 부분적인 결과를보고하도록
         recognitionRequest에 지시합니다.
         */
        recognitionRequest.shouldReportPartialResults = true
        /*
         인식을 시작하려면 speechRecognizer의 recognitionTask 메소드를
         호출합니다. 이 함수는 완료 핸들러가 있습니다. 이 완료 핸들러는 인식
         엔진이 입력을 수신했을 때, 현재의 인식을 세련되거나 취소 또는 정지 한
         때에 불려 최종 성적표를 돌려 준다.
         */
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            /*
             부울을 정의하여 인식이 최종인지 확인한다.
             */
            var isFinal = false
            
            if result != nil {
                /*
                 결과가 nil이 아닌 경우 textView.text 속성을 결과의 최상의 텍스트(inputMsg)로 설정합니다.
                 결과가 최종 결과이면 isFinal을 true로 설정된다.
                 */
                self.input_Msg.text = result?.bestTranscription.formattedString
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
        
        /*
         recognitionRequest에 오디오 입력을 추가하십시오.
         인식 작업을 시작한 후에는 오디오 입력을 추가해도 괜찮습니다.
         오디오 프레임 워크는 오디오 입력이 추가되는 즉시 인식을 시작합니다.
         */
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        //input_sg.text = "무엇이 필요하신가요?"
        input_Msg.text = " "
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*나머지 기본 함수.*/
        
    override func viewDidLoad() {
           super.viewDidLoad()
    }
    
    @IBAction func close_Btn(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
        
    }
}
