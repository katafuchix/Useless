//
//  CalDatePickerViewController.swift
//  Useless
//
//  Created by cano on 2016/04/24.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit
import RealmSwift

class CalDatePickerViewController: UIViewController {

    @IBOutlet var headerView: UIView!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var footerView: UIView!
    
    var date : NSDate?
    var delegate : calPickerDelegate?
    var type : String?
    
    let realm = RealmController.getSharedRealmController()
    var config : Config = Config()
    var wordDic : Dictionary<String, String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        datePicker.backgroundColor = UIColor.whiteColor()
        initUI()
        
    }

    // UIの準備
    func initUI() {
        self.view.backgroundColor = UIColor.clearColor()
        
        // ヘッダの色変更
        headerView.backgroundColor = CommonUtil.getSettingThemaColor()
        
        self.config = realm.getConfig()
        //print(self.config)
        self.wordDic = UtilManager.getLangs(self.config.lang)
        
        // キャンセルボタン
        let cencelTitle = self.wordDic!["CANCEL"]
        cancelButton.titleLabel!.font = UIFont(name: CommonUtil.DEFAULT_FONT_NAME_JP, size: 17)
        cancelButton.setTitle(cencelTitle, forState: UIControlState.Normal)
        cancelButton.setTitle(cencelTitle, forState: UIControlState.Highlighted)
        
        // 実行ボタン
        let doneTitle = self.wordDic!["DONE"]
        doneButton.titleLabel!.font = UIFont(name: CommonUtil.DEFAULT_FONT_NAME_JP, size: 17)
        doneButton.setTitle(doneTitle, forState: UIControlState.Normal)
        doneButton.setTitle(doneTitle, forState: UIControlState.Highlighted)
        doneButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
        
        // ボタン押下時の動作をしてい
        cancelButton.addTarget(self, action: #selector(CalDatePickerViewController.onCancel(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.addTarget(self, action: #selector(CalDatePickerViewController.onDone(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        datePicker.datePickerMode = UIDatePickerMode.Date
        datePicker.date = self.date!
        
        /*let date = NSDate()
        let year = DateUtil.year(date)
        let month = DateUtil.month(date)
        let day = DateUtil.getLastDay(year, month: month)! //1//DateUtil.day(date)
        let date_formatter: NSDateFormatter = NSDateFormatter()
        //date_formatter.locale     = NSLocale(localeIdentifier: "ja")
        date_formatter.locale     = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        date_formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let startstr = String(format: "%04d-%02d-%02d 00:00:00", year,month,day)
        let start: NSDate = date_formatter.dateFromString(startstr)!
        datePicker.date = start*/
    }
    
    // キャンセルボタンタップ時
    func onCancel(sender:UIButton){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // 実行ボタンタップ時
    func onDone(sender:UIButton){
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if (self.delegate?.respondsToSelector(Selector("didCloseCalDatePickerer:"))) != nil {
            // 実装先のメソッドを実行
            self.delegate?.didCloseCalDatePickerer(datePicker.date, type:self.type!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// CalViewController で処理を行うためのデリゲート
protocol calPickerDelegate : NSObjectProtocol {
    // 日付ピッカーを閉じてフォーカスを元に戻す
    func didCloseCalDatePickerer(date:NSDate, type:String)
    // 日付ピッカーからの入力を編集画面に反映 編集なので年は固定
    //func updateEditDate(str: String, sYear: Int, eYear: Int)->Bool
}

