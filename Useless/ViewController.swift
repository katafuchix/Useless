//
//  ViewController.swift
//  Useless
//
//  Created by cano on 2016/02/25.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit
import RAMAnimatedTabBarController
import Device

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    var cell_num_before_today = 180
    var cell_num_after_today = 180
    var event_cell_num: Int = 0
    //var current_year: Int = DateUtil.year(NSDate())
    let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)! //カレンダーデータ
    let LOAD_DATE_NUM = 30 //スクロールが下端に達した時、読み込むセルの数
    let PRELOAD_INDEX = 3
    
    let pData = PublicDatas.getPublicDatas()
    let realm = RealmController.getSharedRealmController()
    var config = Config()
    
    var firstScroll = true
    var wordDic : Dictionary<String, String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //self.title = "カレンダー"
        
        //initNavigationBar()
        
        //初期のテーブルサイズ
        event_cell_num = cell_num_before_today + cell_num_after_today
        
        tableView.delegate = self
        tableView.dataSource = self
        //セルの境界線を消す
        tableView.separatorColor = UIColor.clearColor()
        
        //print("themaColor : " + pData.getStringForKey("themaColor"))
        //print(Constants.langs[0])
        //let dic = UtilManager.getLangs("jp")
        //print(dic["TOP_TITLE"])
        //self.title = dic["TOP_TITLE"]
        //print(RealmController.getSharedRealmController().getConfig())
        //print(Device.size())
    }

    //ナビゲーションバーの初期化
    func initNavigationBar() {
        //透過オフ
        self.navigationController!.navigationBar.translucent = CommonUtil.NAVBAR_TRANSLUCENT
        //ナビゲーションバーの色変更
        self.navigationController!.navigationBar.barTintColor = CommonUtil.getSettingThemaColor()
        // 文字色の変更
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        //ナビゲーションバータイトルの表示
        let titleLabel = UILabel(frame:CGRectMake(0,0,0,0))
        //titleLabel.font = UIFont(name: CommonUtil.DEFAULT_FONT_NAME_JP, size: 17)
        
        //titleLabel.font = UIFont(name: "HigashiOme-Gothic-1.3i.ttf", size: 17)
        //titleLabel.font = UIFont(name: "HigashiOme-Gothic", size: 17)
        //titleLabel.font = UIFont(name: "Honoka-Antique-Kaku", size: 17)
        //titleLabel.font = UIFont(name: "Honoka-Mincho", size: Constants.pickerFontSize)
        //titleLabel.font = UIFont(name: "Honoka-Maru-Gothic", size: Constants.pickerFontSize)
        //titleLabel.font = UIFont(name: "F910-Shin-comic-tai", size: Constants.pickerFontSize)
        //titleLabel.font = UIFont(name: "NicoMoji+", size: Constants.pickerFontSize)
        titleLabel.font = UIFont(name: self.config.font, size: CGFloat(self.config.title_font_size))
        
        titleLabel.text = self.wordDic!["TOP_TITLE"] //NSLocalizedString("MovieListViewController_navi_title", comment: "")
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.userInteractionEnabled = false //タッチを検出しない
        titleLabel.tag = 1
        titleLabel.sizeToFit()
        titleLabel.frame.size.height = (self.navigationController?.navigationBar.frame.height)! // 英語「g」の下が切れる対策
        self.navigationItem.titleView = titleLabel
        
        self.tabBarController?.tabBar.tintColor = CommonUtil.getSettingThemaColor()
        let rm = self.tabBarController as! RAMAnimatedTabBarController
        //rm.tintColor = CommonUtil.getSettingThemaColor()
        
        rm.setSelectIndex(from: 0, to: 0)
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
    }
    
    //Viewが表示される直前
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.config = realm.getConfig()
        print(config)
        self.wordDic = UtilManager.getLangs(self.config.lang)
        initNavigationBar()
        reloadTableView() //テーブルの再描画
        if firstScroll {
            //今日の位置を上端にスクロールしておく
            scrollToday()
            firstScroll = false
        }
        
        self.tabBarController?.tabBar.tintColor = CommonUtil.getSettingThemaColor()
        let rm = self.tabBarController as! RAMAnimatedTabBarController
        let items = self.tabBarController?.tabBar.items as? [RAMAnimatedTabBarItem]
        //print(items)
        var index = 0
        for item in items! {
            //print(item)
            item.animation.textSelectedColor = CommonUtil.getSettingThemaColor()
            item.animation.iconSelectedColor = CommonUtil.getSettingThemaColor()
            //print(item.textFont)
            item.textFont = UIFont(name: self.config.font, size: 10.0)!
            if index == 0 { item.title = self.wordDic!["TOP_TITLE"] }
            if index == 1 { item.title = self.wordDic!["CAL_TITLE"] }
            if index == 2 { item.title = self.wordDic!["SET_TITLE"] }
            index += 1
        }
        rm.setSelectIndex(from: 0, to: 0)
    }
    
    //今日の位置にスクロールする
    private func scrollToday(isNavbar: Bool = false, animated: Bool = false) {
        //タイムラインヘッダーが重なるようになったので、その分余分にスクロールするように修正
        let y = CGFloat(cell_num_before_today) * 40.0 - 68.0 + 20.0///+ 64.0//EventTableViewCell.EVENT_CELL_HEIGHT - EventTableHeaderView.HEADER_HEIGHT
        
        // ナビゲーションバーの透過をオフにしたら下の考慮は必要なくなったのでコメントアウト
        /*
        if isNavbar {
        // 今日の位置がナビゲーションバーに重なるかどうかで、スクロール位置を考慮する必要がある
        //if topRowIndex < cell_num_after_today{
        y -= 64.0
        //}
        }
        */
        let rect = CGRectMake(0, y, self.tableView.frame.size.width, self.tableView.frame.size.height)
        tableView.scrollRectToVisible(rect, animated: false) //スクロールのアニメーションなくす
    }
    
    // テーブルの行数を返す
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return event_cell_num
    }

    //表示するセルの中身
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let today = NSDate() //今日の日付データ
        let cell = tableView.dequeueReusableCellWithIdentifier("TopTableViewCell") as! TopTableViewCell
        let current = calendar.dateByAddingUnit(NSCalendarUnit.Day, value: indexPath.row - cell_num_before_today, toDate: today, options: [])!
        cell.config = self.config
        cell.date = current
        
        //print(cell)
        //セルの選択色なし
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        //cell.row = indexPath.row
        //cell.textLabel?.text = "\(DateUtil.month(current)) \(DateUtil.day(current))"
        
        if indexPath.row == event_cell_num - self.PRELOAD_INDEX - 1 {
            //スクロールして下端ラストx個前のセルを読み込んだ時
            cell_num_after_today += self.LOAD_DATE_NUM
            reloadTableView()
        } else if indexPath.row == 0 {
            //スクロールして上端セルを読み込んだ時
            cell_num_before_today += self.LOAD_DATE_NUM
            reloadTableView()
            
            //スクロール位置を現在位置に再修正
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.LOAD_DATE_NUM, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        }
        cell.setNeedsDisplay()
        return cell
    }
    
    //セルの高さ
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40.0//EventTableViewCell.EVENT_CELL_HEIGHT
    }
    
    // テーブル再描画
    func reloadTableView() {
        
        //画面更新の度に”今日”を更新する
        //current_year = DateUtil.year(NSDate())
        
        event_cell_num = cell_num_before_today + cell_num_after_today
        tableView.reloadData()
    }
    
    //選択された時
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // もっと上位でイベント処理するので、ここではイベント拾えない
        print("\(indexPath.row)行目を選択")
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TopTableViewCell
        //print(cell.date)
        
        /*
        let inputStory = UIStoryboard(name: "Input", bundle: nil)
        let inputVC = inputStory.instantiateViewControllerWithIdentifier("InputViewController") as! InputViewController
        self.navigationController?.pushViewController(inputVC, animated: true)
        */
        let dayStory = UIStoryboard(name: "Day", bundle: nil)
        let dayVC = dayStory.instantiateViewControllerWithIdentifier("DayViewController") as! DayViewController
        dayVC.date = cell.date
        self.navigationController?.pushViewController(dayVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

