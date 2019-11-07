//
//  Protocols.swift
//  Portal
//
//  Created by Rolando Rodriguez on 8/14/19.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

public protocol PortalModel: Codable {
    var portalIdentifier: String {get}
}

public extension Portal {
    typealias Filter = (field: String, value: Any)
    
    enum ReadEvent<T: PortalModel> {
        case fetchOne(String)
        case fetchAll(Filter?)
        case streamAll(Filter?)
    }
    enum WriteEvent<T: PortalModel> {
        case new(T)
        case removeOne(String)
        case update(T)
    }

    enum EventError: Error {
        case resultConversion
        case underlying(Error?)
        case eventMapping
        case noTaskSpecified
    }
}
