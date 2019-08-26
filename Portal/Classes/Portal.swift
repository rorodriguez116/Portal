//
//  Portal.swift
//  Portal
//
//  Created by Rolando Rodriguez on 8/7/19.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import TopicsCore

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
            guard let objectData = model.firestoreObject() else {return}
            reference.document(model.id).setData(objectData, completion: handler)
        case .update(let model):
            guard let objectData = model.firestoreObject() else {return}
            reference.document(model.id).updateData(objectData, completion: handler)
        case .removeOne(let id):
            reference.document(id).delete(completion: handler)
        default: completion(.failure(.eventMapping))
        }
    }
}




























