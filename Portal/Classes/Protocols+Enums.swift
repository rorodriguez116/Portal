//
//  Protocols.swift
//  Portal
//
//  Created by Rolando Rodriguez on 8/14/19.
//

import Foundation
import FirebaseFirestore

public extension Portal {
    typealias EventResult = Result<EventResponse?, EventError>
    typealias EventCompletion = (EventResult) -> Void
    typealias Filter = (field: String, value: Any)
    
    enum EventTask<T: PortalModel> {
        case getOne(String)
        case getAll(Filter)
        case new(T)
        case streamAll(Filter?)
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

public protocol PortalModel: Codable {
    var portalIdentifier: String {get}
}

struct Person: PortalModel {
    var portalIdentifier: String {
        return personId
    }
    
    let personId: String = PortalIdentifier().uidString
}
