//
//  SQLiteBusiness.swift
//  TransmitMusic WatchKit Extension
//
//  Created by chenwei on 2019/10/25.
//  Copyright © 2019 chenwei. All rights reserved.
//

import Foundation

class SQLiteBusiness : NSObject{
    
    // 创建单例
    private static let instance: SQLiteBusiness = SQLiteBusiness()
    
    class func shareInstance() -> SQLiteBusiness {
        return instance
    }
    
    var db : FMDatabase = {
        return SQLiteManager.shareManger().db
    }()
    
    var isOpen : Bool = false
    
    private override init() {
        super.init()
        self.isOpen = self.db.open() && self.createTable()
        print("self.isOpen = \(self.isOpen)")
    }

    // 创建表格
    func createTable() -> Bool{
        let sql = """
            create table if not exists t_album(album_id text primary key,album_name text,album_artist text,album_thumbnail text);
            create table if not exists t_song(song_id text primary key,song_name text,song_artist text,song_thumbnail text,song_file_path text,album_id text,filename text,filemd5 text);
        """
        return db.executeStatements(sql)
    }
    
    // 关闭数据库
    func close(){
        if isOpen{
            db.close()
        }
    }
    
    // 数据库是否打开
    func isDbOpen() -> Bool{
        return isOpen
    }
    
    //----------------歌曲操作---------------
    
    // 获取所有歌曲
    func getAllSong() -> [Song]{
        let sql = "select * from t_song"
        var optionResult: FMResultSet? = nil
        do{
            try optionResult = db.executeQuery(sql, values: nil)
        }
        catch{
            print(error)
        }
        if let result = optionResult{
            var songs:[Song] = []
            while(result.next()){
                songs.append(Song(songId: result.string(forColumn: "song_id")!, songName: result.string(forColumn: "song_name")!, artist: result.string(forColumn: "song_artist")!, thumbnail: result.string(forColumn: "song_thumbnail")!, filePath: result.string(forColumn: "song_file_path")!, albumId: result.string(forColumn: "album_id")!,filename: result.string(forColumn: "filename")!,filemd5: result.string(forColumn: "filemd5")!))
            }
            return songs
        }
        return []
    }
    
    // 根据歌曲编号获取歌曲信息
    func getSongById(_ songId: String) -> Song?{
        let sql = "select * from t_song where song_id = ?"
        var optionResult: FMResultSet? = nil
        do{
            try optionResult = db.executeQuery(sql, values: [songId])
        }
        catch{
            print(error)
        }
        if let result = optionResult{
            var song:Song? = nil
            if(result.next()){
                song = Song(songId: result.string(forColumn: "song_id")!, songName: result.string(forColumn: "song_name")!, artist: result.string(forColumn: "song_artist")!, thumbnail: result.string(forColumn: "song_thumbnail")!, filePath: result.string(forColumn: "song_file_path")!, albumId: result.string(forColumn: "album_id")!,filename: result.string(forColumn: "filename")!,filemd5: result.string(forColumn: "filemd5")!)
            }
            return song
        }
        return nil
    }
    
    // 根据专辑编号获取歌曲
    func getSongsByAlbumId(_ albumId: String) -> [Song]{
        let sql = "select * from t_song where album_id=?"
        var optionResult: FMResultSet? = nil
        do{
            try optionResult = db.executeQuery(sql, values: [albumId])
        }
        catch{
            print(error)
        }
        if let result = optionResult{
            var songs:[Song] = []
            while(result.next()){
                songs.append(Song(songId: result.string(forColumn: "song_id")!, songName: result.string(forColumn: "song_name")!, artist: result.string(forColumn: "song_artist")!, thumbnail: result.string(forColumn: "song_thumbnail")!, filePath: result.string(forColumn: "song_file_path")!, albumId: result.string(forColumn: "album_id")!,filename: result.string(forColumn: "filename")!,filemd5: result.string(forColumn: "filemd5")!))
            }
            return songs
        }
        return []
    }
    
    // 根据文件的md5获取文件
    func getSongsByMd5(_ md5: String) -> [Song]{
        let sql = "select * from t_song where filemd5=?"
        var optionResult: FMResultSet? = nil
        do{
            try optionResult = db.executeQuery(sql, values: [md5])
        }
        catch{
            print(error)
        }
        if let result = optionResult{
            var songs:[Song] = []
            if(result.next()){
                songs.append(Song(songId: result.string(forColumn: "song_id")!, songName: result.string(forColumn: "song_name")!, artist: result.string(forColumn: "song_artist")!, thumbnail: result.string(forColumn: "song_thumbnail")!, filePath: result.string(forColumn: "song_file_path")!, albumId: result.string(forColumn: "album_id")!,filename: result.string(forColumn: "filename")!,filemd5: result.string(forColumn: "filemd5")!))
            }
            return songs
        }
        return []
    }
    
    // 根据文件的md5获取文件
    func getSongByMd5(_ md5: String) -> Song?{
        let sql = "select * from t_song where filemd5=?"
        var optionResult: FMResultSet? = nil
        do{
            try optionResult = db.executeQuery(sql, values: [md5])
        }
        catch{
            print(error)
        }
        if let result = optionResult{
            var song:Song?
            if(result.next()){
                song = Song(songId: result.string(forColumn: "song_id")!, songName: result.string(forColumn: "song_name")!, artist: result.string(forColumn: "song_artist")!, thumbnail: result.string(forColumn: "song_thumbnail")!, filePath: result.string(forColumn: "song_file_path")!, albumId: result.string(forColumn: "album_id")!,filename: result.string(forColumn: "filename")!,filemd5: result.string(forColumn: "filemd5")!)
            }
            return song
        }
        return nil
    }
    
    // 添加歌曲
    func insertSong(_ song: Song) -> Bool {
        let sql = "insert into t_song(song_id,song_name,song_artist,song_thumbnail,song_file_path,album_id,filename,filemd5) values(?,?,?,?,?,?,?,?)"
        var success = false
        do{
            try db.executeUpdate(sql, values: [song.songId,song.songName,song.artist,song.thumbnail,song.filePath,song.albumId,song.filename,song.filemd5])
            success = true
        }
        catch{
            print(error)
        }
        return success
    }
    
    // 删除歌曲
    func deleteSong(_ songId: String) -> Bool{
        let sql = "delete from t_song where song_id=?"
        var success = false
        do{
            try db.executeUpdate(sql, values: [songId])
            success = true
        }
        catch{
            print(error)
        }
        return success
    }
    
    // 更新歌曲信息
    func updateSong(_ songId:String,song: Song) -> Bool{
        let sql = "update t_song set song_name=?,song_artist=?,song_thumbnail=?,song_file_path=?,album_id=?,filename=?,filemd5=? where song_id=?"
        var success = false
        do{
            try db.executeUpdate(sql, values: [song.songName,song.artist,song.thumbnail,song.filePath,song.albumId,song.filename,song.filemd5,songId])
            success = true
        }
        catch{
            print(error)
        }
        return success
    }
    
    //----------------专辑操作---------------
    // 获取所有专辑
    func getAllAlbum() -> [Album]{
        let sql = "select * from t_album"
        var optionResult: FMResultSet? = nil
        do{
            try optionResult = db.executeQuery(sql, values: nil)
        }
        catch{
            print(error)
        }
        if let result = optionResult{
            var albums:[Album] = []
            while(result.next()){
                albums.append(Album(albumId: result.string(forColumn: "album_id")!, albumName: result.string(forColumn: "album_name")!, albumArtistName: result.string(forColumn: "album_artist")!, albumThumbnail: result.string(forColumn: "album_thumbnail")!))
            }
            return albums
        }
        return []
    }
    
    // 根据专辑编号获取专辑信息
    func getAlbumById(_ ablumId: String) -> Album?{
        let sql = "select * from t_album where album_id=?"
        var optionResult: FMResultSet? = nil
        do{
            try optionResult = db.executeQuery(sql, values: [ablumId])
        }
        catch{
            print(error)
        }
        if let result = optionResult{
            var album:Album? = nil
            if(result.next()){
                album = Album(albumId: result.string(forColumn: "album_id")!, albumName: result.string(forColumn: "album_name")!, albumArtistName: result.string(forColumn: "album_artist")!, albumThumbnail: result.string(forColumn: "album_thumbnail")!)
            }
            return album
        }
        return nil
    }
    
    // 根据歌曲编号获取专辑
    func getAlbumBySongId(_ songId: String) -> Album?{
        let optionSong: Song? = getSongById(songId)
        if let song = optionSong{
            return song.albumId != "" ? getAlbumById(song.albumId) : nil
        }
        return nil
    }
    
    // 添加专辑
    func insertAlbum(_ album: Album) -> Bool {
        let sql = "insert into t_album(album_id,album_name,album_artist,album_thumbnail) values(?,?,?,?)"
        var success = false
        do{
            try db.executeUpdate(sql, values: [album.albumId,album.albumName,album.albumArtistName,album.albumThumbnail])
            success = true
        }
        catch{
            print(error)
        }
        return success
    }
    
    // 删除专辑
    func deleteAlbum(_ albumId: String) -> Bool{
        let sql = "delete from t_album where album_id=?"
        var success = false
        do{
            try db.executeUpdate(sql, values: [albumId])
            success = true
        }
        catch{
            print(error)
        }
        return success
    }
    
    // 更新专辑信息
    func updateAblum(_ albumId: String, album: Album) -> Bool{
        let sql = "update t_album set album_name=?,album_artist=?,album_thumbnail=? where album_id=?"
        var success = false
        do{
            try db.executeUpdate(sql, values: [album.albumName,album.albumArtistName,album.albumThumbnail,albumId])
            success = true
        }
        catch{
            print(error)
        }
        return success
    }
}
