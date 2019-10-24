//
//  AlbumController.swift
//  TransmitMusic WatchKit Extension
//
//  Created by chenwei on 2019/10/24.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation
import WatchKit

class AlbumController : WKInterfaceController{
    
    @IBOutlet weak var albumTable: WKInterfaceTable!
    
    var albums:[Album] = []
    
    
    override func awake(withContext context: Any?) {
        
        albums.append(contentsOf: LocalMusicManager.shareInstance().getAlbums())
        albumTable.setNumberOfRows(albums.count, withRowType: "ItemAlbumRowController")
        
        for(i,album) in albums.enumerated(){
            let cell = albumTable.rowController(at: i) as! ItemAlbumRowController
            cell.albumNameLabel.setText(album.albumName)
            do{
                try cell.albumImage.setImage(UIImage(data: Data(contentsOf: URL(string: album.albumThumbnail)!)))
            }catch{
                print(error)
            }
        }
    }
    
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        LocalMusicManager.selectedAblum = albums[rowIndex]
        pushController(withName: "SongController", context: nil)
    }
    
}
