//
//  ResultFactory.swift
//  Portal
//
//  Created by Rolando Rodriguez on 8/23/19.
//

import Foundation
import FirebaseFirestore

extension Portal {
    struct ResultFactory {
        
        let snapshot: Any?
        let error: Error?
        
        init(snapshot: Any? = nil, error: Error? = nil) {
            self.snapshot = snapshot
            self.error = error
        }
        
//        MARK: Builds an event result based on the data given at init
        
        func build() -> EventResult {
            guard let snap = snapshot else { return .failure(.underlying(error!))}
            if let result = snap as? QuerySnapshot {
                return handleQuerySnapshot(result)
            } else if let result = snap as? DocumentSnapshot {
                return handleDocumentSnapshot(result)
            }
            return .failure(.resultConversion)
        }
        
//        MARK: EventResults for read events
        
        func handleQuerySnapshot(_ snap: QuerySnapshot) -> EventResult {
            func unwrapObject(data: [String: Any]) -> T {
                guard let object = T(dictionary: data) else {fatalError("Portal couldn't init object from given data. Either snapshot is corrupted or its data is not modeled as the required type \(String(describing: T.self))")}
                return object
            }
            
            let objects = snap.documents.map { (document) -> T in
                return unwrapObject(data: document.data())
            }
            
            let deltas = snap.documentChanges.map { (documentChange) -> StreamObjectDelta in
                let object = unwrapObject(data: documentChange.document.data())
                return StreamObjectDelta(type: documentChange.type, object: object, oldIndex: Int(documentChange.oldIndex), newIndex: Int(documentChange.newIndex))
            }
           
            let response = EventResponse(objects: objects, deltas: deltas)
                        
            return EventResult.success(response)
        }
        
        func handleDocumentSnapshot(_ snap: DocumentSnapshot) -> EventResult {
            guard let data = snap.data(), let object = T(dictionary: data) else {return .failure(.resultConversion)}
            let response = EventResponse(objects: [object])
            return EventResult.success(response)
            
        }
    }
}
