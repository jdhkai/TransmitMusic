//
//  显示Watch上的专辑
//  WatchAlbumController.swift
//  TransmitMusic
//
//  Created by chenwei on 2019/10/25.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import WatchConnectivity

class WatchAlbumController : UITableViewController{
    
    static var selectedAlbum: Album?
    
    // 手表端的专辑
    var watchAlbums: [Album] = []
    
    var header: MJRefreshNormalHeader?
    
    // 已经尝试激活了
    var tryActived: Bool = false
    
    override func viewDidLoad() {
        // 设置分隔线全屏
        self.tableView.separatorInset = .zero
        self.tableView.layoutMargins = .zero
        // 设置没有数据cell隐藏分隔线
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(onRefresh))
        self.tableView.mj_header = header
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        else{
            showErrorDialog("当前iPhone不支持与Apple Watch通信")
        }
    }
    
    @objc func onRefresh(){
        if checkConnectCondition() {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.getAlbumsFromWatch()
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
    func getAlbumsFromWatch(){
        let message = ["command":"GetAllAlbum"]
        WCSession.default.sendMessage(message, replyHandler: { (replyMessage) in
            print(replyMessage)
            DispatchQueue.main.async {
                self.header?.endRefreshing()
                self.watchAlbums.removeAll()
                let data = replyMessage["data"] as! [[String:String]]
                for album in data{
                    self.watchAlbums.append(Album(albumId: album["albumId"]!, albumName: album["albumName"]!, albumArtistName: album["albumArtist"]!, albumThumbnail: album["albumThumbnail"]!))
                }
                self.tableView.reloadData()
            }
        }, errorHandler: { (error) in
            DispatchQueue.main.async {
                self.header?.endRefreshing()
                self.showErrorDialog(error.localizedDescription)
            }
        })
    }
    
    // 从手表端删除专辑
    func deleteAlbum(_ albumId : String, index: Int){
        let message = ["command":"DeleteAlbumById","albumId":albumId]
        WCSession.default.sendMessage(message, replyHandler: { (replyMessage) in
            print(replyMessage)
            DispatchQueue.main.async {
                let data = replyMessage["success"] as! Bool
                if data {
                    self.watchAlbums.remove(at: index)
                    self.tableView.reloadData()
                }
                else if let message = replyMessage["message"]{
                    self.showErrorDialog((message as! String))
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
        return watchAlbums.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WatchAlbumCell", for: indexPath) as UITableViewCell
        let album = watchAlbums[indexPath.row]
        cell.textLabel?.text = album.albumName
        cell.detailTextLabel?.text = album.albumArtistName
        let optionUrl = URL(string: album.albumThumbnail)
        cell.imageView?.layer.cornerRadius = 5
        cell.imageView?.layer.masksToBounds = true
        if let url = optionUrl {
            cell.imageView?.kf.setImage(with: url,placeholder: UIImage(named: "album"))
        }
        else{
            cell.imageView?.image = UIImage(named: "album")
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
        WatchAlbumController.selectedAlbum = watchAlbums[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            let albumId = watchAlbums[indexPath.row].albumId
            if checkConnectCondition() {
                deleteAlbum(albumId, index: indexPath.row)
            }
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
}
extension WatchAlbumController : WCSessionDelegate{
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(#function)
        guard error != nil else {
            DispatchQueue.main.async {
                if !self.header!.isRefreshing {
                    self.header?.beginRefreshing()
                }
            }
            return
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print(#function)
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print(#function)
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print(#function)
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        replyHandler(["":""])
    }
    
}
