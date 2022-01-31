//
//  GenreViewController.swift
//  Useless
//
//  Created by cano on 2016/02/27.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit
import RealmSwift
import CNPPopupController

class GenreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
    CNPPopupControllerDelegate, SwiftHUEColorPickerDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    var popupController:CNPPopupController = CNPPopupController()
    
    let realm = RealmController.getSharedRealmController()
    var genreList : Results<Genre>?
    
    var genreDic : Dictionary<Int,Genre> = Dictionary<Int,Genre>()  // 削除時に参照する辞書
    
    let pData = PublicDatas.getPublicDatas()
    var colorView: UIView?
    var genreTextField: MKTextField?
    
    var colorPicker: ColorPicker?
    var huePicker: HuePicker?
    
    var config : Config = Config()
    
    var wordDic : Dictionary<String, String>?
    
    var myRightButton = UIButton()
    var myRightButton2 = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loadTableView()
        tableView.delegate = self
        tableView.dataSource = self
        //セルの境界線を消す
        tableView.separatorColor = UIColor.clearColor()
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
        
        titleLabel.text = self.wordDic!["GENRE_LIST"]
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
        let myLeftButton = UIButton(type: .Custom)
        myLeftButton.frame = CGRectMake(0,0,50,25)
        myLeftButton.setTitle(self.wordDic!["BACK"], forState: .Normal)
        myLeftButton.titleLabel!.font = UIFont(name: self.config.font,size: CGFloat(16))
        myLeftButton.addTarget(self, action: #selector(DayViewController.back(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        let lView = UIView(frame: CGRectMake(0,0,50,25))
        lView.addSubview(myLeftButton)
        
        // ナビゲーションバーの左に設置する.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: lView)
        
        // 右ボタンを作成する
        myRightButton = UIButton(type: .Custom)
        myRightButton.frame = CGRectMake(0,0,35,25)
        myRightButton.setTitle(self.wordDic!["ADD"], forState: .Normal)
        myRightButton.titleLabel!.font = UIFont(name: self.config.font,size: CGFloat(16))
        myRightButton.addTarget(self, action: #selector(GenreViewController.onAdd(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        myRightButton.tag = 1
        let addButton : UIBarButtonItem = UIBarButtonItem(customView: myRightButton)

        myRightButton2 = UIButton(type: .Custom)
        myRightButton2.frame = CGRectMake(0,0,35,30)
        myRightButton2.setTitle(self.wordDic!["EDIT"], forState: .Normal)
        myRightButton2.titleLabel!.font = UIFont(name: self.config.font,size: CGFloat(16))
        myRightButton2.addTarget(self, action: #selector(GenreViewController.tappedEditButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        myRightButton2.tag = 2
        let editButton : UIBarButtonItem = UIBarButtonItem(customView: myRightButton2)
        
        self.navigationItem.rightBarButtonItems = [addButton,editButton]
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
    
    func loadTableView()
    {
        genreList = realm.getListGenre()
        genreDic = Dictionary<Int,Genre>()
        
        var i = 0
        for genre in genreList! {
            genreDic[i] = genre
            i += 1
        }
    }
    
    //Viewが表示される直前
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadConfigData()
        tableView.reloadData()
        initNavigationBar()
    }
    
    // テーブルの行数を返す
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genreList!.count
    }
    
    //表示するセルの中身
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GenreTableViewCell") as! GenreTableViewCell
        
        let genre = genreList![indexPath.row]
        cell.genre = genre
        //cell.textLabel?.text = genre.name
        cell.genreLabel.font = UIFont(name: self.config.font, size: 17.0)
        cell.genreLabel.text = genre.name
        cell.setNeedsDisplay()
        
        return cell
    }
    
    //セルの高さ
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0//GenreTableViewCell.CELL_HEIGHT
    }
    
    //セルが選択された時
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("tapped row=\(indexPath.row)")
        
        let genre = genreList![indexPath.row]
        print(genre.id)
        pData.setData(String(genre.id), key: "genreId")
        self.showPopupWithStyle(CNPPopupStyle.ActionSheet)
        /*
        let story = UIStoryboard(name: "Setting", bundle: nil)
        let egenreVC = story.instantiateViewControllerWithIdentifier("EditGenreViewController") as! EditGenreViewController
        egenreVC.genre = genre
        self.navigationController?.pushViewController(egenreVC, animated: true)
        */
    }
    
    func onAdd(sender: UIButton) {
        /*
        let story = UIStoryboard(name: "Setting", bundle: nil)
        let egenreVC = story.instantiateViewControllerWithIdentifier("EditGenreViewController") as! EditGenreViewController
        self.navigationController?.pushViewController(egenreVC, animated: true)
        */
        pData.setData("", key: "genreId")
        self.showPopupWithStyle(CNPPopupStyle.ActionSheet)
    }
    
    
    //編集ボタンをおした時の処理
    func tappedEditButton(sender: AnyObject) {
        print("tapped. EditButton")
        
        if tableView.editing {
            myRightButton2.setTitle(self.wordDic!["EDIT"], forState: .Normal)
            myRightButton.enabled = true
            
            super.setEditing(false, animated: true)
            tableView.setEditing(false, animated: true)
            
            let realmc: RealmController = RealmController.getSharedRealmController()
            // 現在の並び順で順番を入れ替える
            for i in 0 ..< genreDic.count {
                let genre = genreDic[i]
                //print("genre : \(genre)")
                realmc.updateGenreOrder(genre!.id, order: i)
            }
            
            tableView.reloadData()
            
        } else {
            myRightButton2.setTitle(self.wordDic!["EDIT_DONE"], forState: .Normal)
            myRightButton.enabled = false
            
            super.setEditing(true, animated: true)
            // 編集モードでテーブルを再描画して追加セルを非表示
            tableView.reloadData()
            tableView.setEditing(true, animated: true)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ジャンルを削除するときは、必ず編集モードにしてからでないとできないように
    func tableView(tableView: UITableView,
        editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
            // 編集モードの時だけ削除可能に
            if tableView.editing {
                return UITableViewCellEditingStyle.Delete
            }else{
                return UITableViewCellEditingStyle.None
            }
    }
    
    // 削除可能なセル
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == genreList?.count {
            return false //追加ボタンは削除できない
        } else {
            return true
        }
    }
    
    // 並び替え可能なセル
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == genreList?.count {
            return false //追加ボタンは並び替えできない
        } else {
            return true
        }
    }
    
    /*
    //並び替えのときに呼ばれる
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        //最終行が並び替えの対象の場合、何もせずにぬける
        if sourceIndexPath.row == genreList?.count || destinationIndexPath.row == genreList?.count {
            return
        }
    }
    */
    func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
    {
        //print("from=\(fromIndexPath.row) dest=\(toIndexPath.row)")
        
        // 移動元と移動先が同じ場合は何もしない
        if fromIndexPath.row == toIndexPath.row {
            return
        }
        
        // 新しい並び順の辞書
        var newGenreDic = Dictionary<Int, Genre>()
        
        // 下から上への移動
        if fromIndexPath.row > toIndexPath.row {
            // 先に移動先までの順序を決定
            for i in 0 ..< genreDic.count {
                // 移動先の部分は移動元のイベントで詰める
                if toIndexPath.row == i {
                    newGenreDic[i] = genreDic[fromIndexPath.row]
                    break
                }else{
                    newGenreDic[i] = genreDic[i]
                }
            }
            // 残りの順序を決定
            var j = toIndexPath.row + 1
            for i in toIndexPath.row ..< genreDic.count {
                if i == fromIndexPath.row {
                    continue;
                }
                newGenreDic[j] = genreDic[i]
                j += 1
            }
        }
            // 上から下への移動
        else{
            var j = 0
            // 先に移動先までの順序を決定
            for i in 0 ..< toIndexPath.row {
                // 移動先の部分は次のイベントで詰める
                if fromIndexPath.row == i {
                    j += 1
                }
                newGenreDic[i] = genreDic[j]
                j += 1
            }
            // 残りの順序を決定
            for var i=toIndexPath.row; i<genreDic.count; i++ {
                // 移動先は移動元のイベントで置き換える
                if i == toIndexPath.row {
                    newGenreDic[i] = genreDic[fromIndexPath.row]
                    continue;
                }
                newGenreDic[i] = genreDic[i]
            }
        }
        // データソースの辞書を入れ替える
        genreDic = newGenreDic
    }
    
    // テーブルを編集
    func tableView(tableView: UITableView,
                            commitEditingStyle editingStyle: UITableViewCellEditingStyle,
                                               forRowAtIndexPath indexPath: NSIndexPath)
    {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            // 削除
            let g = genreDic[indexPath.row]
            realm.deleteGenre(g!.id)
            //print(g)
            self.genreDic.removeValueForKey( self.getKeyforGenreDic(g!))
            
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            loadTableView()
            tableView.reloadData()
        }
    }
    
    func getKeyforGenreDic(g:Genre) -> Int{
        let keys = self.genreDic.filter{ $1 == g }.map{ $0.0 }
        return keys[0]
    }
    
    func showPopupWithStyle(popupStyle: CNPPopupStyle) {
        var genreId = ""
        if pData.getStringForKey("genreId") != "" {
            genreId = pData.getStringForKey("genreId")
        }
        print("genreId: \(genreId)")
        
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
            self.popupController.dismissPopupControllerAnimated(true)
            print("Block for button: \(self.genreTextField!.text)")
            print(self.colorView?.backgroundColor)
            print(UIColor.toInt32(self.colorView!.backgroundColor!))
            
            if self.genreTextField!.text == "" { return }
            
            if genreId != "" {
                //let g = self.realm.getGenre(Int64(genreId)!)
                self.realm.updateGenreNameColor(Int64(genreId)!, name: self.genreTextField!.text!, color: String(UIColor.toInt32(self.colorView!.backgroundColor!)))
                
            }else{
                let g = self.realm.addGenre(self.genreTextField!.text!, color: String(UIColor.toInt32(self.colorView!.backgroundColor!)), memo: "")
                self.genreDic[self.genreDic.count] = g
            }
            self.tableView.reloadData()
        }
        
        genreTextField = MKTextField(frame: Constants.settingTextFieldSize)
        genreTextField!.floatingPlaceholderEnabled = true
        genreTextField!.cornerRadius = 1.0
        //genreTextField!.placeholder = ""
        genreTextField!.placeholder = self.wordDic!["GENRE_NAME"]
        genreTextField!.layer.borderColor = CommonUtil.getSettingThemaColor().CGColor//UIColor.MKColor.Green.CGColor
        genreTextField!.rippleLayerColor = CommonUtil.getSettingThemaColor()//UIColor.MKColor.LightGreen
        genreTextField!.tintColor = CommonUtil.getSettingThemaColor()//UIColor.MKColor.LightGreen
        
        let cl : SwiftHUEColorPicker = SwiftHUEColorPicker()
        cl.delegate = self
        cl.frame = Constants.colorPickerSize
        print(cl.frame)
        cl.direction = SwiftHUEColorPicker.PickerDirection.Horizontal
        cl.type = SwiftHUEColorPicker.PickerType.Color
        cl.currentColor = CommonUtil.getSettingThemaColor()
        cl.backgroundColor = UIColor.whiteColor()
        
        let color = CommonUtil.getSettingThemaColor()
        colorView = UIView(frame:Constants.colorViewSize)
        colorView?.backgroundColor = color
        
        if genreId != "" {
            let g = realm.getGenre(Int64(genreId)!)
            genreTextField!.text = g!.name
            
            cl.currentColor = UIColor(hex: Int(g!.color)!, alpha: 1.0)
            colorView!.backgroundColor =  UIColor(hex: Int(g!.color)!, alpha: 1.0)
        }
        
        self.popupController = CNPPopupController(contents:[//titleLabel, //lineOneLabel,
            //imageView,lineTwoLabel,picker!, //customView,
            UIView(),
            cl,
            UIView(),
            colorView!,
            UIView(), genreTextField!, UIView(), button, UIView()])
        self.popupController.theme = CNPPopupTheme.defaultTheme()
        self.popupController.theme.popupStyle = CNPPopupStyle.Centered
        self.setPopupSize()
        self.popupController.delegate = self
        self.popupController.presentPopupControllerAnimated(true)
        
        //self.popupController.//layer.borderColor = UIColor.redColor().CGColor
        //targetView.layer.borderWidth = 2.0
        
    }

    func setPopupSize(){
        self.popupController.theme.maxPopupWidth = UtilManager.getPopUpWidth()
    }
    
    func valuePicked(color: UIColor, type: SwiftHUEColorPicker.PickerType) {
        colorView?.backgroundColor = color
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
