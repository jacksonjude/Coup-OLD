//
//  OpponentCollectionViewController.swift
//  Coup
//
//  Created by jackson on 5/13/16.
//  Copyright © 2016 jackson. All rights reserved.
//

import Foundation
import UIKit
import GameKit

class OpponentsViewController: UICollectionViewController
{
    @IBOutlet var opponentsView: UICollectionView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 2
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 2
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("OpponentCell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.blackColor()
        
        return cell
    }
    
    
}