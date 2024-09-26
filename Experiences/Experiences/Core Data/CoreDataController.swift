//
//  CoreDataController.swift
//  Experiences
//
//  Created by Lotanna Igwe-Odunze on 2/22/19.
//  Copyright © 2019 Sugabelly LLC. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class CoreDataController {
    
    static let shared = CoreDataController()
    
    //NSFetchedResultsContainer
    var entries: [Experience] {
        
        let fetchRequest: NSFetchRequest<Experience> = Experience.fetchRequest()
        
        //Return an array of Experiences or an empty array if it fails
        let results = (try? CoreDataStack.shared.mainContext.fetch(fetchRequest)) ?? []
        
        return results //This will be what enters experiences array.
    }
    
    //Core Data CRUD
    
    //Create a new Experience entry
    func newEntry(entryTitle: String, entryPhoto: URL, entryVid: URL?, entryDate: Date, entryLocation: CLLocationCoordinate2D?, moc: NSManagedObjectContext = CoreDataStack.shared.mainContext) //Set the context to the one already in use.
    {
        moc.perform {
            
            //Just declaring a new instance of Experience creates it.
            let entry = Experience(title: entryTitle, date: entryDate, longitude: (entryLocation?.longitude)!, latitude: (entryLocation?.latitude)!, picture: entryPhoto.absoluteString, video: entryVid?.absoluteString)
            
            do { try moc.save()
                
            } catch { NSLog("Failed to save while creating a new Experience") }
            
        }
    }
    
    //Delete Experience Entry
    func deleteEntry(entry: Experience, _ completion:@escaping Completions = Empties) {
        
        guard let moc = entry.managedObjectContext else { return }
        
        moc.performAndWait {
            moc.delete(entry) //Delete the entry
            
            do {
                try moc.save() //Save the change
                
            } catch {
                
                showErrors(completion, "Unable to save moc")
                return
            }
        }
        
    }
    
    //Report Errors
    func showErrors(_ completion: @escaping Completions, _ error: String) {
        NSLog(error)
        completion(error)
    }
    
}//End of class

//Type Alias for pretty completion handling
typealias Completions = (String?) -> Void
let Empties: Completions = {_ in}

/* Match data from FB to Calorie Representation
 func matchToRep(entryRep: CalorieRep, moc: NSManagedObjectContext) throws {
 
 var caughtError: Error?
 
 moc.perform {
 
 let req: NSFetchRequest<Calorie> = Calorie.fetchRequest()
 
 req.predicate = NSPredicate(format: "id == %@", entryRep.id as NSUUID)
 
 var entry: Calorie?
 
 do {
 
 entry = try moc.fetch(req).first //Find the first entry with that ID
 print(entry?.amount)
 
 } catch {
 
 caughtError = error
 }
 
 if let foundEntry = entry { //If there's an entry with that ID...
 
 foundEntry.assignEntry(tempEntry: entryRep) //Match it up.
 
 } else { _ = Calorie(amount: entryRep.amount, date: entryRep.date, id: entryRep.id, context: moc) //Else create a new entry
 
 }
 
 }
 
 if let caughtError = caughtError {
 
 throw caughtError
 
 }
 }// End of Matching Func */

