//
//  InputViewController.swift
//  Useless
//
//  Created by cano on 2016/02/27.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit
import RealmSwift

class InputViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var genrePickerView: UIPickerView!
    
    
    let realm = RealmController.getSharedRealmController()
    var genreList : Results<Genre>?
    
    var genreDic : Dictionary<Int,Genre> = Dictionary<Int,Genre>()  // 削除時に参照する辞書
    
    var devices : Array<String> = Array<String>()
    var items : Array<String> = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contentView.layer.cornerRadius = 20
        loadGenreData()
        
        //ピッカーと選択するデータを定義
        genrePickerView.showsSelectionIndicator = true
        genrePickerView.dataSource = self
        genrePickerView.delegate = self
        genrePickerView.center = self.view.center
        
        devices = ["iPhone", "iPod", "iPad"]
        for(var i=1; i<10; i += 1){
            items.append(String(i))
        }
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
    
    // コンポーネントの数
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // コンポーネント内のデータ
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        /*if component == 0 {
            return devices.count
        }else{
            return items.count
        }*/
        return genreList!.count
    }
    
    // ホイールに表示する選択肢のタイトル
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // 0番目の選択項目のタイトル
        /*if component == 0 {
            return devices[row] as String
        }
            // 1番目の選択項目のタイトル
        else{
            return items[row] as String
        }*/
        return (genreDic[row]?.name)! as String
    }
    
    
    func pickerView(pickerView: UIPickerView,
        viewForRow row: Int,
        forComponent component: Int,
        var reusingView view: UIView?) -> UIView
    {
        let genre = genreDic[row]
        
        if((view == nil)){
            view = UIView(frame: CGRectMake(0, 0, 280, 40))
            
            let colorView = UIView(frame: CGRectMake(15, 5, 30, 30))
            let colorImageView = UIImageView(frame:colorView.frame)
            colorView.backgroundColor = UIColor.hexStr((genre?.color)!, alpha: 1)
            let colorImg = UtilManager.getUIImageFromUIView(colorView)
            colorImageView.image = colorImg
            view?.addSubview(colorView)
            
            let label = UILabel(frame: CGRectMake(60, 0, 200, 30))
            label.text = genre?.name
            label.center.y = view!.frame.size.height/2
            view?.addSubview(label)
        }
        
        return view!
        
        
    }

    
    // コンポーネントの幅を指定
    func pickerView(pickerView: UIPickerView,
        widthForComponent component: Int) -> CGFloat{
            /*
            // 0番目のコンポーネントは幅を200に
            if component == 0 {
                return  200.0
            }
                // 1番目のコンポーネントは幅を60に
            else{
                return 60.0
            }
            */
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
            /*
            // 0番目のコンポーネント選択時
            if component == 0 {
                print(devices[row])
            }
                // 1番目のコンポーネント選択時
            else{
                print(items[row])
            }
            */
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
