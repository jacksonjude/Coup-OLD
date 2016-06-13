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
    var multiplayerViewController: MultiplayerViewController?
    
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
    
    @IBAction func cellDoubleTapped(sender: AnyObject)
    {
        let gestureRecognizer = sender as! UITapGestureRecognizer
        let tappedCell = gestureRecognizer.view as! UICollectionViewCell
        if self.collectionView!.indexPathsForSelectedItems()![0] == self.collectionView!.indexPathForCell(tappedCell)
        {
            print("Play Action Here")
            
            self.multiplayerViewController!.playAction()
        }
    }
}