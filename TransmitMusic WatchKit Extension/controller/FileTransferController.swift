//
//  FileTransferController.swift
//  TransmitMusic WatchKit Extension
//
//  Created by chenwei on 2019/10/22.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation
import WatchKit
import WatchConnectivity

class FileTransferController : InterfaceController{
    
    // 更新专辑通知
    static let ALBUM_UPDATE = Notification.Name.init("ALBUM_UPDATE")
    // 更新歌曲通知
    static let SONG_UPDATE = Notification.Name.init("SONG_UPDATE")
    
    @IBOutlet weak var connectImage: WKInterfaceImage!
    @IBOutlet weak var tipLabel: WKInterfaceLabel!
    
    // 即将从iPhone端发送过来的文件信息
    var waitTransferSong: Song?
    
    
    override func didAppear() {
        print(#function)
        super.didAppear()
        updateSessionStatus()
    }
    
     override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        configureWCSession()
    }
    
    override func willActivate() {
        updateSessionStatus()
    }
    
    func configureWCSession(){
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
    /*
     * 更新WCSession状态
     */
    func updateSessionStatus() {
        if WCSession.default.isReachable {
            connectImage.setImage(UIImage.init(systemName: "tray.and.arrow.down.fill"))
            tipLabel.setText("当前可允许iPhone数据传输")
        }
        else{
            connectImage.setImage(UIImage.init(systemName: "exclamationmark.triangle.fill"))
            tipLabel.setText("请在iPhone上打开“五点半音乐”APP")
        }
    }
    
    // 重新获取获取并更新状态
    @IBAction func resetStatus() {
        if WCSession.default.activationState != .activated {
            configureWCSession()
            updateSessionStatus()
        }
    }
    
}

extension FileTransferController : WCSessionDelegate{
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(#function)
        updateSessionStatus()
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        print(#function)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print(#function)
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print(#function)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print(#function)
    }
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        print(#function)
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        print(#function)
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.updateSessionStatus()
        }
    }
    
    // 接收的信息
    // 1. GetAllAlbum : 获取手表端的所有专辑
    // 2. GetAllSong : 获取所有歌曲
    // 3. GetSongByAlbum: 获取专辑下的所有歌曲
    // 4. DeleteAlbumById : 删除专辑
    // 5. DeleteSongById : 删除歌曲
    // 6. PrepareSendFile : 准备发送歌曲文件（添加歌曲）
    // 7. CreateAlbum : 创建专辑
    // 8. UpdateAlbumById : 更新专辑
    // 9. UpdateSongById : 修改专辑
    // 10. CreateSong : 添加歌曲
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let command = message["command"]{
            let commandStr = command as! String
            switch commandStr {
            case "GetAllAlbum": // 获取手表端的所有专辑
                let dbAlbums = SQLiteBusiness.shareInstance().getAllAlbum()
                var albums = [[String:String]]()
                for albumObj in dbAlbums{
                    albums.append(["albumId":albumObj.albumId,"albumName":albumObj.albumName,"albumArtist":albumObj.albumArtistName,"albumThumbnail":albumObj.albumThumbnail])
                }
                let replyMessage = ["data": albums]
                replyHandler(replyMessage)
            case "GetAllSong": // 获取所有歌曲
                let dbSongs = SQLiteBusiness.shareInstance().getAllSong()
                var songs = [[String:String]]()
                for song in dbSongs{
                    songs.append(["songId":song.songId,"songName":song.songName,"artist":song.artist,"albumId":song.albumId,"filemd5":song.filemd5,"filename":song.filename,"filePath":song.filePath,"thumbnail":song.thumbnail])
                }
                let replyMessage = ["data": songs]
                replyHandler(replyMessage)
            case "GetSongByAlbum": // 获取专辑下的所有歌曲
                let albumId = message["albumId"] as! String
                let dbSongs = SQLiteBusiness.shareInstance().getSongsByAlbumId(albumId)
                var songs = [[String:String]]()
                for song in dbSongs{
                    songs.append(["songId":song.songId,"songName":song.songName,"artist":song.artist,"albumId":song.albumId,"filemd5":song.filemd5,"filename":song.filename,"filePath":song.filePath,"thumbnail":song.thumbnail])
                }
                let replyMessage = ["data": songs]
                replyHandler(replyMessage)
            case "DeleteAlbumById": // 删除专辑
                let albumId = message["albumId"] as! String
                if SQLiteBusiness.shareInstance().getSongsByAlbumId(albumId).count > 0 {
                    let replyMessage : [String : Any] = ["success" : false,"message":"专辑不为空"]
                    replyHandler(replyMessage)
                }
                else{
                    let success = SQLiteBusiness.shareInstance().deleteAlbum(albumId)
                    if success {
                        NotificationCenter.default.post(name: FileTransferController.ALBUM_UPDATE, object: nil)
                    }
                    let replyMessage = ["success" : success]
                    replyHandler(replyMessage)
                }
                print("DeleteAlbumById")
            case "DeleteSongById": // 从专辑中删除歌曲
                let songId = message["songId"] as! String
                let optionSong = SQLiteBusiness.shareInstance().getSongById(songId)
                var success = true
                if let song = optionSong {
                    if SQLiteBusiness.shareInstance().getSongsByMd5(song.filemd5).count <= 1 {
                        let optionDocumentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
                        let documentURL = URL(fileURLWithPath: optionDocumentPath!)
                        let fileURL = documentURL.appendingPathComponent(song.filePath)
                        if FileManager.default.fileExists(atPath: fileURL.path) {
                            do{
                                try FileManager.default.removeItem(at: fileURL)
                                print("删除文件")
                                success = true
                            }
                            catch{
                                print(error)
                                success = false
                            }
                        }
                    }
                    success = SQLiteBusiness.shareInstance().deleteSong(songId)
                    if success {
                        NotificationCenter.default.post(name: FileTransferController.SONG_UPDATE, object: nil)
                    }
                }
                else{
                    success = true
                }
                let replyMessage = ["success" : success]
                replyHandler(replyMessage)
                print("DeleteSongById")
            case "PrepareSendFile": // 准备发送歌曲文件（添加歌曲）
                let songId = message["songId"] as! String
                let songName = message["songName"] as! String
                let artist = message["artist"] as! String
                let thumbnail = message["thumbnail"] as! String
                let filePath = message["filePath"] as! String
                let albumId = message["albumId"] as! String
                let filename = message["filename"] as! String
                let filemd5 = message["filemd5"] as! String
                var song:Song = Song(songId: songId, songName: songName, artist: artist, thumbnail: thumbnail, filePath: filePath, albumId: albumId, filename: filename, filemd5: filemd5)
                // 避免重复添加id
                if SQLiteBusiness.shareInstance().getSongById(songId) != nil{
                    // success : 数据添加成功
                   // exist : 文件是否已存在
                   let replyMessage: [String: Any] = ["success" : true,"exist":true]
                   replyHandler(replyMessage)
                }
                // 已存在的文件直接添加即可，无需再传送文件
                else if let dbSong = SQLiteBusiness.shareInstance().getSongByMd5(filemd5){
                    song.filePath = dbSong.filePath
                    song.filename = dbSong.filename
                    // success : 数据添加成功
                    // exist : 文件是否已存在
                    let success = SQLiteBusiness.shareInstance().insertSong(song)
                    if success {
                        NotificationCenter.default.post(name: FileTransferController.SONG_UPDATE, object: nil)
                    }
                    let replyMessage: [String: Any] = ["success" : success,"exist":true]
                    replyHandler(replyMessage)
                }
                else{
                    waitTransferSong = song
                    // success : 是否已准备就绪
                    // exist : 文件是否已存在
                    let replyMessage = ["success" : true,"exist": false]
                    replyHandler(replyMessage)
                }
                print("PrepareSendFile")
            case "CreateSong": //添加歌曲
                let songId = message["songId"] as! String
                let songName = message["songName"] as! String
                let artist = message["artist"] as! String
                let thumbnail = message["thumbnail"] as! String
                let filePath = message["filePath"] as! String
                let albumId = message["albumId"] as! String
                let filename = message["filename"] as! String
                let filemd5 = message["filemd5"] as! String
                let song:Song = Song(songId: songId, songName: songName, artist: artist, thumbnail: thumbnail, filePath: filePath, albumId: albumId, filename: filename, filemd5: filemd5)
                let replyMessage = ["success" : SQLiteBusiness.shareInstance().insertSong(song)]
                replyHandler(replyMessage)
            case "CreateAlbum": // 创建专辑
                let albumId = message["albumId"] as! String
                let albumName = message["albumName"] as! String
                let albumArtist = message["albumArtist"] as! String
                let albumThumbnail = message["albumThumbnail"] as! String
                let album: Album = Album(albumId: albumId, albumName: albumName, albumArtistName: albumArtist, albumThumbnail: albumThumbnail)
                let success = SQLiteBusiness.shareInstance().insertAlbum(album)
                if success {
                    NotificationCenter.default.post(name: FileTransferController.ALBUM_UPDATE, object: nil)
                }
                let replyMessage = ["success" : success]
                replyHandler(replyMessage)
                print("CreateAlbum")
            case "UpdateAlbumById": // 更新专辑
                let albumId = message["albumId"] as! String
                let albumName = message["albumName"] as! String
                let albumArtist = message["albumArtist"] as! String
                let albumThumbnail = message["albumThumbnail"] as! String
                let album: Album = Album(albumId: albumId, albumName: albumName, albumArtistName: albumArtist, albumThumbnail: albumThumbnail)
                let success = SQLiteBusiness.shareInstance().updateAblum(albumId, album: album)
                if success {
                    NotificationCenter.default.post(name: FileTransferController.ALBUM_UPDATE, object: nil)
                }
                let replyMessage = ["success" : success]
                replyHandler(replyMessage)
                print("UpdateAlbumById")
            case "UpdateSongById": // 修改专辑
                let songId = message["songId"] as! String
                let songName = message["songName"] as! String
                let artist = message["artist"] as! String
                let thumbnail = message["thumbnail"] as! String
                let filePath = message["filePath"] as! String
                let albumId = message["albumId"] as! String
                let filename = message["filename"] as! String
                let filemd5 = message["filemd5"] as! String
                let song:Song = Song(songId: songId, songName: songName, artist: artist, thumbnail: thumbnail, filePath: filePath, albumId: albumId, filename: filename, filemd5: filemd5)
                let success = SQLiteBusiness.shareInstance().updateSong(songId, song: song)
                if success {
                    NotificationCenter.default.post(name: FileTransferController.SONG_UPDATE, object: nil)
                }
                let replyMessage = ["success" : success]
                replyHandler(replyMessage)
                print("UpdateSongById")
            default:
                print("无法解析")
            }
            
        }
        print(#function)
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        print("fileTransfer")
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("接收文件")
        if let song = waitTransferSong{
            print(file.fileURL)
//            let path = file.fileURL.path
//            let index = path.index(path.lastIndex(of: "/")!, offsetBy: 1)
//            let songName = path[index...].removingPercentEncoding
            let optionDocumentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            let documentURL = URL(fileURLWithPath: optionDocumentPath!)
            let fileURL = documentURL.appendingPathComponent(song.filePath)
            print(fileURL)
            print(fileURL.deletingLastPathComponent().path)
            if !FileManager.default.fileExists(atPath: fileURL.deletingLastPathComponent().path) {
                do{
                    try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                }
                catch{
                    print("创建文件夹失败")
                    print(error)
                    return
                }
            }
            do{
                try FileManager.default.moveItem(at: file.fileURL, to: fileURL)
            }
            catch{
                print("文件保存错误!")
                print(error)
                return
            }
            print("文件上传成功")
            if(SQLiteBusiness.shareInstance().insertSong(song)){
                NotificationCenter.default.post(name: FileTransferController.SONG_UPDATE, object: nil)
            }
        }
        else{
            print("上传文件前没有调用PrepareSendFile")
        }
    }
}
