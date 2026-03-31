//
//  ATError.swift
//  IndustryX
//
//  Created by Andryuchshenko Nikita on 21.03.2026.
//

import Foundation
import SwiftUI

struct AlertItem: Identifiable{
    let id = UUID()
    let title: Text
    let message: Text
    let dismissButton: Alert.Button
}

struct alertContext {
    static let invalidForm = AlertItem(
        title: Text("Invalid Form"),
        message: Text("Please fill in all fields."),
        dismissButton: .default(Text("OK"))
    )
    
    static let noAccount = AlertItem(
        title: Text("Sign In Failed"),
        message: Text("Wrong email or password, or account does not exist."),
        dismissButton: .default(Text("OK"))
    )
    
    static let verificationSent = AlertItem(
        title: Text("Verification Email Sent"),
        message: Text("Please check your email and verify your account."),
        dismissButton: .default(Text("OK"))
    )
    
    static let emailNotVerified = AlertItem(
        title: Text("Email Not Verified"),
        message: Text("Please verify your email before logging in."),
        dismissButton: .default(Text("OK"))
    )
    
    static let verificationResent = AlertItem(
        title: Text("Email Sent"),
        message: Text("Verification email was sent again."),
        dismissButton: .default(Text("OK"))
    )
    
    static let fileIssues = AlertItem(
        title: Text("File Error"),
        message: Text("Please check your file"),
        dismissButton: .default(Text("OK"))
    )
    
    static let invalidData = AlertItem(
        title: Text("Server Error"),
        message: Text("invalidData"),
        dismissButton: .default(Text("Ok"))
    )
    
    static let lackOfEmail = AlertItem(
        title: Text("No email"),
        message: Text("Enter email to reset the password"),
        dismissButton: .default(Text("Ok"))
    )
    
    static let resetError = AlertItem(
        title: Text("Error"),
        message: Text("Couldnt reset the password"),
        dismissButton: .default(Text("Ok"))
    )
    
    static let resetDone = AlertItem(
        title: Text("Reset Email"),
        message: Text("Please check your email to reset the password"),
        dismissButton: .default(Text("Ok"))
    )
}
