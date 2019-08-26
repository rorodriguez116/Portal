//
//  Model.swift
//  Portal_Example
//
//  Created by Rolando Rodriguez on 8/26/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Portal

struct User: PortalModel {
    init(id: String) {
        self.id = id
    }
    
    var id: String
    
    static func compareContent(_ a: User, _ b: User) -> Bool {
        return a.name == b.name
    }
    var diffId: String {
        return id
    }
        
    var name: String?
    var age: Int?
    var pictureUrl: URL?
}
