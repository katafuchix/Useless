//
//  FontPickerViewController.swift
//  Useless
//
//  Created by cano on 2016/05/01.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit
import RealmSwift

class FontPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{

    
    @IBOutlet var picker: UIPickerView!
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var doneButton: UIButton!
    
    var delegate : fontPickerDelegate?
    
    let realm = RealmController.getSharedRealmController()
    let pData = PublicDatas.getPublicDatas()
    var config : Config = Config()
    
    let fm = FontManager()
    var fontNameArray : Array<String> = Array<String>()
    var fontValArray : Array<String> = Array<String>()
    
    var wordDic : Dictionary<String, String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.clearColor()
        loadConfigData()
        
        picker.showsSelectionIndicator = true
        picker.dataSource = self
        picker.delegate = self
        picker.backgroundColor = UIColor.whiteColor()
        
        let blackTap = UITapGestureRecognizer(target: self, action: #selector(FontPickerViewController.blackTapGesture(_:)))
        self.view?.addGestureRecognizer(blackTap)
        
        doneButton.setTitle(self.wordDic!["DONE"], forState: .Normal)
        doneButton.titleLabel!.font = UIFont(name: self.config.font,size: CGFloat(16))
        
        cancelButton.setTitle(self.wordDic!["CANCEL"], forState: .Normal)
        cancelButton.titleLabel!.font = UIFont(name: self.config.font,size: CGFloat(16))
    }

    func blackTapGesture(sender: UITapGestureRecognizer){
        self.dismissViewControllerAnimated(true, completion: nil)
        if (self.delegate?.respondsToSelector(Selector("didClose"))) != nil {
            // 実装先のメソッドを実行
            self.delegate?.didClose()
        }
    }
    
    //Viewが表示される直前
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.headerView.backgroundColor = CommonUtil.getSettingThemaColor()
        
        if let index = self.fontValArray.indexOf(self.config.font) {
            picker.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
    func loadConfigData(){
        self.config = realm.getConfig()
        if self.config.lang == "jp" {
            self.fontNameArray = fm.font_names_jp
        }else{
            self.fontNameArray = fm.font_names
        }
        self.fontValArray = fm.font_values
        //self.fontNameArray = Constants.font_names
        //self.fontValArray = Constants.font_values
        self.wordDic = UtilManager.getLangs(self.config.lang)
    }
    
    // コンポーネントの数
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // コンポーネント内のデータ
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fontNameArray.count
    }
    
    // ホイールに表示する選択肢のタイトル
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return fontNameArray[row]
    }
    
    // コンポーネントの幅を指定
    func pickerView(pickerView: UIPickerView,
                    widthForComponent component: Int) -> CGFloat{
        return 300.0
    }
    // 選択肢の高さを指定
    func pickerView(pickerView: UIPickerView,
                    rowHeightForComponent component: Int) -> CGFloat{
        return 40.0
    }
    
    // 選択時の処理
    func pickerView(pickerView: UIPickerView,
                    didSelectRow row: Int,
                                 inComponent component: Int){
            print(fontValArray[row])
    }
    
    func pickerView(pickerView: UIPickerView,
                      viewForRow row: Int,
                                 forComponent component: Int,
                                              reusingView view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        
        pickerLabel.text = fontNameArray[row]
        pickerLabel.font = UIFont(name: fontValArray[row], size: Constants.pickerFontSize)
        
        return pickerLabel
    }
    
    @IBAction func onDoneButton(sender: AnyObject) {
        
        if (self.delegate?.respondsToSelector(Selector("didSelectFont:"))) != nil {
            // 実装先のメソッドを実行
            self.delegate?.didSelectFont(picker.selectedRowInComponent(0))
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if (self.delegate?.respondsToSelector(Selector("didClose"))) != nil {
            // 実装先のメソッドを実行
            self.delegate?.didClose()
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

// SettingViewController で処理を行うためのデリゲート
protocol fontPickerDelegate : NSObjectProtocol {
    // 日付ピッカーを閉じてフォーカスを元に戻す
    func didSelectFont(index:Int)
    // 日付ピッカーからの入力を編集画面に反映 編集なので年は固定
    //func updateEditDate(str: String, sYear: Int, eYear: Int)->Bool
    
    func didClose()
}

