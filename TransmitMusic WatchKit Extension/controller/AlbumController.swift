//
//  AlbumController.swift
//  TransmitMusic WatchKit Extension
//
//  Created by chenwei on 2019/10/24.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation
import WatchKit
import Kingfisher

class AlbumController : WKInterfaceController{
    
    @IBOutlet weak var albumTable: WKInterfaceTable!
    
    var albums:[Album] = []
    
    
    override func awake(withContext context: Any?) {
        
        reloadTable()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateAlbums), name: FileTransferController.ALBUM_UPDATE, object: nil)
    }
    
    func reloadTable(){
        albums.removeAll()
        albums.append(LocalMusicManager.ALL_ALBUM)
        albums.append(contentsOf: SQLiteBusiness.shareInstance().getAllAlbum())
        
        if albumTable.numberOfRows > 0 {
            albumTable.removeRows(at: IndexSet.init(0...albumTable.numberOfRows))
        }
        albumTable.setNumberOfRows(albums.count, withRowType: "ItemAlbumRowController")
        
        for(i,album) in albums.enumerated(){
            let cell = albumTable.rowController(at: i) as! ItemAlbumRowController
            cell.albumNameLabel.setText(album.albumName)
            let optionUrl = URL(string: album.albumThumbnail)
            cell.albumImage.kf.setImage(with: optionUrl, placeholder: KFCrossPlatformImage(named: "album"), options: nil, progressBlock: nil, completionHandler: nil)
        }
    }
    
    @objc func updateAlbums(myNotification: Notification){
        reloadTable()
    }
    
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        AlbumSongController.selectedAlbum = albums[rowIndex]
        pushController(withName: "AlbumSongController", context: nil)
    }
    
    
}
