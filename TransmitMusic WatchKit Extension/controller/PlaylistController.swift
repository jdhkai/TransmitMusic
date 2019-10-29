//
//  SongController.swift
//  TransmitMusic WatchKit Extension
//
//  Created by chenwei on 2019/10/24.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation
import WatchKit
import Kingfisher

class PlaylistController : WKInterfaceController{
    @IBOutlet weak var songTable: WKInterfaceTable!
    
    var songList:[Song] = []
    
    override func awake(withContext context: Any?) {
        songList.append(contentsOf: LocalMusicManager.shareInstance().currentPlayList)
        
        songTable.setNumberOfRows(songList.count, withRowType: "ItemSongRowController")
        for(i,song) in songList.enumerated(){
            let cell = songTable.rowController(at: i) as! ItemSongRowController
            cell.songNameLabel.setText(song.songName)
            let optionUrl = URL(string: song.thumbnail)
            cell.songImage.kf.setImage(with: optionUrl, placeholder: KFCrossPlatformImage(named: "music"), options: nil, progressBlock: nil, completionHandler: nil)
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        LocalMusicManager.shareInstance().playCurrentAlbum(rowIndex)
        popToRootController()
    }
}
