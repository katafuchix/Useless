//
//  TopTableViewCell.swift
//  Useless
//
//  Created by cano on 2016/02/25.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit

class TopTableViewCell: UITableViewCell {
    
    var date:NSDate?
    var config : Config?
    
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var weekdayLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    //セルの描画処理
    override func drawRect(rect: CGRect) {
        //weekdayLabel.backgroundColor = UIColor.clearColor()
        //weekdayLabel.frame = CGRectMake(80, 10, 100, 20)
        
        drawWhiteBackground(rect)
        
        self.dayLabel?.font = UIFont(name: self.config!.font, size: 17)
        
        let dateFormatter = NSDateFormatter()
        //dateFormatter.locale = NSLocale(localeIdentifier: "ja") // ロケールの設定
        dateFormatter.locale     = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        //dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        dateFormatter.dateFormat = self.config!.dateformat //"MM/dd"
        self.dayLabel?.text = dateFormatter.stringFromDate(self.date!)
        self.dayLabel?.backgroundColor = UIColor.clearColor()
        
        // 曜日
        switch(self.config!.weekday_lang){
        case "en":
            self.weekdayLabel.text = " \(DateUtil.weekday_str(self.date!))"
        case "jp":
            self.weekdayLabel.text = " (\(DateUtil.weekday_str_jp(self.date!)))"
        default:
            self.weekdayLabel.text = ""
        }
        
        weekdayLabel.font = UIFont(name: self.config!.font, size: 12)
        
        if(DateUtil.weekday(date!) == 1 ){
            dayLabel.textColor = UIColor.redColor()
            weekdayLabel.textColor = UIColor.redColor()
        }
        else if(DateUtil.weekday(date!) == 7 ){
            dayLabel.textColor = UIColor.blueColor()
            weekdayLabel.textColor = UIColor.blueColor()
        }
        else {
            dayLabel.textColor = UIColor.blackColor()
            weekdayLabel.textColor = UIColor.blackColor()
        }
        
        if self.config?.lang == "jp" {
            if let holidayName = Holiday.getHolidayNameForDate(self.date!)
            {
                print(holidayName)          // 山の日
                dayLabel.textColor = UIColor.redColor()
                weekdayLabel.textColor = UIColor.redColor()
            }
        }
        
        let sList = RealmController.getSharedRealmController().getSpendsFromDate(self.date!)
        //print(sList)
        var total:Float = 0.0
        for s in sList {
            total = total + s.price
        }
        
        self.priceLabel.font = UIFont(name: self.config!.font, size: 15)
        self.priceLabel.text = "\(CommonUtil.addFigure(self.config!, value: total))"
        
        drawLine(CGPointMake(0, self.frame.height), to:CGPointMake(self.frame.width, self.frame.height), width: 0.5)
    }
}
