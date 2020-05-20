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

    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // Location of the database.
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    var categoryArray = [ListCategory]()

    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
        print(dataFilePath)

    }
    
    // MARK: - Add new Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New List", message: "", preferredStyle: .alert)
        alert.addTextField { (alerTextField) in
            alerTextField.placeholder = "Name of the list..."
            textField = alerTextField
        }
        
        
        let add = UIAlertAction(title: "Add", style: .default) { (action) in
            if let name = textField.text {
                if self.checkValidName(for: name) {
                    let newList = ListCategory(context: self.context)
                    newList.name = name
                    self.categoryArray.append(newList)
                    self.saveCategory()
                } else {
                    // If the name is not valid
                    let enterAgainAlert = UIAlertController(title: "Invalid Name", message: "Please enter a valid name.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK!", style: .default) { (action) in
                        self.addButtonPressed(self.addButton)
                    }
                    enterAgainAlert.addAction(ok)
                    self.present(enterAgainAlert, animated: true, completion: nil)
                }
            }
        }
        alert.addAction(add)
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
//            print("Cancelled")
        }
        alert.addAction(cancel)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Data Manipulation Methods
    
    func saveCategory() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadCategory(with request: NSFetchRequest<ListCategory> = ListCategory.fetchRequest()) {
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context\(error)")
        }
        tableView.reloadData()
    }
    
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        return cell
    }
    
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Go to next view controller.
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! GetToDoTableViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
            destinationVC.navigationBar.title = categoryArray[indexPath.row].name!
        }
    }
   
    
    
}
