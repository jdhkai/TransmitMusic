//
//  AlbumSongController.swift
//  TransmitMusic WatchKit Extension
//
//  Created by chenwei on 2019/10/25.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation
import WatchKit
import Kingfisher

class AlbumSongController : WKInterfaceController{
    
    static var selectedAlbum: Album? = nil
    
    @IBOutlet weak var songTable: WKInterfaceTable!
    
    var songList:[Song] = []
    
    override func awake(withContext context: Any?) {
        
        reloadTable()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateAlbumSongs), name: FileTransferController.SONG_UPDATE, object: nil)
    }
    
    func reloadTable(){
        songList.removeAll()
        if songTable.numberOfRows > 0 {
            songTable.removeRows(at: IndexSet.init(0...songTable.numberOfRows))
        }
        
        let album = AlbumSongController.selectedAlbum!
        setTitle(album.albumName)
        if album.albumId == "0" {
            songList.append(contentsOf: SQLiteBusiness.shareInstance().getAllSong())
        }
        else{
            songList.append(contentsOf: SQLiteBusiness.shareInstance().getSongsByAlbumId(album.albumId))
        }
        
        songTable.setNumberOfRows(songList.count, withRowType: "ItemAlbumSongRowController")
        for(i,song) in songList.enumerated(){
            let cell = songTable.rowController(at: i) as! ItemAlbumSongRowController
            cell.songNameLabel.setText(song.songName)
            let optionUrl = URL(string: song.thumbnail)
            cell.coverImage.kf.setImage(with: optionUrl, placeholder: KFCrossPlatformImage(named: "music"), options: nil, progressBlock: nil, completionHandler: nil)
        }
    }
    
    @objc func updateAlbumSongs(myNotification: Notification){
        reloadTable()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        LocalMusicManager.shareInstance().play(songList, index: rowIndex, album: AlbumSongController.selectedAlbum!)
    }
}
