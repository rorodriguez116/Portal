//
//  Model.swift
//  Portal_Example
//
//  Created by Rolando Rodriguez on 8/26/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Portal

struct User: PortalUser {
    
    var portalIdentifier: String {
        return id
    }
    var displayName: String?
    var id: String
    var age: Int?
    var pictureUrl: URL?
    var email: String?
    var phoneNumber: String?
    
  
}
