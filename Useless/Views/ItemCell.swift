//
//  ItemCell.swift
//  View
//
//

import UIKit

class ItemCell: UICollectionViewCell {
    
    
    override func drawRect(rect: CGRect) {
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 1.0
        
        // セルの背景色を白に指定
        self.backgroundColor = UIColor.whiteColor()
        
        // 選択時に表示するビューを指定
        //self.selectedBackgroundView = UIView(frame: self.bounds)
        //self.selectedBackgroundView!.backgroundColor = UIColor.redColor()
    }
}
