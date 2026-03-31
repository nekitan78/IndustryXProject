//
//  AuthenticationManager.swift
//  IndustryX
//
//  Created by Andryuchshenko Nikita on 20.03.2026.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel{
    let uid: String
    let email: String?
    let photoUrl: String?
    let isEmailVerified: Bool
    
    init(user: User){
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.isEmailVerified = user.isEmailVerified
    }
}

final class AuthenticationManager{
    
    static let shared = AuthenticationManager()
    
    private init(){}
    
    func getAuthenticatedUser() throws -> AuthDataResultModel{
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badURL)
        }
        
        return AuthDataResultModel(user: user)
    }
    
    func createUser(email: String, password: String)async throws -> AuthDataResultModel{
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func signInUser(email: String, password: String)async throws -> AuthDataResultModel{
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func sendVerificationEmail() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        try await user.sendEmailVerification()
    }
    
    func reloadUser() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        try await user.reload()
    }
    
    func isEmailVerified() -> Bool {
        Auth.auth().currentUser?.isEmailVerified ?? false
    }
    
    func signOut()throws{
       try  Auth.auth().signOut()
    }
    
    func resetPassword(email:String)async throws{
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
}
