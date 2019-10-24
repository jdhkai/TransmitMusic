//
//  SongController.swift
//  TransmitMusic WatchKit Extension
//
//  Created by chenwei on 2019/10/24.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation
import WatchKit

class SongController : WKInterfaceController{
    @IBOutlet weak var songTable: WKInterfaceTable!
    
    var songList:[Song] = []
    
    override func awake(withContext context: Any?) {
        if let ablum = LocalMusicManager.selectedAblum{
            setTitle("专辑：\(ablum.albumName)")
            songList.append(contentsOf: LocalMusicManager.shareInstance().getSongsByAlbumId(ablum.albumId))
        }
        else{
            setTitle("音乐列表")
        }
        
        songTable.setNumberOfRows(songList.count, withRowType: "ItemSongRowController")
        for(i,song) in songList.enumerated(){
            let cell = songTable.rowController(at: i) as! ItemSongRowController
            cell.songNameLabel.setText(song.songName)
            do{
                try cell.songImage.setImage(UIImage(data: Data(contentsOf: URL(string: song.thumbnail)!)))
            }catch{
                print(error)
                cell.songImage.setImage(UIImage(named: "music_thumbnail"))
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
    }
}
