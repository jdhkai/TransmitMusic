//
//  UserDefaultUtils.swift
//  TransmitMusic WatchKit Extension
//
//  Created by chenwei on 2019/10/23.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation
class UserDefaultUtils : NSObject{
    
    // 是否支持扬声器播放
    // 在没有插入耳机时会使用扬声器播放
    static func supportSpeaker() -> Bool{
        return UserDefaults.standard.bool(forKey: "SUPPORT_SPEAKER")
    }
    
    // 设置是否支持扬声器播放
    static func setSpeaker(_ support: Bool){
        UserDefaults.standard.setValue(support, forKey: "SUPPORT_SPEAKER")
    }
    
    // 设置播放模式
    static func setLoopStyle(_ loop: LoopStyle){
        UserDefaults.standard.setValue(loop.rawValue, forKey: "LOOP_STYLE")
    }
    
    // 获取播放模式
    static func loopStyle() -> LoopStyle{
        let value = UserDefaults.standard.integer(forKey: "LOOP_STYLE")
        return LoopStyle(rawValue: value) ?? .sequence
    }
    
    // 设置音量大小
    static func setVolumeSize(_ size: Float){
        UserDefaults.standard.setValue(size, forKey: "VOLUME_SIZE")
    }
    
    // 获取音量大小
    static func getVolumeSize() -> Float{
        let optionVolume = UserDefaults.standard.value(forKey: "VOLUME_SIZE")
        if optionVolume != nil {
            return optionVolume as! Float
        }
        return 50.0
    }
}

enum LoopStyle : Int {
    case sequence
    case single
    case random
}
