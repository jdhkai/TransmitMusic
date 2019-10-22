//
//  SyncMusicController.swift
//  TransmitMusic
//
//  Created by chenwei on 2019/10/20.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation
import UIKit
import WatchConnectivity

class SyncMusicController: UIViewController,UINavigationBarDelegate {
    
    static var syncSongs:[String] = []
    
    var currentSyncIndex = -1;
    
    
    var transferTask: WCSessionFileTransfer?
    
    var syncing : Bool = false //是否正在同步
    
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var currentSongLabel: UILabel!
    
    var syncTimer : Timer?
    
    override func viewDidLoad() {
        
        var images = [UIImage]()
        for i in 1 ... 28 {
            images.append(UIImage(named: "Loading_\(i)")!)
        }
        loadingImageView.animationImages = images
        loadingImageView.animationDuration = 5
        loadingImageView.animationRepeatCount = 0
        print(SyncMusicController.syncSongs)
        if SyncMusicController.syncSongs.count > 0 {
            startSync()
        }
        else{
            counterLabel.text = "同步完成"
            currentSongLabel.text = ""
            loadingImageView.image = UIImage(named: "finished")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopSync()
    }
    
    func stopSync(){
        SyncMusicController.syncSongs.removeAll()
        if let transfer = transferTask {
            if transfer.isTransferring {
                transfer.cancel()
            }
            transferTask = nil
        }
        if let timer = syncTimer{
            if timer.isValid {
                timer.invalidate()
                syncTimer = nil
            }
        }
        print("释放资源")
    }
    
    @objc func transferTime(timer: Timer){
        if let transfer = transferTask {
            if transfer.progress.isFinished {
                print("上传下一个")
                timer.invalidate()
                startSync()
            }
            else{
                print("还没有g完成")
            }
        }
        else{
            timer.invalidate()
        }
    }
    
    func startSync(){
        currentSyncIndex += 1
        if currentSyncIndex > SyncMusicController.syncSongs.count - 1 {
            counterLabel.text = "同步完成"
            currentSongLabel.text = ""
            loadingImageView.stopAnimating()
            loadingImageView.image = UIImage(named: "finished")
            syncing = false
            return
        }
        syncing = true
        loadingImageView.startAnimating()
        counterLabel.text = "正在同步... (\(currentSyncIndex+1) / \(SyncMusicController.syncSongs.count))"
        currentSongLabel.text = "当前歌曲：\(SyncMusicController.syncSongs[currentSyncIndex])"
        if WCSession.default.isReachable{
            let optionDocumentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            let documentURL = URL(fileURLWithPath: optionDocumentPath!)
            let fileURL = documentURL.appendingPathComponent(SyncMusicController.syncSongs[currentSyncIndex])
            if FileManager.default.fileExists(atPath: fileURL.path) {
                transferTask = WCSession.default.transferFile(fileURL, metadata: nil)
                syncTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target:self , selector: #selector(transferTime), userInfo: nil, repeats: true)
            }
            else{
                print("文件不存在")
                Timer.scheduledTimer(withTimeInterval: TimeInterval(2), repeats: false) { (timer) in
                    self.startSync()
                    timer.invalidate()
                }
            }
//            if !isDirectory.boolValue {
//                transferTask = WCSession.default.transferFile(fileURL, metadata: nil)
//                time = Int(Date().timeIntervalSince1970)
//                Timer.scheduledTimer(withTimeInterval: TimeInterval(1), repeats: true) { (timer) in
//                    print("\(self.transferTask?.isTransferring)")
//                    print("\(self.transferTask?.progress.isFinished)")
//                    print("\(self.transferTask?.progress.fileCompletedCount)")
//                    print("\(self.transferTask?.progress.fileTotalCount)")
//                    print("\(self.transferTask?.progress)")
//                    if self.transferTask?.progress.isFinished ?? false {
//                        let length = Int(Date().timeIntervalSince1970) - self.time
//                        print("花费时长：\(length)")
//                    }
//
//                }
//            }
//            else{
//                let alert = UIAlertController(title: "错误", message: "该文件不支持发送!", preferredStyle: .alert)
//                let okAction = UIAlertAction(title: "知道了", style: .cancel, handler: nil)
//                alert.addAction(okAction)
//                present(alert, animated: true, completion: nil)
//            }
        }
        else{
            let alert = UIAlertController(title: "错误", message: "无法连接Watch设备!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "知道了", style: .cancel, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
}
