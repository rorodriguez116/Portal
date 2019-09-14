//
//  Portal.swift
//  Portal
//
//  Created by Rolando Rodriguez on 8/7/19.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

public class Portal<T: PortalModel> {
    
    private var listener: ListenerRegistration?
    private let database: Firestore
    private let path: String
    private var reference: CollectionReference {
        return database.collection(path)
    }
    
        
    public init(path: String){
        self.database = Firestore.firestore()
        self.path = path
    }
    
    public func event(_ task: EventTask<T>, completion: @escaping EventCompletion) {
        switch task {
        case .getAll,.getOne,.streamAll: processRead(task, completion)
        case .new, .update, .removeOne: processWrite(task, completion)
        }
    }
    
    public func stopStreaming(){
        self.listener?.remove()
    }
    
    private func processRead(_ task: EventTask<T>, _ completion: @escaping EventCompletion) {
                
        let handler = HandlerFactory(completion: completion).produceReadHandler()

        switch task {
        case .getOne(let id):
            reference.document(id).getDocument(completion: handler)
            
        case .getAll(let filter):
            reference.whereField(filter.field, isEqualTo: filter.value).getDocuments(completion: handler)
            
        case .streamAll(let filter):
            guard let f = filter else {self.listener = reference.addSnapshotListener(handler);return}
            self.listener = reference.whereField(f.field, isEqualTo: f.value).addSnapshotListener(handler)
        default: completion(.failure(.eventMapping))
        }
    }
    
    private func processWrite(_ task: EventTask<T>, _ completion: @escaping EventCompletion) {
        
        let handler = HandlerFactory(completion: completion).produceWriteHandler()
        
        switch task {
        case .new(let model):
            self.create(model: model, handler: handler)
        case .update(let model):
            self.update(model: model, handler: handler)
        case .removeOne(let id):
            reference.document(id).delete(completion: handler)
        default: completion(.failure(.eventMapping))
        }
    }
    
    private func create(model: PortalModel, handler: @escaping HandlerFactory.WriteHandler){
        let data = unwrap(model: model)
        reference.document(model.portalIdentifier).setData(data, completion: handler)
    }
    
    private func update(model: PortalModel, handler: @escaping HandlerFactory.WriteHandler){
        let data = unwrap(model: model)
        reference.document(model.portalIdentifier).updateData(data, completion: handler)
    }
    
    fileprivate func unwrap(model: PortalModel) -> [String: Any] {
        guard let data = model.firestoreObject() else {fatalError(ErrorMessage.unwrapping.body)}
        return data
    }
}

public struct PortalIdentifier {
    public var uidString: String
    
    public init() {
        self.uidString = Firestore.firestore().collection("").document().documentID
    }
}

public extension Portal {
    enum ErrorMessage {
        case identifierLinking
        case update
        case unwrapping
        
        var body: String {
            switch self {
            case .identifierLinking:
                return "Portal for \(String(describing: T.self)): automaticallAyssignId is turned off on this portal's option, notheless no PortalID is provided for the model, please provide an ID in order to create your document at the specified path"
                
            case .unwrapping:
                return "Portal couldn't parse your model \(String(describing: T.self)) to a representable dictionary suited for Firestore"
                
            case .update:
                return "Portal for \(String(describing: T.self)): There's no PortalID provided for the model. Please provide an ID in order to update your document at the specified path, if no ID is provided Portal wont know what document to update."
            }
        }
    }
}

























