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
        self.sortDescriptor = SortDescriptor(key: "name", ascending: true)
        self.tableView = self.gamesTableView
        
        super.viewDidLoad()
        
        self.authenticateGameCenter()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        //Crash for corruption
        
        if self.fetchedResultsController.sections![0].numberOfObjects > 0 && self.fetchedResultsController.fetchedObjects?.count > 0
        {
            let object = self.fetchedResultsController.object(at: indexPath) 
            
            cell.textLabel?.font = UIFont(name: "SanFrancisco", size: 1)
            
            cell.textLabel!.text = NSString(format: "%@", object.name!) as String
        }
        else
        {
            //CORRUPPTED
        }
    }
    
    func insertNewObject(_ sender: AnyObject, name: String, uuid: String) {
        let context = AppDelegate.sharedAppDelegate().managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let newManagedObject = NSEntityDescription.insertNewObject(forEntityName: entity.name!, into: context!) as! Game
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        newManagedObject.name = "Game"
        newManagedObject.uuid = UUID().uuidString
        newManagedObject.dateStarted = Date().addingTimeInterval(0)
        newManagedObject.dateUpdated = Date().addingTimeInterval(0)
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
    {
        self.currentGame = self.fetchedResultsController.object(at: indexPath)
        self.findMatchWithMinPlayers(2, maxPlayers: 2)
        
        self.performSegue(withIdentifier: "enterGame", sender: self)
    }
    
    func authenticateGameCenter()
    {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController : UIViewController?, error : NSError?) -> Void in
            if ((viewController) != nil) {
                self.present(viewController!, animated: true, completion: nil)
            }
            else
            {
                if GKLocalPlayer.localPlayer().isAuthenticated == true
                {
                    print((GKLocalPlayer.localPlayer().isAuthenticated))
                    GKLocalPlayer.localPlayer().register(self)
                    self.gameCenter = true
                }
                else
                {
                    self.gameCenter = false
                }
            }
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gcViewController: GKGameCenterViewController)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func findMatch()
    {
        self.findMatchWithMinPlayers(2, maxPlayers: 2)
    }
    
    func findMatchWithMinPlayers(_ minPlayers: NSInteger, maxPlayers: NSInteger)
    {
        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers
        
        let viewControllerMatch = GKMatchmakerViewController(matchRequest: request)
        viewControllerMatch!.matchmakerDelegate = self
        
        self.show(viewControllerMatch!, sender: self)
        self.navigationController?.pushViewController(viewControllerMatch!, animated: true)
    }
    
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController)
    {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: NSError)
    {
        viewController.dismiss(animated: true, completion: nil)
        print("Matching failed with error: \(error)")
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didReceiveAcceptFromHostedPlayer playerID: String)
    {
        print("Game Accepted from player \(playerID)")
        self.performSegue(withIdentifier: "enterGame", sender: self)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFindPlayers playerIDs: [String])
    {
        print("Found Players With Name: \(playerIDs[0])")
        self.performSegue(withIdentifier: "enterGame", sender: self)
    }
    
    func player(_ player: GKPlayer, didAccept invite: GKInvite)
    {
        self.performSegue(withIdentifier: "enterGame", sender: self)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch)
    {
        if (!self.matchStarted && match.expectedPlayerCount == 0) {
            NSLog("Ready to start match!")
            print("Players: \(match.players)")
            
            self.currentMatch = match
            match.delegate = self
            
            viewController.dismiss(animated: true, completion: {
                DispatchQueue.main.async(execute: {
                    self.performSegue(withIdentifier: "enterGame", sender: self)
                })
            })
        }
    }
    
    func match(_ match: GKMatch, player playerID: String, didChange state: GKPlayerConnectionState)
    {
        switch (state)
        {
        case .stateConnected:
            // handle a new player connection.
            NSLog("Player connected!")
            
            if (!self.matchStarted && match.expectedPlayerCount == 0)
            {
                NSLog("Ready to start match!")
                self.currentMatch = match
                match.delegate = self
            }
            
            break
        case .stateDisconnected:
            // a player just disconnected.
            NSLog("Player disconnected!")
            self.matchStarted = false
            break
        default:
            break
        }
    }
    
    func match(_ match: GKMatch, shouldReinviteDisconnectedPlayer player: GKPlayer) -> Bool
    {
        return true
    }
    
    func match(_ matchCurrent: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer)
    {
        self.multiplayerSceneRef!.saveDataRecived(data, fromMatch: matchCurrent, fromPlayer: player.playerID!)
    }
    
    func match(_ matchCurrent: GKMatch, didReceive data: Data, fromPlayer playerID: String)
    {
        self.multiplayerSceneRef!.saveDataRecived(data, fromMatch: matchCurrent, fromPlayer: playerID)
    }
    
    func sendData(_ matchCurrent: GKMatch!, withData data: Data!)
    {
        do {
            try matchCurrent.sendData(toAllPlayers: data, with: GKMatchSendDataMode.unreliable)
        } catch _ {
        }
    }
    
    func match(_ match: GKMatch, didFailWithError error: NSError?)
    {
        
    }
    
    func player(_ player: GKPlayer, didRequestMatchWithPlayers playerIDsToInvite: [String]) {
        
    }
    
    @IBAction func addNewMatch(_ sender: AnyObject)
    {
        self.insertNewObject(self, name: "Game", uuid: UUID().uuidString)
        
        self.findMatchWithMinPlayers(2, maxPlayers: 2)
        
        self.performSegue(withIdentifier: "enterGame", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let controller = segue.destinationViewController as! MultiplayerViewController
        controller.game = self.currentGame
        controller.gamesViewController = self
        controller.match = self.currentMatch
        
        self.multiplayerSceneRef = controller
        
        if let indexPath = self.tableView!.indexPathForSelectedRow {
            self.tableView!.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @IBAction func exitMultiplayerView(_ segue: UIStoryboardSegue)
    {
        NSLog("Exiting Multiplayer View")
    }
}

