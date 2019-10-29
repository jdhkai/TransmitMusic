//
//  LocalSongController.swift
//  TransmitMusic
//
//  Created by chenwei on 2019/10/26.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation
import UIKit

class LocalSongController : UITableViewController{
    
    var documentSongs:[String] = []
    
    var selectedSong: Set<String> = []
    
    // 准备上传的歌曲
    static var prepareUploadSong : [String] = []
    
    //手表端已存在的歌曲名称
    var watchSongsFilename: [String] = []
    
    override func viewDidLoad() {
        // 设置分隔线全屏
        self.tableView.separatorInset = .zero
        self.tableView.layoutMargins = .zero
        // 设置没有数据cell隐藏分隔线
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        let optionMusicFiles = loadMusicFromDocument()
        documentSongs.append(contentsOf: optionMusicFiles)
        
        for song in WatchSongController.watchExistSongs{
            watchSongsFilename.append(song.filename)
        }
        print(watchSongsFilename)
    }
    
    // 从Document目录下获取所有文件
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
    
    // 上传歌曲至手表
    @IBAction func uploadToWatch(_ sender: UIBarButtonItem) {
        if selectedSong.isEmpty {
            let alert = UIAlertController(title: "提示", message: "请先选择需要上传的歌曲。", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return;
        }
        LocalSongController.prepareUploadSong.removeAll()
        LocalSongController.prepareUploadSong.append(contentsOf: selectedSong)
        performSegue(withIdentifier: "UploadToWatch", sender: nil)
        dismiss(animated: false, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentSongs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocalSongCell", for: indexPath) as! LocalSongCell
        if watchSongsFilename.contains(documentSongs[indexPath.row]) {
            cell.songNameLabel.textColor = UIColor.gray
            cell.songNameLabel?.text = "[重复]\(documentSongs[indexPath.row])"
        }
        else{
            cell.songNameLabel.textColor = UIColor.black
            cell.songNameLabel?.text = documentSongs[indexPath.row]
        }
        return  cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return watchSongsFilename.contains(documentSongs[indexPath.row]) ? nil : indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSong.insert(documentSongs[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if selectedSong.contains(documentSongs[indexPath.row]){
            selectedSong.remove(documentSongs[indexPath.row])
        }
    }
}

