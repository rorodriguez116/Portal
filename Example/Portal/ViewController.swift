//
//  ViewController.swift
//  Portal_Example
//
//  Created by Rolando Rodriguez on 8/26/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Portal

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Portal Example"
                
    }
    
//    MARK: Sign-in a new user in FirebaseAuth and create it in your Firestore database easily.
    
//    Use Portal's simple API to access FirebaseAuth features.
    
//    1) This function creates a new user in FirebaseAuth with a phone number and also adding it to your Firestore database automatically following your defined Data layer's model wich is passed as a Generic when creating an instance of PortalAuth.
    
    func signInUserWithPhoneNumber(){
        let auth = PortalAuth<User>(path: "users")
        
        auth.verify(phoneNumber: "YourTestPhoneNumber") { (result) in
            switch result {
            case .success(let state): handle(state: state)
            case .failure(let error): print(error)
            }
        }
        
        func handle(state: PortalAuth<User>.PhoneAuthProcessState){
            switch state {
            case .verificationCode: print("Show verification code entry UI")
            case .newUser(let user): print("Show new user welcome screen and complete its profile ", user.id)
            case .signedIn(let user): print("Show user homescreen or handle with message", user.id)
                
            }
        }
    }
}
