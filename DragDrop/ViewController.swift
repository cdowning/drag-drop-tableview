//
//  ViewController.swift
//  DragDrop
//
//  Created by Caitlin on 11/2/18.
//  Copyright © 2018 Caitlin. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITableViewDragDelegate, UITableViewDropDelegate {

    // MARK: Properties
    
    var leftTableView = UITableView()
    var rightTableView = UITableView()
    
    var leftItems = [String](repeating: "Left", count: 20)
    var rightItems = [String](repeating: "Right", count: 20)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftTableView.dataSource = self
        rightTableView.dataSource = self
        
        leftTableView.dragDelegate = self
        leftTableView.dropDelegate = self
        rightTableView.dragDelegate = self
        rightTableView.dropDelegate = self
        
        leftTableView.dragInteractionEnabled = true
        rightTableView.dragInteractionEnabled = true
        
        let width = view.frame.width
        
        leftTableView.frame = CGRect(x: 0, y: 40, width: width/2, height: view.frame.height)
        rightTableView.frame = CGRect(x: width/2, y: 40, width: width/2, height: view.frame.height)
        
        leftTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        rightTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        view.addSubview(leftTableView)
        view.addSubview(rightTableView)
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == leftTableView {
            return leftItems.count
        } else {
            return rightItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if tableView == leftTableView {
            cell.textLabel?.text = leftItems[indexPath.row]
        } else {
            cell.textLabel?.text = rightItems[indexPath.row]
        }
        
        return cell
    }
    
    
    
    // protocols for UITableViewDragDelegate, UITableViewDropDelegate
    
    // This gets called when the user has initiated a drag operation on a table view cell by holding down their finger, and needs to return an array of drag items
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        // if the table view in question is the left table view then read from leftItems, otherwise read from rightItems
        let string = tableView == leftTableView ? leftItems[indexPath.row] : rightItems[indexPath.row]
        
        // Attempt to convert the string to a Data object so it can be passed around using drag and drop
        guard let data = string.data(using: .utf8) else { return [] }
        
        // Place that data inside an NSItemProvider, marking it as containing a plain text string so other apps know what to do with it
        let itemProvider = NSItemProvider(item: data as NSData, typeIdentifier: kUTTypePlainText as String)
        
        // place that item provider inside a UIDragItem so that it can be used for drag and drop by UIKit
        return [UIDragItem(itemProvider: itemProvider)]
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        // attempt to load strings from the drop coordinator
        coordinator.session.loadObjects(ofClass: NSString.self) { items in
            // convert the item provider array to a string array or bail out
            guard let strings = items as? [String] else { return }
            
            // create an empty array to track rows we've copied
            var indexPaths = [IndexPath]()
            
            // loop over all the strings we received
            for (index, string) in strings.enumerated() {
                // create an index path for this new row, moving it down depending on how many we've already inserted
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                
                // insert the copy into the correct array
                if tableView == self.leftTableView {
                    self.leftItems.insert(string, at: indexPath.row)
                } else {
                    self.rightItems.insert(string, at: indexPath.row)
                }
                
                // keep track of this new row
                indexPaths.append(indexPath)
            }
            
            // insert them all into the table view at once
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }

}

