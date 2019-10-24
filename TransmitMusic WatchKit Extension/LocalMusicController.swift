//
//  LocalMusicController.swift
//  LocalMusic WatchKit Extension
//
//  Created by chenwei on 2019/10/14.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation
import UIKit
import WatchKit
import AVFoundation
import MediaPlayer

class LocalMusicController : InterfaceController{
    @IBOutlet weak var musicTable: WKInterfaceTable!
    
    var audioPlayer: AVAudioPlayer?
    //当前正在播放的索引
    var currentPlayIndex = -1
    //准备播放的索引
    var preparePlayIndex = -1
    //是否循环
    var loop = true
    
    //中断前的播放状态
    var interruptPlayStatus = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        loadTableData()
        
        setupRemoteTransportControls()
        
        //注册监听
        //中断通知
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
        //路由改变通知
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleSecondaryAudio), name: AVAudioSession.silenceSecondaryAudioHintNotification, object: nil)
        
        //监听音乐传输完成
        NotificationCenter.default.addObserver(self, selector: #selector(handleTransmitFinished), name: NSNotification.Name("UPDATE_MUSIC_LIST"), object: nil)
        
        
    }
    
    func loadTableData(){
        let localMp3 = LocalMusicManager.shareInstance().getAllSong()
        musicTable.setNumberOfRows(localMp3.count, withRowType: "ItemMusicRowController")
        
        for(i,music) in localMp3.enumerated(){
            let cell = musicTable.rowController(at: i) as! ItemMusicRowController
            cell.titleLabel.setText(music)
        }
    }
    
    
    @objc func handleTransmitFinished(notification: Notification){
        print("更新页面")
        musicTable.removeRows(at: IndexSet.init(0...musicTable.numberOfRows))
        loadTableData()
    }
    
    @objc func handleInterruption(notification: Notification){
        print(#function)
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        print(type.rawValue)
        if type == .began {
            // Interruption began, take appropriate actions
            if let player = self.audioPlayer{
                interruptPlayStatus = player.isPlaying
            }
            else{
                interruptPlayStatus = false
            }
        }
        else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // Interruption Ended - playback should resume
                    if interruptPlayStatus{
                        if let player = self.audioPlayer{
                            if !player.isPlaying {
                                player.play()
                            }
                        }
                    }
                } else {
                    // Interruption Ended - playback should NOT resume
                }
            }
        }
    }
    var headphonesConnected = false
    @objc func handleRouteChange(notification: Notification){
        print(#function)
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
                return
        }
        switch reason {
        case .newDeviceAvailable:
            let session = AVAudioSession.sharedInstance()
            for output in session.currentRoute.outputs where output.portType == AVAudioSession.Port.headphones {
                headphonesConnected = true
                break
            }
        case .oldDeviceUnavailable:
            if let previousRoute =
                userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                for output in previousRoute.outputs where output.portType == AVAudioSession.Port.headphones {
                    headphonesConnected = false
                    break
                }
            }
        default: ()
        }
    }
    
    @objc func handleSecondaryAudio(notification: Notification){
        print(#function)
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        preparePlayIndex = rowIndex
        
        playMusic(preparePlayIndex)
    }
    
    func playMusic(_ rowIndex: Int) -> Void {
        if prepareSongPlayer(rowIndex) && initSession() {
            print("准备播放成功")
        }
        else{
            print("播放失败")
            let cancelAction = WKAlertAction(title: "知道了", style: .cancel) {
                print("Cancel")
            }
            presentAlert(withTitle: "提示", message: "播放失败", preferredStyle: .alert, actions: [cancelAction])
        }
    }
    /*
     * 准备歌曲播放信息
     */
    func prepareSongPlayer(_ rowIndex:Int) -> Bool {
        let localMp3 = LocalMusicManager.shareInstance().getAllSong()
        let songName = localMp3[rowIndex]
        let optionDocumentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let documentURL = URL(fileURLWithPath: optionDocumentPath!)
        let fileURL = documentURL.appendingPathComponent(songName)
        //使用AVAudioPlayer播放
        if audioPlayer != nil {
            audioPlayer?.stop()
            audioPlayer?.currentTime = 0
            audioPlayer = nil
        }
        if FileManager.default.fileExists(atPath: fileURL.path) {
            print(fileURL)
            do{
                try audioPlayer = AVAudioPlayer(contentsOf: fileURL)
//                audioPlayer?.pan = 0.0
//                audioPlayer?.volume = 0.5
                audioPlayer?.delegate = self
                return true
            }
            catch{
                print(error)
                return false
            }
        }
        else{
            print("路径不存在")
        }
        return false
    }
    
    /*
     * 设置远程控制
     */
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()

        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if let player = self.audioPlayer{
                if !player.isPlaying {
                    self.setupRemoteNowPlaying(songName: LocalMusicManager.shareInstance().getAllSong()[self.currentPlayIndex])
                    player.play()
                    return .success
                }
            }
            return .commandFailed
        }

        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if let player = self.audioPlayer{
                if player.isPlaying {
                    player.pause()
                    return .success
                }
            }
            return .commandFailed
        }
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            let localMp3 = LocalMusicManager.shareInstance().getAllSong()
            self.preparePlayIndex = self.currentPlayIndex + 1
            if self.preparePlayIndex >= localMp3.count{
                self.preparePlayIndex = 0
            }
            self.playMusic(self.preparePlayIndex)
            return .success
        }
        commandCenter.previousTrackCommand.addTarget{ [unowned self] event in
            self.preparePlayIndex = self.currentPlayIndex - 1
            if self.preparePlayIndex < 0{
                self.preparePlayIndex = 0
            }
            self.playMusic(self.preparePlayIndex)
            return .success
        }
    }
    
    /*
     * 设置锁屏或NowPlaying控件的信息
     */
    func setupRemoteNowPlaying(songName: String){
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = songName
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.audioPlayer!.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.audioPlayer!.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.audioPlayer!.rate
        nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = self.audioPlayer!.rate

        if let image = UIImage(named: "music_thumbnail") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
                MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
            }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    /*
     * 初始化AVSession
     */
    func initSession() -> Bool {
        let session = AVAudioSession.sharedInstance()
        do{
            if UserDefaultUtils.supportSpeaker(){
                try session.setCategory(.soloAmbient, mode: .default,policy: .default, options: [])
            }
            else{
                try session.setCategory(.playback, mode: .default,policy: .longFormAudio, options: [])
            }
        }
        catch{
            print(error)
            return false
        }
        session.activate(options: []) { (success, error) in
            guard error == nil else{
                print("*** An error occurred: \(error!.localizedDescription) ***")
                return
            }
            if let player = self.audioPlayer {
                player.prepareToPlay()
                player.play()
                self.currentPlayIndex = self.preparePlayIndex
                let localMp3 = LocalMusicManager.shareInstance().getAllSong()
                self.setupRemoteNowPlaying(songName:localMp3[self.currentPlayIndex])
            }
            else{
                print("audioPlayer is nil")
            }
        }
        return true
    }
    
}

extension LocalMusicController : AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        print("==+++++++++播放完成++++++++==")
        self.preparePlayIndex = self.currentPlayIndex + 1
        let localMp3 = LocalMusicManager.shareInstance().getAllSong()
        if self.preparePlayIndex >= localMp3.count{
            self.preparePlayIndex = 0
        }
        self.playMusic(self.preparePlayIndex)
    }


    /* if an error occurs while decoding it will be reported to the delegate. */
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?){
        print("=======播放错误======")
        let cancelAction = WKAlertAction(title: "知道了", style: .cancel) {
            print("Cancel")
        }
        presentAlert(withTitle: "提示", message: "音频解码错误", preferredStyle: .alert, actions: [cancelAction])
    }
}
