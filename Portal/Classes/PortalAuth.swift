//
//  PortalAuth.swift
//  Portal
//
//  Created by Rolando Rodriguez on 8/26/19.
//

import Foundation
import FirebaseAuth

public struct PortalAuth<S: PortalUser> {
    
    private let portal: Portal<S>
    private let auth = Auth.auth()
    private var currentUser: User? {
        auth.currentUser
    }
    
    public init(path: String){
        self.portal = Portal<S>(path: path)
    }
    
//    MARK: Flow goes as follow: 1) verify phone number, 2) signInWith verification code, 3) Handle User state
    public func verify(phoneNumber: String, callback: @escaping PhoneAuthResultCallback) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil)  { (verificationID, error) in
            if let error = error {callback(.failure(.underlying(error))) ; return}
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            callback(.success(.verificationCode))
        }
    }
    
    public func signInWith(verificationCode: String, callback: @escaping PhoneAuthResultCallback) {
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else { fatalError("Stored verificationID failed to load")}
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            guard let result = authResult, let userInfo = result.additionalUserInfo else {callback(.failure(.underlying(error)));return}
            
            if userInfo.isNewUser {
                callback(.success(.newUser(self.createUserInDatabase())))
            } else {
                self.getUserFromDatabase { (user) in
                    callback(.success(.signedIn(user)))
                }
            }
        }
    }
    
    private func createUserInDatabase() -> S {
        guard let user = currentUser else {fatalError("PortalAuth: Can't create user in database without any data.")}
        let newUser = S(id: user.uid, email: user.email, phoneNumber: user.phoneNumber)
        portal.event(.new(newUser)) { (result) in
            switch result {
            case .success: print("PortalAuth: User successfully created.")
            case .failure(let error): print(error)
            }
        }
        return newUser
    }
    
    private func getUserFromDatabase(callback: @escaping (S) -> Void) {
        portal.event(.getOne(currentUser!.uid)) { (result) in
            switch result {
            case .success(let response): print("PortalAuth: User successfully obtained."); callback(response!.objects.first!)
            case .failure(let error): print(error)
            }
        }
    }
        
    private func update(user: S) {
        portal.event(.update(user)) { (result) in
            switch result {
            case .success: print("PortalAuth: User successfully updated.")
            case .failure(let error): print(error)
            }
        }
    }
}

public protocol PortalUser: PortalModel {
    init(id: String, email: String?, phoneNumber: String?)
}

public extension PortalAuth {
    typealias PhoneAuthResult = Result<PhoneAuthProcessState, PhoneAuthVerificationError>
    typealias PhoneAuthResultCallback = (PhoneAuthResult) -> Void
    enum PhoneAuthProcessState {
        case verificationCode
        case signedIn(S)
        case newUser(S)
    }
    
    enum PhoneAuthVerificationError: Error {
        case invalidVerificationCode
        case invalidPhoneNumber
        case underlying(Error?)
    }
}
