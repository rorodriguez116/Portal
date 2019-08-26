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
        
        let portal = Portal<User>(path: "users")
        portal.event(.getOne("chookity")) { (result) in
            switch result {
            case .success(let response): print("Success");
            print(response?.objects.first)
            case .failure(let error): print(error)
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
