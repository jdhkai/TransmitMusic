//
//  DocumentMusicController.swift
//  TransmitMusic
//
//  Created by chenwei on 2019/10/20.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation
import UIKit

class DocumentMusicController : UITableViewController{
    
    var documentSongs:[String] = []
    
    override func viewDidLoad() {
        let optionMusicFiles = loadMusicFromDocument()
        documentSongs.append(contentsOf: optionMusicFiles)
    }
    
    func loadMusicFromDocument() -> [String]{
        let optionDocumentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        var files:[String]?
        do{
            files = try FileManager.default.contentsOfDirectory(atPath: optionDocumentPath!)
        }
        catch{
            print(error)
        }
        let songs = (files ?? []).filter({ (songName:String) -> Bool in
            return songName.hasSuffix(".mp3") || songName.hasSuffix(".flac")
        })
        return songs
    }
    
    //同步歌曲
    @IBAction func syncSong(_ sender: Any) {
        var waitSyncSong:[String] = []
        for song in documentSongs{
            if !ViewController.watchSongs.contains(song){
                waitSyncSong.append(song)
            }
        }
        if waitSyncSong.count > 0 {
            SyncMusicController.syncSongs.append(contentsOf: waitSyncSong)
        }
        else{
            let alert = UIAlertController(title: "提示", message: "没有需要同步的歌曲，歌曲列表为空或歌曲已全部同步完成!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "知道了", style: .cancel, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
        self.performSegue(withIdentifier: "ToSyncSegue", sender: self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentSongs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "musicCell", for: indexPath)  as UITableViewCell
        let label1 = cell.viewWithTag(1001) as! UILabel
        let label2 = cell.viewWithTag(1002) as! UILabel
        label1.text = "\(indexPath.row + 1)"
        label2.text = documentSongs[indexPath.row]
        if ViewController.watchSongs.contains(documentSongs[indexPath.row]){
            label1.backgroundColor = UIColor.green
        }
        else{
            label1.backgroundColor = UIColor.link
        }
        return  cell
    }
//    var time = 0
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if WCSession.default.isReachable{
//            let optionDocumentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
//            let documentURL = URL(fileURLWithPath: optionDocumentPath!)
//            let fileURL = documentURL.appendingPathComponent(documentSongs[indexPath.row])
//            var isDirectory = ObjCBool.init(false)
//            FileManager.default.fileExists(atPath: fileURL.path, isDirectory: &isDirectory)
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
//        }
//        else{
//            let alert = UIAlertController(title: "错误", message: "无法连接Watch设备!", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "知道了", style: .cancel, handler: nil)
//            alert.addAction(okAction)
//            present(alert, animated: true, completion: nil)
//        }
//    }
}
