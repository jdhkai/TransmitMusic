//
//  SelectImageController.swift
//  TransmitMusic
//
//  Created by chenwei on 2019/10/27.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation
import UIKit

class SelectImageController : UICollectionViewController{
    
    // 列数
    let columnCount = 3
    // 内置图片
    let builtInImages: [String] = [
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572280283090&di=268dcf91bcbbaece50819a4e4a3fd9a1&imgtype=0&src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fimages%2F20170920%2F4fd3070015f04f3aa22c98dffccfc289.jpeg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572280311668&di=25143d78030dba1dbaa89d8061b32196&imgtype=0&src=http%3A%2F%2Fp1.qhimg.com%2Ft011f88d9e88b2a6f22.jpg",
        "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=4186456430,3244978690&fm=26&gp=0.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572280311666&di=e2506f94c841589a78a8bc799657679d&imgtype=0&src=http%3A%2F%2Fpic.qqtn.com%2Fup%2F2018-2%2F15178955404382246.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572280311666&di=582206b87e1ba9ecb140a5f544837e83&imgtype=0&src=http%3A%2F%2Fwww.seoxiehui.cn%2Fdata%2Fattachment%2Fportal%2F201811%2F17%2F010057aopu9imsycmcz9tc.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572280364240&di=2a88106e7a289d8e030f653089b463da&imgtype=0&src=http%3A%2F%2Fimg.duoziwang.com%2F2016%2F09%2F15%2F19091916313.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572280375907&di=6d5115efbca2ae257825f00326178ae0&imgtype=jpg&src=http%3A%2F%2Fimg0.imgtn.bdimg.com%2Fit%2Fu%3D4266354250%2C2231683142%26fm%3D214%26gp%3D0.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572280311663&di=c691c8dd97a629e422dc7cdd67ac4513&imgtype=0&src=http%3A%2F%2Fpic.qqtn.com%2Fup%2F2018-5%2F15254871484404493.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572280398532&di=64d626b26a5dfeee9ef267c2e42b6542&imgtype=0&src=http%3A%2F%2Fwww.96weixin.com%2Fupload%2F20181128%2F1543369173962176.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572280311662&di=413a7ce2740a4894e9e37e90b3e1e398&imgtype=0&src=http%3A%2F%2Fd.ifengimg.com%2Fw600%2Fp0.ifengimg.com%2Fpmop%2F2018%2F0621%2FBAC742242EDB16AEC9C35E285E3FD6D2DB62BD58_size70_w640_h640.jpeg",
        "https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=1469895385,4220337778&fm=26&gp=0.jpg",
        "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=719185259,384254147&fm=26&gp=0.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572280440146&di=f4975466f79ce462d5290e029e7ebf9c&imgtype=0&src=http%3A%2F%2Fpic.qqtn.com%2Fup%2F2018-2%2F15178955405771192.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572280449865&di=8a7ea9d9e7d82907937febb8684b757a&imgtype=0&src=http%3A%2F%2Fpic.qqtn.com%2Fup%2F2018-2%2F15178955417024732.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572280470903&di=e0ce0afb966e0017839b9702ea1ed69b&imgtype=jpg&src=http%3A%2F%2Fpic.qqtn.com%2Fup%2F2018-5%2F2018052410514879089.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572280491488&di=cddeb72f022ef8c63e6c84848d3d8da2&imgtype=jpg&src=http%3A%2F%2Fimg.qqzhi.com%2Fuploads%2F2018-12-27%2F151248445.jpg",
        "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=1669485771,1755540353&fm=26&gp=0.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572280483188&di=80c8f039ba1f957afe6396b14e54b089&imgtype=0&src=http%3A%2F%2Fwww.xitongcheng.cc%2Fuploads%2Fallimg%2F180711%2F0UJT114-16.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572280483188&di=6cdabc7ad0593cae864aa2abde3aec68&imgtype=0&src=http%3A%2F%2Fpic.qqtn.com%2Fup%2F2018-7%2F15305011175900556.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572280483188&di=cfab45cb43faebff85d5bef0397e36fc&imgtype=0&src=http%3A%2F%2Fpic.qqtn.com%2Fup%2F2018-3%2F15209963443984266.jpg",
        "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=3738218171,2335275206&fm=26&gp=0.jpg",
        "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=3251025748,2003500598&fm=26&gp=0.jpg"]
    
    override func viewDidLoad() {
        let layout = self.collectionViewLayout as! UICollectionViewFlowLayout
        let spacing = CGFloat(10)
        layout.minimumLineSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset.left = spacing
        layout.sectionInset.right = spacing
        layout.sectionInset.top = spacing
        let width: CGFloat = (UIScreen.main.bounds.width - spacing*CGFloat(columnCount -  1) - layout.sectionInset.left - layout.sectionInset.right)/CGFloat(columnCount)
        layout.itemSize = CGSize(width: Int(width), height: Int(width))
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return builtInImages.count
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionCell
//        cell.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        let optionUrl = URL(string: builtInImages[indexPath.row])
        cell.coverImage.layer.cornerRadius = 5
        cell.coverImage.layer.masksToBounds = true
        if let url = optionUrl {
            cell.coverImage.kf.setImage(with: url,placeholder: UIImage(named: "album"))
        }
        else{
            cell.coverImage.image = UIImage(named: "album")
        }
        return cell;
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("选中了：\(indexPath.row)")
        AddAlbumController.selectedCover = builtInImages[indexPath.row]
        self.navigationController?.popViewController(animated: true)
    }

}
