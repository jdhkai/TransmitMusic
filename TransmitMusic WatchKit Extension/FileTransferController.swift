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
    
    @IBOutlet weak var connectImage: WKInterfaceImage!
    @IBOutlet weak var tipLabel: WKInterfaceLabel!
    
    
    override func didAppear() {
        print(#function)
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
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let command = message["command"]{
            let commandStr = command as! String
            switch commandStr {
            case "getLocalSongs":
                let replyMessage = ["data": LocalMusicManager.shareInstance().loadMusicFromDocument()]
                replyHandler(replyMessage)
            case "delete":
                let songName = message["songName"] as! String
                let optionDocumentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
                let documentURL = URL(fileURLWithPath: optionDocumentPath!)
                let fileURL = documentURL.appendingPathComponent(songName)
                var success = true
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    do{
                        try FileManager.default.removeItem(at: fileURL)
                    }
                    catch{
                        print(error)
                        success = false
                    }
                }
                if success{
                    LocalMusicManager.shareInstance().refreshMusic()
                    NotificationCenter.default.post(name: NSNotification.Name("UPDATE_MUSIC_LIST"), object: nil)
                }
                let replyMessage = ["data":success]
                replyHandler(replyMessage)
            default:
                print("无法解析")
            }
            
        }
        print(#function)
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        print("g正在改善文件")
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("接收文件")
        print(file.fileURL)
        let path = file.fileURL.path
        let index = path.index(path.lastIndex(of: "/")!, offsetBy: 1)
        let songName = path[index...].removingPercentEncoding
        let optionDocumentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let documentURL = URL(fileURLWithPath: optionDocumentPath!)
        let fileURL = documentURL.appendingPathComponent(songName!)
        do{
            try FileManager.default.moveItem(at: file.fileURL, to: fileURL)
        }
        catch{
            print("文件保存错误!")
        }
        LocalMusicManager.shareInstance().refreshMusic()
        NotificationCenter.default.post(name: NSNotification.Name("UPDATE_MUSIC_LIST"), object: nil)
    }
}
