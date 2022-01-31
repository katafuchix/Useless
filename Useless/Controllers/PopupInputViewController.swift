//
//  PopupInputViewController.swift
//  Useless
//
//  Created by cano on 2016/03/21.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit
import RealmSwift
import AKPickerView_Swift

class PopupInputViewController: UIViewController, UITextFieldDelegate,
      AKPickerViewDataSource, AKPickerViewDelegate
{

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var textField: UITextField!
    

    @IBOutlet weak var pickerView: AKPickerView!
    
    let realm = RealmController.getSharedRealmController()
    var genreList : Results<Genre>?
    
    var genreDic : Dictionary<Int,Genre> = Dictionary<Int,Genre>()  // 削除時に参照する辞書
    
    var grayView : UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        contentView.layer.cornerRadius = 20
        grayView = UIView(frame:self.view.frame)
        grayView?.backgroundColor = UIColor.grayColor()
        grayView?.alpha = 0.3
        self.view.addSubview(grayView!)
        
        self.view.bringSubviewToFront(contentView)
        
        textField.delegate = self
        textField.borderStyle = UITextBorderStyle.RoundedRect
        
        loadGenreData()
        
        //ピッカーと選択するデータを定義
        //pickerView.showsSelectionIndicator = true
        //pickerView.dataSource = self
        //pickerView.delegate = self
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        self.pickerView.font = UIFont(name: "HelveticaNeue-Light", size: Constants.pickerFontSize)!
        self.pickerView.highlightedFont = UIFont(name: "HelveticaNeue", size: Constants.pickerFontSize)!
        self.pickerView.pickerViewStyle = .Wheel
        self.pickerView.maskDisabled = false
        self.pickerView.reloadData()
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
        print("Your favorite city is \(genreDic[item]?.name)")
    }
    
    func pickerView(pickerView: AKPickerView, configureLabel label: UILabel, forItem item: Int) {
        label.textColor = UIColor.lightGrayColor()
        label.highlightedTextColor = UIColor.whiteColor()
        /*label.backgroundColor = UIColor(
            hue: CGFloat(item) / CGFloat(self.titles.count),
            saturation: 1.0,
            brightness: 0.5,
            alpha: 1.0)*/
        
        let genre = genreDic[item]
        label.backgroundColor = UIColor.hexStr((genre?.color)!, alpha: 1)
    }
    
    func pickerView(pickerView: AKPickerView, marginForItem item: Int) -> CGSize {
        return CGSizeMake(40, 20)
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    
    
    
    
    
    
    
    
    // コンポーネントの数
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // コンポーネント内のデータ
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genreList!.count
    }
    
    // ホイールに表示する選択肢のタイトル
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (genreDic[row]?.name)! as String
    }
    
    
    func pickerView(pickerView: UIPickerView,
        viewForRow row: Int,
        forComponent component: Int,
        var reusingView view: UIView?) -> UIView
    {
        let genre = genreDic[row]
        
        if((view == nil)){
            view = UIView(frame: CGRectMake(-10, 0, 240, 40))
            
            let colorView = UIView(frame: CGRectMake(-5, 5, 30, 30))
            let colorImageView = UIImageView(frame:colorView.frame)
            colorView.backgroundColor = UIColor.hexStr((genre?.color)!, alpha: 1)
            let colorImg = UtilManager.getUIImageFromUIView(colorView)
            colorImageView.image = colorImg
            view?.addSubview(colorView)
            
            let label = UILabel(frame: CGRectMake(40, 0, 200, 30))
            label.text = genre?.name
            //label.center.y = view!.frame.size.height/2
            view?.addSubview(label)
        }
        return view!
    }
    
    // コンポーネントの幅を指定
    func pickerView(pickerView: UIPickerView,
        widthForComponent component: Int) -> CGFloat{
            return self.view.bounds.size.width
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
            
            print(row)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

/*
extension PopupInputViewController: PickerViewDataSource {
    
    // MARK: - PickerViewDataSource
    //func numberOfRowsInPickerView(pickerView: PickerView) -> Int {
    func pickerViewNumberOfRows(pickerView: PickerView) -> Int {
        /*switch presentationType {
        case .Numbers(_, _):
            return numbers.count
        case .Names(_, _):
            return osxNames.count
        }*/
        return genreList!.count
    }
    //func pickerView(pickerView: PickerView, titleForRow row:Int) -> String {
    func pickerView(pickerView: PickerView, titleForRow row: Int, index: Int) -> String {
        /*
        switch presentationType {
        case .Numbers(_, _):
            return numbers[index]
        case .Names(_, _):
            return osxNames[index]
        }
        */
        return (genreDic[row]?.name)! as String
    }
    
}
*/
/*
extension PopupInputViewController: PickerViewDelegate {
    
    // MARK: - PickerViewDelegate
    func heightForRowInPickerView(pickerView: PickerView) -> CGFloat {
    //func pickerViewHeightForRows(pickerView: PickerView) -> CGFloat {
        return 40.0
    }
    
    func pickerView(pickerView: PickerView, didSelectRow row: Int){
    //func pickerView(pickerView: PickerView, didSelectRow row: Int, index: Int) {
        /*switch presentationType {
        case .Numbers(_, _):
            currentSelectedValue = numbers[index]
        case .Names(_, _):
            currentSelectedValue = osxNames[index]
        }
        */
        print(row)
    }
    func styleForLabel(label: UILabel, inPickerView pickerView: PickerView){
    //func pickerView(pickerView: PickerView, styleForLabel label: UILabel, highlighted: Bool) {
        /*label.textAlignment = .Center
        if #available(iOS 8.2, *) {
            if (highlighted) {
                label.font = UIFont.systemFontOfSize(26.0, weight: UIFontWeightLight)
            } else {
                label.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightLight)
            }
        } else {
            if (highlighted) {
                label.font = UIFont(name: "HelveticaNeue-Light", size: 16.0)
            } else {
                label.font = UIFont(name: "HelveticaNeue-Light", size: 26.0)
            }
        }
        
        if (highlighted) {
            label.textColor = view.tintColor
        } else {
            label.textColor = UIColor(red: 161.0/255.0, green: 161.0/255.0, blue: 161.0/255.0, alpha: 1.0)
        }*/
        label.textColor = view.tintColor
    }
    
    
    func styleForHighlightedLabel(label: UILabel, inPickerView pickerView: PickerView){
    //func pickerView(pickerView: PickerView, viewForRow row: Int, index: Int, highlited: Bool, reusingView view: UIView?) -> UIView? {
    
        var customView = view
        
        let imageTag = 100
        let labelTag = 101
        
        if (customView == nil) {
            var frame = pickerView.frame
            frame.origin = CGPointZero
            frame.size.height = 50
            customView = UIView(frame: frame)
            
            let imageView = UIImageView(frame: frame)
            imageView.tag = imageTag
            imageView.contentMode = .ScaleAspectFill
            imageView.image = UIImage(named: "AbstractImage")
            imageView.clipsToBounds = true
            
            customView?.addSubview(imageView)
            
            let label = UILabel(frame: frame)
            label.tag = labelTag
            label.textColor = UIColor.whiteColor()
            label.shadowColor = UIColor.blackColor()
            label.shadowOffset = CGSizeMake(1.0, 1.0)
            label.textAlignment = .Center
            
            if #available(iOS 8.2, *) {
                label.font = UIFont.systemFontOfSize(26.0, weight: UIFontWeightLight)
            } else {
                label.font = UIFont(name: "HelveticaNeue-Light", size: 26.0)
            }
            
            customView?.addSubview(label)
        }
        
        let imageView = customView?.viewWithTag(imageTag) as? UIImageView
        let label = customView?.viewWithTag(labelTag) as? UILabel
        /*
        switch presentationType {
        case .Numbers(_, _):
            label?.text = numbers[index]
        case .Names(_, _):
            label?.text = osxNames[index]
        }
        */
        /*
        label?.text = (genreDic[row]?.name)! as String
        let alpha : CGFloat = highlited ? 1.0 : 0.5
        
        imageView?.alpha = alpha
        label?.alpha = alpha
        */
        //return customView
    }
}
*/