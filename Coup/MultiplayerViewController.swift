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
    var cards: [Card] = []
    var coins: [Coin] = []
    var playerGoing = 1
    var targetPlayer = 1
    var playerSelected = false
    var selectedMove = ""
    var cardsFlipped: [Bool] = [false, false]
    var opponentPressTimer = Date()
    var canChallenge = false
    var initilizeProcess = true
    
    @IBOutlet weak var firstCard: UIImageView!
    @IBOutlet weak var secondCard: UIImageView!
    @IBOutlet weak var opponentsViewControllerContainer: UIView!
    @IBOutlet weak var challengeButton: UIButton!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var acceptActionButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.currentView = self
        self.playerCount = self.match!.players.count
        self.coins = [Coin(), Coin(), Coin()]
        
        for coin in self.coins
        {
            coin.frame = CGRect(x: self.view.frame.minX+50, y: self.view.frame.maxY-50, width: 30, height: 30)
            
            self.view.addSubview(coin)
        }
        
        self.toggleChallengeButton()
        
        let background = UIImageView()
        background.image = UIImage(named: "background")
        background.frame = CGRect(x: self.view.frame.midX, y: self.view.frame.midY, width: 736, height: 736)
        background.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY)
        self.view.addSubview(background)
        self.view.sendSubview(toBack: background)
        
        self.coins[0].frame = CGRect(x: self.view.frame.minX+50, y: self.view.frame.maxY-50, width: 30, height: 30)
        
        self.coins[1].frame = CGRect(x: self.view.frame.minX+100, y: self.view.frame.maxY-50, width: 30, height: 30)
        
        self.coins[2].frame = CGRect(x: self.view.frame.minX+150, y: self.view.frame.maxY-50, width: 30, height: 30)
        
        self.hostNumber = NSNumber(value: arc4random())
        self.hostNumbers.insert(Int(self.hostNumber!), at: self.hostNumbers.count)
        
        let hostData = self.formatData(["message", "host"], values: ["hostNumber", self.hostNumber!])
        self.gamesViewController!.sendData(self.match, withData: hostData)
    }
    
    func toggleChallengeButton()
    {
        self.canChallenge = !self.canChallenge
        
        if self.canChallenge
        {
            self.challengeButton.isEnabled = true
        }
        else
        {
            self.challengeButton.isEnabled = false
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for coin in self.coins
        {
            if coin.selectable && coin.frame.contains(touches.first!.location(in: self.view))
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
                        if card.cardType == .assasin && move == "assasinate" && !confirmed
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
                        if card.cardType == .captian && move == "steal" && !confirmed
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
        
        if self.firstCard.frame.contains(touches.first!.location(in: self.view))
        {
            self.flipCard(1)
        }
        
        if self.secondCard.frame.contains(touches.first!.location(in: self.view))
        {
            self.flipCard(2)
        }
    }
    
    func formatData(_ keys: [String], values: [AnyObject]) -> Data
    {
        let messageData = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: messageData)
        
        for key in keys
        {
            let pos = keys.index(of: key)
            let value = values[pos!]
            
            archiver.encode(value, forKey: key)
        }
        
        archiver.finishEncoding()
        
        return messageData as Data
    }
    
    func saveDataRecived(_ data: Data, fromMatch: GKMatch, fromPlayer: String)
    {
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        let message = unarchiver.decodeObject(forKey: "message") as? NSString
        if message == "hostNumber"
        {
            let recivedHostNumber = unarchiver.decodeObject(forKey: "host") as! NSNumber
            self.hostNumbers.insert(Int(recivedHostNumber), at: self.hostNumbers.count)
            
            if self.hostNumbers.count == self.playerCount+1
            {
                if self.hostNumber == nil
                {
                    self.hostNumber = NSNumber(value: arc4random())
                }
                
                if Int(self.hostNumber!) == self.hostNumbers.max()
                {
                    self.host = true
                }
                
                print("Host: \(self.host)")
                
                self.hostNumbers.sort {
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
                    
                    print("PlayerNumber: \(self.playerNumber)")
                    
                    self.loadCards()
                }
            }
        }
        
        if message == "turnOrder"
        {
            let playerOrder = unarchiver.decodeObject(forKey: "playerOrder") as! NSNumber
            let testHostNumber = unarchiver.decodeObject(forKey: "hostNumber") as! NSNumber
            if testHostNumber == self.hostNumber
            {
                self.playerNumber = Int(playerOrder)
                
                print("PlayerNumber: \(self.playerNumber)")
            }
            else
            {
                self.recivedTurns += 1
            }
            
            //undo
            self.targetPlayer = Int(playerOrder)
        }
        
        if message == "playAction"
        {
            print("Recived Action...")
            
            let action = unarchiver.decodeObject(forKey: "action") as! Action
            
            if action.defendingPlayer == self.playerNumber
            {
                let lie = action.lie
                let move: Action.ActionType = action.actionType
                let opposingPlayer = action.attackingPlayer
                
                print("Player \(opposingPlayer) \(move)s You!")
                
                if move == .assasinate
                {
                    print("Choose a card to lose or block this action")
                }
                
                if move == .steal
                {
                    print("Block this action or agree")
                }
                
                if move == .coup
                {
                    print("Choose a card to lose")
                }
                
                print("This is a lie: \(lie)")
                
                self.defendAction(action)
            }
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
            let playerRecivedCards = unarchiver.decodeObject(forKey: "player") as! Int
            if playerRecivedCards+1 == self.playerNumber
            {
                let recivedCards = unarchiver.decodeObject(forKey: "cards") as! [Card]
                self.cards = recivedCards
                
                self.setCardImages(true, secondCardShouldDraw: true)
            }
        }
    }
    
    func loadCards()
    {
        var deck: [Int] = []
        
        for _ in 1..<4
        {
            for card in 1..<4
            {
                deck.insert(card, at: deck.count)
            }
        }
        
        let shuffledDeck = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: deck) as! [Int]
        var cardDeck: [Card] = []
        
        for integerCard in shuffledDeck
        {
            cardDeck.append(Card(type: integerCard))
        }
        
        var cardNumber = 0
        for currentPlayerNumber in 0..<self.playerCount+1
        {
            let cards = [cardDeck[cardNumber], cardDeck[cardNumber+1]]
            
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
        
        self.initilizeProcess = false
    }
    
    func setCardImages(_ firstCardShouldDraw: Bool, secondCardShouldDraw: Bool)
    {
        var imageNumber = 0
        
        for card in self.cards
        {
            var cardType = ""
            if card.cardType == .duke
            {
                cardType = "jack"
            }
            
            if card.cardType == .assasin
            {
                cardType = "ace"
            }
            
            if card.cardType == .amassator
            {
                cardType = "10"
            }
            
            if card.cardType == .captian
            {
                cardType = "king"
            }
            
            if card.cardType == .contessa
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
            
            if self.initilizeProcess
            {
                print("Got " + cardType)
            }
            
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
    
    func flipCard(_ cardOrig: Int)
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
    
    @IBAction func challengeTapped(_ sender: AnyObject)
    {
        //Challenge Here
    }
    
    func organizeCoins()
    {
        let xPos: [CGFloat] = [50, 100, 150]
        let yPos: [CGFloat] = [-50, -50, -50]
        
        var coinNumber = 0
        
        for coin in self.coins
        {
            coin.frame = CGRect(x: self.view.frame.minX+xPos[coinNumber], y: self.view.frame.maxY+yPos[coinNumber], width: 30, height: 30)
            
            coinNumber += 1
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "openOpponentsView"
        {
            let opponentsView = segue.destinationViewController as! OpponentsViewController
            opponentsView.multiplayerViewController = self
            opponentsView.numberOfPlayers = self.playerCount
        }
    }
    
    func playAction()
    {
        var coinsSelected = 0
        var move: Action.ActionType = .none
        
        for coin in self.coins
        {
            if coin.selected
            {
                coinsSelected += 1
            }
        }
        
        if coinsSelected == 3
        {
            move = .assasinate
        }
        
        if coinsSelected == 7
        {
            move = .coup
        }
        
        if coinsSelected == 0 && self.playerSelected
        {
            move = .steal
        }
        
        var lie = false
        var confirmed = false
        
        for card in self.cards
        {
            if !confirmed
            {
                if card.cardType == .assasin && move == .assasinate && !confirmed
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
                if card.cardType == .captian && move == .steal && !confirmed
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
        
        let action = Action(actionType: move, attackingPlayer: self.playerNumber as NSNumber, defendingPlayer: self.targetPlayer as NSNumber, lie: lie)
        
        let moveData = self.formatData(["message", "action"], values: ["playAction", action])
        self.gamesViewController!.sendData(self.match, withData: moveData)
    }
    
    func defendAction(_ currentAction: Action)
    {
        let move = currentAction.actionType
        
        if move.defendable()
        {
            self.blockButton.isEnabled = true
            for card in self.cards
            {
                if card.canDefend(move)
                {
                    self.blockButton.setTitleColor(UIColor.green(), for: [])
                }
                else
                {
                    self.blockButton.setTitleColor(UIColor.red(), for: [])
                }
            }
        }
    }
}
