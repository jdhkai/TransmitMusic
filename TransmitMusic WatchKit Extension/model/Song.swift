//
//  Song.swift
//  TransmitMusic WatchKit Extension
//
//  Created by chenwei on 2019/10/24.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation

// 歌曲实体类
struct Song {
    // 歌曲编号
    var songId : String
    // 歌曲名称
    var songName : String
    // 艺术家名称
    var artist : String
    // 文件缩略图
    var thumbnail: String
    // 文件路径（相对于Document的地址，一般为albumId/songName）
    var filePath: String
    // 专辑编号
    var albumId: String
    // 文件名称
    var filename: String
    // 文件的md5值
    var filemd5: String
}
