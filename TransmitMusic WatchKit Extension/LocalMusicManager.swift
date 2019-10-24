//
//  LocalMusicManager.swift
//  LocalMusic WatchKit Extension
//
//  Created by chenwei on 2019/10/19.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation
import AVFoundation

class LocalMusicManager: NSObject {
    
    private static let manager : LocalMusicManager = LocalMusicManager()
    
    var audioPlayer: AVAudioPlayer?
    
    // 所有歌曲
    var allSongs : [String] = []
    
    // 当前播放歌曲
    var currentSong : Song?
    
    // 当前的循环方式
    var loopStyle: LoopStyle = LoopStyle.sequence
    
    // 播放列表
    // 区别于allSongs,allSongs是顺序的列表，播放列表是根据循环方式重新生成的列表
    var currentPlayList: [Song] = []
    
    // 当前选择的专辑
    static var selectedAblum : Album?
    
    // 当前播放的专辑
    var currentPlayAblum: Album?

    static func shareInstance() -> LocalMusicManager{
        return manager;
    }
    
    override init() {
        super.init()
        loopStyle = UserDefaultUtils.loopStyle()
        let songs = loadMusicFromDocument()
        allSongs.append(contentsOf: songs)
        //currentPlayList = Array.init(allSongs)
    }
    
    func refreshMusic(){
        allSongs.removeAll()
        allSongs.append(contentsOf: loadMusicFromDocument())
    }
    
    func loadMusicFromDocument() -> [String]{
        let optionDocumentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        var files:[String]?
        do{
            files = try FileManager.default.contentsOfDirectory(atPath: optionDocumentPath!)
        }
        catch{
            print(error)
        }
        let songs = (files ?? []).filter({ (songName:String) -> Bool in
            return songName.hasSuffix(".mp3") || songName.hasSuffix(".flac")
        })
        return songs
    }
    
    func getAllSong() -> [String]{
        return allSongs
    }
    
    // 设置声音
    func setVolume(_ volume : Float){
        if let player = audioPlayer {
            player.volume = volume / 100
        }
        UserDefaultUtils.setVolumeSize(volume)
    }
    
    // 播放上一首
    func playPrevious(){
        
    }
    
    // 播放下一首
    func playNext(){
        
    }
    
    // 播放和暂停
    func playOrPause(_ play: Bool){
        
    }
    
    // 当前是否正在播放
    func isPlaying() -> Bool{
        return true
    }
    
    // 获取初始播放的歌曲
    func getInitSong() -> Song?{
        return currentSong
    }
    
    // 获取当前播放器
    func getPlayer() -> AVAudioPlayer?{
        return audioPlayer
    }
    
    // 设置当前循环模式
    func setLoopStyle(_ style: LoopStyle){
        loopStyle = style
        UserDefaultUtils.setLoopStyle(style)
    }
    
    // 根据专辑ID获取音乐
    func getSongsByAlbumId(_ albumId:String) -> [Song] {
        var songs:[Song] = []
        songs.append(Song(songId: "1", songName: "魔鬼中的天使", artist: "unknown", thumbnail: "http://b-ssl.duitang.com/uploads/item/201410/09/20141009224754_AswrQ.jpeg", filePath: "", albumId: "1"))
        songs.append(Song(songId: "2", songName: "天使的翅膀", artist: "未知", thumbnail: "http://b-ssl.duitang.com/uploads/item/201704/18/20170418212409_mG2Nx.jpeg", filePath: "", albumId: "1"))
        songs.append(Song(songId: "3", songName: "说好不哭", artist: "周杰伦", thumbnail: "http://img4.imgtn.bdimg.com/it/u=1376960464,3831632817&fm=214&gp=0.jpg", filePath: "", albumId: "1"))
        songs.append(Song(songId: "3", songName: "那女孩对我说", artist: "Uu", thumbnail: "", filePath: "", albumId: "1"))
        return songs
    }
    
    // 获取专辑列表
    func getAlbums() -> [Album] {
        var albums:[Album] = []
        albums.append(Album(albumId: "1", albumName: "默认", albumArtistName: "默认", albumThumbnail: "http://b-ssl.duitang.com/uploads/item/201508/26/20150826221548_x3SAJ.jpeg"))
        return albums
    }
}

extension Notification.Name{
    //音乐播放歌曲改变
    public static let MUSIC_PLAY_ITEM_CHANGE: NSNotification.Name = NSNotification.Name("MUSIC_PLAY_ITEM_CHANGE")
    // 音乐播放状态改变
    public static let MUSIC_PLAY_STATE_CHANGE: NSNotification.Name = NSNotification.Name("MUSIC_PLAY_STATE_CHANGE")
}
