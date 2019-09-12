//
//  ProcessedResponse.swift
//  Portal
//
//  Created by Rolando Rodriguez on 8/23/19.
//

import Foundation

//  MARK: EventResponse

public extension Portal {
    struct EventResponse {
        public let streamDeltas: [StreamObjectDelta]?
        public let objects: [T]
        public var count: Int {
            return objects.count
        }
        
        init(objects: [T], deltas: [StreamObjectDelta]? = nil) {
            self.streamDeltas = deltas
            self.objects = objects
        }
    }
}
