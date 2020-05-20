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
    
    var itemArray = [ToDoItem]()
    
    var selectedCategory: ListCategory? {
        didSet {
            loadItems()
        }
    }
    
    // To get a reference of the "viewContext" of "persistentContainer".
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Place where the database live.
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    override func viewDidLoad() {
        super.viewDidLoad()
//        print(listName)
//        navigationBar.title = listName
//        print(dataFilePath)
//        loadItems()

//        // Code for understanding Core Data.
//        let oneMoreItem = ToDoItem(context: context)
//        oneMoreItem.title = "oneMoreItem"
//        oneMoreItem.done = true
//        saveItem()
//        itemArray.append(oneMoreItem)
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
            newItem.parentCategory = self.selectedCategory
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
    
    // MARK: - Model Manupulation Methods
    
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
    func loadItems(with request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }

        do {
            // Save the fetched data into itemArray.
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
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
        
//        // Remove if selected
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
