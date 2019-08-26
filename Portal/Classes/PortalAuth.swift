//
//  PortalAuth.swift
//  Portal
//
//  Created by Rolando Rodriguez on 8/26/19.
//

import Foundation
import FirebaseAuth


public protocol PortalUser: PortalModel {
    var displayName: String? {get set}
    var pictureUrl: URL? {get set}
    var email: String? {get set}
    var phoneNumber: String? {get set}
    
    init(authUser: User)
}

extension PortalUser where Self: PortalModel {
    init(authUser: User) {
        self.init(id: authUser.uid)
        self.displayName = authUser.displayName
        self.phoneNumber = authUser.phoneNumber
        self.pictureUrl = authUser.photoURL
        self.email = authUser.email
    }
}

public struct PortalAuth<S: PortalUser> {
    
    private let portal = Portal<S>(path: "users")
    private let auth = Auth.auth()
    private var currentUser: User? {
        auth.currentUser
    }
    
    public func verify(phoneNumber: String, callback: @escaping PhoneAuthResultCallback) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil)  { (verificationID, error) in
            if let error = error {callback(.failure(.underlying(error))) ; return}
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
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
        let newUser = S(authUser: self.currentUser!)
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
