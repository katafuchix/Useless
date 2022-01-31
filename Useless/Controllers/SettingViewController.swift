//
//  SettingViewController.swift
//  Useless
//
//  Created by cano on 2016/02/27.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit
import CNPPopupController
import AKPickerView_Swift
import RealmSwift
import RAMAnimatedTabBarController

class SettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate, AKPickerViewDataSource, AKPickerViewDelegate, CNPPopupControllerDelegate, SwiftHUEColorPickerDelegate,
    fontPickerDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    let kTitleKey: String = "title"
    let kViewControllerKey: String = "viewController"
    let kCellIdentifier = "CellIdentifier"
    
    //var menuList: Array<Dictionary<String, AnyObject>> = Array<Dictionary<String, AnyObject>>()
    
    // array of fruit list
    var fruitList: [String] = Array()
    
    // array of fruit list that converted into Group (i.e. section)
    var fruitListGrouped = NSDictionary() as! [String : [String]]
    
    // array of section titles
    var sectionTitleList = [String]()
    
    var popupController:CNPPopupController = CNPPopupController()
    
    var picker : AKPickerView?
    
    let realm = RealmController.getSharedRealmController()
    var genreList : Results<Genre>?
    var genreDic : Dictionary<Int,Genre> = Dictionary<Int,Genre>()  // 削除時に参照する辞書
    
    let pData = PublicDatas.getPublicDatas()
    var colorView: UIView?
    
    var sections: Array<String> = Array<String>()
    var menuList: Array<Array<String>> = Array<Array<String>>()
    
    var colorPicker: ColorPicker?
    var huePicker: HuePicker?
    
    let fm = FontManager()
    var config : Config = Config()
    var langDic                             = Dictionary<Int,String>()
    var langArray : Array<String>           = Array<String>()
    var formatArray : Array<String>         = Array<String>()
    var weekdayArray : Array<String>        = Array<String>()
    var centerFormatArray : Array<String>   = Array<String>()
    var fontSizeArray : Array<Int>          = Array<Int>()
    
    var fontNameArray : Array<String>       = Array<String>()
    var fontValArray : Array<String>        = Array<String>()
    var currencySymbolArray : Array<String> = Array<String>()
    
    var encodingArray : Array<String>       = Array<String>()
    var imageSizeArray : Array<String>       = Array<String>()
    var animationArray : Array<String>       = Array<String>()
    
    var fontPickerVC : FontPickerViewController?
    
    var blackOutView : UIView?
    
    var wordDic : Dictionary<String, String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        //initNavigationBar()
        loadGenreData()
        loadConfigData()
        
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.scrollEnabled = false
        tableView.bounces = false
        
        self.tabBarController?.delegate = self
        
        initNavigationBar()
    }
    
    func tabBarController(tabBarController: UITabBarController,
                          didSelectViewController viewController: UIViewController){
        //print("didselect")
        self.fontPickerVC?.dismissViewControllerAnimated(true, completion: nil)
        blackOutView?.removeFromSuperview()
    }
    
    //Viewが表示される直前
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //reloadTable()
        self.loadConfigData()
        self.tableView.reloadData()
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
        print(self.config)
        self.langArray = Constants.langs
        self.formatArray = Constants.dateformats
        self.weekdayArray = Constants.weekday_langs
        self.centerFormatArray = Constants.center_dateformats
        self.fontSizeArray = Constants.font_size
        if self.config.lang == "jp" {
            self.fontNameArray = fm.font_names_jp
        }else{
            self.fontNameArray = fm.font_names
        }
        self.fontValArray = fm.font_values
        //self.fontNameArray = Constants.font_names
        //self.fontValArray = Constants.font_values
        self.currencySymbolArray = Constants.currency_symbols
        self.encodingArray = Constants.encodings
        self.imageSizeArray = Constants.image_sizes
        self.animationArray = Constants.animation
        
        self.wordDic = UtilManager.getLangs(self.config.lang)
        self.loadList()
    }
    
    func loadList(){
        sections = [String]()
        menuList = [[String]]()
        
        // セクションの見出し
        sections = [self.wordDic!["GENERAL"]!, self.wordDic!["GENRE"]!, self.wordDic!["GRAPH"]!,]
        // セルに表示するデータ
        //menuList.append(["テーマカラー", "言語", "日付フォーマット", "曜日表示", "フォント", "タイトルフォントサイズ", "通貨単位"])
        menuList.append([
                            self.wordDic!["THEME_COLOR"]!,
                            self.wordDic!["LANGUAGE"]!,
                            self.wordDic!["DATE_FORMAT"]!,
                            self.wordDic!["WEEKDAY"]!,
                            self.wordDic!["FONT"]!,
                            self.wordDic!["TITLE_FONT_SIZE"]!,
                            self.wordDic!["CURRENCY_SYMBOL"]!
                        ])
        
        menuList.append([self.wordDic!["GENRE_LIST"]!,])
        
        //menuList.append(["日時フォーマット", "フォントサイズ", "フォントサイズ", "投稿画像サイズ", "CSV出力文字コード", "アニメーション"])
        menuList.append([
                            self.wordDic!["GRAPH_DATE_FORMAT"]!,
                            self.wordDic!["GRAPH_CENTER_FOMT_SIZE"]!,
                            self.wordDic!["GRAPH_ITEM_FOMT_SIZE"]!,
                            self.wordDic!["GRAPH_IMAGE_POST_SIZE"]!,
                            self.wordDic!["GRAPH_CSV_ENCODING"]!,
                            self.wordDic!["GRAPH_ANIMATION"]!
                        ])
    }
    
    func reloadTable(){
        self.loadConfigData()
        self.tableView.reloadData()
        self.initNavigationBar()
    }
    
    // return the number of sections
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //return self.fruitListGrouped.count
        return sections.count
    }
    
    // return the number of rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuList[section].count
    }
    
    // return cell for given row
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // collect reusable cell
        //let cell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath) as UITableViewCell
        let cell = tableView.dequeueReusableCellWithIdentifier("myCell")! as UITableViewCell
        
        // Configure the cell...
        let cellTitle = menuList[indexPath.section][indexPath.row]
        //print(cellTitle)
        cell.textLabel?.text = cellTitle
        cell.textLabel?.font = UIFont(name: self.config.font, size: 15.0)
        
        cell.detailTextLabel?.font = UIFont(name: self.config.font, size: 15.0)
        cell.detailTextLabel?.backgroundColor = UIColor.whiteColor()
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.detailTextLabel!.text = "        "
                cell.detailTextLabel?.backgroundColor = CommonUtil.getSettingThemaColor()
            case 1:
                cell.detailTextLabel!.text = self.config.lang
            case 2:
                cell.detailTextLabel!.text = self.config.dateformat
            case 3:
                cell.detailTextLabel!.text = self.config.weekday_lang
            case 4:
                //cell.detailTextLabel!.text = self.config.font
                if let index = self.fontValArray.indexOf(self.config.font) {
                    cell.detailTextLabel!.text = self.fontNameArray[index]
                    cell.detailTextLabel?.font = UIFont(name: self.config.font, size: 16)
                }else{
                    cell.detailTextLabel!.text = ""
                }
            case 5:
                cell.detailTextLabel!.text = "\(self.config.title_font_size)"
            case 6:
                cell.detailTextLabel!.text = self.config.currency_symbol
            default:
                break // do nothing
            }
        case 1:
            cell.detailTextLabel!.text = ""
        case 2:
            switch indexPath.row {
            case 0:
                cell.detailTextLabel!.text = self.config.center_dateformat
            case 1:
                cell.detailTextLabel!.text = "\(self.config.center_font_size)"
            case 2:
                cell.detailTextLabel!.text = "\(self.config.graph_font_size)"
            case 3:
                cell.detailTextLabel!.text = self.config.image_size
            case 4:
                cell.detailTextLabel!.text = self.config.character_encoding
            case 5:
                cell.detailTextLabel!.text = self.config.animation
            default:
                break // do nothing
            }
        default:
            break // do nothing
        }
        
        // return cell
        return cell
    }
    
    func tableView(tableView: UITableView,
                     viewForHeaderInSection section: Int) -> UIView?{
        let sectionLabel = UILabel()
        
        if section == 0 {
            sectionLabel.frame = CGRectMake(10, 30, 320, 20)
        }else{
            sectionLabel.frame = CGRectMake(10, 10, 320, 20)
        }
        sectionLabel.font = UIFont(name: self.config.font, size: 17.0)
        //sectionLabel.backgroundColor = UIColor.blueColor()
        sectionLabel.text = sections[section]
        //print(sections[section])
        let headerView = UIView()
        headerView.addSubview(sectionLabel)
        return headerView
    }
    
    // return section header title
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //return self.sectionTitleList[section]
        return sections[section]
    }
    
    //選択された時
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // もっと上位でイベント処理するので、ここではイベント拾えない
        print("\(indexPath.section)   \(indexPath.row)行目を選択")
        //self.showPopupWithStyle(CNPPopupStyle.ActionSheet)
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                self.showPopupWithStyle(CNPPopupStyle.ActionSheet)
            case 1:
                self.showPopupLang(CNPPopupStyle.ActionSheet)
            case 2:
                self.showPopupDateFormat(CNPPopupStyle.ActionSheet)
            case 3:
                self.showPopupWeekdayFormat(CNPPopupStyle.ActionSheet)
            case 4:
                //self.showPopupFont(CNPPopupStyle.ActionSheet)
                self.showFontPicker()
            case 5:
                self.showPopupTitleFontSize(CNPPopupStyle.ActionSheet)
            case 6:
                self.showPopupCurrencySymbol(CNPPopupStyle.ActionSheet)
            default:
                break // do nothing
            }
        case 1:
            switch indexPath.row {
            case 0:
                let story = UIStoryboard(name: "Setting", bundle: nil)
                let genreVC = story.instantiateViewControllerWithIdentifier("GenreViewController") as! GenreViewController
                self.navigationController?.pushViewController(genreVC, animated: true)
                //case 1:
            //ret = array2.count
            default:
                break // do nothing
            }
        case 2:
            switch indexPath.row {
            case 0:
                self.showPopupCenterDateFormat(CNPPopupStyle.ActionSheet)
            case 1:
                self.showPopupCenterFontSize(CNPPopupStyle.ActionSheet)
            case 2:
                self.showPopupGraphFontSize(CNPPopupStyle.ActionSheet)
            case 3:
                self.showPopupImageSize(CNPPopupStyle.ActionSheet)
            case 4:
                self.showPopupCharacterEncoding(CNPPopupStyle.ActionSheet)
            case 5:
                self.showPopupAnimation(CNPPopupStyle.ActionSheet)
            default:
                break // do nothing
            }
        default:
            break // do nothing
        }
    }
    
    func showPopupLang(popupStyle: CNPPopupStyle) {
        
        let button = CNPPopupButton.init(frame: Constants.buttonSize)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont(name: self.config.font, size: Constants.buttonFontSize)!
        button.setTitle(self.wordDic!["SAVE"], forState: UIControlState.Normal)
        button.backgroundColor = UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        button.backgroundColor = CommonUtil.getSettingThemaColor()
        button.layer.cornerRadius = 4;
        button.selectionHandler = { (button) -> Void in
            self.popupController.dismissPopupControllerAnimated(true)
            //print(self.picker!.selectedItem)
            //print(self.langArray[self.picker!.selectedItem])
            let lang = self.langArray[self.picker!.selectedItem]
            self.realm.updateConfigLang(lang)
            
            self.loadConfigData()
            self.initNavigationBar()
            
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
            rm.setSelectIndex(from: 2, to: 2)
            self.reloadTable()
        }
        
        picker = AKPickerView(frame:Constants.pickerSize)
        picker!.delegate = self
        picker!.dataSource = self
        picker!.font = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.highlightedFont = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.pickerViewStyle = .Wheel
        picker!.maskDisabled = false
        picker!.reloadData()
        picker!.tag = 1
        
        if let index = self.langArray.indexOf(self.config.lang) {
            picker!.selectItem(index, animated: true)
        }
        
        self.popupController = CNPPopupController(contents:[UIView(),picker!,UIView(),UIView(),button, UIView()])
        self.popupController.theme = CNPPopupTheme.defaultTheme()
        self.popupController.theme.popupStyle = CNPPopupStyle.Centered
        self.setPopupSize()
        self.popupController.delegate = self
        self.popupController.presentPopupControllerAnimated(true)
    }
    
    func showPopupDateFormat(popupStyle: CNPPopupStyle) {
        let button = CNPPopupButton.init(frame: Constants.buttonSize)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont(name: self.config.font, size: Constants.buttonFontSize)!
        button.setTitle(self.wordDic!["SAVE"], forState: UIControlState.Normal)
        button.backgroundColor = UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        button.backgroundColor = CommonUtil.getSettingThemaColor()
        button.layer.cornerRadius = 4;
        button.selectionHandler = { (button) -> Void in
            self.popupController.dismissPopupControllerAnimated(true)
            let format = self.formatArray[self.picker!.selectedItem]
            self.realm.updateConfigDateFormat(format)
            self.reloadTable()
        }
        
        picker = AKPickerView(frame:Constants.pickerSize)
        picker!.delegate = self
        picker!.dataSource = self
        picker!.font = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.highlightedFont = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.pickerViewStyle = .Wheel
        picker!.maskDisabled = false
        picker!.reloadData()
        picker!.tag = 2
        
        if let index = self.formatArray.indexOf(self.config.dateformat) {
            picker!.selectItem(index, animated: true)
        }
        
        self.popupController = CNPPopupController(contents:[UIView(),picker!,UIView(),UIView(),button, UIView()])
        self.popupController.theme = CNPPopupTheme.defaultTheme()
        self.popupController.theme.popupStyle = CNPPopupStyle.Centered
        self.setPopupSize()
        self.popupController.delegate = self
        self.popupController.presentPopupControllerAnimated(true)
    }
    
    func showPopupWeekdayFormat(popupStyle: CNPPopupStyle) {
        let button = CNPPopupButton.init(frame: Constants.buttonSize)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont(name: self.config.font, size: Constants.buttonFontSize)!
        button.setTitle(self.wordDic!["SAVE"], forState: UIControlState.Normal)
        button.backgroundColor = UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        button.backgroundColor = CommonUtil.getSettingThemaColor()
        button.layer.cornerRadius = 4;
        button.selectionHandler = { (button) -> Void in
            self.popupController.dismissPopupControllerAnimated(true)
            let format = self.weekdayArray[self.picker!.selectedItem]
            self.realm.updateConfigWeekdayFormat(format)
            self.reloadTable()
        }
        
        picker = AKPickerView(frame:Constants.pickerSize)
        picker!.delegate = self
        picker!.dataSource = self
        picker!.font = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.highlightedFont = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.pickerViewStyle = .Wheel
        picker!.maskDisabled = false
        picker!.reloadData()
        picker!.tag = 3
        
        if let index = self.weekdayArray.indexOf(self.config.weekday_lang) {
            picker!.selectItem(index, animated: true)
        }
        
        self.popupController = CNPPopupController(contents:[UIView(),picker!,UIView(),UIView(),button, UIView()])
        self.popupController.theme = CNPPopupTheme.defaultTheme()
        self.popupController.theme.popupStyle = CNPPopupStyle.Centered
        self.setPopupSize()
        self.popupController.delegate = self
        self.popupController.presentPopupControllerAnimated(true)
    }
    
    // font
    func showPopupFont(popupStyle: CNPPopupStyle) {
        let button = CNPPopupButton.init(frame: Constants.buttonSize)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont(name: self.config.font, size: Constants.buttonFontSize)!
        button.setTitle(self.wordDic!["SAVE"], forState: UIControlState.Normal)
        button.backgroundColor = UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        button.backgroundColor = CommonUtil.getSettingThemaColor()
        button.layer.cornerRadius = 4;
        button.selectionHandler = { (button) -> Void in
            self.popupController.dismissPopupControllerAnimated(true)
            let format = self.fontValArray[self.picker!.selectedItem]
            self.realm.updateConfigFont(format)
            self.reloadTable()
        }
        
        picker = AKPickerView(frame:CGRectMake(0, 0, 240, 50))
        picker!.delegate = self
        picker!.dataSource = self
        picker!.font = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.highlightedFont = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.pickerViewStyle = .Wheel
        picker!.maskDisabled = false
        picker!.reloadData()
        picker!.tag = 4
        
        if let index = self.fontValArray.indexOf(self.config.font){
            picker!.selectItem(index, animated: true)
        }
        
        self.popupController = CNPPopupController(contents:[UIView(),picker!,UIView(),UIView(),button, UIView()])
        self.popupController.theme = CNPPopupTheme.defaultTheme()
        self.popupController.theme.popupStyle = CNPPopupStyle.Centered
        self.setPopupSize()
        self.popupController.delegate = self
        self.popupController.presentPopupControllerAnimated(true)
    }
    
    // font
    func didSelectFont(index:Int){
        blackOutView?.removeFromSuperview()
        let font = self.fontValArray[index]
        self.realm.updateConfigFont(font)
        self.reloadTable()
    }
    
    func didClose() {
        blackOutView?.removeFromSuperview()
    }
    
    // タイトルフォントサイズ
    func showPopupTitleFontSize(popupStyle: CNPPopupStyle) {
        let button = CNPPopupButton.init(frame: Constants.buttonSize)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont(name: self.config.font, size: Constants.buttonFontSize)!
        button.setTitle(self.wordDic!["SAVE"], forState: UIControlState.Normal)
        button.backgroundColor = UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        button.backgroundColor = CommonUtil.getSettingThemaColor()
        button.layer.cornerRadius = 4;
        button.selectionHandler = { (button) -> Void in
            self.popupController.dismissPopupControllerAnimated(true)
            let size = self.fontSizeArray[self.picker!.selectedItem]
            self.realm.updateConfigTitleFontSize(size)
            self.reloadTable()
        }
        
        picker = AKPickerView(frame:Constants.pickerSize)
        picker!.delegate = self
        picker!.dataSource = self
        picker!.font = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.highlightedFont = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.pickerViewStyle = .Wheel
        picker!.maskDisabled = false
        picker!.reloadData()
        picker!.tag = 5
        
        if let index = self.fontSizeArray.indexOf(Int(self.config.title_font_size)) {
            picker!.selectItem(index, animated: true)
        }
        
        self.popupController = CNPPopupController(contents:[UIView(),picker!,UIView(),UIView(),button, UIView()])
        self.popupController.theme = CNPPopupTheme.defaultTheme()
        self.popupController.theme.popupStyle = CNPPopupStyle.Centered
        self.setPopupSize()
        self.popupController.delegate = self
        self.popupController.presentPopupControllerAnimated(true)
    }
    
    // currency_symbol
    func showPopupCurrencySymbol(popupStyle: CNPPopupStyle) {
        let button = CNPPopupButton.init(frame: Constants.buttonSize)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont(name: self.config.font, size: Constants.buttonFontSize)!
        button.setTitle(self.wordDic!["SAVE"], forState: UIControlState.Normal)
        button.backgroundColor = UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        button.backgroundColor = CommonUtil.getSettingThemaColor()
        button.layer.cornerRadius = 4;
        button.selectionHandler = { (button) -> Void in
            self.popupController.dismissPopupControllerAnimated(true)
            let format = self.currencySymbolArray[self.picker!.selectedItem]
            self.realm.updateConfigCurrencySymbol(format)
            self.reloadTable()
        }
        
        picker = AKPickerView(frame:Constants.pickerSize)
        picker!.delegate = self
        picker!.dataSource = self
        picker!.font = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.highlightedFont = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.pickerViewStyle = .Wheel
        picker!.maskDisabled = false
        picker!.reloadData()
        picker!.tag = 6
        
        if let index = self.currencySymbolArray.indexOf(self.config.currency_symbol) {
            picker!.selectItem(index, animated: true)
        }
        
        self.popupController = CNPPopupController(contents:[UIView(),picker!,UIView(),UIView(),button, UIView()])
        self.popupController.theme = CNPPopupTheme.defaultTheme()
        self.popupController.theme.popupStyle = CNPPopupStyle.Centered
        self.setPopupSize()
        self.popupController.delegate = self
        self.popupController.presentPopupControllerAnimated(true)
    }
    
    // グラフ中心日時フォーマット
    func showPopupCenterDateFormat(popupStyle: CNPPopupStyle) {
        let button = CNPPopupButton.init(frame: Constants.buttonSize)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont(name: self.config.font, size: Constants.buttonFontSize)!
        button.setTitle(self.wordDic!["SAVE"], forState: UIControlState.Normal)
        button.backgroundColor = UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        button.backgroundColor = CommonUtil.getSettingThemaColor()
        button.layer.cornerRadius = 4;
        button.selectionHandler = { (button) -> Void in
            self.popupController.dismissPopupControllerAnimated(true)
            let format = self.centerFormatArray[self.picker!.selectedItem]
            self.realm.updateConfigCenterDateFormat(format)
            self.reloadTable()
        }
        
        picker = AKPickerView(frame:Constants.pickerSize)
        picker!.delegate = self
        picker!.dataSource = self
        picker!.font = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.highlightedFont = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.pickerViewStyle = .Wheel
        picker!.maskDisabled = false
        picker!.reloadData()
        picker!.tag = 30
        
        if let index = self.centerFormatArray.indexOf(self.config.center_dateformat) {
            picker!.selectItem(index, animated: true)
        }
        
        self.popupController = CNPPopupController(contents:[UIView(),picker!,UIView(),UIView(),button, UIView()])
        self.popupController.theme = CNPPopupTheme.defaultTheme()
        self.popupController.theme.popupStyle = CNPPopupStyle.Centered
        self.setPopupSize()
        self.popupController.delegate = self
        self.popupController.presentPopupControllerAnimated(true)
    }
    
    // グラフ中心日時フォントサイズ
    func showPopupCenterFontSize(popupStyle: CNPPopupStyle) {
        let button = CNPPopupButton.init(frame: Constants.buttonSize)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont(name: self.config.font, size: Constants.buttonFontSize)!
        button.setTitle(self.wordDic!["SAVE"], forState: UIControlState.Normal)
        button.backgroundColor = UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        button.backgroundColor = CommonUtil.getSettingThemaColor()
        button.layer.cornerRadius = 4;
        button.selectionHandler = { (button) -> Void in
            self.popupController.dismissPopupControllerAnimated(true)
            let size = self.fontSizeArray[self.picker!.selectedItem]
            self.realm.updateConfigCenterFontSize(size)
            self.reloadTable()
        }
        
        picker = AKPickerView(frame:Constants.pickerSize)
        picker!.delegate = self
        picker!.dataSource = self
        picker!.font = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.highlightedFont = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.pickerViewStyle = .Wheel
        picker!.maskDisabled = false
        picker!.reloadData()
        picker!.tag = 31
        
        if let index = self.fontSizeArray.indexOf(Int(self.config.center_font_size)) {
            picker!.selectItem(index, animated: true)
        }
        
        self.popupController = CNPPopupController(contents:[UIView(),picker!,UIView(),UIView(),button, UIView()])
        self.popupController.theme = CNPPopupTheme.defaultTheme()
        self.popupController.theme.popupStyle = CNPPopupStyle.Centered
        self.setPopupSize()
        self.popupController.delegate = self
        self.popupController.presentPopupControllerAnimated(true)
    }
    
    // グラフ項目フォントサイズ
    func showPopupGraphFontSize(popupStyle: CNPPopupStyle) {
        let button = CNPPopupButton.init(frame: Constants.buttonSize)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont(name: self.config.font, size: Constants.buttonFontSize)!
        button.setTitle(self.wordDic!["SAVE"], forState: UIControlState.Normal)
        button.backgroundColor = UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        button.backgroundColor = CommonUtil.getSettingThemaColor()
        button.layer.cornerRadius = 4;
        button.selectionHandler = { (button) -> Void in
            self.popupController.dismissPopupControllerAnimated(true)
            let size = self.fontSizeArray[self.picker!.selectedItem]
            self.realm.updateConfigGraphFontSize(size)
            self.reloadTable()
        }
        
        picker = AKPickerView(frame:Constants.pickerSize)
        picker!.delegate = self
        picker!.dataSource = self
        picker!.font = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.highlightedFont = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.pickerViewStyle = .Wheel
        picker!.maskDisabled = false
        picker!.reloadData()
        picker!.tag = 32
        
        if let index = self.fontSizeArray.indexOf(Int(self.config.graph_font_size)) {
            picker!.selectItem(index, animated: true)
        }
        
        self.popupController = CNPPopupController(contents:[UIView(),picker!,UIView(),UIView(),button, UIView()])
        self.popupController.theme = CNPPopupTheme.defaultTheme()
        self.popupController.theme.popupStyle = CNPPopupStyle.Centered
        self.setPopupSize()
        self.popupController.delegate = self
        self.popupController.presentPopupControllerAnimated(true)
    }
    
    // image size
    func showPopupImageSize(popupStyle: CNPPopupStyle) {
        let button = CNPPopupButton.init(frame: Constants.buttonSize)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont(name: self.config.font, size: Constants.buttonFontSize)!
        button.setTitle(self.wordDic!["SAVE"], forState: UIControlState.Normal)
        button.backgroundColor = UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        button.backgroundColor = CommonUtil.getSettingThemaColor()
        button.layer.cornerRadius = 4;
        button.selectionHandler = { (button) -> Void in
            self.popupController.dismissPopupControllerAnimated(true)
            let size = self.imageSizeArray[self.picker!.selectedItem]
            self.realm.updateConfigImageSize(size)
            self.reloadTable()
        }
        
        picker = AKPickerView(frame:Constants.pickerSize)
        picker!.delegate = self
        picker!.dataSource = self
        picker!.font = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.highlightedFont = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.pickerViewStyle = .Wheel
        picker!.maskDisabled = false
        picker!.reloadData()
        picker!.tag = 33
        
        if let index = self.imageSizeArray.indexOf(self.config.image_size) {
            picker!.selectItem(index, animated: true)
        }
        
        self.popupController = CNPPopupController(contents:[UIView(),picker!,UIView(),UIView(),button, UIView()])
        self.popupController.theme = CNPPopupTheme.defaultTheme()
        self.popupController.theme.popupStyle = CNPPopupStyle.Centered
        self.setPopupSize()
        self.popupController.delegate = self
        self.popupController.presentPopupControllerAnimated(true)
    }
    
    // 文字エンコーディング
    func showPopupCharacterEncoding(popupStyle: CNPPopupStyle) {
        let button = CNPPopupButton.init(frame: Constants.buttonSize)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont(name: self.config.font, size: Constants.buttonFontSize)!
        button.setTitle(self.wordDic!["SAVE"], forState: UIControlState.Normal)
        button.backgroundColor = UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        button.backgroundColor = CommonUtil.getSettingThemaColor()
        button.layer.cornerRadius = 4;
        button.selectionHandler = { (button) -> Void in
            self.popupController.dismissPopupControllerAnimated(true)
            let chara = self.encodingArray[self.picker!.selectedItem]
            self.realm.updateConfigCharacterEncoding(chara)
            self.reloadTable()
        }
        
        picker = AKPickerView(frame:Constants.pickerSize)
        picker!.delegate = self
        picker!.dataSource = self
        picker!.font = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.highlightedFont = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.pickerViewStyle = .Wheel
        picker!.maskDisabled = false
        picker!.reloadData()
        picker!.tag = 34
        
        if let index = self.encodingArray.indexOf(self.config.character_encoding) {
            picker!.selectItem(index, animated: true)
        }
        
        self.popupController = CNPPopupController(contents:[UIView(),picker!,UIView(),UIView(),button, UIView()])
        self.popupController.theme = CNPPopupTheme.defaultTheme()
        self.popupController.theme.popupStyle = CNPPopupStyle.Centered
        self.setPopupSize()
        self.popupController.delegate = self
        self.popupController.presentPopupControllerAnimated(true)
    }
    
    // animation
    func showPopupAnimation(popupStyle: CNPPopupStyle) {
        let button = CNPPopupButton.init(frame: Constants.buttonSize)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont(name: self.config.font, size: Constants.buttonFontSize)!
        button.setTitle(self.wordDic!["SAVE"], forState: UIControlState.Normal)
        button.backgroundColor = UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        button.backgroundColor = CommonUtil.getSettingThemaColor()
        button.layer.cornerRadius = 4;
        button.selectionHandler = { (button) -> Void in
            self.popupController.dismissPopupControllerAnimated(true)
            let animation = self.animationArray[self.picker!.selectedItem]
            self.realm.updateConfigAnimation(animation)
            self.reloadTable()
        }
        
        picker = AKPickerView(frame:Constants.pickerSize)
        picker!.delegate = self
        picker!.dataSource = self
        picker!.font = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.highlightedFont = UIFont(name: self.config.font, size: Constants.pickerFontSize)!
        picker!.pickerViewStyle = .Wheel
        picker!.maskDisabled = false
        picker!.reloadData()
        picker!.tag = 35
        
        if let index = self.animationArray.indexOf(self.config.animation) {
            picker!.selectItem(index, animated: true)
        }
        
        self.popupController = CNPPopupController(contents:[UIView(),picker!,UIView(),UIView(),button, UIView()])
        self.popupController.theme = CNPPopupTheme.defaultTheme()
        self.popupController.theme.popupStyle = CNPPopupStyle.Centered
        self.setPopupSize()
        self.popupController.delegate = self
        self.popupController.presentPopupControllerAnimated(true)
    }
    
    // テーマカラー
    func showPopupWithStyle(popupStyle: CNPPopupStyle) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraphStyle.alignment = NSTextAlignment.Center
        
        let button = CNPPopupButton.init(frame: Constants.buttonSize)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont(name: self.config.font, size: Constants.buttonFontSize)!
        button.titleLabel?.font = UIFont(name: self.config.font, size: Constants.buttonFontSize)!
        button.setTitle(self.wordDic!["SAVE"], forState: UIControlState.Normal)
        
        button.backgroundColor = UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        button.backgroundColor = CommonUtil.getSettingThemaColor()
        button.layer.cornerRadius = 4;
        button.selectionHandler = { (button) -> Void in
            self.popupController.dismissPopupControllerAnimated(true)
            print("Block for button: \(button.titleLabel?.text)")
            print(self.colorView!.backgroundColor)
            print(UIColor.toInt32(self.colorView!.backgroundColor!))
            self.pData.setData(String(UIColor.toInt32(self.colorView!.backgroundColor!)), key: "themaColor")
            CommonUtil.setThemaColor(String(UIColor.toInt32(self.colorView!.backgroundColor!)))
            UtilManager.setNaviThemaColor()
            self.reloadTable()
            
            self.tabBarController?.tabBar.tintColor = CommonUtil.getSettingThemaColor()
            let rm = self.tabBarController as! RAMAnimatedTabBarController
            let items = self.tabBarController?.tabBar.items as? [RAMAnimatedTabBarItem]
            //print(items)
            for item in items! {
                //print(item)
                item.animation.textSelectedColor = CommonUtil.getSettingThemaColor()
                item.animation.iconSelectedColor = CommonUtil.getSettingThemaColor()
            }
            rm.setSelectIndex(from: 2, to: 2)
        }
        
        let cl : SwiftHUEColorPicker = SwiftHUEColorPicker()
        cl.delegate = self
        cl.frame = Constants.colorPickerSize
        print(cl.frame)
        cl.direction = SwiftHUEColorPicker.PickerDirection.Horizontal
        cl.type = SwiftHUEColorPicker.PickerType.Color
        cl.currentColor = CommonUtil.getSettingThemaColor()
        cl.backgroundColor = UIColor.whiteColor()
        
        colorPicker = ColorPicker(frame:CGRectMake(0,0,220,50))
        huePicker = HuePicker(frame:CGRectMake(0,0,220,20))
        
        let color = CommonUtil.getSettingThemaColor()
        colorView = UIView(frame:Constants.colorViewSize)
        colorView?.backgroundColor = color
        
        let pickerController = ColorPickerController(svPickerView: colorPicker!, huePickerView: huePicker!, colorWell: ColorWell())
        pickerController.color = CommonUtil.getSettingThemaColor() //UIColor.redColor()
        
        pickerController.onColorChange = {(color, finished) in
            if finished {
                //self.view.backgroundColor = UIColor.whiteColor() // reset background color to white
            } else {
                self.colorView!.backgroundColor = color // set background color to current selected color (finger is still down)
            }
        }
        
        self.popupController = CNPPopupController(contents:[
            UIView(),
            colorPicker!,huePicker!,UIView(),colorView!,UIView(),button, UIView()
            ])
        self.popupController.theme = CNPPopupTheme.defaultTheme()
        self.popupController.theme.popupStyle = CNPPopupStyle.Centered
        self.setPopupSize()
        self.popupController.delegate = self
        self.popupController.presentPopupControllerAnimated(true)
    }
    
    func setPopupSize(){
        self.popupController.theme.maxPopupWidth = UtilManager.getPopUpWidth()
    }
    
    // MARK: - CNPPopupController Delegate
    func popupController(controller: CNPPopupController, dismissWithButtonTitle title: NSString) {
        print("Dismissed with button title \(title)")
    }
    
    func popupControllerDidPresent(controller: CNPPopupController) {
        print("Popup controller presented")
    }
    
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        switch pickerView.tag {
        case 1:
            return self.langArray.count
        case 2:
            return self.formatArray.count
        case 3:
            return self.weekdayArray.count
        case 4:
            return self.fontValArray.count
        case 5:
            return self.fontSizeArray.count
        case 6:
            return self.currencySymbolArray.count
        case 30:
            return self.centerFormatArray.count
        case 31:
            return self.fontSizeArray.count
        case 32:
            return self.fontSizeArray.count
        case 33:
            return self.imageSizeArray.count
        case 34:
            return self.encodingArray.count
        case 35:
            return self.animationArray.count
        default:
            return self.genreDic.count
        }
        //return 0
    }
    
    func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String {
        
        switch pickerView.tag {
        case 1:
            return self.langArray[item]
        case 2:
            return self.formatArray[item]
        case 3:
            return self.weekdayArray[item]
        case 4:
            return self.fontNameArray[item]
        case 5:
            return String(self.fontSizeArray[item])
        case 6:
            return self.currencySymbolArray[item]
        case 30:
            return self.centerFormatArray[item]
        case 31:
            return String(self.fontSizeArray[item])
        case 32:
            return String(self.fontSizeArray[item])
        case 33:
            return String(self.imageSizeArray[item])
        case 34:
            return String(self.encodingArray[item])
        case 35:
            return self.animationArray[item]
        default:
            return (genreDic[item]?.name)! as String
        }
        
        //return (genreDic[item]?.name)! as String
    }
    /*
     func pickerView(pickerView: AKPickerView, imageForItem item: Int) -> UIImage {
     return UIImage(named: self.titles[item])!
     }
     */
    // MARK: - AKPickerViewDelegate
    
    func pickerView(pickerView: AKPickerView, didSelectItem item: Int) {
        switch pickerView.tag {
        case 1:
            print(self.langArray[item])
        case 2:
            print(self.formatArray[item])
        case 3:
            print(self.weekdayArray[item])
        case 4:
            print(self.fontValArray[item])
        case 5:
            print(self.fontSizeArray[item])
        case 6:
            print(self.currencySymbolArray[item])
        case 30:
            print(self.centerFormatArray[item])
        case 31:
            print(self.fontSizeArray[item])
        case 32:
            print(self.fontSizeArray[item])
        case 33:
            print(self.imageSizeArray[item])
        case 34:
            print(self.encodingArray[item])
        case 35:
            print(self.animationArray[item])
        default:
            print("Your favorite city is \(genreDic[item]?.name)")
            break // do nothing
        }
    }
    
    func pickerView(pickerView: AKPickerView, configureLabel label: UILabel, forItem item: Int) {
        label.backgroundColor = UIColor(red: 210 / 255, green: 213 / 255, blue: 218 / 255, alpha: 1.0)
        switch pickerView.tag {
        case 1:
            label.text = self.langArray[item]
        case 2:
            label.text = self.formatArray[item]
        case 3:
            label.text = self.weekdayArray[item]
        case 4:
            print(self.fontValArray[item])
            label.font = UIFont(name: self.fontValArray[item], size: 16)
            label.text = self.fontNameArray[item]
        case 5:
            label.text = String(self.fontSizeArray[item])
        case 6:
            label.text = self.currencySymbolArray[item]
        case 30:
            label.text = self.centerFormatArray[item]
        case 31:
            label.text = String(self.fontSizeArray[item])
        case 32:
            label.text = String(self.fontSizeArray[item])
        case 33:
            label.text = String(self.imageSizeArray[item])
        case 34:
            label.text = String(self.encodingArray[item])
        case 35:
            label.text = self.animationArray[item]
        default:
            label.textColor = UIColor.lightGrayColor()
            label.highlightedTextColor = UIColor.whiteColor()
            let genre = genreDic[item]
            label.backgroundColor = UIColor.hexStr((genre?.color)!, alpha: 1)
        }
    }
    
    func pickerView(pickerView: AKPickerView, marginForItem item: Int) -> CGSize {
        return CGSizeMake(40, 20)
    }
    
    func valuePicked(color: UIColor, type: SwiftHUEColorPicker.PickerType) {
        print("color : \(color)")
        colorView?.backgroundColor = color
    }
    
    // ピッカーを表示
    func showFontPicker(){
        
        blackOutView = UIView(frame: CGRectInset(self.view.frame, -100, -200))
        //CGRectMake(0,0,self.view.frame.width, self.view.frame.height))
        blackOutView?.backgroundColor = UIColor.blackColor()
        blackOutView?.alpha = 0.5
        self.view.addSubview(blackOutView!)
        
        // ピッカー用のコントローラーをモーダルで表示
        let story = UIStoryboard(name: "Main", bundle: nil)
        fontPickerVC = story.instantiateViewControllerWithIdentifier("FontPickerViewController") as? FontPickerViewController
        fontPickerVC!.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        fontPickerVC?.delegate = self
        
        // 日付ピッカー出現時には右上の完了ボタンを無効にしておく
        //self.navigationItem.rightBarButtonItem?.enabled = false
        self.presentViewController(fontPickerVC!, animated: true, completion: nil)
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
        //titleLabel.font = UIFont(name: CommonUtil.DEFAULT_FONT_NAME_JP, size: Constants.pickerFontSize)
        titleLabel.font = UIFont(name: self.config.font, size: CGFloat(self.config.title_font_size))
        
        titleLabel.text = self.wordDic!["SET_TITLE"]
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.userInteractionEnabled = false //タッチを検出しない
        titleLabel.tag = 1
        titleLabel.sizeToFit()
        titleLabel.frame.size.height = (self.navigationController?.navigationBar.frame.height)! // 英語「g」の下が切れる対策
        self.navigationItem.titleView = titleLabel
        
        self.tabBarController?.tabBar.tintColor = CommonUtil.getSettingThemaColor()
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
    }
    
    /*
     // return title list for section index
     func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
     return self.sectionTitleList
     }
     // return section for given section index title
     func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
     return index
     }
     */
    // MARK: - Utility functions
    
    /*
     // テーブルの行数を返す
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return menuList.count
     }
     
     //表示するセルの中身
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     
     let cell = tableView.dequeueReusableCellWithIdentifier("TopTableViewCell") as! TopTableViewCell
     cell.textLabel?.text = menuList[indexPath.row][kTitleKey] as? String
     return cell
     }
     
     //セルの高さ
     func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
     return 40.0//EventTableViewCell.EVENT_CELL_HEIGHT
     }
     
     
     //選択された時
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
     // もっと上位でイベント処理するので、ここではイベント拾えない
     print("\(indexPath.row)行目を選択")
     let vc = menuList[indexPath.row][kViewControllerKey] as! UIViewController
     self.navigationController?.pushViewController(vc, animated: true)
     }
     */
    
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
