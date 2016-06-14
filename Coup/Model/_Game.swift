// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Game.swift instead.

import CoreData

public enum GameAttributes: String {
    case cards = "cards"
    case dateStarted = "dateStarted"
    case dateUpdated = "dateUpdated"
    case name = "name"
    case turn = "turn"
    case uuid = "uuid"
}

public class _Game: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Game"
    }

    public class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Game.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var cards: Data?

    @NSManaged public
    var dateStarted: Date?

    @NSManaged public
    var dateUpdated: Date?

    @NSManaged public
    var name: String?

    @NSManaged public
    var turn: NSNumber?

    @NSManaged public
    var uuid: String?

    // MARK: - Relationships

}

