//
//  PublicDatas.swift
//  MapSample
//
//  Created by cano on 2016/02/20.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit

// NSUserDefaultを共通して使うためのインターフェース用のクラス
public class PublicDatas: NSObject {
    
    static var instance : PublicDatas? = nil
    var ud : NSUserDefaults?
    
    // インスタンス取得
    static func getPublicDatas() -> PublicDatas {
        if instance == nil {
            instance = PublicDatas()
        }
        return instance!
    }
    
    // 初期化処理
    required public override init () {
        super.init()
        ud = NSUserDefaults.standardUserDefaults()
    }
    
    // 値をセット 全ての型で共通して利用
    func setData(value:AnyObject, key:String){
        ud!.setObject(value, forKey:key)
        ud!.synchronize()
    }
    
    // 型を指定せずに値を取得
    func getDataForKey(key:String)->AnyObject?{
        if ud?.objectForKey(key) != nil {
            return (ud?.objectForKey(key))!
        }else{
            return nil
        }
    }
    
    // Stringで値を取得
    func getStringForKey(key:String)->String!{
        if ud!.objectForKey(key) != nil {
            return ud!.objectForKey(key) as! String
        }else{
            return ""
        }
    }
    
    // Intで値を取得
    func getIntegerForKey(key:String)->Int!{
        if ud!.objectForKey(key) != nil {
            return ud!.objectForKey(key) as! Int
        }else{
            return 0
        }
    }
    
    // Floatで値を取得
    func getFloatForKey(key:String)->Float!{
        if ud!.objectForKey(key) != nil {
            return ud!.objectForKey(key) as! Float
        }else{
            return 0.0
        }
    }
    
    // Bool型で値を取得
    func getBoolForKey(key:String)->Bool!{
        if ud!.objectForKey(key) != nil {
            return ud!.objectForKey(key) as! Bool
        }else{
            return false
        }
    }
}

/*
public class PublicDatas: NSObject{

    static var instance : PublicDatas? = nil
    var dictionary : Dictionary<String,AnyObject>?
    
    static func getPublicDatas() -> PublicDatas {
        if instance == nil {
            instance = PublicDatas()
        }
        return instance!
    }
    
    required public override init () {
        super.init()
        dictionary = Dictionary<String,AnyObject>()
    }
    
    func setData(value:AnyObject, key:String){
        let lock = AutoSync(self)
        dictionary![key] = value
    }
    
    func getData(key:String)->AnyObject{
        return (dictionary?[key])!
    }
}

class AutoSync {
    let object : AnyObject
    
    init(_ obj : AnyObject) {
        object = obj
        objc_sync_enter(object)
    }
    
    deinit {
        objc_sync_exit(object)
    }
}
*/