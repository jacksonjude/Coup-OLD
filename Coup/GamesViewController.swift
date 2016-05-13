//
//  GamesViewController.swift
//  Coup
//
//  Created by jackson on 5/7/16.
//  Copyright © 2016 jackson. All rights reserved.
//

import UIKit
import CoreData
import GameKit

class GamesViewController: TableViewController, GKGameCenterControllerDelegate, GKMatchmakerViewControllerDelegate, GKLocalPlayerListener, GKMatchDelegate

{
    @IBOutlet weak var gamesTableView: UITableView!
    var currentGame: Game?
    var gameCenter: Bool?
    var matchStarted: Bool = false
    var currentMatch: GKMatch? = nil
    var multiplayerSceneRef: MultiplayerViewController? = nil
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view, typically from a nib.
        
        self.viewControllerName = "Game"
        self.sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        self.tableView = self.gamesTableView
        
        super.viewDidLoad()
        
        self.authenticateGameCenter()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        //Crash for corruption
        
        if self.fetchedResultsController.sections![0].numberOfObjects > 0 && self.fetchedResultsController.fetchedObjects?.count > 0
        {
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Game
            
            cell.textLabel?.font = UIFont(name: "SanFrancisco", size: 1)
            
            cell.textLabel!.text = NSString(format: "%@", object.name!) as String
        }
        else
        {
            //CORRUPPTED
        }
    }
    
    func insertNewObject(sender: AnyObject, name: String, uuid: String) {
        let context = AppDelegate.sharedAppDelegate().managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context!) as! Game
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        newManagedObject.name = "Game"
        newManagedObject.uuid = NSUUID().UUIDString
        newManagedObject.dateStarted = NSDate().dateByAddingTimeInterval(0)
        newManagedObject.dateUpdated = NSDate().dateByAddingTimeInterval(0)
        
        // Save the context.
        var error: NSError? = nil
        do {
            try context!.save()
        } catch let error1 as NSError {
            error = error1
            NSLog("%@", error!)
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        self.currentGame = newManagedObject
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.currentGame = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Game
        self.findMatchWithMinPlayers(2, maxPlayers: 2)
        
        self.performSegueWithIdentifier("enterGame", sender: self)
    }
    
    func authenticateGameCenter()
    {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController : UIViewController?, error : NSError?) -> Void in
            if ((viewController) != nil) {
                self.presentViewController(viewController!, animated: true, completion: nil)
            }
            else
            {
                if GKLocalPlayer.localPlayer().authenticated == true
                {
                    print((GKLocalPlayer.localPlayer().authenticated))
                    GKLocalPlayer.localPlayer().registerListener(self)
                    self.gameCenter = true
                }
                else
                {
                    self.gameCenter = false
                }
            }
        }
    }
    
    func gameCenterViewControllerDidFinish(gcViewController: GKGameCenterViewController)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func findMatch()
    {
        self.findMatchWithMinPlayers(2, maxPlayers: 2)
    }
    
    func findMatchWithMinPlayers(minPlayers: NSInteger, maxPlayers: NSInteger)
    {
        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers
        
        let viewControllerMatch = GKMatchmakerViewController(matchRequest: request)
        viewControllerMatch!.matchmakerDelegate = self
        
        self.showViewController(viewControllerMatch!, sender: self)
        self.navigationController?.pushViewController(viewControllerMatch!, animated: true)
    }
    
    func matchmakerViewControllerWasCancelled(viewController: GKMatchmakerViewController)
    {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func matchmakerViewController(viewController: GKMatchmakerViewController, didFailWithError error: NSError)
    {
        viewController.dismissViewControllerAnimated(true, completion: nil)
        print("Matching failed with error: \(error)")
    }
    
    func matchmakerViewController(viewController: GKMatchmakerViewController, didReceiveAcceptFromHostedPlayer playerID: String)
    {
        print("Game Accepted from player \(playerID)")
        self.performSegueWithIdentifier("enterGame", sender: self)
    }
    
    func matchmakerViewController(viewController: GKMatchmakerViewController, didFindPlayers playerIDs: [String])
    {
        print("Found Players With Name: \(playerIDs[0])")
        self.performSegueWithIdentifier("enterGame", sender: self)
    }
    
    func player(player: GKPlayer, didAcceptInvite invite: GKInvite)
    {
        self.performSegueWithIdentifier("enterGame", sender: self)
    }
    
    func matchmakerViewController(viewController: GKMatchmakerViewController, didFindMatch match: GKMatch)
    {
        if (!self.matchStarted && match.expectedPlayerCount == 0) {
            NSLog("Ready to start match!")
            print("Players: \(match.players)")
            
            self.currentMatch = match
            match.delegate = self
            
            viewController.dismissViewControllerAnimated(true, completion: {
                dispatch_async(dispatch_get_main_queue(), {
                    self.performSegueWithIdentifier("enterGame", sender: self)
                })
            })
        }
    }
    
    func match(match: GKMatch, player playerID: String, didChangeState state: GKPlayerConnectionState)
    {
        switch (state)
        {
        case .StateConnected:
            // handle a new player connection.
            NSLog("Player connected!")
            
            if (!self.matchStarted && match.expectedPlayerCount == 0)
            {
                NSLog("Ready to start match!")
                self.currentMatch = match
                match.delegate = self
            }
            
            break
        case .StateDisconnected:
            // a player just disconnected.
            NSLog("Player disconnected!")
            self.matchStarted = false
            break
        default:
            _ = "BLAHBLAHBLAH"
        }
    }
    
    func match(match: GKMatch, shouldReinviteDisconnectedPlayer player: GKPlayer) -> Bool
    {
        return true
    }
    
    func match(matchCurrent: GKMatch, didReceiveData data: NSData, fromRemotePlayer player: GKPlayer)
    {
        self.multiplayerSceneRef!.saveDataRecived(data, fromMatch: matchCurrent, fromPlayer: player.playerID!)
    }
    
    func match(matchCurrent: GKMatch, didReceiveData data: NSData, fromPlayer playerID: String)
    {
        self.multiplayerSceneRef!.saveDataRecived(data, fromMatch: matchCurrent, fromPlayer: playerID)
    }
    
    func sendData(matchCurrent: GKMatch!, withData data: NSData!)
    {
        do {
            try matchCurrent.sendDataToAllPlayers(data, withDataMode: GKMatchSendDataMode.Unreliable)
        } catch _ {
        }
    }
    
    @IBAction func addNewMatch(sender: AnyObject)
    {
        self.insertNewObject(self, name: "Game", uuid: NSUUID().UUIDString)
        
        self.findMatchWithMinPlayers(2, maxPlayers: 2)
        
        self.performSegueWithIdentifier("enterGame", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let controller = segue.destinationViewController as! MultiplayerViewController
        controller.game = self.currentGame
        controller.gamesViewController = self
        controller.match = self.currentMatch
        
        self.multiplayerSceneRef = controller
        
        if let indexPath = self.tableView!.indexPathForSelectedRow {
            self.tableView!.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    @IBAction func exitMultiplayerView(segue: UIStoryboardSegue)
    {
        NSLog("Exiting Multiplayer View")
        
        /*let multiplayerViewController = segue.sourceViewController as! MultiplayerViewController
        let game = multiplayerViewController.game*/
    }
}

