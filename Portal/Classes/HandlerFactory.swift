//
//  MapperFactory.swift
//  Portal
//
//  Created by Rolando Rodriguez on 8/23/19.
//

import Foundation

extension Portal {
    struct HandlerFactory {
        
        typealias ReadHandler = (Any?, Error?) -> Void
        typealias WriteHandler = (Error?) -> Void
        
        let completion: EventCompletion

        func produceWriteHandler() -> WriteHandler {
            let handler: WriteHandler = { (error) in
                guard let err = error else {
                    self.completion(.success(nil))
                    return
                }
                self.completion(.failure(.underlying(err)))
            }
            return handler
        }
        
        func produceReadHandler() -> ReadHandler {
            let handler: ReadHandler = { (snapshot, error) in
                var result: EventResult!
                if let err = error {
                    result = ResultFactory(error: err).build()
                } else {
                    guard let snap = snapshot else {return}
                    result = ResultFactory(snapshot: snap).build()
                }
                self.completion(result)
            }
            return handler
        }
    }
}
