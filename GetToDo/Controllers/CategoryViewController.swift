//
//  CategoryViewController.swift
//  GetToDo
//
//  Created by Canbin Mei on 5/19/20.
//  Copyright © 2020 Canbin Mei. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    @IBOutlet weak var addButton: UIBarButtonItem! // The "+" button in the navigation bar.
    
    // Location of the database.
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    // An array of ListCategory objects.
    var categoryArray = [ListCategory]()

    // Get a reference of the viewContext for CoreData.
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
//        print(dataFilePath) // Follow this path to find the database, instead of Documents folder, go to Library/Application Support.
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
                if self.checkValidName(for: name) {
                    // If the name is valid, save the text to database.
                    let newList = ListCategory(context: self.context)
                    newList.name = name
                    self.categoryArray.append(newList)
                    self.saveCategory()
                } else {
                    // If the name is not valid, present an alert, then ask user to type again.
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
//            print("Cancelled")
        }
        alert.addAction(cancel) // Add the "cancel" action to the alert.
        
        // Show the alert.
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Data Manipulation Methods
    
    // Save everything in the context to database/persisdentContainer.
    func saveCategory() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
        self.tableView.reloadData() // Reload the data to the tableview.
    }
    
    // Load every ListCategory from persisdentContainer.
    func loadCategory(with request: NSFetchRequest<ListCategory> = ListCategory.fetchRequest()) {
        do {
            categoryArray = try context.fetch(request) // Save the loaded data to "categoryArray".
        } catch {
            print("Error fetching data from context\(error)")
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
        return categoryArray.count
    }
    
    // Set up what to display for each cell.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        return cell
    }
    
    
    // MARK: - TableView Delegate Methods
    
    // When a cell/row in the tableview is selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self) // Go to next view controller where "goToITem" segue is pointing to.
    }
    
    // Preparation before going to next ViewController.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! GetToDoTableViewController // Get a reference of the of the next viewcontroller.
        if let indexPath = tableView.indexPathForSelectedRow { // Get a reference of the index of the selected cell/row.
            destinationVC.selectedCategory = categoryArray[indexPath.row] // Set the selectedCategory variable in next viewcontroller to categoryArray[indexPath.row]
            destinationVC.navigationBar.title = categoryArray[indexPath.row].name // Set the navigationbar's title to the name of the list/category.
        }
    }
   
}
