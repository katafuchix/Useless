//
//  Spend.swift
//  Useless
//
//  Created by cano on 2016/02/27.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import RealmSwift

public class Spend: Object {
    dynamic var id: Int64 = 0
    dynamic var date: NSDate?
    dynamic var genre: Genre?
    dynamic var price: Float = 0.0
    
    /*
    dynamic var name : String?  // 任意に編集できる名前
    dynamic var color : Int32 = 0  // 過去のデータ保存しておくための色情報
    dynamic var memo : String?  // メモ
    dynamic var order: Int64 = 0 //並び順の番号
    */
    
    //インデックスの設定
    override public static func indexedProperties() -> [String] {
        return ["id"]
    }
    //プライマリキーの設定
    override public static func primaryKey() -> String? {
        return "id"
    }
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
