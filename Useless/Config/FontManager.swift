//
//  FontManager.swift
//  Useless
//
//  Created by cano on 2016/05/10.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit

class FontManager {

    var font_names_jp   = [String]()
    var font_names      = [String]()
    var font_values     = [String]()
    
    
    // 初期化処理
    internal init(){
        font_names_jp   = [String]()
        font_names      = [String]()
        font_values     = [String]()
        
        //let digits = NSCharacterSet.decimalDigitCharacterSet()
        
        // sample.txtファイルを読み込み
        let path = NSBundle.mainBundle().pathForResource("font", ofType: "txt")!
        if let data = NSData(contentsOfFile: path){
            let str = String(NSString(data: data, encoding: NSUTF8StringEncoding)!)
            
            // 改行で分割
            var valArray = str.componentsSeparatedByString("\n")
            //print(valArray[0])
            
            // 全体を回す
            for i in 0 ..< valArray.count {
                // ヘッダはスルー
                if i == 0 { continue }
                
                // , で各値に分割
                var vals = valArray[i].componentsSeparatedByString(",")
                font_names_jp.append(vals[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
                font_names.append(vals[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
                font_values.append(vals[2].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
            }
        }
    }
}
