//
//  Genre.swift
//  Useless
//
//  Created by cano on 2016/02/27.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import RealmSwift

public class Genre: Object {
    dynamic var id: Int64 = 0
    dynamic var name: String = ""
    dynamic var color: String = ""
    dynamic var order: Int64 = 0 //並び順の番号
    dynamic var memo : String = ""
    
    //インデックスの設定
    override public static func indexedProperties() -> [String] {
        return ["id"]
    }
    //プライマリキーの設定
    override public static func primaryKey() -> String? {
        return "id"
    }
}
