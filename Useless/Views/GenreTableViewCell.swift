//
//  GenreTableViewCell.swift
//  Useless
//
//  Created by cano on 2016/02/28.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit

class GenreTableViewCell: UITableViewCell {

    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var colorImageView: UIImageView!
    static var CELL_HEIGHT: CGFloat = 50.0
    
    var genre : Genre?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //セルの描画処理
    override func drawRect(rect: CGRect) {
        if(self.genre != nil ){
            //drawColorRect(UIColor.hexStr((genre?.color)!, alpha: 1))
            let view = UIView(frame: CGRectMake(0, 0, 30, 30))
            //view.backgroundColor = UIColor.hexStr((genre?.color)!, alpha: 1)
            view.backgroundColor =  UIColor(hex: Int((genre?.color)!)!, alpha: 1.0)
            let colorImg = UtilManager.getUIImageFromUIView(view)
            colorImageView.image = colorImg
        }
        drawLine(CGPointMake(0, self.frame.height), to: CGPointMake(self.frame.width, self.frame.height), width: 1.0)
        //genreLabel.hidden = true
        //genreLabel.backgroundColor = UIColor.grayColor()
        genreLabel.sizeToFit()
    }
    //色の四角を描画する
    private func drawColorRect(color: UIColor) {
        //let rectangle = UIBezierPath(rect: CGRectMake(16, 10, 30, 30))
        let rectangle = UIBezierPath(rect: CGRectMake(0, 0, 30, 30))
        color.setFill()
        rectangle.fill()
    }
    /*
    // セルに線を引く
    private func drawLine(from: CGPoint, to: CGPoint, color: UIColor = UIColor.grayColor()) {
        let line = UIBezierPath()
        line.moveToPoint(from)
        line.addLineToPoint(to)
        color.setStroke()
        line.lineWidth = 0.5
        line.stroke();
    }
    */
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
