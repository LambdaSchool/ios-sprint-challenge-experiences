//
//  CoreDataStack.swift
//  Experiences
//
//  Created by Lotanna Igwe-Odunze on 2/22/19.
//  Copyright © 2019 Sugabelly LLC. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    let container: NSPersistentContainer
    let mainContext: NSManagedObjectContext
    
    private init() {
        
        container = NSPersistentContainer(name: "Experiences")
        container.loadPersistentStores { (description, error) in
            if let loadingError = error { fatalError("Couldn't load the data store: \(loadingError)") }
        } //End of container
        
        mainContext = container.viewContext

    } // End of Init
    
}//End of CoreDataStack

