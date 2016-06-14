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
        case none
        case duke
        case assasin
        case amassator
        case captian
        case contessa
    }
    
    var cardType = CardType.none
    
    init(type: NSNumber)
    {
        self.cardType = CardType(rawValue: type)!
    }
    
    init(type: CardType)
    {
        self.cardType = type
    }
    
    func canDefend(_ action: Action.ActionType) -> Bool
    {
        var defendableActions: [Action.ActionType] = []
        switch self.cardType
        {
        case .duke:
            defendableActions.append(.foreinAid)
        case .assasin:
            break
        case .amassator:
            defendableActions.append(.steal)
        case .captian:
            defendableActions.append(.steal)
        case .contessa:
            defendableActions.append(.assasinate)
        case .none:
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
