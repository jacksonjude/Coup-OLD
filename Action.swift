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
        case None
        case Assasinate
        case Steal
        case Coup
        
        func defendable() -> Bool
        {
            switch self {
            case .Assasinate:
                return true
            case .Steal:
                return true
            case .Coup:
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