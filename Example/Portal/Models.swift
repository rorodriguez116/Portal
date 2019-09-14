//
//  Model.swift
//  Portal_Example
//
//  Created by Rolando Rodriguez on 8/26/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Portal

struct Pet: PortalModel {
    
    var portalIdentifier: String {
        self.id
    }
    
    let id: String
    let name: String
    let age: Int
}


struct MyUser: PortalUser {
    
    init(id: String, email: String?, phoneNumber: String?) {
        self.id = id
    }
    
    var portalIdentifier: String {
        return id
    }
    
    var id: String
    
}
