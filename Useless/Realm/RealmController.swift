//
//  RealmController.swift
//
//
//  Created by cano on 2016/01/22.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import RealmSwift


public class RealmController {
    var realm: Realm?
    
    private static var realmController: RealmController? = nil
    private static let SCHEMA_VERSION: UInt64 = 3
    
    public static func getSharedRealmController() -> RealmController {
        if realmController == nil {
            realmController = RealmController()
        }
        return realmController!
    }
    
    //コンストラクタ
    init () {
        setDefaultRealmConfig()
        
        //Realmインスタンス初期化
        do {
            realm = try Realm()
        } catch let error as NSError {
            // handle error
            print("Realm init error" + error.description)
        }
    }
    
    func setDefaultRealmConfig() {
        var config = Realm.Configuration()
        config.schemaVersion = RealmController.SCHEMA_VERSION
        Realm.Configuration.defaultConfiguration = config
    }
    

    //DBマイグレーション処理  タイミング次第では使えないので値を代入する場合は別途実装
    public static func migration() {
        print("------ migration ------")
        //Realmのマイグレーションの処理
        let config = Realm.Configuration(
            // 新しいスキーマバージョンを設定します。以前のバージョンより大きくなければなりません。
            // （スキーマバージョンを設定したことがなければ、最初は0が設定されています）
            schemaVersion: RealmController.SCHEMA_VERSION,
            
            // マイグレーション処理を記述します。古いスキーマバージョンのRealmを開こうとすると
            // 自動的にマイグレーションが実行されます。
            migrationBlock: { migration, oldSchemaVersion in
                print("------ migrationBlock oldSchemaVersion=\(oldSchemaVersion)  ------")
                // 最初のマイグレーションの場合、`oldSchemaVersion`は0です
                if (oldSchemaVersion < 1) {
                    // enumerate(_:_:)メソッドで保存されているすべてオブジェクトを列挙します
                    migration.enumerate(Config.className()) { oldObject, newObject in
                        newObject!["character_encoding"]? = "UTF-8"
                    }
                }
                if (oldSchemaVersion < 2) {
                    migration.enumerate(Config.className()) { oldObject, newObject in
                        newObject!["image_size"]? = "M"
                    }
                }
                if (oldSchemaVersion < 3) {
                    migration.enumerate(Config.className()) { oldObject, newObject in
                        newObject!["animation"]? = "on"
                    }
                }
        })
        
        // デフォルトRealmに新しい設定を適用します
        Realm.Configuration.defaultConfiguration = config
        // Realmファイルを開こうとしたときスキーマバージョンが異なれば、
        // 自動的にマイグレーションが実行されます
        //try! Realm()
        // try! Realm(configuration:config)
        
        do {
            _ = try Realm()
        } catch let error as NSError {
            // print error
            print("Realm migration error" + error.description)
        }

    }
    
    public func addGenre(id: Int64, name: String, color: String, order:Int64, memo: String) -> Genre {
        // Titleオブジェクトを作成する
        let g = Genre()
        g.id = id
        g.name = name
        g.color = color
        g.order = order
        g.memo = memo
        
        // トランザクションを開始して、オブジェクトをRealmに追加する
        do {
            try self.realm!.write {
                self.realm!.add(g)
            }
            print("Realm add Title complete. id=\(g.id) name=\(g.name) color=\(g.color)")
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
        
        return g
    }
    
    public func updateGenreNameColor(id: Int64, name: String, color: String) {
        let genres = self.realm!.objects(Genre).filter("id = \(id)")
        
        // トランザクションを開始して、オブジェクトを更新する
        do{
            try self.realm!.write {
                genres[0].name = name
                genres[0].color = color
            }
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
    }
    
    //イベントの取得
    public func getGenre(id: Int64) -> Genre? {
        let gs = self.realm!.objects(Genre).filter("id = \(id)")
        if gs.count > 0 {
            return gs[0]
        } else {
            return nil
        }
    }
    
    // ジャンルリストを取得する
    public func getListGenre() -> Results<Genre> {
        let genreList = self.realm!.objects(Genre).filter("id > 0").sorted("order",ascending:true)
        return genreList
    }
    
    // ジャンルを追加する
    public func addGenre(name: String, color: String, memo: String) -> Genre {
        let id: Int64 = getNextGenreId()
        return addGenre(id, name: name, color: color, order:id, memo:memo)
    }
    
    // ジャンルを削除する
    public func deleteGenre(id: Int64) {
        let titles = self.realm!.objects(Genre).filter("id = \(id)")
        // トランザクションを開始してオブジェクトを削除します
        try! self.realm!.write {
            self.realm!.delete(titles)
        }
    }
    
    // 内訳を追加する
    public func addSpend(date: NSDate, genre: Genre, price: Float) -> Spend {
        let id: Int64 = getNextSpendId()
        return addSpend(id, date: date, genre: genre, price: price)
    }
    
    public func addSpend(id: Int64, date: NSDate, genre: Genre, price: Float) -> Spend {
        // Spendオブジェクトを作成する
        let s = Spend()
        s.id = id
        s.date = date
        s.genre = genre
        s.price = price
        
        // トランザクションを開始して、オブジェクトをRealmに追加する
        do {
            try self.realm!.write {
                self.realm!.add(s)
            }
            print("Realm add Title complete. id=\(s.id) genre=\(s.genre) price=\(s.price)")
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
        
        return s
    }
    
    // 更新
    public func updateAddSpend(date: NSDate, genre: Genre, price: Float) -> Spend {
        
        let year = DateUtil.year(date)
        let month = DateUtil.month(date)
        let day = DateUtil.day(date)
        let date_formatter: NSDateFormatter = NSDateFormatter()
        //date_formatter.locale     = NSLocale(localeIdentifier: "ja")
        date_formatter.locale     = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        date_formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let startstr = String(format: "%04d-%02d-%02d 00:00:00", year,month,day)
        let start: NSDate? = date_formatter.dateFromString(startstr)
        let endstr = String(format: "%04d-%02d-%02d 23:59:59", year,month,day)
        
        //ここでは対象日に関するものだけ取得する
        let end: NSDate? = date_formatter.dateFromString(endstr)
        
        // SQL
        let format = "(date >= %@ and date <= %@) AND genre.id = %d " //対象日内の予定
        let predicate = NSPredicate(format: format,
                                    start!, end!, genre.id
        )
        let spends = self.realm!.objects(Spend).filter(predicate)
        //print(spends)
        // トランザクションを開始して、オブジェクトを更新する
        do{
            try self.realm!.write {
                spends[0].price = spends[0].price + price
            }
            return spends[0]
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
        return Spend()
    }
    
    // 更新
    public func updateSpend(date: NSDate, genre: Genre, price: Float) -> Spend {
        
        let year = DateUtil.year(date)
        let month = DateUtil.month(date)
        let day = DateUtil.day(date)
        let date_formatter: NSDateFormatter = NSDateFormatter()
        //date_formatter.locale     = NSLocale(localeIdentifier: "ja")
        date_formatter.locale     = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        date_formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let startstr = String(format: "%04d-%02d-%02d 00:00:00", year,month,day)
        let start: NSDate? = date_formatter.dateFromString(startstr)
        let endstr = String(format: "%04d-%02d-%02d 23:59:59", year,month,day)
        
        //ここでは対象日に関するものだけ取得する
        let end: NSDate? = date_formatter.dateFromString(endstr)
        
        // SQL
        let format = "(date >= %@ and date <= %@) AND genre.id = %d " //対象日内の予定
        let predicate = NSPredicate(format: format,
                                    start!, end!, genre.id
        )
        let spends = self.realm!.objects(Spend).filter(predicate)
        //print(spends)
        // トランザクションを開始して、オブジェクトを更新する
        do{
            try self.realm!.write {
                spends[0].price = price
            }
            return spends[0]
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
        return Spend()
    }
    
    // 更新
    public func deleteSpend(date: NSDate, genre: Genre) -> Spend {
        
        let year = DateUtil.year(date)
        let month = DateUtil.month(date)
        let day = DateUtil.day(date)
        let date_formatter: NSDateFormatter = NSDateFormatter()
        //date_formatter.locale     = NSLocale(localeIdentifier: "ja")
        date_formatter.locale     = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        date_formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let startstr = String(format: "%04d-%02d-%02d 00:00:00", year,month,day)
        let start: NSDate? = date_formatter.dateFromString(startstr)
        let endstr = String(format: "%04d-%02d-%02d 23:59:59", year,month,day)
        
        //ここでは対象日に関するものだけ取得する
        let end: NSDate? = date_formatter.dateFromString(endstr)
        
        // SQL
        let format = "(date >= %@ and date <= %@) AND genre.id = %d " //対象日内の予定
        let predicate = NSPredicate(format: format,
                                    start!, end!, genre.id
        )
        let spends = self.realm!.objects(Spend).filter(predicate)
        //print(spends)
        // トランザクションを開始して、オブジェクトを更新する
        do{
            try self.realm!.write {
                self.realm!.delete(spends)
            }
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
        return Spend()
    }
    
    // 対象日に合致する内訳を返す
    public func getSpendsFromDate(date: NSDate) -> Results<Spend> {
        let year = DateUtil.year(date)
        let month = DateUtil.month(date)
        let day = DateUtil.day(date)
        let date_formatter: NSDateFormatter = NSDateFormatter()
        //date_formatter.locale     = NSLocale(localeIdentifier: "ja")
        date_formatter.locale     = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        date_formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let startstr = String(format: "%04d-%02d-%02d 00:00:00", year,month,day)
        let start: NSDate? = date_formatter.dateFromString(startstr)
        let endstr = String(format: "%04d-%02d-%02d 23:59:59", year,month,day)
        
        //ここでは対象日に関するものだけ取得する
        let end: NSDate? = date_formatter.dateFromString(endstr)
        
        // SQL
        let format = " genre != nil AND "
            + "(date >= %@ and date <= %@) " //対象日内の予定
        let predicate = NSPredicate(format: format,
                                    start!, end!
        )
        //print("predicate : \(predicate)")
        let sortProperties = [SortDescriptor(property: "price", ascending: false)]
        let spends = self.realm!.objects(Spend).filter(predicate).sorted(sortProperties)
        return spends
    }
    
    // 対象日に合致する内訳を返す
    public func getSpendsFromDate(start: NSDate, end:NSDate) -> Results<Spend> {
        let syear = DateUtil.year(start)
        let smonth = DateUtil.month(start)
        let sday = DateUtil.day(start)
        let eyear = DateUtil.year(end)
        let emonth = DateUtil.month(end)
        let eday = DateUtil.day(end)
        
        let date_formatter: NSDateFormatter = NSDateFormatter()
        //date_formatter.locale     = NSLocale(localeIdentifier: "ja")
        date_formatter.locale     = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        date_formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let startstr = String(format: "%04d-%02d-%02d 00:00:00", syear,smonth,sday)
        let startVal: NSDate? = date_formatter.dateFromString(startstr)
        let endstr = String(format: "%04d-%02d-%02d 23:59:59", eyear,emonth,eday)
        
        //ここでは対象日に関するものだけ取得する
        let endVal: NSDate? = date_formatter.dateFromString(endstr)
        
        print("\(startVal) - \(endVal)")
        // SQL
        let format = " genre != nil AND "
            + "(date >= %@ and date <= %@) " //対象日内の予定
        let predicate = NSPredicate(format: format,
                                    startVal!, endVal!
        )
        //print("predicate : \(predicate)")
        let sortProperties = [SortDescriptor(property: "price", ascending: false)]
        let spends = self.realm!.objects(Spend).filter(predicate).sorted(sortProperties)
        return spends
    }
    
    // 対象日に合致する内訳を返す
    public func getSpendsFromDate(start: NSDate, end:NSDate, genre:Genre) -> Results<Spend> {
        let syear = DateUtil.year(start)
        let smonth = DateUtil.month(start)
        let sday = DateUtil.day(start)
        let eyear = DateUtil.year(end)
        let emonth = DateUtil.month(end)
        let eday = DateUtil.day(end)
        
        let date_formatter: NSDateFormatter = NSDateFormatter()
        //date_formatter.locale     = NSLocale(localeIdentifier: "ja")
        date_formatter.locale     = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        date_formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let startstr = String(format: "%04d-%02d-%02d 00:00:00", syear,smonth,sday)
        let startVal: NSDate? = date_formatter.dateFromString(startstr)
        let endstr = String(format: "%04d-%02d-%02d 23:59:59", eyear,emonth,eday)
        
        //ここでは対象日に関するものだけ取得する
        let endVal: NSDate? = date_formatter.dateFromString(endstr)
        
        print("\(startVal) - \(endVal)")
        // SQL
        let format = "  date >= %@ and date <= %@  AND genre.id = %d" //対象日内
        let predicate = NSPredicate(format: format,
                                    startVal!, endVal!, genre.id)
        
        //print("predicate : \(predicate)")
        let sortProperties = [SortDescriptor(property: "date", ascending: true)]
        let spends = self.realm!.objects(Spend).filter(predicate).sorted(sortProperties)
        return spends
    }
    
    // 対象日に合致する内訳を返す
    public func getSpendsFromDate(date: NSDate, genre:Genre) -> Results<Spend> {
        let year = DateUtil.year(date)
        let month = DateUtil.month(date)
        let day = DateUtil.day(date)
        let date_formatter: NSDateFormatter = NSDateFormatter()
        //date_formatter.locale     = NSLocale(localeIdentifier: "ja")
        date_formatter.locale     = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        date_formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let startstr = String(format: "%04d-%02d-%02d 00:00:00", year,month,day)
        let start: NSDate? = date_formatter.dateFromString(startstr)
        let endstr = String(format: "%04d-%02d-%02d 23:59:59", year,month,day)
        
        //ここでは対象日に関するものだけ取得する
        let end: NSDate? = date_formatter.dateFromString(endstr)
        
        /*
        // SQL
        let format = " genre.id = %d AND date >= %@ and date <= %@  " //対象日内
        let predicate = NSPredicate(format: format, genre.id, 
                                    start!, end!
        )*/
        let format = "  date >= %@ and date <= %@  AND genre.id = %d" //対象日内
        let predicate = NSPredicate(format: format,
                                    start!, end!, genre.id
        )
        //print("predicate : \(predicate)")
        let sortProperties = [SortDescriptor(property: "price", ascending: false)]
        let spends = self.realm!.objects(Spend).filter(predicate).sorted(sortProperties)
        return spends
    }
    
    // realmにautoincrementの仕組みがないので、max id + 1する
    public func getNextGenreId() -> Int64 {
        var id: Int64 = 0
        let max = self.realm!.objects(Genre).sorted("id",ascending:false)
        if max.count > 0 {
            id = max[0].id
        }
        id += 1
        return id
    }
    public func getNextSpendId() -> Int64 {
        var id: Int64 = 0
        let max = self.realm!.objects(Spend).sorted("id",ascending:false)
        if max.count > 0 {
            id = max[0].id
        }
        id += 1
        return id
    }
    
    //デフォルトのタイトルの作成
    public func initDefaultGenre() {
        let gs = self.realm!.objects(Genre)
        if gs.count > 0 {
            //すでにジャンルが登録済みの状態ではなにもしない
            return
        }
        /*
        addGenre(1, name: "その他", color: "#000000", order: 9999,memo: "")
        addGenre(2, name: "お菓子", color: "#ffa500", order: 1,memo: "")
        addGenre(3, name: "漫画・雑誌", color: "#6495ed", order: 2,memo: "")
        addGenre(4, name: "外食", color: "#800000", order: 3,memo: "")
        addGenre(5, name: "ゲーム", color: "#2e8b57", order: 4,memo: "")
        */
        
        // 日本語の場合
        if(CommonUtil.isJa()){
            
            addGenre(1, name: "お菓子", color: "14256636", order: 1,memo: "")
            addGenre(2, name: "漫画・雑誌", color: "9017340", order: 2,memo: "")
            addGenre(3, name: "外食", color: "16562313", order: 3,memo: "")
            addGenre(4, name: "カフェ", color: "16550281", order: 4,memo: "")
            addGenre(5, name: "ゲーム", color: "9043157", order: 5,memo: "")
            
        }else{
            
            addGenre(1, name: "confection", color: "14256636", order: 1,memo: "")
            addGenre(2, name: "comic magazine", color: "9017340", order: 2,memo: "")
            addGenre(3, name: "eating‐out", color: "16562313", order: 3,memo: "")
            addGenre(4, name: "cafe", color: "16550281", order: 4,memo: "")
            addGenre(5, name: "game", color: "9043157", order: 5,memo: "")
            
        }
    }
    
    // ジャンルの並び順を指定
    public func updateGenreOrder(id: Int64, order: Int) {
        let gs = self.realm!.objects(Genre).filter("id = \(id)")
        // トランザクションを開始して、オブジェクトを更新する
        do{
            try self.realm!.write {
                gs[0].order = Int64(order)
            }
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
    }
    
    // realmにautoincrementの仕組みがないので、max id + 1する
    public func getNextConfigId() -> Int64 {
        var id: Int64 = 0
        let max = self.realm!.objects(Config).sorted("id",ascending:false)
        if max.count > 0 {
            id = max[0].id
        }
        id += 1
        return id
    }
    
    //Configの取得
    func getConfig() -> Config {
        let cs = self.realm!.objects(Config).filter("id = 1")
        //print(cs)
        if cs.count > 0 {
            return cs[0]
        } else {
            return Config()
        }
    }
    
    public func updateConfigLang(lang:String) {
        let c = self.realm!.objects(Config).filter("id = 1")
        
        // トランザクションを開始して、オブジェクトを更新する
        do{
            try self.realm!.write {
                c[0].lang = lang
            }
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
    }
    
    public func updateConfigDateFormat(format:String) {
        let c = self.realm!.objects(Config).filter("id = 1")
        do{
            try self.realm!.write {
                c[0].dateformat = format
            }
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
    }
    
    public func updateConfigWeekdayFormat(format:String) {
        let c = self.realm!.objects(Config).filter("id = 1")
        do{
            try self.realm!.write {
                c[0].weekday_lang = format
            }
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
    }
    
    public func updateConfigCenterDateFormat(format:String) {
        let c = self.realm!.objects(Config).filter("id = 1")
        do{
            try self.realm!.write {
                c[0].center_dateformat = format
            }
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
    }
    
    public func updateConfigCenterFontSize(size:Int) {
        let c = self.realm!.objects(Config).filter("id = 1")
        do{
            try self.realm!.write {
                c[0].center_font_size = Int64(size)
            }
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
    }
    
    public func updateConfigGraphFontSize(size:Int) {
        let c = self.realm!.objects(Config).filter("id = 1")
        do{
            try self.realm!.write {
                c[0].graph_font_size = Int64(size)
            }
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
    }
    
    public func updateConfigFont(font:String) {
        let c = self.realm!.objects(Config).filter("id = 1")
        do{
            try self.realm!.write {
                c[0].font = font
            }
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
    }
    
    public func updateConfigTitleFontSize(size:Int) {
        let c = self.realm!.objects(Config).filter("id = 1")
        do{
            try self.realm!.write {
                c[0].title_font_size = Int64(size)
            }
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
    }
    
    public func updateConfigCurrencySymbol(format:String) {
        let c = self.realm!.objects(Config).filter("id = 1")
        do{
            try self.realm!.write {
                c[0].currency_symbol = format
            }
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
    }
    
    public func updateConfigCharacterEncoding(chara:String) {
        let c = self.realm!.objects(Config).filter("id = 1")
        do{
            try self.realm!.write {
                c[0].character_encoding = chara
            }
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
    }
    
    public func updateConfigImageSize(size:String) {
        let c = self.realm!.objects(Config).filter("id = 1")
        do{
            try self.realm!.write {
                c[0].image_size = size
            }
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
    }
    
    public func updateConfigAnimation(setting:String) {
        let c = self.realm!.objects(Config).filter("id = 1")
        do{
            try self.realm!.write {
                c[0].animation = setting
            }
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
    }
    
    //デフォルトのconfigの作成
    public func initDefaultConfig() {
        //print(self.realm)
        let cs = self.realm!.objects(Config)
        //print(cs)
        if cs.count > 0 {
            //すでにジャンルが登録済みの状態ではなにもしない
            return
        }
        let c = Config()
        c.id = 1
        c.dateformat = "MM/dd"
        //c.lang = "en"
        c.weekday_lang = "en"
        c.center_dateformat = "YYYY/MM/dd"
        c.center_font_size = 18
        c.graph_font_size = 14
        c.font = "Helvetica"
        c.title_font_size = 17
        
        // 日本語の場合
        if(CommonUtil.isJa()){
            c.lang = "jp"
            c.currency_symbol = "¥"
        }else{
            c.lang = "en"
            c.currency_symbol = "$"
        }
        c.character_encoding = "UTF-8"
        c.image_size = "M"
        
        // トランザクションを開始して、オブジェクトをRealmに追加する
        do {
            try self.realm!.write {
                self.realm!.add(c)
            }
            print("Realm add Title complete. id=\(c.id)")
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
    }
    
    /*
    //対象のジャンルに紐づく過去の予定データを取得する
    public func getEventsFromTitleInPast(title: Title) -> Results<Event> {
        let todays = DateUtil.getTodayStartDate() //今日の00:00:00
        if todays == nil {
            print("todays == nil")
        }
        // 日をまたぐ場合を考慮
        let format = "end < %@" //対象のジャンルに合致する
        let predicate = NSPredicate(format: format,
            todays!
        )
        var events = self.realm!.objects(Event).filter("title.id == \(title.id)")
        var results = events.filter(predicate)
        return results
    }
    
    // 対象日に合致するイベントデータを返す
    public func getEventsFromDate(date: NSDate, isDraft: Bool = false) -> Results<Event> {
        let year = DateUtil.year(date)
        let month = DateUtil.month(date)
        let day = DateUtil.day(date)
        let date_formatter: NSDateFormatter = NSDateFormatter()
        date_formatter.locale     = NSLocale(localeIdentifier: "ja")
        date_formatter.locale     = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        date_formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let startstr = String(format: "%04d-%02d-%02d 00:00:00", year,month,day)
        let start: NSDate? = date_formatter.dateFromString(startstr)
        let endstr = String(format: "%04d-%02d-%02d 23:59:59", year,month,day)
        
        //ここでは対象日に関するものだけ取得する
        let end: NSDate? = date_formatter.dateFromString(endstr)
        // 翌日の6時まで
        let nextend: NSDate? = NSDate(timeInterval: 60*60*6, sinceDate: date_formatter.dateFromString(endstr)!)
        
        // 日をまたぐ場合を考慮
        let format = "( "
            + "(start >= %@ and end <= %@) " //対象日内の予定
            + "or (start >= %@ and end > %@ and start <= %@) " //対象日より前の日から、対象日で終わる
            + "or (start < %@ and end > %@ and end <= %@) " //対象日から、対象日より後で終わる
            + "or (start < %@ and end > %@) " //対象日を完全にまたぐ場合
            + "or (start > %@ and start < %@) " //翌日の６時まで開始の予定
            + " ) and is_draft = %@ "
        let predicate = NSPredicate(format: format,
            start!, end!,
            start!, end!, end!,
            start!, start!, end!,
            start!, end!,
            end!, nextend!,
            isDraft
        )
        let events = self.realm!.objects(Event).filter(predicate)
        return events
    }
    
    // 対象日以降のイベントデータを返す
    public func getEventsListFromDate(date: NSDate, isDraft: Bool = false) -> Results<Event> {
        let year = DateUtil.year(date)
        let month = DateUtil.month(date)
        let day = DateUtil.day(date)
        let date_formatter: NSDateFormatter = NSDateFormatter()
        date_formatter.locale     = NSLocale(localeIdentifier: "ja")
        date_formatter.locale     = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        date_formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let startstr = String(format: "%04d-%02d-%02d 00:00:00", year,month,day)
        let start: NSDate? = date_formatter.dateFromString(startstr)
        
        // 日をまたぐ場合を考慮
        let format = " "
            + " start >= %@  " //対象日以降の予定
            + " and is_draft = %@ "
        let predicate = NSPredicate(format: format,
            start!, 
            isDraft
        )
        
        let sortProperties = [SortDescriptor(property: "start", ascending: true)]
        let events = self.realm!.objects(Event).filter(predicate).sorted(sortProperties)
        return events
    }
    
    // イベント名と日時が一致するイベントがあるか？
    public func isExistEvent(name:String, start: NSDate, end: NSDate) -> Bool {
        
        // イベント名、開始日時、終了日時で検索
        let format = " name = %@ "
            + " and start = %@ "
            + " and end = %@ "
        let predicate = NSPredicate(format: format,
            name,
            start,
            end
        )
        let sortProperties = [SortDescriptor(property: "start", ascending: true)]
        let events = self.realm!.objects(Event).filter(predicate).sorted(sortProperties)
        
        // レコードがあればtrue
        if events.count > 0 {
            return true
        }else{
            return false
        }
    }
    
    public func addTitle(id: Int64, name: String, color: Int32, memo: String) -> Title {
        // Titleオブジェクトを作成する
        let title = Title()
        title.id = id
        title.name = name
        title.color = color
        title.number = id
        title.memo = memo
        
        // トランザクションを開始して、オブジェクトをRealmに追加する
        do {
            try self.realm!.write {
                self.realm!.add(title)
            }
            print("Realm add Title complete. id=\(title.id) name=\(title.name) color=\(title.color)")
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
        
        return title
    }
    
    // idに合致するタイトルを取得する
    public func getTitle(id: Int64) -> Title? {
        let titles = self.realm!.objects(Title).filter("id = \(id)")
        if titles.count > 0 {
            return titles[0]
        } else {
            return nil
        }
    }
    
    // タイトルリストを取得する
    public func getListTitle() -> Results<Title> {
        let titleList = self.realm!.objects(Title).filter("id > 0").sorted("number",ascending:true)
        return titleList
    }
    
    // ジャンルを追加する
    public func addTitle(name: String, color: Int32, memo: String) -> Title {
        let id: Int64 = getNextTitleId()
        return addTitle(id, name: name, color: color, memo:memo)
    }
    
    // ジャンルの並び替えの更新
    public func updateTitle(id: Int64, number: Int64) {
        let titles = self.realm!.objects(Title).filter("id = \(id)")
        // トランザクションを開始して、オブジェクトを更新する
        try! self.realm!.write {
            titles[0].number = number
        }
    }
    
    // ジャンルの更新
    public func updateTitle(id: Int64, name: String, color: Int32, number: Int64, memo: String) {
        let titles = self.realm!.objects(Title).filter("id = \(id)")
        // トランザクションを開始して、オブジェクトを更新する
        try! self.realm!.write {
            titles[0].name = name
            titles[0].color = color
            titles[0].number = number
            titles[0].memo = memo
        }
    }
    
    // ジャンルを削除する
    public func deleteTitle(id: Int64) {
        let titles = self.realm!.objects(Title).filter("id = \(id)")
        // トランザクションを開始してオブジェクトを削除します
        try! self.realm!.write {
            self.realm!.delete(titles)
        }
    }
    
    // realmにautoincrementの仕組みがないので、max id + 1する
    public func getNextTitleId() -> Int64 {
        var id: Int64 = 0
        let max = self.realm!.objects(Title).sorted("id",ascending:false)
        if max.count > 0 {
            id = max[0].id
        }
        id++
        return id
    }
    public func getNextEventId() -> Int64 {
        var id: Int64 = 0
        let max = self.realm!.objects(Event).sorted("id",ascending:false)
        if max.count > 0 {
            id = max[0].id
        }
        id++
        return id
    }
    
    //ジャンルが削除された際にそのジャンルに紐付いている予定を未分類に移行する
    public func updateEventFromDeleteTitle(delete_title_id: Int64) {
        let events = self.realm!.objects(Event).filter("title.id == \(delete_title_id)")
        let notitle = getTitle(Title.NO_TITLE_ID)
        updateEventsFromTitle(events, title: notitle!)
    }
    // 予定のジャンルの更新
    public func updateEventsFromTitle(events: Results<Event>, title: Title) {
        // トランザクションを開始して、オブジェクトを更新する
        for event in events {
            try! self.realm!.write {
                event.title = title
            }
        }
    }
    //イベントの取得
    public func getEvent(id: Int64) -> Event? {
        let events = self.realm!.objects(Event).filter("id = \(id)")
        if events.count > 0 {
            return events[0]
        } else {
            return nil
        }
    }
    //イベントの追加 autoincrements まで考慮する
    public func addEvent(start: NSDate, end: NSDate, titleid: Int64, name: String, memo: String, is_draft: Bool = false) -> Event? {
        let id:Int64 = getNextEventId()
        let title = getTitle(titleid)
        if title == nil {
            return nil
        }
        return addEvent(id, start: start, end: end, title: title!, name: name, memo: memo, is_draft: is_draft)
    }
    //イベントの追加 idを指定
    public func addEvent(id: Int64, start: NSDate, end: NSDate, title: Title, name: String, memo:String, is_draft:Bool) -> Event {
        let event = Event()
        event.id = id
        event.start = start
        event.end = end
        event.title = title
        event.name = name
        event.memo = memo
        event.color = -1
        event.is_draft = is_draft
        
        // トランザクションを開始して、オブジェクトをRealmに追加する
        do {
            try self.realm!.write {
                self.realm!.add(event)
            }
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
        
        return event
    }
    public func updateEvent(id: Int64, start: NSDate, end: NSDate, title: Title, name: String, memo: String, color: Int32, is_draft: Bool = false) {
        let events = self.realm!.objects(Event).filter("id = \(id)")
        
        // トランザクションを開始して、オブジェクトを更新する
        do{
            try self.realm!.write {
                events[0].start = start
                events[0].end = end
                events[0].title = title
                events[0].name = name
                events[0].memo = memo
                events[0].color = color
                events[0].is_draft = is_draft
            }
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
    }
    
    // 予定を削除する
    public func deleteEvent(id: Int64) {
        let events = self.realm!.objects(Event).filter("id = \(id)")
        // トランザクションを開始してオブジェクトを削除します
        try! self.realm!.write {
            self.realm!.delete(events)
        }
    }
    
    // 予定を下書きにする
    public func draftEvent(id: Int64) {
        let events = self.realm!.objects(Event).filter("id = \(id)")
        // トランザクションを開始して、オブジェクトを更新する
        do{
            try self.realm!.write {
                events[0].is_draft = true
            }
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
    }
    
    // 予定を下書きから正式なものにする
    public func unDraftEvent(id: Int64) {
        let events = self.realm!.objects(Event).filter("id = \(id)")
        // トランザクションを開始して、オブジェクトを更新する
        do{
            try self.realm!.write {
                events[0].is_draft = false
            }
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
    }
    
    //デフォルトのタイトルの作成
    public func initDefaultTitle() {
        let titles = self.realm!.objects(Title)
        if titles.count > 0 {
            //すでにジャンルが登録済みの状態ではなにもしない
            return
        }
        let colorNoTitle = UIColor.toInt32(Title.NO_TITLE_COLOR)
        let colorRed = UIColor.toInt32(Title.Red)
        let colorYellow = UIColor.toInt32(Title.Yellow)
        let colorDarkGreen = UIColor.toInt32(Title.DarkGreen)
        let colorOceanBlue = UIColor.toInt32(Title.OceanBlue)
        addTitle(0, name: Title.NO_TITLE_NAME, color: colorNoTitle, memo: "")
        addTitle(1, name: NSLocalizedString("DefaultTitle_1", comment: ""), color: colorRed, memo: "")
        addTitle(2, name: NSLocalizedString("DefaultTitle_2", comment: ""), color: colorYellow, memo: "")
        addTitle(3, name: NSLocalizedString("DefaultTitle_3", comment: ""), color: colorDarkGreen, memo: "")
        addTitle(4, name: NSLocalizedString("DefaultTitle_4", comment: ""), color: colorOceanBlue, memo: "")
    }
    // データの全削除
    public func deleteAllDatas() {
        //一旦データを全削除
        do {
            try self.realm!.write {
                self.realm!.deleteAll()
            }
        } catch let error as NSError {
            print("Realm init error" + error.description)
        }
    }
    */
}