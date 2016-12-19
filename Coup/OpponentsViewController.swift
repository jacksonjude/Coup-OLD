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
        
        self.numberOfPlayers = self.multiplayerViewController?.match?.players.count.hashValue
        
        if self.multiplayerViewController?.playerNumber == 1
        {
            self.selectedPlayer = 2
            self.multiplayerViewController?.targetPlayer = 2
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        print("Number of players: \(self.numberOfPlayers)")
        return self.numberOfPlayers!+1
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
        let playerName = cell.contentView.viewWithTag(503) as! UILabel
        
        if self.multiplayerViewController?.match?.players[indexPath.endIndex-2] != nil
        {
            self.multiplayerViewController?.match?.players[indexPath.endIndex-2].loadPhoto(forSize: 1, withCompletionHandler: { (photo: UIImage?, error: NSError?) -> Void in
                if error == nil
                {
                    playerImageView.image = photo!
                }
                else
                {
                    print("Error: \(error)")
                    
                    print("Using generic photo")
                    playerImageView.image = #imageLiteral(resourceName: "genericAvatar")
                }
            })
            
            playerName.text = self.multiplayerViewController?.match?.players[indexPath.endIndex-2].alias
        }
        
        coinCount.text = "2 coins"
        cardCount.text = "2 cards"
    }
    
    func updateStatus(alias: String, coins: Int, cards: Int)
    {
        for cell in self.collectionView!.visibleCells()
        {
            let playerNameLabel = cell.contentView.viewWithTag(503) as! UILabel
            
            if playerNameLabel.text == alias
            {
                let coinCount = cell.contentView.viewWithTag(501) as! UILabel
                let cardCount = cell.contentView.viewWithTag(502) as! UILabel
                
                if coinCount != 1
                {
                    coinCount.text = String(coins) + "coins"
                }
                else
                {
                    coinCount.text = "1 coin"
                }
                
                if cardCount != 1
                {
                    coinCount.text = String(cards) + " cards"
                }
                else
                {
                    cardCount.text = "1 card"
                }
            }
        }
    }
    
    @IBAction func cellDoubleTapped(_ sender: AnyObject)
    {
        let gestureRecognizer = sender as! UITapGestureRecognizer
        let tappedCell = gestureRecognizer.view as! UICollectionViewCell
        
        let hostNumbers = self.multiplayerViewController!.hostNumbers
        let targetAliasLabel = tappedCell.contentView.viewWithTag(503) as! UILabel
        let targetAlias = targetAliasLabel.text!
        let aliasDictionary = self.multiplayerViewController!.playerAlias
        
        self.multiplayerViewController!.targetPlayer = hostNumbers.index(of: aliasDictionary[targetAlias]!)!+1
        
        print("Playing Action...")
            
        self.multiplayerViewController!.playAction()
    }
}
