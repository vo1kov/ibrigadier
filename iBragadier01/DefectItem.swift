//
//  DefectItem.swift
//  iBrigadier
//
//  Created by Mikhail Volkov on 26.02.15.
//  Copyright (c) 2015 imsut. All rights reserved.
//

import Foundation
import CoreData

class DefectItem: NSManagedObject {

    @NSManaged var type: String
    @NSManaged var adress: String
    @NSManaged var image: NSData
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    
   /* convenience init(type: String, adress: String, image: NSData, latitude: NSNumber, longitude: NSNumber,  entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
       
            
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.type = type
        self.adress = adress
        self.image = image
        self.latitude = latitude
        self.longitude = longitude
    }*/
    
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, type: String, adress: String, image: NSData, latitude: NSNumber, longitude: NSNumber) -> DefectItem {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("DefectItem", inManagedObjectContext: moc) as! DefectItem
        
        newItem.type = type
        newItem.adress =  adress
        newItem.image = image
        newItem.latitude = latitude
        newItem.longitude = longitude
        
        
        
        return newItem
    }


}
