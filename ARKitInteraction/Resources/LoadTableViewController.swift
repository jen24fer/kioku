//
//  LoadTableViewController.swift
//  ARKitInteraction
//
//  Created by Jenny Ferina on 3/9/19.
//  Copyright © 2019 Apple. All rights reserved.
//
import os.log
import UIKit
import AudioToolbox
import ARKit
import SceneKit

class LoadTableViewController: UITableViewController {

    static var palaces = [MemoryPalace]()
    
    @IBAction func loadClicked(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1519)
        /// - Tag: ReadWorldMap

        // Display the snapshot image stored in the world map to aid user in relocalizing.
//        if let snapshotData = worldMap.snapshotAnchor?.imageData,
//            let snapshot = UIImage(data: snapshotData) {
//            self.snapshotThumbnail.image = snapshot
//        } else {
//            print("No snapshot image in world map")
//        }
        // Remove the snapshot anchor from the world map since we do not need it in the scene.
//        worldMap.anchors.removeAll(where: { $0 is SnapshotAnchor })
//

    }
    
    @IBAction func editPressed(_ sender: UIBarButtonItem) {

    }
    
    
    private func loadSamplePalace()
    {
        let lamp = UIImage(named: "lamp")
        guard let palace1 = MemoryPalace(name: "Palace", photo:lamp ,data: nil, objectQueue: nil) else {
            fatalError("palace 1 failed")
        }
        LoadTableViewController.palaces += [palace1]
    }
    
    @IBAction func unwindToMapList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? SaveViewController, let palace = sourceViewController.memoryPalace {
            
            // Add a new meal.
            let newIndexPath = IndexPath(row: LoadTableViewController.palaces.count, section: 0)
            
            LoadTableViewController.palaces.append(palace)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
        
        savePalaces()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let savedPalaces = loadPalaces()
        {
            LoadTableViewController.palaces += savedPalaces
        } else{
            loadSamplePalace()
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return LoadTableViewController.palaces.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cellIdentifier = "MapTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MapTableViewCell else {
        fatalError("The dequeued cell is not an instance of MapTableViewCell")
        }
        
        let palace = LoadTableViewController.palaces[indexPath.row]
        cell.nameLabel.text = palace.name
        cell.mapImage.image = palace.photo
        
        return cell
    }

    func savePalaces()
    {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(LoadTableViewController.palaces, toFile: MemoryPalace.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadPalaces() -> [MemoryPalace]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: MemoryPalace.ArchiveURL.path) as? [MemoryPalace]
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            LoadTableViewController.palaces.remove(at: indexPath.row)
            savePalaces()
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            
        }
    }
 

    
    // Override to support rearranging the table view.
//    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
//
//    }
 
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
 

}
