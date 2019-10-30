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

class SettingController : WKInterfaceController{
    
    @IBOutlet weak var speakerSwitch: WKInterfaceSwitch!
    
    override func awake(withContext context: Any?) {
        
    }
    
    override func didAppear() {
        super.didAppear()
        speakerSwitch.setOn(UserDefaultUtils.supportSpeaker())
    }
    
    @IBAction func speakerEnable(_ value: Bool) {
        LocalMusicManager.shareInstance().pause()
        LocalMusicManager.shareInstance().willResetSession()
        UserDefaultUtils.setSpeaker(value)
    }
}
