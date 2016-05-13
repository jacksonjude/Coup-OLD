//
//  MultiplayerViewController.swift
//  Coup
//
//  Created by jackson on 5/7/16.
//  Copyright © 2016 jackson. All rights reserved.
//

import Foundation
import CoreData
import GameKit
import GameplayKit

class MultiplayerViewController: UIViewController
{
    var gamesViewController: GamesViewController?
    var currentView: MultiplayerViewController?
    var game: Game?
    var match: GKMatch?
    var hostNumber: NSNumber?
    var host = false
    var hostNumbers: [Int] = []
    var playerCount = 0
    var playerNumber = 0
    var recivedTurns = 0
    var cards: [Int] = []
    var coins: [Coin] = []
    var playerGoing = 1
    var coinsMovedThisTurn = false
    var targetPlayer = 0
    var playerSelected = false
    var selectedMove = ""
    var cardsFlipped: [Bool] = [false, false]
    
    @IBOutlet weak var firstCard: UIImageView!
    @IBOutlet weak var secondCard: UIImageView!
    @IBOutlet weak var opponentFeild: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.currentView = self
        self.playerCount = self.match!.players.count
        self.coins = [Coin(), Coin(), Coin()]
        
        for coin in self.coins
        {
            coin.frame = CGRectMake(CGRectGetMinX(self.view.frame)+50, CGRectGetMaxY(self.view.frame)-50, 30, 30)
            
            self.view.addSubview(coin)
        }
        
        let background = UIImageView()
        background.image = UIImage(named: "background")
        background.frame = CGRectMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame), 736, 736)
        background.center = CGPoint(x: CGRectGetMidX(self.view.frame), y: CGRectGetMidY(self.view.frame))
        self.view.addSubview(background)
        self.view.sendSubviewToBack(background)
        
        self.coins[0].frame = CGRectMake(CGRectGetMinX(self.view.frame)+50, CGRectGetMaxY(self.view.frame)-50, 30, 30)
        
        self.coins[1].frame = CGRectMake(CGRectGetMinX(self.view.frame)+100, CGRectGetMaxY(self.view.frame)-50, 30, 30)
        
        self.coins[2].frame = CGRectMake(CGRectGetMinX(self.view.frame)+150, CGRectGetMaxY(self.view.frame)-50, 30, 30)
        
        self.hostNumber = NSNumber(unsignedInt: arc4random())
        self.hostNumbers.insert(Int(self.hostNumber!), atIndex: self.hostNumbers.count)
        
        let hostData = self.formatData(["message", "host"], values: ["hostNumber", self.hostNumber!])
        self.gamesViewController!.sendData(self.match, withData: hostData)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        for coin in self.coins
        {
            if coin.selectable && coin.selected
            {
                let touch : UITouch! = touches.first! as UITouch
                let location = touch.locationInView(self.view)
                
                coin.center = location
                
                self.coinsMovedThisTurn = true
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if !self.coinsMovedThisTurn
        {
            for coin in self.coins
            {
                if coin.selectable && CGRectContainsPoint(coin.frame, touches.first!.locationInView(self.view))
                {
                    coin.selected = !coin.selected
                    if coin.selected == false
                    {
                        coin.image = UIImage(named: "coin")
                    }
                    
                    var coinsSelected = 0
                    var move = ""
                    
                    for coinSelectedTest in self.coins
                    {
                        if coinSelectedTest.selected
                        {
                            coinsSelected += 1
                        }
                    }
                    
                    if coinsSelected == 3
                    {
                        move = "assasinate"
                    }
                    
                    if coinsSelected == 7
                    {
                        move = "coup"
                    }
                    
                    if coinsSelected == 0 && self.playerSelected
                    {
                        move = "steal"
                    }
                    
                    var lie = false
                    var confirmed = false
                    
                    for card in self.cards
                    {
                        if !confirmed
                        {
                            if card == 1 && move == "assasinate" && !confirmed
                            {
                                lie = false
                                confirmed = true
                            }
                            else
                            {
                                lie = true
                            }
                        }
                        
                        if !confirmed
                        {
                            if card == 3 && move == "steal" && !confirmed
                            {
                                lie = false
                                confirmed = true
                            }
                            else
                            {
                                lie = true
                            }
                        }
                    }
                    
                    if move != ""
                    {
                        if lie == true
                        {
                            for coinToChange in self.coins
                            {
                                if coinToChange.selected
                                {
                                    coinToChange.image = UIImage(named: "coinLie")
                                }
                            }
                        }
                        else
                        {
                            for coinToChange in self.coins
                            {
                                if coinToChange.selected
                                {
                                    coinToChange.image = UIImage(named: "coinTrue")
                                }
                            }
                        }
                    }
                    else
                    {
                        for coinToChange in self.coins
                        {
                            if coinToChange.selected
                            {
                                coinToChange.image = UIImage(named: "coinSelected")
                            }
                        }
                    }
                }
            }
        }
        else
        {
            self.coinsMovedThisTurn = false
            if CGRectContainsPoint(self.opponentFeild.frame, touches.first!.locationInView(self.view))
            {
                var coinsSelected = 0
                var move = ""
                
                for coin in self.coins
                {
                    if coin.selected
                    {
                        coinsSelected += 1
                    }
                }
                
                if coinsSelected == 3
                {
                    move = "assasinate"
                }
                
                if coinsSelected == 7
                {
                    move = "coup"
                }
                
                if coinsSelected == 0 && self.playerSelected
                {
                    move = "steal"
                }
                
                var lie = false
                var confirmed = false
                
                for card in self.cards
                {
                    if card == 1 && move == "assasinate" && !confirmed
                    {
                        lie = false
                        confirmed = true
                    }
                    else
                    {
                        lie = true
                    }
                    
                    if card == 3 && move == "steal" && !confirmed
                    {
                        lie = false
                        confirmed = true
                    }
                    else
                    {
                        lie = true
                    }
                }
                
                let moveData = self.formatData(["message", "move", "lie", "targetPlayer"], values: ["playAction", move, lie, targetPlayer])
                self.gamesViewController!.sendData(self.match, withData: moveData)
            }
        }
    }
    
    func formatData(keys: [String], values: [AnyObject]) -> NSData
    {
        let messageData = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: messageData)
        
        for key in keys
        {
            let pos = keys.indexOf(key)
            let value = values[pos!]
            
            archiver.encodeObject(value, forKey: key)
        }
        
        archiver.finishEncoding()
        
        return messageData
    }
    
    func saveDataRecived(data: NSData, fromMatch: GKMatch, fromPlayer: String)
    {
        let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
        let message = unarchiver.decodeObjectForKey("message") as? NSString
        if message == "hostNumber"
        {
            let recivedHostNumber = unarchiver.decodeObjectForKey("host") as! NSNumber
            self.hostNumbers.insert(Int(recivedHostNumber), atIndex: self.hostNumbers.count)
            
            if self.hostNumbers.count == self.playerCount+1
            {
                if self.hostNumber == nil
                {
                    self.hostNumber = NSNumber(unsignedInt: arc4random())
                }
                
                if Int(self.hostNumber!) == self.hostNumbers.maxElement()
                {
                    self.host = true
                }
                
                print("Host:")
                print(self.host)
                
                self.hostNumbers.sortInPlace {
                    return $0 < $1
                }
                
                if self.host
                {
                    self.playerNumber = self.playerCount+1
                    
                    var playerNumber = 1
                    
                    for otherHostNumber in self.hostNumbers
                    {
                        let turnOrder = self.formatData(["message", "playerOrder", "hostNumber"], values: ["turnOrder", playerNumber, otherHostNumber])
                        self.gamesViewController!.sendData(self.match, withData: turnOrder)
                        
                        playerNumber += 1
                    }
                    
                    print("PlayerNumber:")
                    print(self.playerNumber)
                    
                    self.loadCards()
                }
            }
        }
        
        if message == "turnOrder"
        {
            let testHostNumber = unarchiver.decodeObjectForKey("hostNumber") as! NSNumber
            if testHostNumber == self.hostNumber
            {
                let playerOrder = unarchiver.decodeObjectForKey("playerOrder") as! NSNumber
                self.playerNumber = Int(playerOrder)
                
                print("PlayerNumber:")
                print(self.playerNumber)
            }
            else
            {
                self.recivedTurns += 1
            }
        }
        
        if message == "playAction"
        {
            
        }
        
        if message == "endTurn"
        {
            self.playerGoing += 1
            
            if self.playerGoing > self.playerCount+1
            {
                self.playerGoing = 1
            }
            
            if self.playerGoing == self.playerNumber
            {
                self.startTurn()
            }
        }
        
        if message == "cards"
        {
            let playerRecivedCards = unarchiver.decodeObjectForKey("player") as! Int
            if playerRecivedCards+1 == self.playerNumber
            {
                let recivedCards = unarchiver.decodeObjectForKey("cards") as! [Int]
                self.cards = recivedCards
                
                self.setCardImages(true, secondCardShouldDraw: true)
            }
        }
    }
    
    func loadCards()
    {
        var deck: [Int] = []
        
        for _ in 0..<5
        {
            for card in 0..<5
            {
                deck.insert(card, atIndex: deck.count)
            }
        }
        
        let shuffledDeck = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(deck) as! [Int]
        
        var cardNumber = 0
        for currentPlayerNumber in 0..<self.playerCount+1
        {
            let cards = [shuffledDeck[cardNumber], shuffledDeck[cardNumber+1]]
            
            if currentPlayerNumber+1 != self.playerNumber
            {
                let cardData = self.formatData(["message", "cards", "player"], values: ["cards", cards, currentPlayerNumber])
                self.gamesViewController!.sendData(self.match, withData: cardData)
            }
            else
            {
                self.cards = cards
                
                self.setCardImages(true, secondCardShouldDraw: true)
            }
            
            cardNumber += 2
        }
        
        if self.playerNumber == 1
        {
            self.startTurn()
        }
    }
    
    func setCardImages(firstCardShouldDraw: Bool, secondCardShouldDraw: Bool)
    {
        var imageNumber = 0
        
        for card in self.cards
        {
            var cardType = ""
            if card == 0
            {
                cardType = "jack"
            }
            
            if card == 1
            {
                cardType = "ace"
            }
            
            if card == 2
            {
                cardType = "10"
            }
            
            if card == 3
            {
                cardType = "king"
            }
            
            if card == 4
            {
                cardType = "queen"
            }
            
            if imageNumber == 0
            {
                if firstCardShouldDraw
                {
                    self.firstCard.image = UIImage(named: cardType)
                }
            }
            else
            {
                if secondCardShouldDraw
                {
                    self.secondCard.image = UIImage(named: cardType)
                }
            }
            
            print("Got " + cardType)
            
            imageNumber += 1
        }
    }
    
    func startTurn()
    {
        for coin in self.coins
        {
            coin.selectable = true
        }
    }
    
    @IBAction func tappedCard1(sender: AnyObject)
    {
        self.flipCard(1)
    }
    
    @IBAction func tappedCard2(sender: AnyObject)
    {
        self.flipCard(2)
    }
    
    func flipCard(cardOrig: Int)
    {
        let card = cardOrig - 1
        
        self.cardsFlipped[card] = !self.cardsFlipped[card]
        
        if self.cardsFlipped[card]
        {
            if card == 0
            {
                self.firstCard.image = UIImage(named: "backCard")
            }
            else
            {
                self.secondCard.image = UIImage(named: "backCard")
            }
        }
        else
        {
            if card == 0
            {
                self.setCardImages(true, secondCardShouldDraw: false)
            }
            else
            {
                self.setCardImages(false, secondCardShouldDraw: true)
            }
        }
    }
    
    func organizeCoins()
    {
        let xPos: [CGFloat] = [50, 100, 150]
        let yPos: [CGFloat] = [-50, -50, -50]
        
        var coinNumber = 0
        
        for coin in self.coins
        {
            coin.frame = CGRectMake(CGRectGetMinX(self.view.frame)+xPos[coinNumber], CGRectGetMaxY(self.view.frame)+yPos[coinNumber], 30, 30)
            
            coinNumber += 1
        }
    }
}