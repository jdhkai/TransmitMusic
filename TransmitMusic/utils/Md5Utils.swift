//
//  Md5Utils.swift
//  TransmitMusic
//
//  Created by chenwei on 2019/10/27.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation
import CommonCrypto

class Md5Utils : NSObject{
    // 获取文件的md5值
    static func md5File(url: URL) -> String? {
        let bufferSize = 1024 * 1024
        do {
            //打开文件
            let file = try FileHandle(forReadingFrom: url)
            defer {
                file.closeFile()
            }
            //初始化内容
            var context = CC_MD5_CTX()
            CC_MD5_Init(&context)
            
            //读取文件信息
            while case let data = file.readData(ofLength: bufferSize), data.count > 0 {
                data.withUnsafeBytes {
                    _ = CC_MD5_Update(&context, $0, CC_LONG(data.count))
                }
            }
            //计算Md5摘要
            var digest = Data(count: Int(CC_MD5_DIGEST_LENGTH))
            digest.withUnsafeMutableBytes {
                _ = CC_MD5_Final($0, &context)
            }
            return digest.map { String(format: "%02hhx", $0) }.joined()
        } catch {
            print("Cannot open file:", error.localizedDescription)
            return nil
        }
    }
}
