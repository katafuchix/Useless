//
//  Holiday.swift
//  Useless
//
//  Created by cano on 2016/05/21.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit

class Holiday {
    
    enum WeekDay: Int {
        case Sunday = 1, Monday = 2, Tuesday = 3, Wednesday = 4, Thursday = 5, Friday = 6, Saturday = 7
    }
    
    class func isDayOfWeek(weekNumber: Int, weekDay: WeekDay) -> Bool {
        if weekNumber == weekDay.rawValue {
            return true
        } else {
            return false
        }
    }
    
    class func getHolidayNameForDate(date: NSDate) -> String? {
        
        let result = holidayNameForDate(date)
        
        if result != nil {
            return result
        } else {
            let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
            let myWeek = calendar.component(.Weekday, fromDate: date)
            if isDayOfWeek(myWeek, weekDay: .Monday) {
                let yesterday = calendar.dateByAddingUnit(.Day, value: -1, toDate: date, options: [])!
                if let _ = holidayNameForDate(yesterday) {
                    return "振替休日"
                }
            }
        }
        return nil
    }
    
    class private func holidayNameForDate(date: NSDate) -> String? {
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        let myYear = calendar.component(.Year, fromDate: date)
        let myMonth = calendar.component(.Month, fromDate: date)
        let myDay = calendar.component(.Day, fromDate: date)
        let myWeek = calendar.component(.Weekday, fromDate: date)
        var result: String?
        
        switch myMonth {
        case 1:
            if myDay == 1 {
                result = "元旦"
            } else {
                if myYear >= 2000 {
                    let numberOfWeek = ((myDay - 1) / 7) + 1
                    if numberOfWeek == 2 && isDayOfWeek(myWeek, weekDay: .Monday) { // 2週目の月曜日
                        result = "成人の日"
                    }
                } else {
                    if myDay == 15 {
                        result = "成人の日"
                    }
                }
            }
        case 2:
            if myDay == 11 {
                if myYear >= 1967 {
                    result = "建国記念の日"
                }
            }
        case 3:
            if myDay == dayOfSpringEqinox(myYear) {
                result = "春分の日"
            }
        case 4:
            if myDay == 29 {
                if myYear >= 1989 {
                    result = "みどりの日"
                } else {
                    result = "天皇誕生日"
                }
            }
        case 5:
            if myDay == 3 {
                result = "憲法記念日"
            } else if myDay == 4 {
                if (!isDayOfWeek(myWeek, weekDay: .Sunday)) && (!isDayOfWeek(myWeek, weekDay: .Monday)) {
                    if myYear >= 1986 {
                        result = "国民の休日"
                    }
                }
            } else if myDay == 5 {
                result = "子供の日"
            }
        case 6:
            break
        case 7:
            if myYear >= 2003 {
                let numberOfWeek = ((myDay - 1) / 7) + 1
                if numberOfWeek == 3 && isDayOfWeek(myWeek, weekDay: .Monday) {
                    result = "海の日"
                }
            } else if myYear >= 1996 && myDay == 20 {
                result = "海の日"
            }
        case 8:
            if myYear >= 2016 && myDay == 11 {
                result = "山の日"
            }
        case 9:
            let autumnEquinox = dayOfAutumnEquinox(myYear)
            if myDay == autumnEquinox {
                result = "秋分の日"
            } else {
                if myYear >= 2003 {
                    let numberOfWeek = ((myDay - 1) / 7) + 1
                    if numberOfWeek == 3 && isDayOfWeek(myWeek, weekDay: .Monday) {
                        result = "敬老の日"
                    } else {
                        if isDayOfWeek(myWeek, weekDay: .Tuesday) {
                            if myDay == (autumnEquinox - 1) {
                                result = "国民の休日"
                            }
                        }
                    }
                } else if myYear >= 1966 {
                    if myDay == 15 {
                        result = "敬老の日"
                    }
                }
            }
        case 10:
            if myYear >= 2000 {
                let numberOfWeek = ((myDay - 1) / 7) + 1
                if numberOfWeek == 2 && isDayOfWeek(myWeek, weekDay: .Monday) {
                    result = "体育の日"
                }
            } else if myYear >= 1966 {
                if myDay == 10 {
                    result = "体育の日"
                }
            }
        case 11:
            if myDay == 3 {
                result = "文化の日"
            } else if myDay == 23 {
                result = "勤労感謝の日"
            }
        case 12:
            if myDay == 23 {
                if myYear >= 1989 {
                    result = "天皇誕生日"
                }
            }
        default:
            break
        }
        return result
    }
    
    class private func dayOfSpringEqinox(year: Int) -> Int {
        var springEquinox = 0
        if year <= 1947 {
            springEquinox = 99
        } else if year <= 1979 {
            springEquinox = Int(20.8357 + (0.242194 * Double(year - 1980))) - ((year - 1983) / 4)
        } else if year <= 2099 {
            springEquinox = Int(20.8431 + (0.242194 * Double(year - 1980))) - ((year - 1980) / 4)
        } else if year <= 2150 {
            springEquinox = Int(21.851 + (0.242194 * Double(year - 1980))) - ((year - 1980) / 4)
        } else {
            springEquinox = 99
        }
        return springEquinox
    }
    
    class private func dayOfAutumnEquinox(year: Int) -> Int {
        var autumnEquinox = 0
        if year <= 1947 {
            autumnEquinox = 99
        } else if year <= 1979 {
            autumnEquinox = Int(23.2588 + (0.242194 * Double(year - 1980))) - ((year - 1983) / 4)
        } else if year <= 2099 {
            autumnEquinox = Int(23.2488 + (0.242194 * Double(year - 1980))) - ((year - 1980) / 4)
        } else if year <= 2150 {
            autumnEquinox = Int(24.2488 + (0.242194 * Double(year - 1980))) - ((year - 1980) / 4)
        } else {
            autumnEquinox = 99
        }
        return autumnEquinox
    }
}