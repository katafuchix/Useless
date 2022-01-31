//
//  DayPieChartView.swift
//  Useless
//
//  Created by cano on 2016/04/18.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit
import Charts

class DayPieChartView: PieChartView {

    //var delegate : dayPieChartDelegate?
    
    internal override func getSelectionDetailsAtIndex(xIndex: Int) -> [ChartSelectionDetail]
    {
        print(xIndex)
        
        var vals = [ChartSelectionDetail]()
        /*
        if (self.delegate?.respondsToSelector(Selector("onClick:"))) != nil {
            self.delegate?.onClick(xIndex)
        }
        */
        return vals
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

protocol dayPieChartDelegate : NSObjectProtocol {
    
    func onClick(xIndex: Int)
    
}