//
//  SlideMenu.swift
//  Useless
//
//  Created by cano on 2016/05/11.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit

class SlideMenu: UIView {

    @IBOutlet var button: UIButton!
    
    @IBOutlet var twitterButton: UIButton!
    
    @IBOutlet var fbButton: UIButton!
    
    @IBOutlet var lineButton: UIButton!
    
    @IBOutlet var mailButton: UIButton!
    
    @IBOutlet var photoButton: UIButton!
    
    let cornerRadius = 10.0
    
    override func awakeFromNib() {
        //print(button)
        
        twitterButton.layer.cornerRadius = 10.0
        twitterButton.clipsToBounds = (cornerRadius > 0)
        
        fbButton.layer.cornerRadius = 10.0
        fbButton.clipsToBounds = (cornerRadius > 0)
        
        lineButton.layer.cornerRadius = 10.0
        lineButton.clipsToBounds = (cornerRadius > 0)
        
        mailButton.layer.cornerRadius = 10.0
        mailButton.clipsToBounds = (cornerRadius > 0)
        
        photoButton.layer.cornerRadius = 10.0
        photoButton.clipsToBounds = (cornerRadius > 0)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
