//
//  WatchSongController.swift
//  TransmitMusic
//
//  Created by chenwei on 2019/10/26.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import WatchConnectivity

class WatchSongController : UITableViewController{
    
    // 手表中已经存在的歌曲
    static var watchExistSongs : [Song] = []
    
    var header: MJRefreshNormalHeader?
    
    override func viewDidLoad() {
        // 设置分隔线全屏
        self.tableView.separatorInset = .zero
        self.tableView.layoutMargins = .zero
        // 设置没有数据cell隐藏分隔线
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(onRefresh))
        self.tableView.mj_header = header
        
        header?.beginRefreshing()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        WatchSongController.watchExistSongs.removeAll()
    }
    
    @IBAction func toLocalSong(_ sender: Any) {
        performSegue(withIdentifier: "ToLocalSongSeque", sender: nil)
    }
    
    @objc func onRefresh(){
        if checkConnectCondition() {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.getSongsFromWatch()
            }
        }
        else{
           self.header?.endRefreshing()
        }
    }
    // 检查连接条件
    func checkConnectCondition() -> Bool {
        var errorMessage : String? = nil
        if !WCSession.isSupported() {
            errorMessage = "当前iPhone不支持与Apple Watch通信"
        }
        else if !WCSession.default.isPaired {  //设备是否配对watch
            errorMessage = "当前设备没有配对的Apple Watch"
        }
        else if !WCSession.default.isWatchAppInstalled{ //Watch app是否安装
            errorMessage = "Apple Watch上未安装此应用"
        }
//        else if !WCSession.default.isComplicationEnabled{  //并发是否可用
//            errorMessage = "当前设备不支持并发"
//        }
        else if WCSession.default.activationState != .activated{
            errorMessage = "通信未激活"
        }
        else if !WCSession.default.isReachable { //能否传递信息
            errorMessage = "当前设备无法与Watch通信，请在Apple Watch上打开此应用"
        }
        if let error = errorMessage {
            showErrorDialog(error)
        }
        return errorMessage == nil
    }
    
    // 提示错误信息
    func showErrorDialog(_ errorMessage : String){
        let alert = UIAlertController(title: "错误", message: errorMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    // 从手表端获取专辑
    func getSongsFromWatch(){
        let message = ["command":"GetSongByAlbum","albumId":WatchAlbumController.selectedAlbum!.albumId]
        WCSession.default.sendMessage(message, replyHandler: { (replyMessage) in
            print(replyMessage)
            DispatchQueue.main.async {
                WatchSongController.watchExistSongs.removeAll()
                let data = replyMessage["data"] as! [[String:String]]
                for song in data{
                    WatchSongController.watchExistSongs.append(Song(songId: song["songId"]!, songName: song["songName"]!, artist: song["artist"]!, thumbnail: song["thumbnail"]!, filePath: song["filePath"]!, albumId: song["albumId"]!, filename: song["filename"]!, filemd5: song["filemd5"]!))
                }
                self.header?.endRefreshing()
                self.tableView.reloadData()
            }
        }, errorHandler: { (error) in
            DispatchQueue.main.async {
                self.header?.endRefreshing()
                self.showErrorDialog(error.localizedDescription)
            }
        })
    }
    
    // 从手表端专辑删除歌曲
    func deleteSong(_ songId : String, index: Int){
        let message = ["command":"DeleteSongById","songId":songId]
        WCSession.default.sendMessage(message, replyHandler: { (replyMessage) in
            print(replyMessage)
            DispatchQueue.main.async {
                let data = replyMessage["success"] as! Bool
                if data {
                    WatchSongController.watchExistSongs.remove(at: index)
                    self.tableView.reloadData()
                }
            }
        }, errorHandler: { (error) in
            DispatchQueue.main.async {
                self.showErrorDialog(error.localizedDescription)
            }
        })
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WatchSongController.watchExistSongs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WatchSongCell", for: indexPath) as UITableViewCell
        let album = WatchSongController.watchExistSongs[indexPath.row]
        cell.textLabel?.text = album.songName
        cell.detailTextLabel?.text = album.artist
        let optionUrl = URL(string: album.thumbnail)
        cell.imageView?.layer.cornerRadius = 5
        cell.imageView?.layer.masksToBounds = true
        if let url = optionUrl {
            cell.imageView?.kf.setImage(with: url,placeholder: UIImage(named: "album"))
        }
        else{
            cell.imageView?.image = nil
        }
        let itemSize = CGSize(width: 50, height: 50)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
        let imageRect = CGRect(x: 0, y: 0, width: itemSize.width, height: itemSize.height)
        cell.imageView?.image?.draw(in: imageRect)
        cell.imageView?.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.performSegue(withIdentifier: "AblumToSong", sender: self)
//        WatchAlbumController.selectedAlbum = watchSongs[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            let songId = WatchSongController.watchExistSongs[indexPath.row].songId
            if checkConnectCondition(){
                deleteSong(songId,index:indexPath.row)
            }
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
}
