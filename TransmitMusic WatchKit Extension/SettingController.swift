//
//  SettingController.swift
//  TransmitMusic WatchKit Extension
//
//  Created by chenwei on 2019/10/22.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation
import AVFoundation
import WatchKit

class SettingController : InterfaceController{
    
    @IBOutlet weak var speakerSwitch: WKInterfaceSwitch!
    
    override func awake(withContext context: Any?) {
        
    }
    
    override func didAppear() {
        speakerSwitch.setOn(UserDefaultUtils.supportSpeaker())
    }
    
    @IBAction func speakerEnable(_ value: Bool) {
        let session = AVAudioSession.sharedInstance()
        do{
            if value{
                try session.setCategory(.soloAmbient, mode: .default,policy: .default, options: [])
            }
            else{
                try session.setCategory(.playback, mode: .default,policy: .longFormAudio, options: [])
            }
            UserDefaultUtils.setSpeaker(value)
        }
        catch{
            print(error)
            speakerSwitch.setOn(!value)
        }
        session.activate(options: []) { (success, error) in
            guard error == nil else{
                print("*** An error occurred: \(error!.localizedDescription) ***")
                return
            }
            print("激活成功!")
        }
    }
}
