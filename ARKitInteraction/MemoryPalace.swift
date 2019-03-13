//
//  MemoryPalace.swift
//  ARKitInteraction
//
//  Created by Jenny Ferina on 3/12/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import os.log
import UIKit





class MemoryPalace: NSObject, NSCoding
{

    // MArk: Properties
    var name: String
    var photo: UIImage?
    var data: Data?
    var objectQueue: [VirtualObject]?
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("palaces")
    
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let data = "data"
        static let objectQueue = "objectQueue"
    }
    
    init?(name: String, photo: UIImage?, data: Data?, objectQueue: [VirtualObject]?)
    {
        self.name = name
        self.photo = photo
        self.data = data
        self.objectQueue = objectQueue
        if (name.isEmpty)
        {
            return nil
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(data, forKey: PropertyKey.data)
        aCoder.encode(objectQueue, forKey: PropertyKey.objectQueue)
    }
    
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Because photo is an optional property of Meal, just use conditional cast.
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        
        let data = aDecoder.decodeObject(forKey: PropertyKey.data) as? Data
        
        let objectQueue = aDecoder.decodeObject(forKey: PropertyKey.objectQueue) as? [VirtualObject]
        // Must call designated initializer.
        self.init(name: name, photo: photo, data: data, objectQueue: objectQueue)
        
    }
    
    
}
