//
//  LocalMusicManager.swift
//  LocalMusic WatchKit Extension
//
//  Created by chenwei on 2019/10/19.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

class LocalMusicManager: NSObject {
    
    // 表示所有歌曲
    static let ALL_ALBUM:Album = Album(albumId: "0", albumName: "所有歌曲", albumArtistName: "五点半青年", albumThumbnail: "")
    
    private static let manager : LocalMusicManager = LocalMusicManager()
    
    var audioPlayer: AVAudioPlayer?
    
    // 所有歌曲
    var allSongs : [Song] = []
    
    // 当前播放歌曲
    var currentSong : Song?
    
    // 当前的循环方式
    var loopStyle: LoopStyle = LoopStyle.sequence
    
    // 播放列表
    // 区别于allSongs,allSongs是顺序的列表，播放列表是根据循环方式重新生成的列表
    var currentPlayList: [Song] = []
    
    // 当前播放的专辑
    var currentPlayAblum: Album?
    
    
    //当前正在播放的索引
    var currentPlayIndex = -1
    
    // AVAudioSession是否需要重新激活
    var sessionValid: Bool = false
    
    
    //中断前的播放状态，恢复后保留现场
    var interruptPlayStatus = false

    static func shareInstance() -> LocalMusicManager{
        return manager;
    }
    
    override init() {
        super.init()
        
        // 从历史记录中获取上次播放的专辑和音乐
        let lastPlayAlbumId = UserDefaultUtils.getAlbumId()
        let lastPlaySongId = UserDefaultUtils.getSongId()
        if lastPlayAlbumId == LocalMusicManager.ALL_ALBUM.albumId {
            currentPlayAblum = LocalMusicManager.ALL_ALBUM
            let songs = SQLiteBusiness.shareInstance().getAllSong()
            allSongs.append(contentsOf: songs)
        }
        else{
            let optionAlbum = SQLiteBusiness.shareInstance().getAlbumById(lastPlayAlbumId)
            if let album = optionAlbum{
                currentPlayAblum = album
                allSongs.append(contentsOf: SQLiteBusiness.shareInstance().getSongsByAlbumId(album.albumId))
            }
            else{
                currentPlayAblum = LocalMusicManager.ALL_ALBUM
                allSongs.append(contentsOf: SQLiteBusiness.shareInstance().getAllSong())
            }
        }
        
        resetPlaylistByLoopStyle(songId: lastPlaySongId)
        
        // 初始化播放器
        // 延迟执行，避免MusicPlayerController无法收到通知
        Timer.scheduledTimer(withTimeInterval: TimeInterval(1.5), repeats: false) { (timer) in
            timer.invalidate()
            self.playByIndex(index: self.currentPlayIndex, immediately: false)
        }
        
        addPlayerInterruptObserver()
        
    }
    
    // 根据循环方式重新刷新播放列表
    func resetPlaylistByLoopStyle(songId:String){
        
        // 根据循环模式，将allSongs重新排列
        loopStyle = UserDefaultUtils.loopStyle()
        currentPlayList.removeAll()
        switch loopStyle {
        case .sequence:
            currentPlayList.append(contentsOf: allSongs)
        case .random:
            currentPlayList = allSongs.shuffled()
        case .single:
            currentPlayList.append(contentsOf: allSongs)
        }
        
        // 根据当前播放歌曲id,重新生成currentPlayIndex及currentSong
        if currentPlayList.count > 0 {
            var isExist: Bool = false
            for (index,item) in currentPlayList.enumerated(){
                if item.songId == songId {
                    currentSong = item
                    currentPlayIndex = index
                    isExist = true
                    break
                }
            }
            if !isExist {
                currentPlayIndex = 0
                currentSong = allSongs[0]
            }
        }
        else{
            currentPlayIndex = -1
            currentSong = nil
            Timer.scheduledTimer(withTimeInterval: TimeInterval(1.5), repeats: false) { (timer) in
                timer.invalidate()
                self.postStateMessage("empty")
            }
        }
    }
    
    // >>>>>>>>>>>>>>>>>>>>中断事件处理>>>>>>>>>>>>>>>>>>>>
    //|
    //|
    //|
    //|
    
    // 添加中断监听
    func addPlayerInterruptObserver(){
        //中断通知
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc func handleInterruption(notification: Notification){
        print(#function)
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        if type == .began {
            // Interruption began, take appropriate actions
            if let player = self.audioPlayer{
                interruptPlayStatus = player.isPlaying
            }
            else{
                interruptPlayStatus = false
            }
            self.postStateMessage("pause")
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
                                self.postStateMessage("play")
                            }
                        }
                    }
                } else {
                    // Interruption Ended - playback should NOT resume
                }
            }
        }
    }
    
    // <<<<<<<<<<<<<<<<<<<<<中断事件处理<<<<<<<<<<<<<<<<<<<<<
    
    // >>>>>>>>>>>>>>>>>>>>播放音乐>>>>>>>>>>>>>>>>>>>>
    //|
    //|
    //|
    //|
    
    /*
     * 设置AVSession支持后台播放
     */
    func setupAVSessionPlay(){
        if sessionValid {
            if let player = self.audioPlayer {
                sessionValid = true
                player.play()
                self.setupRemoteNowPlaying()
                self.postStateMessage("play")
            }
            else{
                self.postStateMessage("error",message: "播放对象未失败")
            }
            return
        }
        let session = AVAudioSession.sharedInstance()
        do{
            if UserDefaultUtils.supportSpeaker(){
                try session.setCategory(.soloAmbient, mode: .default,policy: .default, options: [])
            }
            else{
                var headphonesConnected = false
                for output in session.currentRoute.outputs where output.portType == AVAudioSession.Port.headphones {
                    headphonesConnected = true
                    break
                }
                try session.setCategory(.playback, mode: .default,policy: .longFormAudio, options: [])
                if !headphonesConnected {
                    self.postStateMessage("error",message: "未搜索到耳机")
                    return
                }
            }
        }
        catch{
            print(error)
            self.postStateMessage("error",message: "setCategory错误")
            return
        }
        
        do{
            try session.setActive(true, options: [])
        }
        catch{
            print(error)
            self.postStateMessage("error",message: "激活AVAudioSession错误")
            return
        }
        DispatchQueue.main.async {
            // 不管路由有没有切换成功都进行播放
            if let player = self.audioPlayer {
                self.sessionValid = true
                player.play()
                self.setupRemoteNowPlaying()
                self.postMusicChnageMessage(self.currentSong!)
                self.postStateMessage("play")
            }
            else{
                self.postStateMessage("error",message: "播放对象未失败")
            }
        }
    }
    
    // 通过索引进行播放
    // index : 索引
    // immediately : 是否马上进行播放
    func playByIndex(index: Int,immediately: Bool) {
        if self.audioPlayer != nil {
            self.audioPlayer?.stop()
            postStateMessage("stop")
            self.audioPlayer = nil
        }
        if index >= 0 && index < currentPlayList.count {
            currentPlayIndex = index
            currentSong = currentPlayList[currentPlayIndex]
            print(currentSong)
            UserDefaultUtils.setAlbumId(currentPlayAblum!.albumId)
            UserDefaultUtils.setSongId(currentSong!.songId)
            if let song = currentSong{
                postMusicChnageMessage(song)
                let path = song.filePath
                let optionDocumentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
                let documentURL = URL(fileURLWithPath: optionDocumentPath!)
                let fileURL = documentURL.appendingPathComponent(path)
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    do{
                        try self.audioPlayer = AVAudioPlayer(contentsOf: fileURL)
                        self.audioPlayer?.volume = UserDefaultUtils.getVolumeSize() / 100
                        self.audioPlayer?.delegate = self
                        self.audioPlayer?.prepareToPlay()
                        self.postStateMessage("prepare")
                        if immediately {
                            setupAVSessionPlay()
                        }
                    }
                    catch{
                        print(error)
                        self.postStateMessage("error",message: "播放对象创建失败")
                    }
                }
                else{
                    self.postStateMessage("error",message: "播放的文件已删除")
                }
            }
        }
        else{
            self.postStateMessage("empty")
        }
    }
    // <<<<<<<<<<<<<<<<<<<<<播放音乐<<<<<<<<<<<<<<<<<<<<<
    
    
    // >>>>>>>>>>>>>>>>>>>>锁屏和远程控制>>>>>>>>>>>>>>>>>>>>
    //|
    //|
    //|
    //|
    
    
     //设置远程控制
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()

        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if let player = self.audioPlayer {
                if !player.isPlaying {
                    self.setupAVSessionPlay()
                    return .success
                }
            }
            return .commandFailed
        }
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if let player = self.audioPlayer {
                if player.isPlaying {
                    player.pause()
                    self.setupRemoteNowPlaying()
                    self.postStateMessage("pause")
                    return .success
                }
            }
            return .commandFailed
        }
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            self.playNext()
            return .success
        }
        commandCenter.previousTrackCommand.addTarget{ [unowned self] event in
            self.playPrevious()
            return .success
        }
    }
    
    //设置锁屏或NowPlaying控件的信息
    func setupRemoteNowPlaying(){
        if let player = audioPlayer, let song = currentSong {
            self.setupRemoteTransportControls()
            var nowPlayingInfo = [String : Any]()
            nowPlayingInfo[MPMediaItemPropertyTitle] = song.songName
            nowPlayingInfo[MPMediaItemPropertyArtist] = song.artist
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = (player.currentTime <= 0 ? 1 : player.currentTime)
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = Double(player.isPlaying ? player.rate : 0)
            nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = Double(player.isPlaying ? player.rate : 0)
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackProgress] = player.currentTime * 100 / player.duration
            // 设置后模拟器上无效
//            if let image = UIImage(named: "music_thumbnail") {
//                nowPlayingInfo[MPMediaItemPropertyArtwork] =
//                    MPMediaItemArtwork(boundsSize: image.size) { size in
//                        return image
//                }
//            }
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }
    
    // <<<<<<<<<<<<<<<<<<<<<锁屏和远程控制<<<<<<<<<<<<<<<<<<<<<
    
    // >>>>>>>>>>>>>>>>>>>>发送通知>>>>>>>>>>>>>>>>>>>>
    //|
    //|
    //|
    //|
    
    // 发送歌曲切换信息
    func postMusicChnageMessage(_ song: Song){
        let userinfo:[String:Song] = ["song":song]
        NotificationCenter.default.post(Notification.init(name: .MUSIC_PLAY_ITEM_CHANGE, object: nil, userInfo: userinfo))
    }
    
    // 发送错误信息
    func postStateMessage(_ state: String, message : String = ""){
        let userinfo:[String:String] = ["state":state,"message": message]
        NotificationCenter.default.post(Notification.init(name: .MUSIC_PLAY_STATE_CHANGE, object: nil, userInfo: userinfo))
    }
    
    // <<<<<<<<<<<<<<<<<<<<<发送通知<<<<<<<<<<<<<<<<<<<<<
    
    
    // >>>>>>>>>>>>>>>>>>>>播放列表界面操作>>>>>>>>>>>>>>>>>>>>
    //|
    //|
    //|
    //|
    
    // 在歌曲列表中点击歌曲时调用
    func play(_ songs: [Song], index: Int, album: Album){
        // 准备播放的歌曲编号
        let preparePlaySongId = songs[index].songId
        
        currentPlayAblum = album
        allSongs.removeAll()
        allSongs.append(contentsOf: songs)
        
        resetPlaylistByLoopStyle(songId: preparePlaySongId)
        playByIndex(index: currentPlayIndex, immediately: true)
    }
    
    // 在当前播放列表中播放歌曲
    func playCurrentAlbum(_ index: Int){
        playByIndex(index: index, immediately: true)
    }
    
    // <<<<<<<<<<<<<<<<<<<<<播放列表界面操作<<<<<<<<<<<<<<<<<<<<<
    
    
    // >>>>>>>>>>>>>>>>>>>>MusicPlayerController界面操作>>>>>>>>>>>>>>>>>>>>
    //|
    //|
    //|
    //|
    
    // 播放上一首
    func playPrevious(){
        if self.currentPlayList.count > 0 {
            self.currentPlayIndex = self.currentPlayIndex - 1
            if self.currentPlayIndex < 0{
                self.currentPlayIndex = 0
            }
            playByIndex(index: self.currentPlayIndex, immediately: true)
        }
        else{
            // 不响应点击事件
        }
    }
    
    // 播放下一首
    func playNext(){
        if self.currentPlayList.count > 0 {
            self.currentPlayIndex = self.currentPlayIndex + 1
            if self.currentPlayIndex >= currentPlayList.count{
                self.currentPlayIndex = 0
            }
            playByIndex(index: self.currentPlayIndex, immediately: true)
        }
        else{
            // 不响应点击事件
        }
    }
    
    // 播放和暂停
    func playOrPause(){
        if let player = audioPlayer {
            if !player.isPlaying {
                setupAVSessionPlay()
            }
            else{
                player.pause()
                postStateMessage("pause")
            }
        }
        else{
            // 不响应点击事件
        }
    }
    
    // 播放暂停
    func pause(){
        if let player = audioPlayer {
            if player.isPlaying {
                player.pause()
                postStateMessage("pause")
            }
        }
        else{
            // 不响应点击事件
        }
    }
    
    // 准备重新设置Session
    func willResetSession(){
        sessionValid = false
    }
    
    // <<<<<<<<<<<<<<<<<<<<<MusicPlayerController界面操作<<<<<<<<<<<<<<<<<<<<<
    
    
    
    // >>>>>>>>>>>>>>>>>>>>Setter/Getter操作>>>>>>>>>>>>>>>>>>>>
    //|
    //|
    //|
    //|
    
    // 设置声音
    func setVolume(_ volume : Float){
        if let player = audioPlayer {
            player.volume = volume / 100
        }
        UserDefaultUtils.setVolumeSize(volume)
    }
    
    // 获取初始播放的歌曲
    func getInitSong() -> Song?{
        return currentSong
    }
    
    // 获取当前播放列表
    func getPlayList() -> [Song]{
        return currentPlayList
    }
    
    // 获取当前播放器
    func getPlayer() -> AVAudioPlayer?{
        return audioPlayer
    }
    
    // 设置当前循环模式
    func setLoopStyle(_ style: LoopStyle){
        loopStyle = style
        UserDefaultUtils.setLoopStyle(style)
        if let song = currentSong {
            resetPlaylistByLoopStyle(songId: song.songId)
        }
    }
    // <<<<<<<<<<<<<<<<<<<<<Setter/Getter操作<<<<<<<<<<<<<<<<<<<<<
}

extension Notification.Name{
    //音乐播放歌曲改变
    public static let MUSIC_PLAY_ITEM_CHANGE: NSNotification.Name = NSNotification.Name("MUSIC_PLAY_ITEM_CHANGE")
    // 音乐播放状态改变
    public static let MUSIC_PLAY_STATE_CHANGE: NSNotification.Name = NSNotification.Name("MUSIC_PLAY_STATE_CHANGE")
}

extension LocalMusicManager : AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        // 单曲循环时直接将播放进度置为0，然后重新播放
        if loopStyle == .single{
            player.currentTime = 0
            player.prepareToPlay()
            player.play()
        }
        else{
            self.playNext()
        }
    }


    /* if an error occurs while decoding it will be reported to the delegate. */
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?){
        self.postStateMessage("error",message: "音频文件解码错误")
    }
}
