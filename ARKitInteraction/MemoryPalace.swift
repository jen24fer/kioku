//
//  MemoryPalace.swift
//  ARKitInteraction
//
//  Created by Jenny Ferina on 3/12/19.
//  Copyright © 2019 Apple. All rights reserved.
//


import UIKit
class MemoryPalace
{
    // MArk: Properties
    var name: String
    var photo: UIImage?
    var data: Data
    
    init?(name: String, photo: UIImage?, data: Data)
    {
        self.name = name
        self.photo = photo
        self.data = data
        
        if (name.isEmpty || data.isEmpty)
        {
            return nil
        }
    }
    
}
