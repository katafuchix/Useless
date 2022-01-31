//
//  CalDetailViewController.swift
//  Useless
//
//  Created by cano on 2016/05/04.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit
import Charts
import MessageUI
import Social

class CalDetailViewController: UIViewController, MFMailComposeViewControllerDelegate{
    
    var myLeftButton : UIButton?
    var myRightButton : UIButton?
    
    //@IBOutlet var barChartView: BarChartView!
    var days: [String]!
    
    let realm = RealmController.getSharedRealmController()
    var config = Config()
    var start : NSDate?
    var end : NSDate?
    var gList: Array<Int64> = Array<Int64>()
    var dataPoints: [String] = []
    var values: [Double] = []
    var colors: [UIColor] = []
    
    var genreId : Int64 = 0
    var genre : Genre?
    
    var barChartView: BarChartView?
    
    @IBOutlet weak var slideView: UIView!
    @IBOutlet weak var slideViewConstraint: NSLayoutConstraint!
    var isShowSlide = false
    var slideMenu : SlideMenu?
    
    var wordDic : Dictionary<String, String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadConfigData()
        initNavigationBar()
        
        genre = realm.getGenre(self.genreId)
        //print(realm.getSpendsFromDate(start!, end:end!, genre:genre!))
        
        let diff = end!.timeIntervalSinceDate(start!)/(60 * 60 * 24)
        //print(diff)
        let w : CGFloat = 30.0
        let width = w * CGFloat(diff)
        //print("width : \(width)")
        let rect = CGRectMake(10, 0, width , self.view.frame.height - 200.0)
        
        //let rect = CGRectMake(10, 0, 200.0 , self.view.frame.height - 200.0)
        
        let scrollView = UIScrollView(frame:CGRectMake(0, 50, self.view.frame.width , self.view.frame.height - 150.0))
        //scrollView.contentSize = CGSizeMake(self.view.frame.width * 2 , self.view.frame.height - 200.0)
        
        scrollView.contentSize = CGSizeMake(width + 50.0 , self.view.frame.height - 200.0)
        scrollView.bounces = false
        self.view.addSubview(scrollView)
        
        barChartView = BarChartView(frame:rect)
        scrollView.addSubview(barChartView!)
        
        // slidemenu
        self.slideViewConstraint.constant -= 20.0
        slideMenu = NSBundle.mainBundle().loadNibNamed("SlideMenu", owner: self, options: nil).first as! SlideMenu
        slideView.addSubview(slideMenu!)
        slideView.layer.cornerRadius = 10
        slideMenu?.button.addTarget(self, action: #selector(CalDetailViewController.slide(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        slideMenu?.button.backgroundColor = CommonUtil.getSettingThemaColor()
        slideMenu!.layer.borderColor = UIColor.grayColor().CGColor
        slideMenu!.layer.borderWidth = 0.3
        slideMenu!.layer.cornerRadius = 10
        slideMenu!.layer.masksToBounds = true
        
        //slideMenu?.mailButton!.addTarget(self, action: #selector(CalDetailViewController.makeCSV), forControlEvents: UIControlEvents.TouchUpInside)
        slideMenu?.twitterButton!.addTarget(self, action: #selector(CalDetailViewController.onTwitter(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        slideMenu?.fbButton!.addTarget(self, action: #selector(CalDetailViewController.onFacebook(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        slideMenu?.lineButton!.addTarget(self, action: #selector(CalDetailViewController.onLine(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        slideMenu?.mailButton!.addTarget(self, action: #selector(CalDetailViewController.sendMailWithCSVImage), forControlEvents: UIControlEvents.TouchUpInside)
        slideMenu?.photoButton!.addTarget(self, action: #selector(CalDetailViewController.saveImage), forControlEvents: UIControlEvents.TouchUpInside)
    }

    func slide(sender:UIButton){
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
                                    self.slideViewConstraint.constant += 280.0
            }, completion: { finished in
                self.isShowSlide = true
                self.slideMenu?.button.setTitle("▶︎", forState: .Normal)
                print(self.slideMenu)
        } )
    }
    
    func hideSlide(){
        UIView.animateWithDuration(1.0,
                                   delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: {
                                    self.slideViewConstraint.constant -= 280.0
            }, completion: { finished in
                self.isShowSlide = false
                self.slideMenu?.button.setTitle("◀︎", forState: .Normal)
        } )
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
        titleLabel.text = self.wordDic!["DAY_BY_DAY"] //NSLocalizedString("MovieListViewController_navi_title", comment: "")
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.userInteractionEnabled = false //タッチを検出しない
        titleLabel.tag = 1
        titleLabel.sizeToFit()
        titleLabel.frame.size.height = (self.navigationController?.navigationBar.frame.height)! // 英語「g」の下が切れる対策
        self.navigationItem.titleView = titleLabel
        
        self.tabBarController?.tabBar.tintColor = CommonUtil.getSettingThemaColor()
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        
        // ナビゲーションバーのボタンが画面の戻りで下がってしまうことがあるので下地のビューを作ってframeを固定して配置する
        // 左ボタンを作成する
        myLeftButton = UIButton(type: .Custom)
        myLeftButton!.frame = CGRectMake(0,0,50,25)
        myLeftButton!.setTitle(self.wordDic!["BACK"], forState: .Normal)
        myLeftButton!.titleLabel!.font = UIFont(name: self.config.font,size: CGFloat(16))
        myLeftButton!.addTarget(self, action: #selector(DayViewController.back(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        let lView = UIView(frame: CGRectMake(0,0,50,25))
        lView.addSubview(myLeftButton!)
        
        // ナビゲーションバーの左に設置する.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: lView)
        
        // 右ボタンを作成する
        myRightButton = UIButton(type: .Custom)
        myRightButton!.frame = CGRectMake(0,0,25,25)
        let image = UIImage(named: "menuIcon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        myRightButton!.setImage(image, forState: .Normal)
        myRightButton!.addTarget(self, action: #selector(CalDetailViewController.slide(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        myRightButton!.tag = 1
        let rView = UIView(frame: CGRectMake(0,0,25,25))
        rView.addSubview(myRightButton!)
        
        // ナビゲーションバーの右に設置する.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rView)
    }
    
    // 前の画面に戻る
    func back(sender:UIBarButtonItem){
        self.navigationController?.popViewControllerAnimated(true)
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
        //initNavigationBar()
        //self.pieChartView.delegate = self
        //showChart()
        showVarChart()
        slideMenu?.button.backgroundColor = CommonUtil.getSettingThemaColor()
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
        headerData.append(genre!.name)
        
        var isFloat = false
        var dic = Dictionary<String,Float>()
        let saleList = realm.getSpendsFromDate(start!, end:end!, genre:genre!)
        
        for s in saleList {
            dic[formatter.stringFromDate(s.date!)] = s.price
            if (UtilManager.isFloatData(s.price)) {
                isFloat = true
            }
        }
        let keys = days.filter{ !dic.keys.contains($0) }
        keys.map{ dic[$0] = 0 }
        
        lineData.append(dic)
        
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
        //print("\(getNowDateTime()).csv")
        return csvStr
    }

    
    func showVarChart(){
        // Customization
        barChartView!.descriptionText = ""
        barChartView!.xAxis.labelPosition = .Bottom
        barChartView!.xAxis.setLabelsToSkip(0)
        barChartView!.leftAxis.axisMinValue = 0.0
        //barChartView!.leftAxis.axisMaxValue = 1000.0
        //barChartView!.leftAxis.axisMinimum = 0.0
        //barChartView!.leftAxis.axisMaximum = 1000.0
        barChartView!.rightAxis.enabled = false
        barChartView!.xAxis.drawGridLinesEnabled = false
        barChartView!.legend.enabled = false
        barChartView!.scaleYEnabled = false
        barChartView!.scaleXEnabled = false
        barChartView!.pinchZoomEnabled = false
        barChartView!.doubleTapToZoomEnabled = false
        barChartView!.highlighter = nil
        
        // Get and prepare the data
        let sales = DataGenerator.data()
        
        // Initialize an array to store chart data entries (values; y axis)
        var salesEntries = [ChartDataEntry]()
        
        // Initialize an array to store months (labels; x axis)
        var salesMonths = [String]()
        
        var i = 0
        /*
        for sale in sales {
            // Create single chart data entry and append it to the array
            let saleEntry = BarChartDataEntry(value: sale.value, xIndex: i)
            salesEntries.append(saleEntry)
            
            // Append the month to the array
            salesMonths.append(sale.month)
            
            i += 1
        }
        */
        
        var dataEntries: [ChartDataEntry] = []
        self.dataPoints = []
        self.values = []
        self.colors = []
        self.days = []
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        formatter.dateFormat = config.center_dateformat
        formatter.dateFormat =  "M/d"
        
        let diff = end!.timeIntervalSinceDate(start!)/(60 * 60 * 24)
        print(diff)
        for var i = 0; i < Int(diff); i = i + 1{
            let d = NSDate.init(timeInterval: Double(60*60*24*i), sinceDate: start!)
            //print(d)
            days.append(formatter.stringFromDate(d))
        }
        
        var dic = Dictionary<String,Spend>()
        let saleList = realm.getSpendsFromDate(start!, end:end!, genre:genre!)
        for s in saleList {
            dic[formatter.stringFromDate(s.date!)] = s
        }
        
        for d in days {
            if dic[d] != nil {
                let s = dic[d]
                let saleEntry = BarChartDataEntry(value: Double(s!.price), xIndex: i)
                dataEntries.append(saleEntry)
                colors.append(UIColor(hex: Int((s!.genre?.color)!)!, alpha: 1.0))
                self.values.append(Double(s!.price))
            }else{
                let saleEntry = BarChartDataEntry(value: 0.0, xIndex: i)
                dataEntries.append(saleEntry)
                colors.append(UIColor.clearColor())
                self.values.append(0.0)
            }
            i += 1
        }
        
        barChartView!.leftAxis.axisMaxValue = self.values.maxElement()!
        //print("max : \(self.values.maxElement())")
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Profit")
        chartDataSet.colors = colors
        let chartData = BarChartData(xVals: days, dataSets: [chartDataSet])
        
        // Create bar chart data set containing salesEntries
        //let chartDataSet = BarChartDataSet(yVals: salesEntries, label: "Profit")
        //chartDataSet.colors = ChartColorTemplates.joyful()
        
        // Create bar chart data with data set and array with values for x axis
        //let chartData = BarChartData(xVals: salesMonths, dataSets: [chartDataSet])
        
        // Set bar chart data to previously created data
        barChartView!.data = chartData
        
        // Animation
        if self.config.animation == "on" {
            barChartView!.animate(yAxisDuration: 1.5, easingOption: .EaseInOutQuart)
        }
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
        let image = UtilManager.clipView(self.barChartView, rect: CGRectInset(self.barChartView!.frame, -10.0, -10.0))
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

struct Sale {
    var month: String
    var value: Double
}

class DataGenerator {
    
    static var randomizedSale: Double {
        return Double(arc4random_uniform(10000) + 1) / 10
    }
    
    static func data() -> [Sale] {
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        var sales = [Sale]()
        
        for month in months {
            let sale = Sale(month: month, value: randomizedSale)
            sales.append(sale)
        }
        
        return sales
    }
}
