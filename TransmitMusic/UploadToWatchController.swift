//
//  UploadToWatchController.swift
//  TransmitMusic
//
//  Created by chenwei on 2019/10/26.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation

import UIKit
import WatchConnectivity

class UploadToWatchController : UIViewController {
    @IBOutlet weak var thumbnailImage: RoundImageView!
    @IBOutlet weak var syncProgressLabel: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    // 准备上传的歌曲
    var prepareUploadSong: [String] = []
    
    // 内置的默认歌曲图片
    let defaultThumbnail : [String] = [
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572114429450&di=c8c91d0a75eb903a2c2955f120769953&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201807%2F31%2F20180731152127_fctgj.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572114429449&di=2f914fb0b6de64f2ea42f5d19ce9047f&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201509%2F21%2F20150921173512_PehaH.jpeg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572114429447&di=959625c64f7c6f6721733bb08049971d&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201604%2F29%2F20160429225403_dvrsx.thumb.700_0.jpeg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572114429446&di=11ba078d92374b2eb4fe52a7d97b6438&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201706%2F11%2F20170611164039_wVsck.thumb.700_0.jpeg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572114429445&di=582fc65fd8ceb1e4b74f78cfc1be867f&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201508%2F18%2F20150818212758_JXLHZ.thumb.700_0.jpeg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572114429445&di=0547084d475239c3cd1920eb3048e780&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201704%2F04%2F20170404153225_EiMHP.jpeg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572114429445&di=68e7aa158bfa39afe69c956efb015007&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201710%2F20%2F20171020164428_KXUMZ.thumb.700_0.jpeg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572114515155&di=4534822a578a49573b1c115e21485c55&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201502%2F11%2F20150211012500_w3YBN.jpeg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572114515155&di=24b2a3a3b75448748f5f23d780e5d074&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201510%2F30%2F20151030214223_4unTk.jpeg",
        "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=2717659886,1311182805&fm=26&gp=0.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572114611048&di=6e590ee7f1b6fed06d5fa872eb3c4baf&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201808%2F15%2F20180815112431_keyzi.thumb.700_0.jpeg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572114611048&di=e269da11ea4609814864f3a918f3e1ca&imgtype=0&src=http%3A%2F%2Fimage.biaobaiju.com%2Fuploads%2F20180801%2F18%2F1533118783-zDSdXfRHuE.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572114611047&di=d451a03049ce5bb8696695119033d3b8&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201805%2F30%2F20180530080009_jwnfa.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572114611046&di=5dc49d76bce6bd7f154062ec6f843c10&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201708%2F07%2F20170807114113_4efNW.thumb.700_0.jpeg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572114611045&di=afe9358ee4f9ff790bb28fc6d1efe43c&imgtype=0&src=http%3A%2F%2Fimg.mp.sohu.com%2Fq_mini%2Cc_zoom%2Cw_640%2Fupload%2F20170522%2F25320f4a8c7240d685f30f08426f853e_th.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572114611043&di=56c217fbf3993241bec209ba5b8057df&imgtype=0&src=http%3A%2F%2Fbpic.588ku.com%2Felement_origin_min_pic%2F17%2F12%2F24%2Fdfc95146f6b8151bef81c27f9653119e.jpg%2521%2Ffwfh%2F804x804%2Fquality%2F90%2Funsharp%2Ftrue%2Fcompress%2Ftrue",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572114611042&di=5b9884889894c8b3a0433a21dd520703&imgtype=0&src=http%3A%2F%2Fpic.51yuansu.com%2Fpic3%2Fcover%2F03%2F48%2F08%2F5badf4e45869d_610.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572114656643&di=527577f92e45347ee028aabbd18e0f23&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201808%2F23%2F20180823233039_wbqhc.jpg"
    ]
    
    // 当前上传的歌曲
    var uploadSong: Song? = nil
    //当前上传歌曲在列表中的索引位置
    var currentUploadIndex = -1;
    
    // 上传文件的任务
    var transferTask: WCSessionFileTransfer?
    
    // 上传状态
    var uploadState: Int = 0
    
    // 定时器：检查当前上传状态
    var uploadTimer : Timer?
    
    override func viewDidLoad() {
        prepareUploadSong.append(contentsOf: LocalSongController.prepareUploadSong)
        uploadNextToWatch()
    }
    
    // 通过状态设置UI
    // state:
    //   0 正在上传
    //   1 上传错误
    //   2 上传完成
    func setupUIByState(_ state: Int, errorMessage: String? = nil){
        uploadState = state
        print("当前上传状态：\(state)")
        switch state {
        case 0: //正在上传
            errorLabel.isHidden = true
            retryButton.isHidden = true
            syncProgressLabel.isHidden = false
            currentLabel.isHidden = false
            if let song = uploadSong {
                currentLabel.text = "当前上传歌曲：\(song.songName)"
                syncProgressLabel.text = "上传中(\(currentUploadIndex+1) / \(prepareUploadSong.count))..."
                let optionUrl = URL(string: uploadSong!.thumbnail)
                if let url = optionUrl {
                    thumbnailImage.kf.setImage(with: url,placeholder: UIImage(named: "album"))
                }
                thumbnailImage.rotation()
            }
        case 1: //上传错误
            errorLabel.isHidden = false
            retryButton.isHidden = false
            syncProgressLabel.isHidden = true
            currentLabel.isHidden = true
            if let song = uploadSong {
                errorLabel.text = "上传\"\(song.songName)\"错误：\(errorMessage ?? "未知")"
                thumbnailImage.layer.removeAllAnimations()
            }
            else{
                errorLabel.text = "上传错误：\(errorMessage ?? "未知")"
            }
            thumbnailImage.image = UIImage(named: "upload_error")
            stopUpload()
        case 2: //上传完成
            errorLabel.isHidden = true
            retryButton.isHidden = true
            syncProgressLabel.isHidden = false
            currentLabel.isHidden = false
            currentLabel.text = ""
            syncProgressLabel.text = "\(prepareUploadSong.count)首歌上传完成"
            thumbnailImage.layer.removeAllAnimations()
            thumbnailImage.image = UIImage(named: "finished")
            stopUpload()
        default:
            print("")
        }
    }
    
    // 发送歌曲至手表端
    func uploadSongToWatch(_ index: Int){
        currentUploadIndex = index
        let isReachable = WCSession.default.isReachable
        let isActived = (WCSession.default.activationState == .activated)
        if isReachable && isActived{
            let filename = prepareUploadSong[index]
            var songName  = filename
            if let index = filename.lastIndex(of: ".") {
                songName = filename[..<index].removingPercentEncoding!
            }
            
            let songId = UUID().uuidString
            var artist = songName
            if artist.lastIndex(of: "-") != nil{
                let array = artist.split(separator: "-")
                artist = String(array[array.count-1]).trimmingCharacters(in: .whitespaces)
            }
            let thumbnail = defaultThumbnail.randomElement()!
            let albumId = WatchAlbumController.selectedAlbum!.albumId
            let filePath = "\(albumId)/\(songId)"
            let optionDocumentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            let url = URL(fileURLWithPath: optionDocumentPath!)
            let fileUrl = url.appendingPathComponent(filename)
            
            var filemd5 = ""
            if let md5 = Md5Utils.md5File(url: fileUrl) {
                filemd5 = md5.uppercased()
            }
            uploadSong = Song(songId: songId, songName: songName, artist: artist, thumbnail: thumbnail, filePath: filePath, albumId: albumId, filename: filename, filemd5: filemd5)
            
            setupUIByState(0)
            sendSongPrepareToWhatch(uploadSong!)
        }
        else if(isActived){
            setupUIByState(1,errorMessage: "请在Apple Watch上打开APP,并开启远程同步")
        }
        else{
            setupUIByState(1,errorMessage: "请在Apple Watch上打开APP,并靠近手机")
        }
    }
    
    // 发送下一首歌至手表端
    func uploadNextToWatch(){
        stopUpload()
        if currentUploadIndex >= prepareUploadSong.count - 1 {
            setupUIByState(2)
        }
        else{
            uploadSongToWatch(currentUploadIndex+1)
        }
    }
    
    // 告诉手表端：iPhone将发送歌曲文件了
    func sendSongPrepareToWhatch(_ song: Song){
        let message = ["command": "PrepareSendFile","songId":song.songId,"songName":song.songName,"artist":song.artist,"thumbnail": song.thumbnail,"filePath":song.filePath,"albumId":song.albumId,"filename":song.filename,"filemd5":song.filemd5]
        WCSession.default.sendMessage(message, replyHandler: { (replyMessage) in
            DispatchQueue.main.async {
                let exist: Bool = replyMessage["exist"] as! Bool
                let success: Bool = replyMessage["success"] as! Bool
                if exist && success{
                    // 数据库已存在并已添加到数据库
                    // 上传下一首歌曲
                    self.uploadNextToWatch()
                }
                else if(success){
                    self.sendFileToWatch(song.filename)
                }else{
                    self.setupUIByState(1,errorMessage: "Apple Watch拒绝上传此文件")
                }
            }
        }) { (error) in
            DispatchQueue.main.async {
                self.setupUIByState(1,errorMessage: error.localizedDescription)
            }
        }
    }
    
    // 上传文件至手表
    func sendFileToWatch(_ filename: String){
        if WCSession.default.isReachable{
            let optionDocumentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            let documentURL = URL(fileURLWithPath: optionDocumentPath!)
            let fileURL = documentURL.appendingPathComponent(filename)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                transferTask = WCSession.default.transferFile(fileURL, metadata: nil)
                uploadTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target:self , selector: #selector(transferTime), userInfo: nil, repeats: true)
            }
            else{
                self.setupUIByState(1,errorMessage: "上传的文件已删除!")
            }
        }
        else{
            setupUIByState(1,errorMessage: "请在Apple Watch上打开APP,并开启远程同步")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        thumbnailImage.layer.removeAllAnimations()
        stopUpload()
    }
    
    // 重新开始上传
    @IBAction func retryUpload(_ sender: Any) {
        uploadSongToWatch(currentUploadIndex)
    }
    
    // 停止上传
    func stopUpload(){
        if let transfer = transferTask {
            if transfer.isTransferring {
                transfer.cancel()
            }
            transferTask = nil
        }
        if let timer = uploadTimer{
            if timer.isValid {
                timer.invalidate()
                uploadTimer = nil
            }
        }
        print("释放资源")
    }
    
    @objc func transferTime(timer: Timer){
        if let transfer = transferTask {
            if transfer.progress.isFinished {
                uploadNextToWatch()
            }
            else{
                print("--------------")
                print("\(transfer.progress)")
                print("\(transfer.isTransferring)")
                print("--------------")
            }
        }
        else{
            setupUIByState(1,errorMessage: "未知")
        }
    }
}
