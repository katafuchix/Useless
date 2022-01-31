//
//  EditGenreViewController.swift
//  Useless
//
//  Created by cano on 2016/02/27.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit

class EditGenreViewController: UIViewController
, UICollectionViewDelegate, UICollectionViewDataSource
{

    @IBOutlet var colorView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveBtn: MKButton!
    @IBOutlet var collectionView: UICollectionView!
    
    let realm = RealmController.getSharedRealmController()
    
    let reuseIdentifier = "Cell"
    let DaysPerWeek = 7
    let CellMargin : CGFloat = 2.0
    
    var genre : Genre?
    var sctions: Array<String> = Array<String>()
    var items: Array<String> = Array<String>()
    var itemDic: Dictionary<Int, String> = Dictionary<Int, String>()
    let pData : PublicDatas = PublicDatas.getPublicDatas()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /*for (var i = 0; i < 50; i++) {
            items.append(String(i))
        }*/
        print(genre)
        if genre != nil {
            colorView.backgroundColor = UIColor.hexStr((genre?.color)!, alpha: 1)
            textField.text = genre!.name
        }
        items = ["#000000",
            "#f0f8ff",
            "#008b8b",
            "#ffffe0",
            "#ff7f50",
            "#696969",
            "#e6e6fa",
            "#008080",
            "#fafad2",
            "#ff6347",
            "#808080",
            "#b0c4de",
            "#2f4f4f",
            "#fffacd",
            "#ff4500",
            "#a9a9a9",
            "#778899",
            "#006400",
            "#f5deb3",
            "#ff0000",
            "#c0c0c0",
            "#708090",
            "#008000",
            "#deb887",
            "#dc143c",
            "#d3d3d3",
            "#4682b4",
            "#228b22",
            "#d2b48c",
            "#c71585",
            "#dcdcdc",
            "#4169e1",
            "#2e8b57",
            "#f0e68c",
            "#ff1493",
            "#f5f5f5",
            "#191970",
            "#3cb371",
            "#ffff00",
            "#ff69b4",
            "#ffffff",
            "#000080",
            "#66cdaa",
            "#ffd700",
            "#db7093",
            "#fffafa",
            "#00008b",
            "#8fbc8f",
            "#ffa500",
            "#ffc0cb",
            "#f8f8ff",
            "#0000cd",
            "#7fffd4",
            "#f4a460",
            "#ffb6c1",
            "#fffaf0",
            "#0000ff",
            "#98fb98",
            "#ff8c00",
            "#d8bfd8",
            "#faf0e6",
            "#1e90ff",
            "#90ee90",
            "#daa520",
            "#ff00ff",
            "#faebd7",
            "#6495ed",
            "#00ff7f",
            "#cd853f",
            "#ff00ff",
            "#ffefd5",
            "#00bfff",
            "#00fa9a",
            "#b8860b",
            "#ee82ee",
            "#ffebcd",
            "#87cefa",
            "#7cfc00",
            "#d2691e",
            "#dda0dd",
            "#ffe4c4",
            "#87ceeb",
            "#7fff00",
            "#a0522d",
            "#da70d6",
            "#ffe4b5",
            "#add8e6",
            "#adff2f",
            "#8b4513",
            "#ba55d3",
            "#ffdead",
            "#b0e0e6",
            "#00ff00",
            "#800000",
            "#9932cc",
            "#ffdab9",
            "#afeeee",
            "#32cd32",
            "#8b0000",
            "#9400d3",
            "#ffe4e1",
            "#e0ffff",
            "#9acd32",
            "#a52a2a",
            "#8b008b",
            "#fff0f5",
            "#00ffff",
            "#556b2f",
            "#b22222",
            "#800080",
            "#fff5ee",
            "#00ffff",
            "#6b8e23",
            "#cd5c5c",
            "#4b0082",
            "#fdf5e6",
            "#40e0d0",
            "#808000",
            "#bc8f8f",
            "#483d8b",
            "#fffff0",
            "#48d1cc",
            "#bdb76b",
            "#e9967a",
            "#8a2be2",
            "#f0fff0",
            "#00ced1",
            "#eee8aa",
            "#f08080",
            "#9370db",
            "#f5fffa",
            "#20b2aa",
            "#fff8dc",
            "#fa8072",
            "#6a5acd",
            "#f0ffff",
            "#5f9ea0",
            "#f5f5dc",
            "#ffa07a",
            "#7b68ee"]
        //for(var i=0; i<items.count; i++){
        var i=0;
        for str in items {
            itemDic[i] = str
            i += 1
        }
        //print(itemDic)
        //self.view.backgroundColor = UIColor.blackColor()
        
        // レイアウトを指定
        let flowLayout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        // セルのサイズ
        //flowLayout.itemSize = CGSizeMake(50.0, 50.0)
        // 縦、横のスペース
        //flowLayout.minimumInteritemSpacing = 0.0
        //flowLayout.minimumLineSpacing = 2.0
        // スクロールの方向
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        // サイズ、レイアウトを指定して初期化
        //collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        
        //let collectionView = UICollectionView(frame: CGRectMake(20, 200, 200,200), collectionViewLayout: flowLayout)
        
        // delegateを指定
        collectionView.delegate = self
        // dataSourceを指定
        collectionView.dataSource = self
        // セルのクラスを登録
        collectionView.registerClass(ItemCell.classForCoder(), forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView.setContentOffset(CGPointZero , animated: true)
        collectionView.bounces = false
        
        //self.view.addSubview(collectionView)
        //let rect = CGRectMake(0, -64, self.collectionView.frame.size.width, self.collectionView.frame.size.height)
        //collectionView.scrollRectToVisible(rect, animated: false)
        //self.automaticallyAdjustsScrollViewInsets = false
        
        collectionView.backgroundColor = UIColor.whiteColor()
        
        saveBtn.addTarget(self, action: #selector(EditGenreViewController.onSave(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        pData.setData("", key: "color")
    }

    //Viewが表示される直前
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //テーブルの再描画
    }
    
    func onSave(sender: UIButton) {
        //realm.updateGenreName(genre?.id, name: textField.text, color: <#T##String#>)
        
        let val = pData.getStringForKey("color")//getData("color") as! String
        if val != "" && textField.text != "" {
            realm.updateGenreNameColor((genre?.id)!, name: textField.text!, color: val)
        }
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        let numberOfMargin  = 6
        let val = CGFloat(CellMargin) * CGFloat(numberOfMargin)
        let width = (collectionView.frame.size.width - val) / 5.0//CGFloat(DaysPerWeek))
        let height = width * 1.0
        
        return CGSizeMake(width, height)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(CellMargin, CellMargin, CellMargin, CellMargin)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        return CellMargin
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        return CellMargin
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ItemCell
        
        // Configure the cell
        //cell.backgroundColor = UIColor.whiteColor()
        let val = itemDic[indexPath.row]
        cell.backgroundColor =  UIColor.hexStr(val!, alpha: 1)
        
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 2
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath){
            /*
            // 選択されたセルの番号を表示
            let alert:UIAlertController = UIAlertController(title: "\(indexPath.row)", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                // OKボタンが押された時の処理
                (action:UIAlertAction) -> Void in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            */
            let val = itemDic[indexPath.row]
            print("val : \(val!)")
            colorView.backgroundColor =  UIColor.hexStr(val!, alpha: 1)
            
            pData.setData(val!, key: "color")
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
