//
//  ViewController.swift
//  GetToDo
//
//  Created by Canbin Mei on 5/17/20.
//  Copyright © 2020 Canbin Mei. All rights reserved.
//

// Note for Core Data:
// Every NSManagedObject created is saved after context.save()

import UIKit
import CoreData

class GetToDoTableViewController: UITableViewController {
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // An array of ToDoItem objects.
    var itemArray = [ToDoItem]()
    
    var selectedCategory: ListCategory? { // selectedCategory is not initialized, it would be initialized in prepare() from root viewcontroller.
        didSet { // didSet would be executed after selectedCategory is initialized.
            loadItems()
        }
    }
    
    // To get a reference of the "viewContext" of "persistentContainer".
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Location of the database.
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    override func viewDidLoad() {
        super.viewDidLoad()
//        print(dataFilePath) // Follow this path to find the database, instead of Documents folder, go to Library/Application Support.
    }
    
    // MARK: - Add New To Do Item
    
    // When the "+" button in navigation bar is pressed.
    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {
        
        // The textfield and message in the alert.
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item..."
            textField = alertTextField
        }
        
        // The "Add" button in the alert.
        let add = UIAlertAction(title: "Add", style: .default) { (action) in
            if let name = textField.text {
                if self.checkValidName(for: name) {
                    // If the name is valid, save the text to database.
                    let newItem = ToDoItem(context: self.context)
                    newItem.title = textField.text!
                    newItem.done = false
                    newItem.parentCategory = self.selectedCategory
                    self.itemArray.append(newItem)
                    self.saveItem()
                } else {
                    // If the name is not valid, present an alert, then ask user to type again.
                    let enterAgainAlert = UIAlertController(title: "Invalid Name", message: "Please enter a valid name.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK!", style: .default) { (action) in
                        self.AddButtonPressed(self.addButton)
                    }
                    enterAgainAlert.addAction(ok)
                    self.present(enterAgainAlert, animated: true, completion: nil)
                }
            }
        }
        alert.addAction(add) // Add the "add" action to the alert.
        
        // The "Cancel" button in the alert.
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Cancelled")
        }
        alert.addAction(cancel) // Add the "cancel" action to the alert.
        
        // Show the alert.
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Model Manupulation Methods
    
    // Save everything in the context to database/persisdentContainer.
    func saveItem() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
        self.tableView.reloadData()
    }
    
    // Load content from persisdentContainer with 
    func loadItems(with request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest(), predicate: NSPredicate? = nil) {
        
        // Filter the data, get all the NSManagedOjbect with the "parentCategory.name" match "selectedCategory!.name!".
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        // Add more filter, combine the categoryPredicate with predicate argument.
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }

        do {
            itemArray = try context.fetch(request) // Save the loaded data to "itemArray".
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData() // Reload the data to the tableview.
    }
    
    // This function check if a string is only spaces.
    func checkValidName(for name: String) -> Bool {
        var valid = false
        let charArray = Array(name)
//        print(charArray)
        for char in charArray {
            if char != " " {
                valid = true
            }
        }
        return valid
    }
    
    // MARK: - TableView Datasource Methods
    
    // Return the number of cells in the tableview.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    // Set up what to display for each cell.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    // When a cell/row in the tableview is selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row immediately after the row is selected.
        
        // Change the checkmark, checkmark -> none, none -> checkmark.
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
//        // Remove the data from database/persisdentContainer
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        saveItem()
    }
    
    // Swipe to delete.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(itemArray[indexPath.row])
            itemArray.remove(at: indexPath.row)
            saveItem()
        }
    }

}

    // MARK: - SearchBar Delegate Methods
extension GetToDoTableViewController: UISearchBarDelegate {
    
    // When the search button is clicked.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        
        // Query if any title attribute contains searchBar.text, [cd] means disable case and diacritic sensitive.
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        // Sort the data from the request.
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
        
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    // When the text in search bar changed, or press the x button in the search bar.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            // Dismiss the keyboard and stop editing the search bar.
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else { // Query with the current text in search bar.
            let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
            
            // Query if any title attribute contains searchBar.text, [cd] means disable case and diacritic sensitive.
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            
            // Sort the data from the request.
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            loadItems(with: request, predicate: predicate)
        }
    }

    
}
