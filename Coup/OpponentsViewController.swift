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
    var numberOfPlayers: Int?
    var selectedPlayer = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if self.multiplayerViewController?.playerNumber == 1
        {
            self.selectedPlayer = 2
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.numberOfPlayers!
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OpponentCell", for: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureCell(_ cell: UICollectionViewCell, atIndexPath indexPath: IndexPath) {
        let playerImageView = cell.contentView.viewWithTag(500) as! UIImageView
        let coinCount = cell.contentView.viewWithTag(501) as! UILabel
        let cardCount = cell.contentView.viewWithTag(502) as! UILabel
        self.multiplayerViewController?.gamesViewController?.currentMatch?.players[indexPath.hashValue].loadPhoto(forSize: 1, withCompletionHandler: { (photo: UIImage?, error: NSError?) -> Void in
                if error == nil
                {
                    playerImageView.image = photo!
                }
                else
                {
                    print("Error: \(error)")
                }
        })
        
        coinCount.text = "3"
        cardCount.text = "2"
    }
    
    @IBAction func cellDoubleTapped(_ sender: AnyObject)
    {
        let gestureRecognizer = sender as! UITapGestureRecognizer
        let tappedCell = gestureRecognizer.view as! UICollectionViewCell
        if self.collectionView!.indexPathsForSelectedItems()![self.selectedPlayer] == self.collectionView!.indexPath(for: tappedCell)
        {
            print("Play Action Here")
            
            self.multiplayerViewController!.playAction()
        }
    }
}
