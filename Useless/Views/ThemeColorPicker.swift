//
//  ThemeColorPicker.swift
//
//  Created by PxP_ss on 2014/11/05.
//  Copyright (c) 2014年 pxp_ss. All rights reserved.
//

import UIKit

protocol ThemeColorPickerDelegate {
    func themeColorPicker(picker: ThemeColorPicker, themeColor: UIColor)
}

class ThemeColorPicker: UIView {
    
    //var delegate: AddUserViewController! = nil
    
    var colors     = NSMutableArray()
    var themeColor = UIColor()
    var selected   = UIButton()
    
    /**
     * setThemeColor
     * param: color
     */
    /*
    func setThemeColor(color: UIColor!) {
        self.themeColor = color
    }
    */
    /**
     * getThemeColor
     * returns: self.themeColor
     */
    func getThemeColor() -> UIColor {
        return self.themeColor
    }
    
    /**
     * HSVtoHexString
     * HSV形式のUIColorをHEX形式のStringにして返す
     * param  : color hsv形式のUIColor
     * returns: hex hex形式のカラーコード(ex.#81F7D8)
     */
    func HSVtoHexString(color: UIColor) -> NSString {
        let components = CGColorGetComponents(color.CGColor)
        let r = NSString(format:"%02X", NSInteger(components[0] * 255))
        let g = NSString(format:"%02X", NSInteger(components[1] * 255))
        let b = NSString(format:"%02X", NSInteger(components[2] * 255))
        
        return "\(r)\(g)\(b)"
    }
    
    /**
     * init
     * protocolで宣言したイニシャライザinitを利用するために、修飾子requiredが必要
     * param  : aDecoder
     */
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     * init
     * param: frame ビューのサイズを決定する
     */
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
    }
    
    /**
     * drawRect
     * Pickerに必要なContentを描画
     * param: rect
     */
    override func drawRect(rect: CGRect) {
        for i in 0...8 {
            var pixelY = CGFloat(i) / 9
            for j in 0...20 {
                var pixelX = CGFloat(j) / 19
                
                let color = self.createHSVColor(pixelX, y: pixelY) // 色を決定
                colors.addObject(color)
                
                // 作成した色に基づくボタンの作成
                var editBtn = UIButton()
                editBtn.backgroundColor = color
                editBtn.frame           = CGRectMake(0, 0, 40, 40)
                editBtn.center          = CGPointMake(self.center.x + CGFloat((j - 10) * 45), CGFloat(i * 45) + 100)
                editBtn.tag             = i * 20 + j
                
                editBtn.addTarget(self, action: "selectThemeColor:", forControlEvents: .TouchUpInside)
                
                self.addSubview(editBtn)
                self.bringSubviewToFront(editBtn)
            }
        }
        
        // 決定ボタンの作成
        var btn = UIButton()
        btn.frame  = CGRectMake(0, 0, 220, 60)
        btn.center = CGPointMake(self.center.x, 200)
        
        btn.setBackgroundImage(UIImage(named: "titleframe_big_b.png"), forState: .Normal)
        btn.setTitle("SetColor_決定", forState: .Normal)
        btn.addTarget(self, action: "decideThemeColor:", forControlEvents: .TouchUpInside)
        
        self.addSubview(btn)
    }
    
    /**
     * createHSVColor
     * x, y座標を用いて、HSV形式のUIColorを作成する
     * param  : x
     * param  : y
     
     * returns: HSV形式のUIColor
     */
    func createHSVColor(x: CGFloat, y: CGFloat) -> UIColor {
        let hue        :CGFloat = x
        let saturation :CGFloat = 1.0 - y * 0.95
        let brightness :CGFloat = 1.0
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
    
    /**
     * selectThemeColor
     * 作成した色に基づくボタンを押した時のイベント
     * param: sender drawRect内におけるeditBtn
     */
    func selectThemeColor(sender: UIButton) {
        var color = colors[sender.tag] as! UIColor
        //self.setThemeColor(color)
        
        selected.layer.borderWidth = 0
        selected = sender as UIButton
        
        sender.layer.borderColor = UIColor.whiteColor().CGColor
        sender.layer.borderWidth = 3.0
    }
    
    /**
     * decideThemeColor
     * 決定ボタンを押した際の処理
     * param: sender 決定ボタン
     */
    func decideThemeColor(sender: UIButton) {
        var color = getThemeColor() as UIColor
        //self.delegate.themeColorPicker(self, themeColor: color)
    }
}