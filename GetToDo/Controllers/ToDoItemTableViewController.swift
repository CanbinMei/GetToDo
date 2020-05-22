//
//  ToDoItemTableViewController.swift
//  GetToDo
//
//  Created by Canbin Mei on 5/17/20.
//  Copyright © 2020 Canbin Mei. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoItemTableViewController: UITableViewController {
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    let realm = try! Realm() // Get the default Realm.
    
    var toDoItems: Results<ToDoItem>? // A Results type containr to store ToDoItem objects, it would auto update the data.
    
    var selectedList: ToDoList? { // It would be initialized in "override func prepare(for segue: UIStoryboardSegue, sender: Any?)"
        didSet { // Code inside didSet would be executed after selectedList is initialized.
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
                    // If the name is valid, save the item.
                    if let currentList = self.selectedList { // if selectedList is not nil.
                        do {
                            try self.realm.write {
                                let newItem = ToDoItem()
                                newItem.title = textField.text!
                                currentList.items.append(newItem) // Add newItem to "items" attribute the of ToDoList object.
                            }
                        } catch {
                            print("Error saving item, \(error)")
                        }
                    } else { // selectedList is nil.
                        // Something is wrong with "prepare(for segue: UIStoryboardSegue, sender: Any?)" in ToDoListTableViewController.
                        print("selectedList is nil...")
                    }
                    self.tableView.reloadData()
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
    
    func loadItems() {
        toDoItems = selectedList?.items.sorted(byKeyPath: "done", ascending: true) // Load all the ToDoItem object and sort them by done attribute.
        tableView.reloadData()
    }
    
    // This function check if a string is only spaces.
    func checkValidName(for name: String) -> Bool {
        var valid = false
        let charArray = Array(name)
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
        return toDoItems?.count ?? 1 // If toDoItems is nil, return 1.
    }
    
    // Set up what to display for each cell.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        if let item = toDoItems?[indexPath.row] { // If toDoItems is not nil.
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        } else { // If toDoItems is nil.
            cell.textLabel?.text = "No item added yet..."
        }
        return cell
    }
    
    
    // MARK: - TableView Delegate Methods
    
    // When a cell/row in the tableview is selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row immediately after the row is selected.
        if let item = toDoItems?[indexPath.row] { // If toDoItems is not nil.
            do {
                try realm.write {
                    item.done = !item.done // Update the checkmark.
                }
            } catch {
                print("Error updating done status, \(error)")
            }
        } else {
            print("toDoItems is nil...")
        }
        tableView.reloadData()
    }
    
    // Swipe to delete.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let item = toDoItems?[indexPath.row] {
                do {
                    try realm.write {
                        realm.delete(item) // Delete the selected item from the list.
                    }
                } catch {
                    print("Error updating done status, \(error)")
                }
            }
            tableView.reloadData()
        }
    }

}


    // MARK: - SearchBar Delegate Methods

extension ToDoItemTableViewController: UISearchBarDelegate {
    
    // When the search button is clicked.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Get the ToDoItem objects whose title attribute contains the text of the searchBar, then sort them by the done attribute.
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "done", ascending: true)
        tableView.reloadData()
        
        // Dismiss the keyboard and stop editing the search bar after pressing "Search" in the keyboard.
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    // When the text in search bar changed, or press the x button in the search bar.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 { // Load all the items if there is nothing in the searchBar.
            loadItems()

            // Dismiss the keyboard and stop editing the search bar.
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        } else { // Query/filter with the current text in search bar.
            toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "done", ascending: true)
            tableView.reloadData()
        }
    }
    
}
