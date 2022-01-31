//
//  HUEColorPickerViewController.swift
//  Useless
//
//  Created by cano on 2016/03/14.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit

class HUEColorPickerViewController: UIViewController, SwiftHUEColorPickerDelegate {
    
    @IBOutlet weak var colorView: UIView!
    
    // MARK: - Horizontal pickers
    
    @IBOutlet weak var horizontalColorPicker: SwiftHUEColorPicker!
    @IBOutlet weak var horizontalSaturationPicker: SwiftHUEColorPicker!
    @IBOutlet weak var horizontalBrightnessPicker: SwiftHUEColorPicker!
    @IBOutlet weak var horizontalAlphaPicker: SwiftHUEColorPicker!
    
    // MARK: - Vertical pickers
    
    @IBOutlet weak var verticalColorPicker: SwiftHUEColorPicker!
    @IBOutlet weak var verticalSaturationPicker: SwiftHUEColorPicker!
    @IBOutlet weak var verticalBrightnessPicker: SwiftHUEColorPicker!
    @IBOutlet weak var verticalAlphaPicker: SwiftHUEColorPicker!
    
    let pData = PublicDatas.getPublicDatas()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        horizontalColorPicker.delegate = self
        horizontalColorPicker.direction = SwiftHUEColorPicker.PickerDirection.Horizontal
        horizontalSaturationPicker.type = SwiftHUEColorPicker.PickerType.Color
        
        horizontalSaturationPicker.delegate = self
        horizontalSaturationPicker.direction = SwiftHUEColorPicker.PickerDirection.Horizontal
        horizontalSaturationPicker.type = SwiftHUEColorPicker.PickerType.Saturation
        
        horizontalBrightnessPicker.delegate = self
        horizontalBrightnessPicker.direction = SwiftHUEColorPicker.PickerDirection.Horizontal
        horizontalBrightnessPicker.type = SwiftHUEColorPicker.PickerType.Brightness
        
        horizontalAlphaPicker.delegate = self
        horizontalAlphaPicker.direction = SwiftHUEColorPicker.PickerDirection.Horizontal
        horizontalAlphaPicker.type = SwiftHUEColorPicker.PickerType.Alpha
        
        verticalColorPicker.delegate = self
        verticalColorPicker.direction = SwiftHUEColorPicker.PickerDirection.Vertical
        verticalColorPicker.type = SwiftHUEColorPicker.PickerType.Color
        
        verticalSaturationPicker.delegate = self
        verticalSaturationPicker.direction = SwiftHUEColorPicker.PickerDirection.Vertical
        verticalSaturationPicker.type = SwiftHUEColorPicker.PickerType.Saturation
        
        verticalBrightnessPicker.delegate = self
        verticalBrightnessPicker.direction = SwiftHUEColorPicker.PickerDirection.Vertical
        verticalBrightnessPicker.type = SwiftHUEColorPicker.PickerType.Brightness
        
        verticalAlphaPicker.delegate = self
        verticalAlphaPicker.direction = SwiftHUEColorPicker.PickerDirection.Vertical
        verticalAlphaPicker.type = SwiftHUEColorPicker.PickerType.Alpha
        
        //let hex = pData.getStringForKey("themaColor")
        //if hex != "" {
            let color = CommonUtil.getSettingThemaColor()
            
            horizontalSaturationPicker.currentColor = color
            horizontalBrightnessPicker.currentColor = color
            horizontalAlphaPicker.currentColor = color
            verticalSaturationPicker.currentColor = color
            verticalBrightnessPicker.currentColor = color
            verticalAlphaPicker.currentColor = color
            
            colorView.backgroundColor = color
        //}
        initNavigationBar()
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
        titleLabel.font = UIFont(name: CommonUtil.DEFAULT_FONT_NAME_JP, size: 17)
        titleLabel.text = "テーマカラー" //NSLocalizedString("MovieListViewController_navi_title", comment: "")
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.userInteractionEnabled = false //タッチを検出しない
        titleLabel.tag = 1
        titleLabel.sizeToFit()
        titleLabel.frame.size.height = (self.navigationController?.navigationBar.frame.height)! // 英語「g」の下が切れる対策
        self.navigationItem.titleView = titleLabel
        
        self.tabBarController?.tabBar.tintColor = CommonUtil.getSettingThemaColor()
    }
    
    // MARK: - SwiftHUEColorPickerDelegate
    
    func valuePicked(color: UIColor, type: SwiftHUEColorPicker.PickerType) {
        colorView.backgroundColor = color
        
        switch type {
        case SwiftHUEColorPicker.PickerType.Color:
            horizontalSaturationPicker.currentColor = color
            horizontalBrightnessPicker.currentColor = color
            horizontalAlphaPicker.currentColor = color
            verticalSaturationPicker.currentColor = color
            verticalBrightnessPicker.currentColor = color
            verticalAlphaPicker.currentColor = color
            break
        case SwiftHUEColorPicker.PickerType.Saturation:
            horizontalColorPicker.currentColor = color
            horizontalBrightnessPicker.currentColor = color
            horizontalAlphaPicker.currentColor = color
            verticalColorPicker.currentColor = color
            verticalBrightnessPicker.currentColor = color
            verticalAlphaPicker.currentColor = color
            break
        case SwiftHUEColorPicker.PickerType.Brightness:
            horizontalColorPicker.currentColor = color
            horizontalSaturationPicker.currentColor = color
            horizontalAlphaPicker.currentColor = color
            verticalColorPicker.currentColor = color
            verticalSaturationPicker.currentColor = color
            verticalAlphaPicker.currentColor = color
            break
        case SwiftHUEColorPicker.PickerType.Alpha:
            horizontalColorPicker.currentColor = color
            horizontalSaturationPicker.currentColor = color
            horizontalBrightnessPicker.currentColor = color
            verticalColorPicker.currentColor = color
            verticalSaturationPicker.currentColor = color
            verticalBrightnessPicker.currentColor = color
            break
        }
    }
    
    // MARK: - Actions
    
    @IBAction func testButtonAction(sender: UIButton) {
        //horizontalColorPicker.currentColor = UIColor.greenColor()
        
        print(colorView.backgroundColor)
        print(UIColor.toInt32(colorView.backgroundColor!))
        
        pData.setData(String(UIColor.toInt32(colorView.backgroundColor!)), key: "themaColor")
        CommonUtil.setThemaColor(String(UIColor.toInt32(colorView.backgroundColor!)))
        
        print(UIColor(hex:Int(UIColor.toInt32(colorView.backgroundColor!)), alpha:1.0))
        
        //self.navigationController?.navigationBar.barTintColor = colorView.backgroundColor
        
        initNavigationBar()
    }
    
}

