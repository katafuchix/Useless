//
//  MenuViewController.swift
//  Useless
//
//  Created by cano on 2016/05/01.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController
, UITableViewDataSource, UITableViewDelegate
{

    let kCellIdentifier = "CellIdentifier"
//    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableView: UITableView!
    var menuList: Array<String> = Array<String>()
    
    let realm = RealmController.getSharedRealmController()
    var config = Config()
    var wordDic : Dictionary<String, String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //self.view.backgroundColor = UIColor.whiteColor()
        loadConfigData()
        /*
        self.config = realm.getConfig()
        //print(self.config)
        self.wordDic = UtilManager.getLangs(self.config.lang)
        
        menuList.append(self.wordDic!["START_DATE"]!)
        menuList.append(self.wordDic!["END_DATE"]!)
        menuList.append(self.wordDic!["CSV_EXPORT"]!)
        menuList.append(self.wordDic!["DAY_BY_DAY"]!)
        */
        //self.tableView.backgroundColor = UIColor.whiteColor()
        tableView.delegate = self
        tableView.dataSource = self
 
    }

    //Viewが表示される直前
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadConfigData()
        tableView.reloadData()
    }
    
    func loadConfigData(){
        self.config = realm.getConfig()
        print(self.config)
        self.wordDic = UtilManager.getLangs(self.config.lang)
        
        menuList = [String]()
        menuList.append(self.wordDic!["START_DATE"]!)
        menuList.append(self.wordDic!["END_DATE"]!)
        menuList.append(self.wordDic!["CSV_EXPORT"]!)
        menuList.append(self.wordDic!["DAY_BY_DAY"]!)
    }
    
    
    // テーブルの行数を返す
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuList.count
    }
    
    //表示するセルの中身
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(
            "menuCell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default,
                                   reuseIdentifier: "menuCell")
        }
        let cellTitle = menuList[indexPath.row]
        cell!.textLabel?.text = cellTitle
        cell?.backgroundColor = UIColor.whiteColor()
        //print(cell)
        
        // セルの背景色はなし
        cell!.backgroundColor = UIColor.clearColor()
        
        // 選択された背景色を白に設定
        let cellSelectedBgView = UIView()
        cellSelectedBgView.backgroundColor = CommonUtil.getSettingThemaColor().colorWithAlphaComponent(0.5)
        //cellSelectedBgView.alpha = 0.5
        cell!.selectedBackgroundView = cellSelectedBgView
        
        return cell!
    }
    
    //セルの高さ
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0//GenreTableViewCell.CELL_HEIGHT
    }

    //セルが選択された時
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("tapped row=\(indexPath.row)")
        //print(getParentViewController())
        
        switch indexPath.row {
        case 0:
            let vc = getParentViewController() as! CalViewController
            vc.showCaldatePicker("start")
        case 1:
            let vc = getParentViewController() as! CalViewController
            vc.showCaldatePicker("end")
        case 2:
            let vc = getParentViewController() as! CalViewController
            vc.sendMailWithCSV() // CSVメール送信
        case 3:
            let story = UIStoryboard(name: "CalDetail", bundle: nil)
            let vc = story.instantiateViewControllerWithIdentifier("CalAllViewController") as! CalAllViewController
            let cVC = getParentViewController() as! CalViewController
            vc.start = cVC.start
            vc.end = cVC.end
            //print("\(cVC.start) \(cVC.end)")
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    //親のビューコントローラーの取得
    func getParentViewController() -> UIViewController? {
        var responder: UIResponder? = self as? UIResponder;
        while (responder?.nextResponder() != nil) {
            responder = responder?.nextResponder()
            if let vc = responder as? UIViewController {
                return vc
            }
        }
        return nil;
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
