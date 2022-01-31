//
//  UIColorExtension.swift
//  FreeNow
//
//  Created by cano on 2016/02/27.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import Foundation

import UIKit

extension UIColor {
    
    class func hexStr (var hexStr : NSString, alpha : CGFloat) -> UIColor {
        hexStr = hexStr.stringByReplacingOccurrencesOfString("#", withString: "")
        let scanner = NSScanner(string: hexStr as String)
        var color: UInt32 = 0
        if scanner.scanHexInt(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r,green:g,blue:b,alpha:alpha)
        } else {
            print("invalid hex string")
            return UIColor.whiteColor();
        }
    }
    /*
    public convenience init(hex: Int, alpha: CGFloat) {
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(hex & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    */
    /*
    convenience init(hexString str: String, alpha: CGFloat) {
        let range = NSMakeRange(0, countElements(str))
        let hex = (str as NSString).stringByReplacingOccurrencesOfString("[^0-9a-fA-F]", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: range)
        var color: UInt32 = 0
        NSScanner(string: hex).scanHexInt(&color)
        self.init(hex: Int(color), alpha: alpha)
    }
*/
    var hexString: String? {
        return self.CGColor.hexString
    }
    var RGBa: (red: Int, green: Int, blue: Int, alpha: CGFloat)? {
        return self.CGColor.RGBa
    }
    
    public static func toInt32(color: UIColor) -> Int32 {
        let rgba = color.RGBa
        let colori: UInt32 = UInt32(rgba!.red * 0x10000) + UInt32(rgba!.green * 0x100) + UInt32(rgba!.blue)
        return Int32(colori)
    }
    
    public convenience init(str: String, alpha: CGFloat) {
        let s = str.componentsSeparatedByString(",")
        let r: CGFloat = CGFloat(float_t(s[0])! / 255)
        let g: CGFloat = CGFloat(float_t(s[1])! / 255)
        let b: CGFloat = CGFloat(float_t(s[2])! / 255)
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

extension CGColor {
    var hexString: String? {
        if let x = self.RGBa {
            let hex = x.red * 0x10000 + x.green * 0x100 + x.blue
            return NSString(format:"%06x", hex) as String
        } else {
            return nil
        }
    }
    var RGBa: (red: Int, green: Int, blue: Int, alpha: CGFloat)? {
        let colorSpace = CGColorGetColorSpace(self)
        let colorSpaceModel = CGColorSpaceGetModel(colorSpace)
        if colorSpaceModel.rawValue == 1 {
            let x = CGColorGetComponents(self)
            let r: Int = Int(x[0] * 255.0)
            let g: Int = Int(x[1] * 255.0)
            let b: Int = Int(x[2] * 255.0)
            let a: CGFloat = x[3]
            return (r, g, b, a)
        } else {
            return nil
        }
    }
}