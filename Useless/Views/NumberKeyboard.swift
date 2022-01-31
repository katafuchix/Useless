//
//  NumberKeyboard.swift
//  SampleKeyboard
//
//  Created by cano on 2016/04/24.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit

class NumberKeyboard: UIView {

    var RIGHT_KEY_X: CGFloat = 0.0
    let RIGHT_KEY_COLOR = UIColor(red: 210 / 255, green: 213 / 255, blue: 218 / 255, alpha: 1.0)
    let BUTTON_HEIGHT:CGFloat = 75.0
    var BUTTON_WIDTH:CGFloat = 0.0
    var RIGHT_BUTTON_WIDTH:CGFloat = 0.0
    var originy:CGFloat = 0
    static let KEYBOARD_HEIGHT: CGFloat = 200
    
    var delegate : keyboardButtonDelegate?
    
    let pData = PublicDatas.getPublicDatas()
    let realm = RealmController.getSharedRealmController()
    var config = Config()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    //描画処理
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        self.config = realm.getConfig()
        
        print("draw")
        print("width=\(self.frame.width) height=\(self.frame.height)")
        
        let h = NumberKeyboard.KEYBOARD_HEIGHT/4
        var w = self.frame.width * 0.8/3
        
        var n = 1
        //for var j=0; j<3; j++ {
        for i in 0 ..< 4 {
            
            //for var i=0; i<4; i++ {
            for j in 0 ..< 3 {
                
                if(i == 3 && j == 2){ continue }
                
                let x = w * CGFloat(j)
                let y = h * CGFloat(i)
                if(i == 3 && j == 1 ){ w = w * 2 }
                let button = UIButton(frame: CGRectMake(x,y, w, h))
                
                drawLine(CGPointMake(x, y), to:CGPointMake(x+w, y), width: 1.0)
                drawLine(CGPointMake(x, y), to:CGPointMake(x, y+h), width: 1.0)
                drawLine(CGPointMake(x, y+h), to:CGPointMake(x+w, y+h), width: 1.0)
                drawLine(CGPointMake(x+w, y), to:CGPointMake(x+w, y+h), width: 1.0)
                
                //button.titleLabel!.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 24)
                button.titleLabel!.font = UIFont(name: self.config.font, size: 24)
                button.titleLabel?.textColor = UIColor.blackColor()
                button.tag = n
                if(n == 12){
                    button.setTitle("x", forState: UIControlState.Normal)
                }
                else if(n == 10){
                    button.setTitle(".", forState: UIControlState.Normal)
                }
                else if(n == 11){
                    button.setTitle("0", forState: UIControlState.Normal)
                }
                else{
                    button.setTitle("\(n)", forState: UIControlState.Normal)
                }
                
                button.setTitleColor(UIColor.blackColor(), forState: .Normal)
                button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
                button.addTarget(self, action: #selector(NumberKeyboard.onButton(_:)), forControlEvents: .TouchUpInside)
                
                self.addSubview(button)
                n = n + 1
                
                //drawLine(CGPointMake(0, h * CGFloat(i) ), to: CGPointMake(self.frame.width, h * CGFloat(i)), width: 1.0)
                //drawLine(CGPointMake(w * CGFloat(i), 0.0 ), to: CGPointMake(w * CGFloat(i), self.frame.height), width: 1.0)
            }
        }
        
        n = n + 1
        w = self.frame.width * 0.8/3
        let _h = CGFloat(NumberKeyboard.KEYBOARD_HEIGHT/2)
        let _w = self.frame.width * 0.2
        let _x = CGFloat(w * 3)
        var _y = CGFloat(0.0)
        let rect = CGRectMake(w * 3,0, _w, _h)
        let button = UIButton(frame: CGRectInset(rect, 1.0, 1.0))
        
        drawLine(CGPointMake(_x, _y), to:CGPointMake(_x + _w, 0.0), width: 1.0)
        drawLine(CGPointMake(_x, _y), to:CGPointMake(_x, _h), width: 1.0)
        drawLine(CGPointMake(_x,_h), to:CGPointMake(_x + _w, _h), width: 1.0)
        drawLine(CGPointMake(_x + _w,0), to:CGPointMake(_x + _w, _h), width: 1.0)
        
        //button.titleLabel!.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 28)
        button.titleLabel!.font = UIFont(name: self.config.font, size: 28)
        button.titleLabel?.textColor = UIColor.blackColor()
        button.setTitle(" < ", forState: UIControlState.Normal)
        button.tag = n
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        button.addTarget(self, action: #selector(NumberKeyboard.onButton(_:)), forControlEvents: .TouchUpInside)
        button.backgroundColor = UIColor.grayColor()
        button.backgroundColor = UIColor(red: 210 / 255, green: 213 / 255, blue: 218 / 255, alpha: 1.0)
        self.addSubview(button)
        
        
        n = n + 1
        _y = _h
        let oRect = CGRectMake(_x,_y, _w, _h)
        let obutton = UIButton(frame: CGRectInset(oRect, 1.0, 1.0))
        
        drawLine(CGPointMake(_x, _y), to:CGPointMake(_x + _w, _y), width: 1.0)
        drawLine(CGPointMake(_x, _y), to:CGPointMake(_x, _y + _h), width: 1.0)
        drawLine(CGPointMake(_x,_y + _h), to:CGPointMake(_x + _w, _y + _h), width: 1.0)
        drawLine(CGPointMake(_x + _w,_y), to:CGPointMake(_x + _w, _y + _h), width: 1.0)
        
        //obutton.titleLabel!.font = UIFont(name: "AppleSDGothicNeo-Bold", size: Constants.pickerFontSize)
        obutton.titleLabel!.font = UIFont(name: self.config.font, size: Constants.pickerFontSize)
        obutton.titleLabel?.textColor = UIColor.blackColor()
        obutton.setTitle("OK", forState: UIControlState.Normal)
        obutton.tag = n
        obutton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        obutton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        obutton.addTarget(self, action: #selector(NumberKeyboard.onButton(_:)), forControlEvents: .TouchUpInside)
        obutton.backgroundColor = UIColor.grayColor()
        obutton.backgroundColor = UIColor(red: 210 / 255, green: 213 / 255, blue: 218 / 255, alpha: 1.0)
        self.addSubview(obutton)
        
    }
    
    func onButton(sender: AnyObject) {
        //let b = sender as! UIButton
        //print(b.tag)
        
        if (self.delegate?.respondsToSelector(#selector(NumberKeyboard.onButton(_:)))) != nil {
            // 実装先のメソッドを実行
            self.delegate?.onButton(sender as! UIButton)
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
}

// ボタン操作のためのデリゲート
protocol keyboardButtonDelegate : NSObjectProtocol {
    func onButton(sender:UIButton)
}
