//
//  ViewController.swift
//  TransmitMusic
//
//  Created by chenwei on 2019/10/19.
//  Copyright © 2019 chenwei. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UITableViewController {
    
    static var watchSongs:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        readWatchSongList()
    }
    
    func readWatchSongList(){
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.sendGetSongMessageToWatch()
            }
        }
        else{
            let alert = UIAlertController(title: "Failed", message: "iOS is not support WCSession.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            print("设备不支持WCSession")
        }
    }
    
    @IBAction func refreshSession(_ sender: UIBarButtonItem) {
        sendGetSongMessageToWatch()
    }
    func sendGetSongMessageToWatch() {
        if WCSession.default.isReachable {
            let message = ["command":"getLocalSongs"]
            WCSession.default.sendMessage(message, replyHandler: { (replyMessage) in
                print(replyMessage)
                DispatchQueue.main.async {
                    ViewController.watchSongs.removeAll()
                    ViewController.watchSongs.append(contentsOf: replyMessage["data"] as! [String])
                    self.tableView.reloadData()
                }
            }, errorHandler: nil)
        }
        else{
            let alert = UIAlertController(title: "Failed", message: "Apple Watch is not reachable.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ViewController.watchSongs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = ViewController.watchSongs[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            if WCSession.default.isReachable {
                let message = ["command":"delete","songName":ViewController.watchSongs[indexPath.row]]
                WCSession.default.sendMessage(message, replyHandler: { (replyMessage) in
                    DispatchQueue.main.async {
                        self.sendGetSongMessageToWatch()
                    }
                }, errorHandler: nil)
            }
            else{
                let alert = UIAlertController(title: "错误", message: "无法连接Watch设备!", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "知道了", style: .cancel, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension ViewController : WCSessionDelegate{
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(#function)
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

