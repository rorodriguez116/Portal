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
        
        let auth = PortalAuth<User>(path: "users")
        
        auth.verify(phoneNumber: "+51944266959") { (result) in
            switch result {
            case .success(let state): handle(state: state)
            case .failure(let error): print(error)
            }
        }
        
        func handle(state: PortalAuth<User>.PhoneAuthProcessState){
            switch state {
            case .verificationCode: print("Show verification code entry UI")
            case .newUser(let user): print("Show new user welcome screent and complete register")
            case .signedIn(let user): print("Show user homescreen or handle with message")
            
            }
        }
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
