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

class Action: NSObject, NSCoding
{
    enum ActionType: String
    {
        case none
        case assasinate
        case steal
        case coup
        case foreignAid
        case exchange
        
        func defendable() -> Bool
        {
            switch self {
            case .assasinate:
                return true
            case .steal:
                return true
            case .foreignAid:
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
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.actionType.rawValue, forKey: "actionType")
        aCoder.encode(Int(self.attackingPlayer), forKey: "attackingPlayer")
        aCoder.encode(Int(self.defendingPlayer), forKey: "defendingPlayer")
        aCoder.encode(self.lie, forKey: "lie")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.actionType = ActionType(rawValue: aDecoder.decodeObject(forKey: "actionType") as! String)!
        self.attackingPlayer = aDecoder.decodeInteger(forKey: "attackingPlayer")
        self.defendingPlayer = aDecoder.decodeInteger(forKey: "defendingPlayer")
        self.lie = aDecoder.decodeBool(forKey: "lie")
    }
}
