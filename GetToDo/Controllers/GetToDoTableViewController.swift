//
//  ViewController.swift
//  GetToDo
//
//  Created by Canbin Mei on 5/17/20.
//  Copyright © 2020 Canbin Mei. All rights reserved.
//

import UIKit
import CoreData

class GetToDoTableViewController: UITableViewController{
    
    var itemArray = [ToDoItem]()
    
    // To get a reference of the "viewContext" of "persistentContainer".
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Place where the database live.
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        print(dataFilePath)
    }
    
    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item..."
            textField = alertTextField
        }
        
        // Add new things
        let add = UIAlertAction(title: "Add", style: .default) { (action) in
            let newItem = ToDoItem(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            self.itemArray.append(newItem)
            self.saveItem()
        }
        alert.addAction(add)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Cancelled")
        }
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    // Save the content in context to persisdentContainer.
    func saveItem() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
        self.tableView.reloadData()
    }
    
    // Load content from persisdentContainer.
    func loadItems() {
        // Create a fetch request of type ToDoItem.
        let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        do {
            // Save the fetched data into itemArray.
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    // MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItem()
    }

}

