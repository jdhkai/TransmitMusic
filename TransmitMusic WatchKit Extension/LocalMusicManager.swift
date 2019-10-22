//
//  LocalMusicManager.swift
//  LocalMusic WatchKit Extension
//
//  Created by chenwei on 2019/10/19.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation

class LocalMusicManager: NSObject {
    
    private static let manager : LocalMusicManager = LocalMusicManager()
    
    // 所有歌曲
    var allSongs : [String] = []

    static func shareInstance() -> LocalMusicManager{
        return manager;
    }
    
    override init() {
        super.init()
        let songs = loadMusicFromDocument()
        allSongs.append(contentsOf: songs)
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
}
