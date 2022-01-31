//
//  DateUtil.swift
//  Useless
//
//  Created by cano on 2016/02/25.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import Foundation

public class DateUtil {
    public static let weekdays   = ["","Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    public static let weekdaysjp = ["","日","月","火","水","木","金","土"]
    public static let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)! //カレンダーデータ
    static let DATE_FORMAT = "yyyy/MM/dd HH:mm:ss"
    static let DAY_START_STR = "00:00:00"
    
    // 日付の年で表される部分を整数型の値で返します
    // パラメータ
    //  date : 日付データ(NSDate型)を指定します
    //
    public static func year(date: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let comp : NSDateComponents = calendar.components(
            NSCalendarUnit.Year, fromDate: date)
        return comp.year
    }
    
    // 日付の月で表される部分を整数型の値で返します
    // パラメータ
    //  date : 日付データ(NSDate型)を指定します
    //
    public static func month(date: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let comp : NSDateComponents = calendar.components(
            NSCalendarUnit.Month, fromDate: date)
        return comp.month
    }
    
    // 日付の日で表される部分を整数型の値で返します
    // パラメータ
    //  date : 日付データ(NSDate型)を指定します
    //
    public static func day(date: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let comp : NSDateComponents = calendar.components(
            NSCalendarUnit.Day, fromDate: date)
        return comp.day
    }
    
    // 曜日を表す数値を含む整数型 の値を返します
    // パラメータ
    //  date : 日付データ(NSDate型)を指定します
    // 戻り値
    //  1 日曜日,2 月曜日,3 火曜日, ... ,7 土曜日
    //
    public static func weekday(date: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let comp : NSDateComponents = calendar.components(
            NSCalendarUnit.Weekday, fromDate: date)
        return comp.weekday
    }
    
    // 曜日の文字列を返す
    public static func weekday_str(date: NSDate) -> String {
        let weekday_i = weekday(date)
        return weekdays[weekday_i]
    }
    
    // 曜日の文字列を返す
    public static func weekday_str_jp(date: NSDate?) -> String {
        if (date == nil) {
            return "?"
        }
        let weekday_i = weekday(date!)
        return weekdaysjp[weekday_i]
    }
    // 日付の時刻で表される部分を整数型の値で返します
    // パラメータ
    //  date : 日付データ(NSDate型)を指定します
    //
    public static func hour(date: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let comp : NSDateComponents = calendar.components(
            NSCalendarUnit.Hour, fromDate: date)
        return comp.hour
    }
    
    // 日付の分で表される部分を整数型の値で返します
    // パラメータ
    //  date : 日付データ(NSDate型)を指定します
    //
    public static func minute(date: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let comp : NSDateComponents = calendar.components(
            NSCalendarUnit.Minute, fromDate: date)
        return comp.minute
    }
    
    // targetの日付が、start endの範囲ないだったらtrue
    public static func contains(start: NSDate, end: NSDate, target: NSDate) -> Bool {
        return isAscDate(start, d2: target) && isDescDate(end, d2: target)
    }
    
    // d1,d2の日付が同値かどうか
    public static func isSameDate(d1: NSDate, d2: NSDate) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        let compare = calendar.compareDate(d1, toDate: d2, toUnitGranularity: NSCalendarUnit.Minute)
        return compare == NSComparisonResult.OrderedSame
    }
    // d1,d2の日付(時間を除いて)が同値かどうか
    public static func isSameDateByDay(d1: NSDate, d2: NSDate) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        let compare = calendar.compareDate(d1, toDate: d2, toUnitGranularity: NSCalendarUnit.Day)
        return compare == NSComparisonResult.OrderedSame
    }
    // d1,d2の日付が昇順かどうか
    public static func isAscDate(d1: NSDate?, d2: NSDate?) -> Bool {
        if d1 == nil || d2 == nil {
            return true
        }
        let calendar = NSCalendar.currentCalendar()
        let compare = calendar.compareDate(d1!, toDate: d2!, toUnitGranularity: NSCalendarUnit.Minute)
        return compare == NSComparisonResult.OrderedAscending
    }
    // d1,d2の日付が降順かどうか
    public static func isDescDate(d1: NSDate, d2: NSDate) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        let compare = calendar.compareDate(d1, toDate: d2, toUnitGranularity: NSCalendarUnit.Minute)
        return compare == NSComparisonResult.OrderedDescending
    }
    
    // 開始日〜終了日の日付欄に表示する文字列を取得する
    public static func getDateLabelStr(start: NSDate, end: NSDate) -> String {
        var result = ""
        let current_year: Int = DateUtil.year(NSDate())
        
        // 日本語の場合
        //if(CommonUtil.isJa()){
            if year(start) > current_year {
                result += "\(year(start))年"
            }
            result += "\(month(start))月\(day(start))日(\(weekday_str_jp(start)))"
            //0時 or 6時 - 23:59の予定は一日の予定
            if DateUtil.isDaySplitEvent(start, end: end) {
                //何もしない
            } else {
                let str = String(NSString(format: "%02d:%02d", hour(start), minute(start)))
                result += str
            }
            
            result += "〜"
            
            if year(start) != year(end) || month(start) != month(end) || day(start) != day(end) {
                if year(end) > current_year {
                    result += "\(year(end))年"
                }
                result += "\(month(end))月\(day(end))日(\(weekday_str_jp(end)))"
            }
            if hour(end) < 23 || minute(end) < 59 {
                let str = String(NSString(format: "%02d:%02d", hour(end), minute(end)))
                result += str
            } else {
                if month(start) == month(end) && day(start) == day(end) {
                    result = result.stringByReplacingOccurrencesOfString("〜", withString: "")
                }
            }
        //}
        /*
            // 日本語以外
        else{
            // Xxx. mm/dd/yyyy at hh:mm
            // 例　Mon. 12/01/2016 08:00 ~ 12:00
            result += weekday_str(start) + ". "
            result += "\(month(start))/\(day(start))"
            if year(start) > current_year {
                result += "/\(year(start))"
            }
            
            result += " " // at はつけない
            
            if hour(start) > 0 || minute(start) > 0 {
                let str = String(NSString(format: "%02d:%02d", hour(start), minute(start)))
                result += str
            }
            
            result += " - "
            
            if year(start) != year(end) || month(start) != month(end) || day(start) != day(end) {
                result += weekday_str(end) + ". "
                result += "\(month(end))/\(day(end))"
                if year(end) > current_year {
                    result += "/\(year(end))"
                }
                result += " " // at はつけない
            }
            
            if hour(end) < 23 || minute(end) < 59 {
                let str = String(NSString(format: "%02d:%02d", hour(end), minute(end)))
                result += str
            } else {
                if month(start) == month(end) && day(start) == day(end) {
                    result = result.stringByReplacingOccurrencesOfString(" - ", withString: "")
                }
            }
            
        }
        */
        return result
    }
    
    //カレンダー開始日を取得(今日の日付から取得)
    public static func getCalendarStartDate(today: NSDate) -> NSDate {
        var sdate = today
        let del = getTodayIndex(today)
        sdate = DateUtil.calendar.dateByAddingUnit(NSCalendarUnit.Day, value: -del, toDate: today, options: [])!
        return sdate
    }
    
    //今日の日付のインデクスを取得
    public static func getTodayIndex(today: NSDate) -> Int {
        var i = 0
        let weekno = DateUtil.weekday(today)
        if weekno == 1 {
            i = 6
        } else {
            i = weekno - 2
        }
        return i
    }
    
    //今日の日付の00:00:00の日付データを取得
    public static func getTodayStartDate() -> NSDate? {
        let today = NSDate()
        let current_year = DateUtil.year(today)
        let month = DateUtil.month(today)
        let day = DateUtil.day(today)
        let date_formatter: NSDateFormatter = NSDateFormatter()
        let str = String(NSString(format: "%04d/%02d/%02d", current_year, month, day))
        date_formatter.locale     = NSLocale(localeIdentifier: "ja")
        date_formatter.dateFormat = DateUtil.DATE_FORMAT
        let todays: NSDate? = date_formatter.dateFromString( str + " " + DateUtil.DAY_START_STR )
        //print("Today=\(todays)")
        return todays
    }
    
    /*
    // 指定のX座標から日付データを取得する
    public static func getDateFromX(x: CGFloat, base: NSDate, hour_width: CGFloat, date_label_width: CGFloat) -> NSDate? {
        var date = base
        let date_formatter: NSDateFormatter = NSDateFormatter()
        let minute_width = hour_width / 60
        let hourf:CGFloat = (x - date_label_width) / hour_width
        var hour:Int = Int(hourf)
        let hourx =  date_label_width + (hour_width * CGFloat(hour))
        let minutef = (x - hourx) / minute_width
        let minute: Int = Int(minutef)
        
        //24時以降の場合は翌日の日付に変換する
        if hour >= 24 {
            date = DateUtil.calendar.dateByAddingUnit(NSCalendarUnit.Day, value: 1, toDate: date, options: [])!
            hour -= 24
        }
        let year = DateUtil.year(date)
        let month = DateUtil.month(date)
        let day = DateUtil.day(date)
        
        let str = String(NSString(format: "%04d/%02d/%02d %02d:%02d:00", year, month, day, hour, minute))
        print("getDateFromX str=" + str)
        date_formatter.locale     = NSLocale(localeIdentifier: "ja")
        date_formatter.dateFormat = DateUtil.DATE_FORMAT
        date = date_formatter.dateFromString( str )!
        return date
    }
    */
    
    //対象の日付のxx:00:00の日付データを取得
    public static func getHourDate(year: Int, month: Int, day: Int, hour: Int) -> NSDate? {
        let date_formatter: NSDateFormatter = NSDateFormatter()
        let str = String(NSString(format: "%04d/%02d/%02d %02d:00:00", year, month, day, hour))
        date_formatter.locale     = NSLocale(localeIdentifier: "ja")
        date_formatter.dateFormat = DateUtil.DATE_FORMAT
        let todays: NSDate? = date_formatter.dateFromString( str )
        return todays
    }
    
    // 日区切りの予定かどうか(時間指定ではない)
    static func isDaySplitEvent(start: NSDate, end: NSDate) -> Bool {
        if ((DateUtil.hour(start) == 0 && DateUtil.minute(start) == 0) || (DateUtil.hour(start) == 6 && DateUtil.minute(start) == 0)) && (DateUtil.hour(end) == 23 || DateUtil.minute(end) == 59) {
            return true
        } else {
            return false
        }
    }
    
    //月末日の取得
    public static func getLastDay(var year:Int,var month:Int) -> Int?{
        let dateFormatter:NSDateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "yyyy/MM/dd";
        if month == 12 {
            month = 0
            year += 1
        }
        let targetDate:NSDate? = dateFormatter.dateFromString(String(format:"%04d/%02d/01",year,month+1));
        if targetDate != nil {
            //月初から一日前を計算し、月末の日付を取得
            let orgDate = NSDate(timeInterval:(24*60*60)*(-1), sinceDate: targetDate!)
            let str:String = dateFormatter.stringFromDate(orgDate)
            let arr = str.componentsSeparatedByString("/")
            return Int(arr.last!)
        }
        
        return nil;
    }
    
    // 翌月を取得
    public static func getNextMonth(var month:Int) -> Int?{
        month += 1
        if month > 12 {
            month = 1
        }
        return month
    }
    
    // 空の開始日時
    public static func getBlankDate() -> NSDate? {
        return getHourDate(1970, month: 1, day: 1, hour: 0)
    }
    
    // yy/mm/ddから日付ラベルを生成
    public static func getDatelabel(year: Int, month: Int, day: Int) -> String? {
        let date_formatter: NSDateFormatter = NSDateFormatter()
        let str = String(NSString(format: "%04d/%02d/%02d 00:00:00", year, month, day))
        
        date_formatter.locale     = NSLocale(localeIdentifier: "ja")
        date_formatter.dateFormat = DateUtil.DATE_FORMAT
        let date: NSDate? = date_formatter.dateFromString( str )
        
        var result = ""
        // 日本語の場合
        //if(CommonUtil.isJa()){
            
            result = "\(DateUtil.month(date!))月\(DateUtil.day(date!))日(\(DateUtil.weekday_str_jp(date)))"
        /*
        }else{
            result += DateUtil.weekday_str(date!) + ". "
            result += "\(DateUtil.month(date!))/\(DateUtil.day(date!))"
        }
*/
        return result
    }
    
}