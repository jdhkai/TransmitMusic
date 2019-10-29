//
//  MusicPlayerController.swift
//  TransmitMusic WatchKit Extension
//
//  Created by chenwei on 2019/10/24.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation
import WatchKit
import Kingfisher

class MusicPlayerControlle : WKInterfaceController,WKCrownDelegate{
    @IBOutlet weak var coverImage: WKInterfaceImage!
    @IBOutlet weak var songnameLabel: WKInterfaceLabel!
    @IBOutlet weak var singerLabel: WKInterfaceLabel!
    @IBOutlet weak var playButton: WKInterfaceButton!
    @IBOutlet weak var previousButton: WKInterfaceButton!
    @IBOutlet weak var nextButton: WKInterfaceButton!
    @IBOutlet weak var volumeSlider: WKInterfaceSlider!
    @IBOutlet weak var songOperateGroup: WKInterfaceGroup!
    @IBOutlet weak var loopButton: WKInterfaceButton!
    @IBOutlet weak var musicListButton: WKInterfaceButton!
    @IBOutlet weak var coverBackgroundGroup: WKInterfaceGroup!
    
    // 音量调节控件隐藏的Timer
    var volumeTimer: Timer?
    
    // 音量大小
    var volumeSize: Float = 0
    
    // 进度查询的Timer
    var progressTimer: Timer?
    
    // 当前页面是否可见
    var pageVisible: Bool = false
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        crownSequencer.delegate = self
        
        setupInitUI()
        
        
        // 添加通知监听
        NotificationCenter.default.addObserver(self, selector: #selector(playMusicChange), name: .MUSIC_PLAY_ITEM_CHANGE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playStateChange), name: .MUSIC_PLAY_STATE_CHANGE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(screenLockChange), name: .SCREEN_LOCK_CHANGE, object: nil)
        
    }
    
    override func willActivate() {
        pageVisible = true
        // 进入后台或进入多任务管理的时候会出现多次调用的情况，所以配合ExtensionDelegate使用避免多次调用
        if ExtensionDelegate.appBackground {
            return
        }
        crownSequencer.focus()
        updateLoopStyle()
        startProgressTimer()
    }
    
    override func didDeactivate() {
        pageVisible = false
        // 进入后台或进入多任务管理的时候会出现多次调用的情况，所以配合ExtensionDelegate使用避免多次调用
        if ExtensionDelegate.appBackground {
            return
        }
        stopProgressTimer()
    }
    
    func setupInitUI(){
        volumeSize = UserDefaultUtils.getVolumeSize()
        volumeSlider.setValue(volumeSize)
        
        let initSong : Song? = LocalMusicManager.shareInstance().getInitSong()
        setUIBySong(initSong)
    }
    
    // 开始计时的timer
    func startProgressTimer(){
        if progressTimer != nil && progressTimer!.isValid {
            return
        }
        print("开始计时")
        progressTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(1), repeats: true, block: { (timer) in
            let audioPlayer = LocalMusicManager.shareInstance().getPlayer()
            var progress = 0
            if let player = audioPlayer{
                progress = Int(player.currentTime*100 / player.duration)
            }
            self.coverBackgroundGroup.setBackgroundImage(self.createProgress(defaultColor: .gray, selectedColor: .green, progress: progress))
            self.crownSequencer.focus()
        })
    }
    
    // 停止计时
    func stopProgressTimer(){
        print("停止计时")
        if let timer = progressTimer {
            timer.invalidate()
            progressTimer = nil
        }
    }
    
    // 创建进度图片
    func createProgress(defaultColor: UIColor,selectedColor: UIColor,progress: Int) -> UIImage?{
        UIGraphicsBeginImageContext(CGSize(width: 60, height: 60))
        let ref = UIGraphicsGetCurrentContext()
        if let context = ref {
            context.beginPath()
            context.setStrokeColor(defaultColor.cgColor)
            
            let level1Path = UIBezierPath(arcCenter: CGPoint(x: 30, y: 30), radius: 25, startAngle: 0, endAngle: (CGFloat)(360*Double.pi/180), clockwise: true)
            level1Path.lineWidth = 10
            level1Path.stroke()
            
            context.setStrokeColor(selectedColor.cgColor)
            let angle = Double(progress*360 / 100 - 90)
            let level2Path = UIBezierPath(arcCenter: CGPoint(x: 30, y: 30), radius: 25, startAngle: (CGFloat)(-90*Double.pi/180), endAngle: (CGFloat)(angle*Double.pi/180), clockwise: true)
            level2Path.lineWidth = 10
            level2Path.stroke()
            
            UIGraphicsEndImageContext()
            let newImage = UIImage(cgImage: context.makeImage()!)
            return newImage
        }
        return nil
    }
    
    // 使用当前歌曲初始化UI
    func setUIBySong(_ optionSong: Song?){
        if let song = optionSong {
            songnameLabel.setText(song.songName)
            singerLabel.setText(song.artist)
            let optionURL = URL(string: song.thumbnail)
            coverImage.kf.setImage(with: optionURL, placeholder: KFCrossPlatformImage(named: "music"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        else{
            songnameLabel.setText("暂无音乐")
            singerLabel.setText("请在iPhone上添加音乐")
            coverImage.setImageNamed("music")
        }
    }
    
    // 设置播放循环模式
    @IBAction func setLoopStyle() {
        switch UserDefaultUtils.loopStyle() {
        case .sequence:
            LocalMusicManager.shareInstance().setLoopStyle(LoopStyle.single)
        case .single:
            LocalMusicManager.shareInstance().setLoopStyle(LoopStyle.random)
        case .random:
            LocalMusicManager.shareInstance().setLoopStyle(LoopStyle.sequence)
        }
        updateLoopStyle()
    }
    
    func updateLoopStyle(){
        switch UserDefaultUtils.loopStyle() {
        case .sequence:
            loopButton.setBackgroundImage(UIImage.init(systemName: "repeat"))
        case .single:
            loopButton.setBackgroundImage(UIImage.init(systemName: "repeat.1"))
        case .random:
            loopButton.setBackgroundImage(UIImage.init(systemName: "shuffle"))
        }
    }
    
    // 播放或暂停歌曲
    @IBAction func playOrPauseSong() {
        LocalMusicManager.shareInstance().playOrPause()
    }
    
    // 播放上一首
    @IBAction func playPreviousTrack() {
        LocalMusicManager.shareInstance().playPrevious()
    }
    
    // 播放下一首
    @IBAction func playNextTrack() {
        LocalMusicManager.shareInstance().playNext()
    }
    
    // 切换歌曲播放的音乐发生改变通知
    @objc func playMusicChange(myNotification: Notification){
        print("收到消息")
        let userinfo = myNotification.userInfo
        if let info = userinfo {
            let value = info["song"]
            if value != nil {
                let song = value as! Song
                setUIBySong(song)
            }
        }
        
    }
    
    // 播放状态发送改变通知
    @objc func playStateChange(myNotification: Notification){
        let userinfo = myNotification.userInfo
        if let info = userinfo {
            let value = info["state"]
            if value != nil {
                let state : String = value as! String
                switch state {
                case "empty": // 没有歌曲
                    playButton.setBackgroundImage(UIImage.init(systemName: "play.circle"))
                    songnameLabel.setText("暂无音乐")
                    singerLabel.setText("请在iPhone上添加音乐")
                    coverImage.setImageNamed("music")
                case "play":  // 正在播放
                    print("play")
                    playButton.setBackgroundImage(UIImage.init(systemName: "pause.circle"))
                case "pause": // 暂停
                    print("pause")
                    playButton.setBackgroundImage(UIImage.init(systemName: "play.circle"))
                case "stop": //停止
                    print("stop")
                    playButton.setBackgroundImage(UIImage.init(systemName: "play.circle"))
                case "error": //错误
                    print("error")
                    playButton.setBackgroundImage(UIImage.init(systemName: "play.circle"))
                    if let message = info["message"] {
                        singerLabel.setText(message as? String)
                    }
                case "prepare": //正在准备
                    print("prepare")
                    playButton.setBackgroundImage(UIImage.init(systemName: "play.circle"))
                default: //未知
                    print("unknown")
                    playButton.setBackgroundImage(UIImage.init(systemName: "play.circle"))
                }
            }
        }
    }
    
    // 屏幕锁屏事件改变通知
    @objc func screenLockChange(myNotification: Notification){
        if ExtensionDelegate.appBackground {
            stopProgressTimer()
        }
        else{
            // 界面可见时才开始计时
            if pageVisible{
                startProgressTimer()
            }
        }
    }
    
    @IBAction func volumeSliderChange(_ value: Float) {
        volumeSize = value
        hideVolumeSlider()
        LocalMusicManager.shareInstance().setVolume(volumeSize)
    }
    
    // 隐藏音量Slider
    func hideVolumeSlider() {
        if let timer = volumeTimer {
            timer.invalidate()
            volumeTimer = nil
        }
        volumeTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(3), repeats: false) { (timer) in
            timer.invalidate()
            self.volumeTimer = nil
            self.songOperateGroup.setHidden(false)
            self.volumeSlider.setHidden(true)
        }
    }
    
    // remark-- WKCrownDelegate实现
    
    func crownDidBecomeIdle(_ crownSequencer: WKCrownSequencer?) {
        print(#function)
        hideVolumeSlider()
    }
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        print(#function)
        print(rotationalDelta)
        if rotationalDelta == 0 {
            return
        }
        songOperateGroup.setHidden(true)
        volumeSlider.setHidden(false)
        if rotationalDelta > 0 {
            if volumeSize + 1 >= 100 {
                volumeSize = 100
            }
            else{
                volumeSize = volumeSize + 1
            }
            volumeSlider.setValue(volumeSize)
        }
        else{
            if volumeSize - 1 <= 0 {
                volumeSize = 0
            }
            else{
                volumeSize = volumeSize - 1
            }
            volumeSlider.setValue(volumeSize)
        }
        LocalMusicManager.shareInstance().setVolume(volumeSize)
    }
    
}
