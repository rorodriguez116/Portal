//
//  Portal.swift
//  Portal
//
//  Created by Rolando Rodriguez on 8/7/19.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import Combine

public final class Portal<T: PortalModel> {
    
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
    
    public func event(_ task: WriteEvent<T>) -> AnyPublisher<Bool, Portal<T>.EventError> {
        return self.processWrite(task)
    }
    
    public func event(_ task: ReadEvent<T>) -> AnyPublisher<[T], Portal<T>.EventError> {
        return self.processRead(task)
    }
    
    public func stopStreaming(){
        self.listener?.remove()
    }
    
    private func processRead(_ task: ReadEvent<T>) -> AnyPublisher<[T], Portal.EventError> {
        
        func handle(promise: ((Result<[T], Portal<T>.EventError>) -> Void), querySnapshot: QuerySnapshot?, documentSnapshot: DocumentSnapshot?, error:  Error?) {
            if let err = error {
                promise(.failure(Portal.EventError.underlying(err)))
            } else if let qsnapshot = querySnapshot {
                let documents = qsnapshot.documents.map({ (snap) -> T in
                    let data = snap.data()
                    return T(dictionary: data)!
                })
                promise(.success(documents))
            } else if let dsnapshot = documentSnapshot {
                guard let data = dsnapshot.data() else { promise(.failure(.eventMapping)); return }
                let object = T(dictionary: data)!
                promise(.success([object]))
            }
            else {
                promise(.failure(.underlying(error)))
            }
        }
        
        return Future<[T], Portal<T>.EventError> { promise in
            switch task {
            case .fetchOne(let id):
                self.reference.document(id).getDocument { (documentSnapshot, error) in
                    handle(promise: promise, querySnapshot: nil, documentSnapshot: documentSnapshot, error: error)
                }
            case .fetchAll(let f):
                if let filter = f {
                    self.reference.whereField(filter.field, isEqualTo: filter.value).getDocuments { (querySnapshot, error) in
                        handle(promise: promise, querySnapshot: querySnapshot, documentSnapshot: nil, error: error)
                    }
                } else {
                    self.reference.getDocuments { (querySnapshot, error) in
                        handle(promise: promise, querySnapshot: querySnapshot, documentSnapshot: nil, error: error)
                    }
                }
            case .streamAll(let filter):
                if let f = filter {
                    self.listener = self.reference.whereField(f.field, isEqualTo: f.value).addSnapshotListener({ (querySnapshot, error) in
                        handle(promise: promise, querySnapshot: querySnapshot, documentSnapshot: nil, error: error)
                    })
                } else {
                    self.listener = self.reference.addSnapshotListener({ (querySnapshot, error) in
                        handle(promise: promise, querySnapshot: querySnapshot, documentSnapshot: nil, error: error)
                    })
                }
            }
        }.eraseToAnyPublisher()
    }
    
    private func processWrite(_ task: WriteEvent<T>) -> AnyPublisher<Bool, Portal<T>.EventError> {
        
        return Future<Bool, Portal<T>.EventError> { promise in

            func handle(promise: ((Result<Bool, Portal<T>.EventError>) -> Void), error:  Error?) {
                if let err = error {
                    promise(.failure(Portal.EventError.underlying(err)))
                } else {
                    promise(.success(true))
                }
            }
            
            switch task {
            case .new(let model):
                let data = self.unwrap(model: model)
                self.reference.document(model.portalIdentifier).setData(data) { (err) in
                    handle(promise: promise, error: err)
                }
            case .update(let model):
                let data = self.unwrap(model: model)
                self.reference.document(model.portalIdentifier).updateData(data) { (err) in
                    handle(promise: promise, error: err)
                }
            case .removeOne(let id):
                self.reference.document(id).delete { (err) in
                    handle(promise: promise, error: err)
                }
            }
        }.eraseToAnyPublisher()
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

























