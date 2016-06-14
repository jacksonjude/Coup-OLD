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
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OpponentCell", for: indexPath)
        cell.backgroundColor = UIColor.black()
        
        return cell
    }
    
    @IBAction func cellDoubleTapped(_ sender: AnyObject)
    {
        let gestureRecognizer = sender as! UITapGestureRecognizer
        let tappedCell = gestureRecognizer.view as! UICollectionViewCell
        if self.collectionView!.indexPathsForSelectedItems()![0] == self.collectionView!.indexPath(for: tappedCell)
        {
            print("Play Action Here")
            
            self.multiplayerViewController!.playAction()
        }
    }
}
