//
//  Protocols.swift
//  Portal
//
//  Created by Rolando Rodriguez on 8/14/19.
//

import Foundation
import FirebaseFirestore
import DeepDiff

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

public protocol PortalModel: Codable, DiffAware {
    var id: String {get set}
    init(id: String)
}
