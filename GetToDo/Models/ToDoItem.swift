//
//  ToDoItem.swift
//  GetToDo
//
//  Created by Canbin Mei on 5/21/20.
//  Copyright © 2020 Canbin Mei. All rights reserved.
//

import Foundation
import RealmSwift

class ToDoItem: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    
    var theList = LinkingObjects(fromType: ToDoList.self, property: "items")
}
