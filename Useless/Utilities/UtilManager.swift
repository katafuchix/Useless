//
//  UtilManager.swift
//  Useless
//
//  Created by cano on 2016/02/28.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit
import RAMAnimatedTabBarController
import Device

public class UtilManager {
    
    public static func getLangs(lang:String)->Dictionary<String, String> {
        var dic = Dictionary<String, String>()
        let path = NSBundle.mainBundle().pathForResource(lang, ofType: "txt")!
        if let data = NSData(contentsOfFile: path){
            let str = String(NSString(data: data, encoding: NSUTF8StringEncoding)!)
            //print(str)
            
            // 改行で分割
            let valArray = str.componentsSeparatedByString("\n")
            for i in 0 ..< valArray.count {
                let vals = valArray[i].componentsSeparatedByString("=")
                if vals.count < 2 { continue }
                dic[vals[0]] = vals[1]
            }
        }
        return dic
    }
    
    // UIViewからUIImageを生成
    public static func getUIImageFromUIView(myUIView:UIView) ->UIImage
    {
        UIGraphicsBeginImageContextWithOptions(myUIView.frame.size, true, 0);//必要なサイズ確保
        let context:CGContextRef = UIGraphicsGetCurrentContext()!;
        CGContextTranslateCTM(context, -myUIView.frame.origin.x, -myUIView.frame.origin.y);
        myUIView.layer.renderInContext(context);
        let renderedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return renderedImage;
    }
    /**
     
     対象のViewを指定したrectで切り取りUIImageとして取得する
     
     - parameter view:切り取り対象のview
     - parameter rect:切り取る座標と大きさ
     - returns: 切り取り結果を返す
     */
    static func clipView(view: UIView?, rect: CGRect?) -> UIImage? {
        
        guard let targetView = view else {
            return nil
        }
        
        guard let frameRect = rect else {
            return nil
        }
        
        // ビットマップ画像のcontextを作成.
        UIGraphicsBeginImageContextWithOptions(frameRect.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        
        //Affine変換
        let affineMoveLeftTop = CGAffineTransformMakeTranslation(-frameRect.origin.x, -frameRect.origin.y)
        CGContextConcatCTM(context, affineMoveLeftTop)
        
        // 対象のview内の描画をcontextに複写する.
        targetView.layer.renderInContext(context)
        
        // 現在のcontextのビットマップをUIImageとして取得.
        let clippedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // contextを閉じる.
        UIGraphicsEndImageContext()
        
        return clippedImage
    }
    
    // 画面遷移をせずにテーマカラーを即時反映
    static func setNaviThemaColor(){
        
        let tc = UIApplication.sharedApplication().keyWindow?.rootViewController;
        // UINavigationBarのテーマ色を変更
        if ((tc?.isKindOfClass(RAMAnimatedTabBarController)) != nil) {
            let rc = tc as! RAMAnimatedTabBarController
            for vc in rc.viewControllers! {
                if (vc.isKindOfClass(UINavigationController)) {
                    let nc = vc as! UINavigationController
                    nc.navigationBar.barTintColor = CommonUtil.getSettingThemaColor()
                }
            }
            
            rc.tabBar.tintColor = CommonUtil.getSettingThemaColor()
            let items = rc.tabBar.items as? [RAMAnimatedTabBarItem]
            //print(items)
            for item in items! {
                //print(item)
                item.animation.textSelectedColor = CommonUtil.getSettingThemaColor()
                item.animation.iconSelectedColor = CommonUtil.getSettingThemaColor()
            }
        }
        AppDelegate.setTabBarColor()
    }
    
    // 画像のリサイズ
    static func getResizeImage(image:UIImage, size:String) -> UIImage {
        let resize = UtilManager.getImageSize(image.size, size: size)
        
        UIGraphicsBeginImageContext(resize)
        image.drawInRect(CGRectMake(0, 0, resize.width, resize.height))
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizeImage
    }
    
    // 画像保存サイズ
    static func getImageSize(s:CGSize, size:String)->CGSize{
        var resize = CGSizeZero
        
        switch size {
        case "L":
            resize = CGSize(width: s.width*0.9*2, height: s.height*0.9*2)
        case "M":
            resize = CGSize(width: s.width*0.7*2, height: s.height*0.7*2)
        case "S":
            resize = CGSize(width: s.width*0.5*2, height: s.height*0.5*2)
        default:
            resize = s
        }
        
        return resize
    }
    
    // 現在日時
    static func getNowDateTime() -> String {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        formatter.dateFormat = "YYYYMMDDHHmmss"
        return formatter.stringFromDate(NSDate())
    }
    
    static func isFloatData(val:Float) -> Bool{
        let str = "\(val)"
        let idx = str.startIndex.advancedBy(str.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)-2)
        if str.substringFromIndex(idx) == ".0" {
            return false
        }else{
            return true
        }
    }
    
    static func getPopUpWidth() ->CGFloat {
        
        if Device.size() == Size.Screen5_5Inch {
            return Constants.popUpWidth + 40.0
        }
        if Device.size() == Size.Screen4_7Inch {
            return Constants.popUpWidth + 20.0
        }
        return Constants.popUpWidth
    }
}
