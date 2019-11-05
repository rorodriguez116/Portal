//
//  ViewController.swift
//  Portal_Example
//
//  Created by Rolando Rodriguez on 8/26/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Portal
import Combine
import Firebase

class ViewController: UIViewController {

    var subscription: AnyCancellable!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Portal Example"
        self.subscription = combineFirestoreRT
//        streamAllModels()
    }
    
//    MARK: Sign-in a new user in FirebaseAuth and create it in your Firestore database easily.
    
//    Use Portal's simple API to access FirebaseAuth features.
    
//    1) This function creates a new user in FirebaseAuth with a phone number and also adding it to your Firestore database automatically following your defined Data layer's model wich is passed as a Generic when creating an instance of PortalAuth.

    
    func createModel(){
        let portal = Portal<Pet>(path: "pets")
        let myPet = Pet(id: "MyPetID2", name: "Machin", age: 4)
        
        subscription = portal.event(.new(myPet)).sink(receiveCompletion: { (completion) in
            print(completion)
        }) { (result) in
            print("data uploaded!")
        }
    }
    
    func getModel() {
        let portal = Portal<Pet>(path: "pets")

        subscription = portal.event(.fetchOne("MyPetID")).sink(receiveCompletion: { (completion) in
            print(completion)
        }, receiveValue: { (pets) in
            print(pets)
        })
    }
    
    func getAllModels() {
        let portal = Portal<Pet>(path: "pets")
        subscription = portal.event(.fetchAll(nil)).sink(receiveCompletion: { (completion) in
            print(completion)
        }, receiveValue: { (pets) in
            print(pets)
        })
    }
    
    func streamAllModels() {
          let portal = Portal<Pet>(path: "pets")
        subscription = portal.event(.streamAll(nil)).sink(receiveCompletion: { (completion) in
              print(completion)
          }, receiveValue: { (pets) in
              print(pets)
          })
      }
    
    var combineFirestoreRT: AnyCancellable {
        let database = Firestore.firestore()
        let reference = database.collection("pets")
        
        return Future<[Pet], Error> { promise in
            reference.addSnapshotListener { (query, error) in
                if let err = error {
                    promise(.failure(err))
                } else {
                    let objects = query?.documents.map({ (document) -> Pet in
                        return Pet(dictionary: document.data())!
                    })
                    
                    promise(.success(objects!))
                }
            }
        }.sink(receiveCompletion: { (completion) in
            print(completion)
        }) { (pets) in
            print("pets manually: ", pets)
        }
    }
}
