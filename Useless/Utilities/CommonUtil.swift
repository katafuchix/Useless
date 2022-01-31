//
//  CommonUtil.swift
//  Useless
//
//  Created by cano on 2016/03/18.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import Foundation
import UIKit

public class CommonUtil {

    public static let DEFAULT_FONT_NAME_JP = "HiraKakuProN-W3"
    public static let DEFAULT_FONT_NAME_EN = "Helvetica"
    public static let NAVBAR_TRANSLUCENT = false // ナビゲーションバーの透過効果
    public static let TABLE_WIDTH_KEY = "TABLE_WIDTH"
    public static let RIGHT_DIFF_KEY = "RIGHT_DIFF"
    public static let HOUR_WIDTH_KEY = "HOUR_WIDTH"
    public static let RECORD_DIFF_KEY = "RECORD_DIFF"
    public static var rightDiff:CGFloat = 0.0
    public static var hourWidth:CGFloat = 0.0
    public static var tableWidth:CGFloat = 0.0
    
    public static let colorRed = UIColor(red: 140 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1)
    
    //チュートリアルを表示したかどうか
    public static let TUTORIAL_TITLE = "TUTORIAL_TITLE"
    //予定追加チュートリアルを表示したかどうか
    public static let TUTORIAL_ADD = "TUTORIAL_ADD"
    
    // テーマカラー保存用のキー
    static let THEMA_COLOR_KEY = "THEMA_COLOR_KEY"
    
    // カレンダー曜日色表示
    static let SAT_COLOR_KEY = "SAT_COLOR_KEY"
    static let SUN_COLOR_KEY = "SUN_COLOR_KEY"

    // テーマカラーを保存
    public static func setThemaColor(str:String) {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(str, forKey: CommonUtil.THEMA_COLOR_KEY)
        ud.synchronize()
    }
    
    // テーマカラーを取得
    public static func getThemaColor() -> String {
        let ud = NSUserDefaults.standardUserDefaults()
        let val = ud.stringForKey(CommonUtil.THEMA_COLOR_KEY)
        //print(val)
        if val != nil {
            return val!
        }else{
            // 設定がなければデフォルトの色を返す
            return String("9025020")
            //UIColor(hex:Int("9036028")!, alpha:1.0)
        }
    }
    
    // 設定してるテーマカラーの取得
    public static func getSettingThemaColor() -> UIColor {
        let defaultColor = CommonUtil.getThemaColor()
        if(defaultColor != ""){
            return UIColor(hex: Int(defaultColor)!, alpha: 1.0)
        }else{
            // 設定がなければデフォルトの色を返す
            return UIColor(hex:Int("9025020")!, alpha:1.0)
        }
    }
    
    // 言語情報を取得
    public static func getLocaleLang() -> String {
        let info = NSLocale.currentLocale().localeIdentifier  // jp_JA ja_US en_US 等
        var splitval = info.componentsSeparatedByString("_")
        return splitval[0]
    }
    
    // 言語がjaか？
    public static func isJa() -> Bool {
        return getLocaleLang() == "ja"
    }
    
    // 金額表示
    static func addFigure(config:Config, value:Float) -> String{
        
        let num = NSNumber(float:value)
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        
        let result = formatter.stringFromNumber(num)
        
        if config.currency_symbol != "None" {
            return  "\(config.currency_symbol) \(result!)"
        }else{
            return result!
        }
    }
}
