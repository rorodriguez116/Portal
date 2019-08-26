//
//  StreamObjectDelta.swift
//  Portal
//
//  Created by Rolando Rodriguez on 8/23/19.
//

import Foundation
import FirebaseFirestore

public extension Portal {
    struct StreamObjectDelta {
        public let type: DocumentChangeType
        public let object: T
        public let oldIndex: Int
        public let newIndex: Int
    }
}
