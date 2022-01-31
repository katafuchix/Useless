//
//  CalViewController.swift
//  Useless
//
//  Created by cano on 2016/04/17.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit
import Social
import Charts
import CNPPopupController
import RealmSwift
import AKPickerView_Swift
import MessageUI

class CalViewController: UIViewController, UITabBarControllerDelegate, MFMailComposeViewControllerDelegate, ChartViewDelegate, calPickerDelegate {

    @IBOutlet weak var menuContainerView: UIView!
    
    @IBOutlet var pieChartView: PieChartView!
    
    //@IBOutlet weak var menuViewConstraint: NSLayoutConstraint!
    
    @IBOutlet var menuViewConstraint: NSLayoutConstraint!
    
    var isShowMenu : Bool = false
    
    var myLeftButton : UIButton?
    var myRightButton : UIButton?
    var datePickerVC : CalDatePickerViewController?
    
    let realm = RealmController.getSharedRealmController()
    var config = Config()
    var blackOutView: UIView?
    
    var genreList : Results<Genre>?
    var genreDic : Dictionary<Int,Genre> = Dictionary<Int,Genre>()  // 削除時に参照する辞書
    var date : NSDate?
    var start : NSDate?
    var end : NSDate?
    var gList: Array<Int64> = Array<Int64>()
    var dataPoints: [String] = []
    var values: [Double] = []
    var colors: [UIColor] = []
    
    @IBOutlet weak var slideView: UIView!
//    @IBOutlet weak var slideViewConstraint: NSLayoutConstraint!
    
    @IBOutlet var slideViewConstraint: NSLayoutConstraint!
    var isShowSlide = false
    var slideMenu : SlideMenu?
    
    var wordDic : Dictionary<String, String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        loadConfigData()
        loadGenreData()
        initNavigationBar()
        
        self.start = self.makeStartDate()
        //print("self.start : \(self.start)")
        self.end = self.makeEndDate()
        
        self.tabBarController?.delegate = self
        
        //self.menuViewConstraint.constant = 100
        //print(menuContainerView)
        menuContainerView.backgroundColor = UIColor.whiteColor()
        blackOutView = UIView(frame:self.view.frame)
        blackOutView?.backgroundColor = UIColor.grayColor()
        blackOutView?.alpha = 0.0
        blackOutView?.hidden = true
        self.view.addSubview(blackOutView!)
        
        let blackTap = UITapGestureRecognizer(target: self, action: #selector(CalViewController.blackTapGesture(_:)))
        blackOutView?.addGestureRecognizer(blackTap)
        
        self.view.bringSubviewToFront(menuContainerView)
        
        //self.title = self.wordDic!["CAL_TITLE"]
        slideMenu = NSBundle.mainBundle().loadNibNamed("SlideMenu", owner: self, options: nil).first as! SlideMenu
        slideView.addSubview(slideMenu!)
        
        // 下敷きのタップ
        slideView.layer.cornerRadius = 10
        
        slideMenu?.button.addTarget(self, action: #selector(DayViewController.test(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        slideMenu?.button.backgroundColor = CommonUtil.getSettingThemaColor()
        slideMenu!.layer.borderColor = UIColor.grayColor().CGColor
        slideMenu!.layer.borderWidth = 0.3
        slideMenu!.layer.cornerRadius = 10
        slideMenu!.layer.masksToBounds = true
        
        //slideMenu?.twitterButton!.addTarget(self, action: #selector(CalViewController.makeCSV), forControlEvents: UIControlEvents.TouchUpInside)
        slideMenu?.twitterButton!.addTarget(self, action: #selector(CalViewController.onTwitter(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        slideMenu?.fbButton!.addTarget(self, action: #selector(CalViewController.onFacebook(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        slideMenu?.lineButton!.addTarget(self, action: #selector(CalViewController.onLine(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        slideMenu?.mailButton!.addTarget(self, action: #selector(CalViewController.sendMailWithCSVImage), forControlEvents: UIControlEvents.TouchUpInside)
        slideMenu?.photoButton!.addTarget(self, action: #selector(CalViewController.saveImage), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    // Line
    func onLine(sender: AnyObject) {
        let pastBoard: UIPasteboard = UIPasteboard.generalPasteboard()
        pastBoard.setData(UIImagePNGRepresentation(self.getChartImage())!, forPasteboardType: "public.png")
        let lineUrlString: String = String(format: "line://msg/image/%@", pastBoard.name)
        UIApplication.sharedApplication().openURL(NSURL(string: lineUrlString)!)
    }
    
    // Twitterへの投稿
    func onTwitter(sender: AnyObject) {
        self.postMedia(SLServiceTypeTwitter)
    }
    
    // Facebookへの投稿
    func onFacebook(sender: AnyObject) {
        self.postMedia(SLServiceTypeFacebook)
    }
    
    func postMedia(type:String)
    {
        // 利用できるかを判定
        if(SLComposeViewController.isAvailableForServiceType(type))
        {
            // 初期化処理
            let SocialMedia :SLComposeViewController = SLComposeViewController(forServiceType: type)
            // 本文をセット
            SocialMedia.setInitialText("")
            
            //let image = UtilManager.getUIImageFromUIView(self.pieChartView)
            let image = getChartImage()
            
            // 画像を添付
            SocialMedia.addImage(image)
            // ハンドラを指定
            SocialMedia.completionHandler = {(result: SLComposeViewControllerResult) in
                // 成功時にUIを閉じる
                if(result==SLComposeViewControllerResult.Done){
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            // SLComposeViewControllerを表示
            self.presentViewController(SocialMedia, animated: true, completion: nil)
        }
    }
    
    func getChartImage() -> UIImage {
        let image = UtilManager.clipView(self.pieChartView, rect: CGRectInset(self.pieChartView.circleBox, -10.0, -10.0))
        return UtilManager.getResizeImage(image!, size: self.config.image_size)
    }
    
    func saveImage() {
        let image = self.getChartImage()
        
        // フォトアルバムに保存
        UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    // 画像保存時のセレクタ
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        
        var message : String?
        if error == nil {
            message = self.wordDic!["SAVE_SUCCESS"]
        } else {
            message = self.wordDic!["SAVE_FAILD"]
        }
        
        // 処理の完了時にはアラートを出す
        let alert = UIAlertController(title: message!, message: "", preferredStyle: .Alert)
        // OKボタンを追加
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        // 表示
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // メール送信
    func sendMailWithCSVImage() {
        
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        
        let nameBase = UtilManager.getNowDateTime()
        let fileName = "\(nameBase).csv"
        let imageName = "\(nameBase).png"
        let image = self.getChartImage()
        if let imageData = UIImagePNGRepresentation(image) {
            mailViewController.addAttachmentData(imageData, mimeType: "image/png", fileName: imageName)
        }
        
        if self.config.character_encoding == "UTF-8" {
            mailViewController.addAttachmentData(makeCSV().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, mimeType: "text/csv", fileName: fileName)
        }else{
            mailViewController.addAttachmentData(makeCSV().dataUsingEncoding(NSShiftJISStringEncoding, allowLossyConversion: false)!, mimeType: "text/csv", fileName: fileName)
        }
        mailViewController.setToRecipients(nil)
        self.presentViewController(mailViewController, animated: true, completion: nil)
    }
    
    // メール送信
    func sendMailWithCSV() {
        
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        
        let nameBase = UtilManager.getNowDateTime()
        let fileName = "\(nameBase).csv"
        if self.config.character_encoding == "UTF-8" {
            mailViewController.addAttachmentData(makeCSV().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, mimeType: "text/csv", fileName: fileName)
        }else{
            mailViewController.addAttachmentData(makeCSV().dataUsingEncoding(NSShiftJISStringEncoding, allowLossyConversion: false)!, mimeType: "text/csv", fileName: fileName)
        }
        mailViewController.setToRecipients(nil)
        self.presentViewController(mailViewController, animated: true, completion: nil)
    }
    
    func makeCSV() -> String{
        
        var days = Array<String>()
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        formatter.dateFormat = self.config.center_dateformat
        //formatter.dateFormat =  "M/d"
        
        let diff = end!.timeIntervalSinceDate(start!)/(60 * 60 * 24) + 1
        //print(diff)
        //for var i = 0; i < Int(diff); i = i + 1{
        for i:Int in 0 ..< Int(diff) {
            let d = NSDate.init(timeInterval: Double(60*60*24*i), sinceDate: start!)
            //print(d)
            days.append(formatter.stringFromDate(d))
        }
        //print(days)
        
        var headerData = Array<String>()
        //var lineData = Dictionary<String, Array<Double>>()
        var lineData = Array<Dictionary<String,Float>>()
        var totalData = Array<String>()
        
        headerData.append(self.wordDic!["DATE"]!)
        var isFloat = false
        let genreList = realm.getListGenre()
        for g in genreList {
            headerData.append(g.name)
            
            var dic = Dictionary<String,Float>()
            let saleList = realm.getSpendsFromDate(start!, end:end!, genre:g)
            
            for s in saleList {
                dic[formatter.stringFromDate(s.date!)] = s.price
                if (UtilManager.isFloatData(s.price)) {
                    isFloat = true
                }
            }
            let keys = days.filter{ !dic.keys.contains($0) }
            keys.map{ dic[$0] = 0 }
            
            lineData.append(dic)
        }
        //print(headerData)
        var csvStr = ""
        csvStr = headerData.joinWithSeparator(",")
        csvStr += "\n"
        //print(csvStr)
        
        var csvData = Array<String>()
        for day in days {
            var tmp = Array<String>()
            tmp.append(day)
            for lined in lineData {
                if isFloat {
                    tmp.append(String(lined[day]!))
                }else{
                    tmp.append(String(Int(lined[day]!)))
                }
            }
            csvData.append(tmp.joinWithSeparator(","))
        }
        csvStr += csvData.joinWithSeparator("\n")
        csvStr += "\n"
        
        totalData.append(self.wordDic!["TOTAL"]!)
        for lined in lineData {
            let lineTotal = lined.values.reduce(0, combine: +)
            if isFloat {
                totalData.append(String(lineTotal))
            }else{
                totalData.append(String(Int(lineTotal)))
            }
        }
        csvStr += totalData.joinWithSeparator(",")
        //print(csvStr)
        return csvStr
    }
    
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError?) {
        
        // ビューコントローラーを閉じる
        self.dismissViewControllerAnimated(true, completion: nil)
        
        switch result.rawValue {
        // 保存した場合
        case MFMailComposeResultSaved.rawValue:
            self.setAlert(self.wordDic!["SAVE_SUCCESS"]!)
        // 送信した場合
        case MFMailComposeResultSent.rawValue:
            self.setAlert(self.wordDic!["SENT_SUCCESS"]!)
        // 失敗した場合
        case MFMailComposeResultFailed.rawValue:
            self.setAlert(self.wordDic!["SENT_FAIL"]!)
        default:
            break
        }
    }
    
    func setAlert(str:String){
        // 処理の完了時にはアラートを出す
        let alert = UIAlertController(title: str, message: "", preferredStyle: .Alert)
        // OKボタンを追加
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        // 表示
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func test(sender:UIButton){
        if self.isShowSlide {
            self.hideSlide()
        }else{
            self.showSlide()
        }
    }
    
    func showSlide(){
        UIView.animateWithDuration(1.0,
                                   delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: {
                                    self.slideViewConstraint.constant += 260.0
            }, completion: { finished in
                self.isShowSlide = true
                self.slideMenu?.button.setTitle("▶︎", forState: .Normal)
        } )
    }
    
    func hideSlide(){
        UIView.animateWithDuration(1.0,
                                   delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: {
                                    self.slideViewConstraint.constant -= 260.0
            }, completion: { finished in
                self.isShowSlide = false
                self.slideMenu?.button.setTitle("◀︎", forState: .Normal)
        } )
    }
    
    func loadConfigData(){
        self.config = realm.getConfig()
        //print(self.config)
        self.wordDic = UtilManager.getLangs(self.config.lang)
    }
    
    //Viewが表示される直前
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.config = realm.getConfig()
        initNavigationBar()
        self.pieChartView.delegate = self
        showChart()
        slideMenu?.button.backgroundColor = CommonUtil.getSettingThemaColor()
    }
    
    func loadGenreData()
    {
        genreList = realm.getListGenre()
        genreDic = Dictionary<Int,Genre>()
        var i = 0
        for genre in genreList! {
            genreDic[i] = genre
            i += 1
        }
    }
    
    func tabBarController(tabBarController: UITabBarController,
                            didSelectViewController viewController: UIViewController){
        //print(tabBarController)
        self.datePickerVC?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight){
        print("selected-----")
        print(entry)
        print("entry.xIndex : \(entry.xIndex)   dataSetIndex : \(dataSetIndex)")
        print("genre!.id : \(gList[entry.xIndex])")
        print(dataPoints[entry.xIndex])
        print(values[entry.xIndex])
        
        let story = UIStoryboard(name: "CalDetail", bundle: nil)
        let vc = story.instantiateViewControllerWithIdentifier("CalDetailViewController") as! CalDetailViewController
        
        vc.start = self.start
        vc.end = self.end
        vc.genreId = gList[entry.xIndex]
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func showChart() {
        self.gList = Array<Int64>()
        self.dataPoints = []
        self.values = []
        self.colors = []
        
        let sList = self.realm.getSpendsFromDate(self.start!, end:self.end!)
        //print(sList)
        for s in sList {
            if let index = self.gList.indexOf(s.genre!.id) {
                //print("index : \(index)")
                let val = Float(values[index]) + s.price
                values[index] = Double(val)
            }else{
                gList.append(s.genre!.id)
                dataPoints.append(s.genre!.name)
                values.append(Double(s.price))
                colors.append(UIColor(hex: Int((s.genre?.color)!)!, alpha: 1.0))
            }
        }
        
        //self.pieChartView.usePercentValuesEnabled = true
        self.pieChartView.descriptionText = ""
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Units Sold")
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        
        pieChartView.data = pieChartData
        pieChartDataSet.colors = colors
        pieChartDataSet.valueTextColor = UIColor.blackColor()
        
        //pieChartDataSet.valueFont = UIFont(name: "HigashiOme-Gothic", size: CGFloat(self.config.graph_font_size))!
        //print("self.config.font : \(self.config.font)")
        pieChartDataSet.valueFont = UIFont(name: self.config.font, size: CGFloat(self.config.graph_font_size))!
        /*
         let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Units Sold")
         let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
         lineChartView.data = lineChartData
         */
        
        if self.config.animation == "on" {
            pieChartView.animate(xAxisDuration: 1.4, yAxisDuration: 1.4, easingOption: ChartEasingOption.EaseOutBack)
        }
        
        //let date = NSDate()
        // タイムゾーンを言語設定にあわせる
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        formatter.dateFormat = config.center_dateformat
        let startStr = formatter.stringFromDate(self.start!)
        var str:String = "\(formatter.stringFromDate(self.start!))\n  〜\n \(formatter.stringFromDate(self.end!))"
        
        let total = Float(values.reduce(0) { $0 + $1 })
        //print("\n\(CommonUtil.addFigure(self.config, value: total))")
        let totalStr = CommonUtil.addFigure(self.config, value: total)
        var diff = 0
        if self.config.center_dateformat == "YYY/MM/dd" || self.config.center_dateformat == "YYYY/M/d" {
            diff = startStr.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) - (totalStr.characters.count+1)
            //diff = startStr.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) - ( totalStr.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) + 0)
            if (self.config.center_dateformat == "YYYY/M/d") {
                diff = diff + 3
            }
        }else{
            //diff = startStr.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) - (totalStr.characters.count+1)
            diff = startStr.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) - ( totalStr.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) + 0)
        }
        var diffStr = ""
        //print("diff : \(diff)")
        for _ in 0 ..< abs(diff) {
            diffStr = diffStr + " "
        }
        str = str + "\n" + diffStr +  totalStr
        
        pieChartView.drawCenterTextEnabled = true
        //let attrText = NSMutableAttributedString(string: "装飾される\n文字列")
        let attrText = NSMutableAttributedString(string: str)
        //attrText.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(UIFont.labelFontSize())], range: NSMakeRange(0, str.characters.count))
        attrText.addAttributes([NSFontAttributeName:UIFont(name: self.config.font, size: CGFloat(self.config.center_font_size))!],range: NSMakeRange(0, str.characters.count))
        pieChartView.centerAttributedText = attrText
        
        // 文字色
        //attrText.addAttributes([NSForegroundColorAttributeName: UIColor.blueColor()], range: NSMakeRange(1, 4))
        
        // 背景色
        //attrText.addAttributes([NSBackgroundColorAttributeName: GSSettings.unreadNotificationColor()], range: NSMakeRange(1, 4))
        
        // フォント(Bold、サイズはUILabelの標準サイズ)
        //attrText.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(UIFont.labelFontSize())], range: NSMakeRange(0, 1))
        
        //pieChartView.centerText = attrText.mutableString as String
        //pieChartView.centerAttributedText = attrText
        //pieChartView.setDescriptionTextPosition(x: 0, y: 0)
        //print(self.pieChartView.data?.xValsObjc)
        //print(self.pieChartView.marker)
        //self.pieChartView.drawSliceTextEnabled = false
        //self.pieChartView.extraLeftOffset = 100.0
        //print(self.pieChartView.legend.labelsObjc)
        //print(self.pieChartView.legend.self)
        //self.pieChartView.description.
        self.pieChartView.legend.enabled = false
    }
    
    // メニューを表示
    func showMenu(sender: UIBarButtonItem){
        if !self.isShowMenu {
            //self.menuViewConstraint.constant = self.view.frame.size.width - 240.0
            showMenu()
        }else{
            //self.menuViewConstraint.constant = self.view.frame.size.width
            hideMenu()
        }
    }
    
    func showMenu(){
        UIView.animateWithDuration(0.2, animations: {
            self.menuViewConstraint.constant -= 160.0 // self.view.frame.size.width - 240.0
            self.view.layoutIfNeeded()
            self.blackOutView!.hidden = false
            self.blackOutView!.alpha = 0.3
            //print(self.menuContainerView)
            self.menuContainerView.frame.origin.y = 0.0
            },completion: nil)
        
        self.isShowMenu = true
    }
    
    func hideMenu(){
        UIView.animateWithDuration(0.2, animations: {
            self.menuViewConstraint.constant += 160.0//= self.view.frame.size.width
            self.view.layoutIfNeeded()
            self.blackOutView!.alpha = 0.0
            self.menuContainerView.frame.origin.y = 0.0
            }, completion: { finished in self.blackOutView!.hidden = true
                self.isShowMenu = false} )
    }
    
    // タップイベントを拾う
    internal func blackTapGesture(sender: UITapGestureRecognizer){
        if self.isShowMenu {
            hideMenu()
        }
    }
    
    // ピッカーを表示
    func showCaldatePicker(type:String){
        
        // ピッカー用のコントローラーをモーダルで表示
        let story = UIStoryboard(name: "Main", bundle: nil)
        datePickerVC = story.instantiateViewControllerWithIdentifier("CalDatePickerViewController") as? CalDatePickerViewController
        
        datePickerVC!.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        datePickerVC!.delegate = self
        if(type == "start"){
            datePickerVC!.date = self.start
            datePickerVC!.type = "start"
        }else{
            datePickerVC!.date = self.end
            datePickerVC!.type = "end"
        }
        
        // 日付ピッカー出現時には右上の完了ボタンを無効にしておく
        //self.navigationItem.rightBarButtonItem?.enabled = false
        self.presentViewController(datePickerVC!, animated: true, completion: nil)
    }
    
    func didCloseCalDatePickerer(date:NSDate, type:String){
        print(date)
        print(type)
        if type == "start" {
            self.start = date
        }else{
            self.end = date
        }
        showChart()
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
        titleLabel.font = UIFont(name: self.config.font, size: CGFloat(self.config.title_font_size))
        titleLabel.text = self.wordDic!["CAL_TITLE"] //NSLocalizedString("MovieListViewController_navi_title", comment: "")
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.userInteractionEnabled = false //タッチを検出しない
        titleLabel.tag = 1
        titleLabel.sizeToFit()
        titleLabel.frame.size.height = (self.navigationController?.navigationBar.frame.height)! // 英語「g」の下が切れる対策
        self.navigationItem.titleView = titleLabel
        
        self.tabBarController?.tabBar.tintColor = CommonUtil.getSettingThemaColor()
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        /*
         // ナビゲーションバーのボタンが画面の戻りで下がってしまうことがあるので下地のビューを作ってframeを固定して配置する
         // 左ボタンを作成する
         myLeftButton = UIButton(type: .Custom)
         myLeftButton!.frame = CGRectMake(0,0,25,25)
         myLeftButton!.setTitle("< ", forState: .Normal)
         myLeftButton!.titleLabel!.font = UIFont(name: "Helvetica-Bold",size: CGFloat(26))
         myLeftButton!.addTarget(self, action: #selector(DayViewController.back(_:)), forControlEvents: UIControlEvents.TouchUpInside)
         let lView = UIView(frame: CGRectMake(0,0,25,25))
         lView.addSubview(myLeftButton!)
         // ナビゲーションバーの左に設置する.
         self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: lView)
         */
        // 右ボタンを作成する
        myRightButton = UIButton(type: .Custom)
        myRightButton!.frame = CGRectMake(0,0,25,25)
        //myRightButton!.setTitle(" + ", forState: .Normal)
        //myRightButton!.titleLabel!.font = UIFont(name: "Helvetica-Bold",size: CGFloat(30))
        let image = UIImage(named: "menuIcon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        myRightButton!.setImage(image, forState: .Normal)
        //myRightButton.titleLabel!.font = UIFont(name: CommonUtil.DEFAULT_FONT_NAME_JP,size: CGFloat(30))
        //myRightButton!.addTarget(self, action: #selector(CalViewController.showCaldatePicker(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        myRightButton!.addTarget(self, action: #selector(CalViewController.showMenu(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        myRightButton!.tag = 1
        let rView = UIView(frame: CGRectMake(0,0,25,25))
        rView.addSubview(myRightButton!)
        
        // ナビゲーションバーの右に設置する.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rView)
    }
    
    func makeStartDate() -> NSDate {
        let date = NSDate()
        let year = DateUtil.year(date)
        let month = DateUtil.month(date)
        let day = 1
        let date_formatter: NSDateFormatter = NSDateFormatter()
        date_formatter.locale     = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        date_formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let str = String(format: "%04d-%02d-%02d 00:00:00", year,month,day)
        return date_formatter.dateFromString(str)!
    }
    
    func makeEndDate() -> NSDate {
        let date = NSDate()
        let year = DateUtil.year(date)
        let month = DateUtil.month(date)
        let endDay = DateUtil.getLastDay(year, month: month)!
        let date_formatter: NSDateFormatter = NSDateFormatter()
        date_formatter.locale     = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        date_formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let str = String(format: "%04d-%02d-%02d 23:59:59", year,month,endDay)
        return date_formatter.dateFromString(str)!
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
