//
//  Coin.swift
//  Coup
//
//  Created by jackson on 5/8/16.
//  Copyright © 2016 jackson. All rights reserved.
//

import Foundation
import UIKit

class Coin: UIImageView, UIGestureRecognizerDelegate
{
    var selected = false
    var selectable = true
    
    init()
    {
        super.init(image: UIImage(named: "coin"))
        
        self.image = UIImage(named: "coin")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}