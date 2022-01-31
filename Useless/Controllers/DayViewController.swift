//
//  DayViewController.swift
//  Useless
//
//  Created by cano on 2016/03/21.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit
import Social
import Charts
import CNPPopupController
import RealmSwift
import AKPickerView_Swift
import MessageUI

class DayViewController: UIViewController, MFMailComposeViewControllerDelegate, CNPPopupControllerDelegate, AKPickerViewDataSource, AKPickerViewDelegate, ChartViewDelegate, keyboardButtonDelegate  {
    
    var popupController:CNPPopupController = CNPPopupController()
    
    @IBOutlet var pieChartView: PieChartView!
    
    //@IBOutlet var pieChartView: DayPieChartView!
    
    var popupViewController : InputViewController?
    var popupInputViewController : PopupInputViewController?
    
    var myLeftButton : UIButton?
    var myRightButton : UIButton?
    
    let realm = RealmController.getSharedRealmController()
    var genreList : Results<Genre>?
    var genreDic : Dictionary<Int,Genre> = Dictionary<Int,Genre>()  // 削除時に参照する辞書
    var config = Config()
    var picker : AKPickerView?
    var date : NSDate?
    var priceTextField: MKTextField?
    
    @IBOutlet var slideView: UIView!
    @IBOutlet var slideMenuConstraint: NSLayoutConstraint!
    var isShowSlide = false
    var slideMenu : SlideMenu?
    
    //var gList: [Genre] = []
    var gList: Array<Int64> = Array<Int64>()
    var dataPoints: [String] = []
    var values: [Double] = []
    var colors: [UIColor] = []
    
    var genreId : Int64 = 0
    var wordDic : Dictionary<String, String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loadGenreData()
        loadConfigData()
        initNavigationBar()
        
        let inputStory = UIStoryboard(name: "Input", bundle: nil)
        popupViewController = inputStory.instantiateViewControllerWithIdentifier("InputViewController") as? InputViewController
        popupInputViewController = inputStory.instantiateViewControllerWithIdentifier("PopupInputViewController") as? PopupInputViewController
        
        print(self.date)
        showChart()
        
        self.pieChartView.delegate = self
        
        slideMenu = NSBundle.mainBundle().loadNibNamed("SlideMenu", owner: self, options: nil).first as! SlideMenu
        slideView.addSubview(slideMenu!)
        
        // 下敷きのタップ
        //let socialViewTapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "socialViewTapped:")
        //slideView.addGestureRecognizer(socialViewTapGesture)
        slideView.layer.cornerRadius = 10
        
        slideMenu?.button.addTarget(self, action: #selector(DayViewController.test(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        slideMenu?.button.backgroundColor = CommonUtil.getSettingThemaColor()
        slideMenu!.layer.borderColor = UIColor.grayColor().CGColor
        slideMenu!.layer.borderWidth = 0.3
        slideMenu!.layer.cornerRadius = 10
        slideMenu!.layer.masksToBounds = true
        
        slideMenu?.twitterButton!.addTarget(self, action: #selector(DayViewController.onTwitter(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        slideMenu?.fbButton!.addTarget(self, action: #selector(DayViewController.onFacebook(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        slideMenu?.lineButton!.addTarget(self, action: #selector(DayViewController.onLine(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        slideMenu?.mailButton!.addTarget(self, action: #selector(DayViewController.sendMailWithImage), forControlEvents: UIControlEvents.TouchUpInside)
        slideMenu?.photoButton!.addTarget(self, action: #selector(DayViewController.saveImage), forControlEvents: UIControlEvents.TouchUpInside)
    }

    func socialViewTapped(sender: UITapGestureRecognizer){
        slideMenuConstraint.constant += 260.0
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
            delay: 0.2,
            //usingSpringWithDamping: 0.5, // スプリングの効果(0..1)
            //initialSpringVelocity: 0.5,  // バネの初速。(0..1)
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: {
            self.slideMenuConstraint.constant += 260.0
            }, completion: { finished in
                self.isShowSlide = true
                self.slideMenu?.button.setTitle("▶︎", forState: .Normal)
        } )
    }
    
    func hideSlide(){
        UIView.animateWithDuration(1.0,
            delay: 0.2,
            //usingSpringWithDamping: 0.5, // スプリングの効果(0..1)
            //initialSpringVelocity: 0.5,  // バネの初速。(0..1)
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: {
            self.slideMenuConstraint.constant -= 260.0
            }, completion: { finished in
                self.isShowSlide = false
                self.slideMenu?.button.setTitle("◀︎", forState: .Normal)
        } )
    }
    
    //Viewが表示される直前
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadConfigData()
        loadGenreData()
        initNavigationBar()
        showChart()
        self.pieChartView.delegate = self
        slideMenu?.button.backgroundColor = CommonUtil.getSettingThemaColor()
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight){
        print("selected-----")
        print(entry)
        print("entry.xIndex : \(entry.xIndex)   dataSetIndex : \(dataSetIndex)")
        print("genre!.id : \(gList[entry.xIndex])")
        print(dataPoints[entry.xIndex])
        print(values[entry.xIndex])
        //self.showPopupWithStyle(CNPPopupStyle.ActionSheet)
        self.showPopupUpdate(CNPPopupStyle.ActionSheet, genreId:gList[entry.xIndex])
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
    
    func loadConfigData(){
        self.config = realm.getConfig()
        //print(self.config)
        self.wordDic = UtilManager.getLangs(self.config.lang)
    }
    
    func showChart() {
        self.gList = Array<Int64>()
        self.dataPoints = []
        self.values = []
        self.colors = []
        
        let sList = self.realm.getSpendsFromDate(self.date!)
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
        pieChartDataSet.valueFont = UIFont(name: self.config.font, size: CGFloat(self.config.graph_font_size))!
        
        if self.config.animation == "on" {
            pieChartView.animate(xAxisDuration: 1.4, yAxisDuration: 1.4, easingOption: ChartEasingOption.EaseOutBack)
        }
        
        //let date = NSDate()
        // タイムゾーンを言語設定にあわせる
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        formatter.dateFormat = config.center_dateformat
        //formatter.dateFormat = "yyyy/MM/dd"
        let total = Float(values.reduce(0) { $0 + $1 })
        //print("\n\(CommonUtil.addFigure(self.config, value: total))")
        
        let dateStr = formatter.stringFromDate(date!)
        let totalStr = CommonUtil.addFigure(self.config, value: total)
        var diff = 0
        if self.config.center_dateformat == "YYY/MM/dd" || self.config.center_dateformat == "YYYY/M/d" {
            diff = dateStr.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) - (totalStr.characters.count)
            //diff = dateStr.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) - ( totalStr.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) + 0)
        }else{
            //diff = dateStr.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) - (totalStr.characters.count)
            diff = dateStr.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) - ( totalStr.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)) - 1
        }
        //print(dateStr.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        //print(totalStr.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        //print( diff )
        //let str:String = formatter.stringFromDate(date!) +  "\n\n\(CommonUtil.addFigure(self.config, value: total))"
        var diffStr = ""
        for _ in 0 ..< abs(diff)  {
            diffStr = diffStr + " "
        }
        var str = ""
        if diff > 0 {
            str = dateStr + "\n" + diffStr +  totalStr
        }else{
            str = diffStr + dateStr + "\n" + totalStr
        }
        
        pieChartView.drawCenterTextEnabled = true
        let attrText = NSMutableAttributedString(string: str)
        attrText.addAttributes([NSFontAttributeName:UIFont(name: self.config.font, size: CGFloat(self.config.center_font_size))!],range: NSMakeRange(0, str.characters.count))
        
        pieChartView.centerAttributedText = attrText
        
        //print(self.pieChartView.data?.xValsObjc)
        //print(self.pieChartView.marker)
        //self.pieChartView.drawSliceTextEnabled = false
        //self.pieChartView.extraLeftOffset = 100.0
        //print(self.pieChartView.legend.labelsObjc)
        //print(self.pieChartView.legend.self)
        //self.pieChartView.description.
        self.pieChartView.legend.enabled = false
    }
    
    func add(sender:UIButton){
        self.showPopupWithStyle(CNPPopupStyle.ActionSheet)
        priceTextField?.becomeFirstResponder()
    }
    
    // add
    func showPopupWithStyle(popupStyle: CNPPopupStyle) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraphStyle.alignment = NSTextAlignment.Center
        
        
        let button = CNPPopupButton.init(frame: Constants.buttonSize)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont(name: self.config.font, size: Constants.buttonFontSize)!
        button.setTitle(self.wordDic!["SAVE"], forState: UIControlState.Normal)
        
        button.backgroundColor = CommonUtil.getSettingThemaColor()
        button.layer.cornerRadius = 4;
        button.selectionHandler = { (button) -> Void in
            if self.priceTextField!.text == "" { return }
            
            self.popupController.dismissPopupControllerAnimated(true)
            //print(self.picker?.selectedItem)
            //print(self.genreDic[(self.picker?.selectedItem)!])
            //print(self.priceTextField!.text)
            
            let g = self.genreDic[(self.picker?.selectedItem)!]
            
            print(self.realm.getSpendsFromDate(self.date!, genre:g!))
            
            if self.realm.getSpendsFromDate(self.date!, genre:g!).count > 0 {
                self.realm.updateAddSpend(self.date!, genre: g!, price: Float(self.priceTextField!.text!)!)
            }else{
                self.realm.addSpend(self.date!, genre: g!, price: Float(self.priceTextField!.text!)!)
            }
            //print(self.realm.getEventsFromDate(self.date!))
            self.showChart()
        }
        
        var xibView = NSBundle.mainBundle().loadNibNamed("NumberKeyboard", owner: self, options: nil)
        let view = xibView[0] as! NumberKeyboard
        //keyboardView = view
        //キーボードの高さを調整 (オートレイアウトで勝手に216に高さが設定されてしまうのをリサイズする)
        view.autoresizingMask = UIViewAutoresizing.None
        view.delegate = self
        
        priceTextField = MKTextField(frame: Constants.textFieldSize)
        priceTextField!.floatingPlaceholderEnabled = true
        priceTextField!.cornerRadius = 1.0
        priceTextField!.placeholder = self.wordDic!["PRICE"]
        priceTextField!.layer.borderColor = CommonUtil.getSettingThemaColor().CGColor//UIColor.MKColor.Green.CGColor
        priceTextField!.rippleLayerColor = CommonUtil.getSettingThemaColor()//UIColor.MKColor.LightGreen
        priceTextField!.tintColor = CommonUtil.getSettingThemaColor()//UIColor.MKColor.LightGreen
        priceTextField?.inputView = view
        
        picker = AKPickerView(frame:Constants.pickerSize)
        picker!.delegate = self
        picker!.dataSource = self
        picker!.font = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.highlightedFont = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.pickerViewStyle = .Wheel
        picker!.maskDisabled = false
        picker!.reloadData()
        
        self.popupController = CNPPopupController(contents:[
            UIView(),
            //titleLabel, //lineOneLabel,
            //imageView,lineTwoLabel, 
            picker!, //customView, 
            UIView(),
            priceTextField!,
            UIView(),
            button, UIView()])
        self.popupController.theme = CNPPopupTheme.defaultTheme()
        self.popupController.theme.popupStyle = CNPPopupStyle.Centered
        //self.popupController.theme.maxPopupWidth = 260
        self.setPopupSize()
        self.popupController.delegate = self
        self.popupController.presentPopupControllerAnimated(true)
        print(self.popupController.theme.maxPopupWidth)
        //self.popupController.//layer.borderColor = UIColor.redColor().CGColor
        //targetView.layer.borderWidth = 2.0
    }
    
    func setPopupSize(){
        self.popupController.theme.maxPopupWidth = UtilManager.getPopUpWidth()
    }
    
    // Update
    func showPopupUpdate(popupStyle: CNPPopupStyle, genreId:Int64) {
        print("update-----")
        print(self.date)
        self.genreId = genreId
        let g = self.realm.getGenre(self.genreId)
        print(g)
        print(self.realm.getSpendsFromDate(self.date!))
        let s = self.realm.getSpendsFromDate(self.date!, genre:g!)[0]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraphStyle.alignment = NSTextAlignment.Center
        
        let button = CNPPopupButton.init(frame: Constants.buttonSize)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont(name: self.config.font, size: Constants.buttonFontSize)!
        button.setTitle(self.wordDic!["SAVE"], forState: UIControlState.Normal)
        
        button.backgroundColor = UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        button.backgroundColor = CommonUtil.getSettingThemaColor()
        button.layer.cornerRadius = 4;
        button.selectionHandler = { (button) -> Void in
            
            if self.priceTextField!.text == "" { return }
            
            self.popupController.dismissPopupControllerAnimated(true)
            //print(self.picker?.selectedItem)
            //print(self.priceTextField!.text)
            //let g = self.genreDic[(self.picker?.selectedItem)!]
            let g = self.realm.getGenre(self.genreId)
            //print(self.realm.getSpendsFromDate(self.date!, genre:g!))
            
            if self.realm.getSpendsFromDate(self.date!, genre:g!).count > 0 {
                self.realm.updateSpend(self.date!, genre: g!, price: Float(self.priceTextField!.text!)!)
            }else{
                self.realm.addSpend(self.date!, genre: g!, price: Float(self.priceTextField!.text!)!)
            }
            //print(self.realm.getEventsFromDate(self.date!))
            self.showChart()
            self.genreId = 0
        }
        
        // 削除ボタン
        let dbutton = CNPPopupButton.init(frame: Constants.buttonSize)
        dbutton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        dbutton.titleLabel?.font = UIFont(name: self.config.font, size: Constants.buttonFontSize)!
        dbutton.setTitle(self.wordDic!["DELETE"], forState: UIControlState.Normal)
        dbutton.backgroundColor = UIColor.darkGrayColor()
        //dbutton.backgroundColor = CommonUtil.getSettingThemaColor()
        dbutton.layer.cornerRadius = 4;
        dbutton.selectionHandler = { (button) -> Void in
            
            
            self.popupController.dismissPopupControllerAnimated(true)
            //print(self.picker?.selectedItem)
            //print(self.priceTextField!.text)
            //let g = self.genreDic[(self.picker?.selectedItem)!]
            let g = self.realm.getGenre(self.genreId)
            //print(self.realm.getSpendsFromDate(self.date!, genre:g!))
            
            if self.realm.getSpendsFromDate(self.date!, genre:g!).count > 0 {
                self.realm.deleteSpend(self.date!, genre: g!)
            }
            //print(self.realm.getEventsFromDate(self.date!))
            self.showChart()
            self.genreId = 0
        }
        
        var xibView = NSBundle.mainBundle().loadNibNamed("NumberKeyboard", owner: self, options: nil)
        let view = xibView[0] as! NumberKeyboard
        //keyboardView = view
        //キーボードの高さを調整 (オートレイアウトで勝手に216に高さが設定されてしまうのをリサイズする)
        view.autoresizingMask = UIViewAutoresizing.None
        view.delegate = self
        
        priceTextField = MKTextField(frame: Constants.textFieldSize)
        priceTextField!.floatingPlaceholderEnabled = true
        priceTextField!.cornerRadius = 1.0
        priceTextField!.placeholder = self.wordDic!["PRICE"]
        priceTextField!.layer.borderColor = CommonUtil.getSettingThemaColor().CGColor//UIColor.MKColor.Green.CGColor
        priceTextField!.rippleLayerColor = CommonUtil.getSettingThemaColor()//UIColor.MKColor.LightGreen
        priceTextField!.tintColor = CommonUtil.getSettingThemaColor()//UIColor.MKColor.LightGreen
        priceTextField?.inputView = view
        //priceTextField?.becomeFirstResponder()
        if (UtilManager.isFloatData(s.price)) {
            priceTextField!.text = "\(s.price)"
        }else{
            priceTextField!.text = "\(Int(s.price))"
        }
        picker = AKPickerView(frame:Constants.pickerSize)
        //picker.backgroundColor = UIColor.blueColor()
        picker!.delegate = self
        picker!.dataSource = self
        picker!.font = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.highlightedFont = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.pickerViewStyle = .Wheel
        picker!.maskDisabled = false
        picker!.reloadData()
        picker!.userInteractionEnabled = false
        //picker!.backgroundColor = UIColor.blueColor()
        //let index = self.fontSizeArray.indexOf(Int(self.config.graph_font_size))
        
        //let keys: Array = Array(genreDic.keys)
        //let values = Array(genreDic.values)
        
        //let index = (genreDic as NSDictionary).allKeysForObject(g!) as! Int
        let index = self.findKeyForValue(g!, dictionary: genreDic)
        picker!.selectItem(index, animated: true)
        
        self.popupController = CNPPopupController(contents:[ UIView(), picker!, UIView(), priceTextField!, UIView(), button, UIView(), dbutton, UIView()])
        self.popupController.theme = CNPPopupTheme.defaultTheme()
        self.popupController.theme.popupStyle = CNPPopupStyle.Centered
        self.setPopupSize()
        self.popupController.delegate = self
        self.popupController.presentPopupControllerAnimated(true)
    }
    
    
    func findKeyForValue(value: Genre, dictionary: [Int: Genre]) ->Int
    {
        for (key, val) in dictionary
        {
            //if (array.contains(value))
            if value == val
            {
                return key
            }
        }
        return 0
    }
    
    func onButton(sender:UIButton) {
        //print(sender)
        print(sender.tag)
        
        var stringToInsert = ""
        switch (sender.tag)
        {
        case 0...9:
            stringToInsert = "\(sender.tag)"
        case 10:
            if priceTextField!.text != "" {
                stringToInsert = "."
            }
        case 11:
            stringToInsert = "0"
        case 12:
            //削除キー
            priceTextField!.deleteBackward()
        case 13:
            //削除キー
            priceTextField!.deleteBackward()
        case 14:
            //Done
            if self.priceTextField!.text == "" { break }
            // edit
            if self.genreId > 0 {
                self.popupController.dismissPopupControllerAnimated(true)
                let g = self.realm.getGenre(self.genreId)
                if self.realm.getSpendsFromDate(self.date!, genre:g!).count > 0 {
                    self.realm.updateSpend(self.date!, genre: g!, price: Float(self.priceTextField!.text!)!)
                }else{
                    self.realm.addSpend(self.date!, genre: g!, price: Float(self.priceTextField!.text!)!)
                }
                self.showChart()
                self.genreId = 0
            }
            // add
            else{
                self.popupController.dismissPopupControllerAnimated(true)
                let g = self.genreDic[(self.picker?.selectedItem)!]
                if self.realm.getSpendsFromDate(self.date!, genre:g!).count > 0 {
                    self.realm.updateAddSpend(self.date!, genre: g!, price: Float(self.priceTextField!.text!)!)
                }else{
                    self.realm.addSpend(self.date!, genre: g!, price: Float(self.priceTextField!.text!)!)
                }
                self.showChart()
            }
            
        default:
            stringToInsert = ""
        }
        priceTextField!.text = priceTextField!.text! + stringToInsert
    }
    
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        return self.genreDic.count
    }
    
    func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String {
        return (genreDic[item]?.name)! as String
    }
    /*
    func pickerView(pickerView: AKPickerView, imageForItem item: Int) -> UIImage {
    return UIImage(named: self.titles[item])!
    }
    */
    // MARK: - AKPickerViewDelegate
    
    func pickerView(pickerView: AKPickerView, didSelectItem item: Int) {
        print("select \(genreDic[item]?.name)")
    }
    
    func pickerView(pickerView: AKPickerView, configureLabel label: UILabel, forItem item: Int) {
        label.textColor = UIColor.lightGrayColor()
        label.highlightedTextColor = UIColor.blackColor()
        let genre = genreDic[item]
        label.backgroundColor = UIColor(hex: Int((genre?.color)!)!, alpha: 1.0)
    }
    
    func pickerView(pickerView: AKPickerView, marginForItem item: Int) -> CGSize {
        return CGSizeMake(40, 20)
    }
    
    func blackTapGesture(sender: UITapGestureRecognizer){
        //print(sender)
        self.popupInputViewController!.view.removeFromSuperview()
        self.myRightButton?.enabled = true
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
        
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        formatter.dateFormat = self.config.center_dateformat
        titleLabel.text = formatter.stringFromDate(self.date!)
        //titleLabel.text = "DAY" //NSLocalizedString("MovieListViewController_navi_title", comment: "")
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.userInteractionEnabled = false //タッチを検出しない
        titleLabel.tag = 1
        titleLabel.sizeToFit()
        titleLabel.frame.size.height = (self.navigationController?.navigationBar.frame.height)! // 英語「g」の下が切れる対策
        self.navigationItem.titleView = titleLabel
        
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
        myRightButton!.frame = CGRectMake(0,0,50,25)
        myRightButton!.setTitle(self.wordDic!["ADD"], forState: .Normal)
        myRightButton!.titleLabel!.font = UIFont(name: self.config.font,size: CGFloat(16))
        //myRightButton.titleLabel!.font = UIFont(name: CommonUtil.DEFAULT_FONT_NAME_JP,size: CGFloat(30))
        myRightButton!.addTarget(self, action: #selector(DayViewController.add(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        myRightButton!.tag = 1
        let rView = UIView(frame: CGRectMake(0,0,50,25))
        rView.addSubview(myRightButton!)
        
        // ナビゲーションバーの右に設置する.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rView)
        
        self.tabBarController?.tabBar.tintColor = CommonUtil.getSettingThemaColor()
    }

    
    // 前の画面に戻る
    func back(sender:UIBarButtonItem){
        /*
        // Xボタン
        if sender.tag == 1 {
            // デリゲートが実装されていたら呼ぶ
            if (self.delegate?.respondsToSelector("didClose")) != nil {
                // 実装先のdidClose:メソッドを実行
                delegate?.didClose()
            }
        }
        */
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - CNPPopupController Delegate
    func popupController(controller: CNPPopupController, dismissWithButtonTitle title: NSString) {
        print("Dismissed with button title \(title)")
    }
    
    func popupControllerDidPresent(controller: CNPPopupController) {
        print("Popup controller presented")
    }
    
    /**
     print(self.pieChartView.circleBox)
     print(CGRectInset(self.pieChartView.circleBox, -10.0, -10.0))
     */
    
    func add1(sender:UIButton){
        //self.view.addSubview(grayView!)
        
        self.view.addSubview((popupInputViewController?.view)!)
        //let center = popupInputViewController!.view.center
        let center = CGPointMake(self.view.center.x, self.view.center.y - 100.0)
        //popupInputViewController!.view.center.y = self.view.center.y - 100.0
        
        let view = (popupInputViewController?.view)!
        view.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.0,0.0)
        view.center = center
        
        let blackTap = UITapGestureRecognizer(target: self, action: #selector(DayViewController.blackTapGesture(_:)))
        
        // アニメーションを開始
        UIView.animateWithDuration(
            // 1秒待って開始、3秒かけて最初はゆるやかに最後は一定の動きに
            0.0,
            delay: 0.2,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: {
                view.transform = CGAffineTransformIdentity
                view.center = center
                //self.view.addSubview(self.grayView!)
            }, completion: {
                // 完了時の処理
                (finished: Bool) in
                // 背景を黒に
                //self.viewA?.backgroundColor = UIColor.blackColor()
                self.popupInputViewController?.grayView!.addGestureRecognizer(blackTap)
                self.myRightButton?.enabled = false
        })
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
    func sendMailWithImage() {
        
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        
        let nameBase = UtilManager.getNowDateTime()
        //let fileName = "\(nameBase).csv"
        let imageName = "\(nameBase).png"
        let image = self.getChartImage()
        if let imageData = UIImagePNGRepresentation(image) {
            mailViewController.addAttachmentData(imageData, mimeType: "image/png", fileName: imageName)
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
