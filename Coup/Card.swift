//
//  Card.swift
//  Coup
//
//  Created by jackson on 6/13/16.
//  Copyright © 2016 jackson. All rights reserved.
//

import Foundation

class Card
{
    enum CardType: NSNumber
    {
        case None
        case Duke
        case Assasin
        case Amassator
        case Captian
        case Contessa
    }
    
    var cardType = CardType.None
    
    init(type: NSNumber)
    {
        self.cardType = CardType(rawValue: type)!
    }
    
    init(type: CardType)
    {
        self.cardType = type
    }
    
    func canDefend(action: Action.ActionType) -> Bool
    {
        var defendableActions: [Action.ActionType] = []
        switch self.cardType
        {
        case .Duke:
            defendableActions.append(.ForeinAid)
        case .Assasin:
            break
        case .Amassator:
            defendableActions.append(.Steal)
        case .Captian:
            defendableActions.append(.Steal)
        case .Contessa:
            defendableActions.append(.Assasinate)
        case .None:
            break
        }
        
        for defendableAction in defendableActions
        {
            if defendableAction == action
            {
                return true
            }
        }
        
        return false
    }
}