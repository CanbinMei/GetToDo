//
//  ToDoList.swift
//  GetToDo
//
//  Created by Canbin Mei on 5/21/20.
//  Copyright © 2020 Canbin Mei. All rights reserved.
//

import Foundation
import RealmSwift

class ToDoList: Object {
    @objc dynamic var name: String = ""
    
    let items = List<ToDoItem>()
}
