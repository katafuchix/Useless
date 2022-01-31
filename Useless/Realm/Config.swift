//
//  Config.swift
//  Useless
//
//  Created by cano on 2016/04/29.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import RealmSwift

class Config: Object {
    dynamic var id: Int64 = 0
    
    // 日付フォーマット
    dynamic var dateformat: String = ""
    
    // 言語
    dynamic var lang: String = ""
    
    // 曜日表示
    dynamic var weekday_lang: String = ""
    
    // トップ金額表示
    dynamic var top_price: String = ""
    
    // グラフフォントサイズ
    dynamic var graph_font_size: Int64 = 0
    
    // 円フォントサイズ
    dynamic var center_font_size: Int64 = 0

    // 円フォントサイズ
    dynamic var center_dateformat: String = ""
    
    // 通貨単位
    dynamic var currency_unit: String = ""
    
    // font
    dynamic var font: String = ""
    
    // title font size
    dynamic var title_font_size: Int64 = 0
    
    // 通貨記号
    dynamic var currency_symbol: String = ""
    
    // csv出力文字コード
    dynamic var character_encoding : String = ""
    
    // image size
    dynamic var image_size : String = ""
    
    // animation
    dynamic var animation : String = ""
}
