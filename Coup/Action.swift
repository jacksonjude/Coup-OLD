//
//  Action.swift
//  Coup
//
//  Created by jackson on 6/10/16.
//  Copyright © 2016 jackson. All rights reserved.
//

import Foundation
import GameKit
import CoreData

class Action
{
    enum ActionType
    {
        case none
        case assasinate
        case steal
        case coup
        case foreinAid
        case exchange
        
        func defendable() -> Bool
        {
            switch self {
            case .assasinate:
                return true
            case .steal:
                return true
            case .foreinAid:
                return true
            case .exchange:
                return false
            case .coup:
                return false
            default:
                return false
            }
        }
    }
    
    var actionType: ActionType
    var attackingPlayer: NSNumber
    var defendingPlayer: NSNumber
    var lie: Bool
    
    init(actionType: ActionType, attackingPlayer: NSNumber, defendingPlayer: NSNumber, lie: Bool)
    {
        self.actionType = actionType
        self.attackingPlayer = attackingPlayer
        self.defendingPlayer = defendingPlayer
        self.lie = lie
    }
}
