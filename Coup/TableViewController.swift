//
//  TableViewController.swift
//  Coup
//
//  Created by jackson on 5/7/16.
//  Copyright © 2016 jackson. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate
{
    var tableView: UITableView?
    var managedObjectContext = AppDelegate.sharedAppDelegate().managedObjectContext
    var sortDescriptor: SortDescriptor?
    var viewControllerName: String?
    
    override func viewDidLoad() {
        self.tableView!.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: self.viewControllerName! + "Cell")
    }
    
    //MARK: - Setup TableView
    
    var fetchedResultsController: NSFetchedResultsController<Game> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Game>?
        
        if #available(iOS 10.0, *) {
            fetchRequest = Game.fetchRequest() as? NSFetchRequest<Game>
        } else {
            fetchRequest = NSFetchRequest(entityName: "Game")
        }
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entity(forEntityName: self.viewControllerName!, in: self.managedObjectContext!)
        fetchRequest?.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest?.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        
        fetchRequest?.sortDescriptors = [self.sortDescriptor!]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController: NSFetchedResultsController<Game> = NSFetchedResultsController(fetchRequest: fetchRequest!, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            print("%@", error)
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Game>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView!.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView!.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView!.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: AnyObject, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView!.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView!.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.configureCell(tableView!.cellForRow(at: indexPath!)!, atIndexPath: indexPath!)
        case .move:
            tableView!.deleteRows(at: [indexPath!], with: .fade)
            tableView!.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView!.endUpdates()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath) as NSManagedObject)
            
            do {
                try context.save()
            } catch {
                print(error)
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //println("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath)
    {
        //Controlled Elsewhere...
    }
}
