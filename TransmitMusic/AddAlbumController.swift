//
//  AddAlbumController.swift
//  TransmitMusic
//
//  Created by chenwei on 2019/10/27.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation
import UIKit
import WatchConnectivity

class AddAlbumController : UIViewController{
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var artistField: UITextField!
    
    // 选择的图片
    static var selectedCover : String?
    
    let uuid = UUID().uuidString
    
    override func viewDidLoad() {
        AddAlbumController.selectedCover = nil
        
        albumImage.layer.cornerRadius = 5
        albumImage.layer.masksToBounds = true
    }
    @IBAction func toSelectImage(_ sender: Any) {
        performSegue(withIdentifier: "ToSelectImageSeque", sender: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let cover = AddAlbumController.selectedCover{
            let optionUrl = URL(string: cover)
            if let url = optionUrl {
                albumImage.kf.setImage(with: url,placeholder: UIImage(named: "album"))
            }
            else{
                albumImage.image = UIImage(named: "album")
            }
        }
        else{
            albumImage.image = UIImage(named: "select_image")
        }
    }
    
    @IBAction func addAlbum(_ sender: UIBarButtonItem) {
        let albumName = nameField.text
        let albumArtist = artistField.text
        let albumThumbnail = AddAlbumController.selectedCover
        if albumName == nil{
            showErrorDialog("请输入专辑名称")
        }
        else if albumArtist == nil{
            showErrorDialog("请输入专辑描述")
        }
        else if albumThumbnail == nil{
            showErrorDialog("请选择专辑封面图")
        }
        else if checkConnectCondition() {
            let album = Album(albumId: uuid, albumName: albumName!, albumArtistName: albumArtist!, albumThumbnail: albumThumbnail!)
            addAlbumToWatch(album)
        }
    }
    
    // 添加专辑到手表端
    func addAlbumToWatch(_ album: Album){
        let message = ["command":"CreateAlbum","albumId":album.albumId,"albumName": album.albumName,"albumArtist":album.albumArtistName,"albumThumbnail":album.albumThumbnail]
        WCSession.default.sendMessage(message, replyHandler: { (replyMessage) in
            print(replyMessage)
            DispatchQueue.main.async {
                let success = replyMessage["success"] as! Bool
                if success {
                    self.navigationController?.popViewController(animated: true)
                }
                else{
                    self.showErrorDialog("创建失败")
                }
            }
        }, errorHandler: { (error) in
            self.showErrorDialog(error.localizedDescription)
        })
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
    
}
