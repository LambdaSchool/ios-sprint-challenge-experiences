//
//  ExperienceConvenience.swift
//  Experiences
//
//  Created by Lotanna Igwe-Odunze on 2/28/19.
//  Copyright © 2019 Sugabelly LLC. All rights reserved.
//

import Foundation
import CoreData

extension Experience { //This should be extending the Entity in the data model.
    
    convenience init(
        title: String,
        date: Date,
        longitude: Double,
        latitude: Double,
        picture: String,
        video: String? = nil,
        
        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title //Attribute from the Entity
        self.date = date //Attribute from the Entity
        self.longitude = longitude //Attribute from the Entity
        self.latitude = latitude //Attribute from the Entity
        self.picture = picture //Attribute from the Entity
        self.video = video ?? nil //Attribute from the Entity

    }
}
