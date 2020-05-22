//
//  ToDoListTableViewController.swift
//  GetToDo
//
//  Created by Canbin Mei on 5/19/20.
//  Copyright © 2020 Canbin Mei. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListTableViewController: UITableViewController {

    @IBOutlet weak var addButton: UIBarButtonItem! // The "+" button in the navigation bar.
    
    let realm = try! Realm() // Get the default Realm.
    
    var toDoLists: Results<ToDoList>? // A Results type containr to store ToDoList objects, it would auto update the data.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLists()
    }
    
    
    // MARK: - Add New Categories
    
    // When the "+" button in navigation bar is pressed.
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        // The textfield and message in the alert.
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New List", message: "", preferredStyle: .alert)
        alert.addTextField { (alerTextField) in
            alerTextField.placeholder = "Name of the list..."
            textField = alerTextField
        }
        
        // The "Add" button in the alert.
        let add = UIAlertAction(title: "Add", style: .default) { (action) in
            if let name = textField.text {
                if self.checkValidName(for: name) { // If the name is valid, save the list.
                    let newList = ToDoList()
                    newList.name = name
                    self.save(list: newList)
                } else { // If the name is not valid, present an alert, then ask user to enter value again.
                    let enterAgainAlert = UIAlertController(title: "Invalid Name", message: "Please enter a valid name.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK!", style: .default) { (action) in
                        self.addButtonPressed(self.addButton)
                    }
                    enterAgainAlert.addAction(ok)
                    self.present(enterAgainAlert, animated: true, completion: nil)
                }
            }
        }
        alert.addAction(add) // Add the "add" action to the alert.
        
        // The "Cancel" button in the alert.
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Cancelled") // Basically do nothing.
        }
        alert.addAction(cancel) // Add the "cancel" action to the alert.
        
        // Show the alert.
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Data Manipulation Methods
    
    // Save a list to toDoLists container.
    func save(list: ToDoList) {
        do {
            try realm.write{
                realm.add(list)
            }
        } catch {
            print("Error saving list, \(error)")
        }
        tableView.reloadData()
    }
    
    // Load all the ToDoList objects from toDoList container.
    func loadLists() {
        toDoLists = realm.objects(ToDoList.self)
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
        return toDoLists?.count ?? 1 // if toDoList is nil, then return 1.
    }
    
    // Set up what to display for each cell.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) // Use the cell with identifier of "ListCell".
        cell.textLabel?.text = toDoLists?[indexPath.row].name ?? "No List Added Yet..." // If toDoList is nil, set cell.textLabel?.text = "No List Added Yet..."
        return cell
    }
    
    
    // MARK: - TableView Delegate Methods
    
     // Swipe to delete functionality.
     // Need to delete every item in the list 1st, then delete the list itself.
     // Delete a list means delete all the items inside the list.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let list = toDoLists?[indexPath.row] {
                for item in list.items { // Need to delete every item in the list 1st.
                    do {
                        try realm.write {
                            realm.delete(item)
                        }
                    } catch {
                        print("Error deleting item, \(error)")
                    }
                }
                do { // Delete the list after deleting every item in it.
                    try realm.write {
                        realm.delete(list)
                    }
                } catch {
                    print("Error deleting list, \(error)")
                }
            }
        }
        tableView.reloadData()
    }
    
    // When a cell/row in the tableview is selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self) // Go to next view controller where "goToITem" segue is pointing to.
    }
    
    // Preparation before going to next ViewController(ToDoItemTableViewController).
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoItemTableViewController // Get a reference of the of the next viewcontroller.
        if let indexPath = tableView.indexPathForSelectedRow { // Get a reference of the index of the selected cell/row.
            destinationVC.selectedList = toDoLists?[indexPath.row] // Set the selectedList variable in next viewcontroller to toDoLists[indexPath.row]
            destinationVC.navigationBar.title = toDoLists?[indexPath.row].name // Set the navigationbar's title to the name of the list.
        }
    }
   
}
