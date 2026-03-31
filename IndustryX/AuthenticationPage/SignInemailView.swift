//
//  SignInemailView.swift
//  IndustryX
//
//  Created by Andryuchshenko Nikita on 18.03.2026.
//

import SwiftUI
import Combine

@MainActor
final class SignInEmailViewModel: ObservableObject{
    @Published var email = ""
    @Published var password = ""
    @Published var alertItem: AlertItem?
    
    
    
    
    func signIn() async -> Bool {
            guard !email.isEmpty, !password.isEmpty else {
                alertItem = alertContext.invalidForm
                return false
            }
            
            do {
                let returnedData = try await AuthenticationManager.shared.signInUser(email: email, password: password)
                print("Success")
                print(returnedData)
                
                try await AuthenticationManager.shared.reloadUser()
                
                if AuthenticationManager.shared.isEmailVerified() {
                    return true
                } else {
                    alertItem = alertContext.emailNotVerified
                    try? AuthenticationManager.shared.signOut()
                    return false
                }
            } catch {
                print("Sign in error: \(error.localizedDescription)")
                alertItem = alertContext.noAccount
                return false
            }
    }
    
    func resetPassowrd()async{
        
        do{
            guard !email.isEmpty else{
                alertItem = alertContext.lackOfEmail
                return
            }
            
            try await AuthenticationManager.shared.resetPassword(email: email)
            
            alertItem = alertContext.resetDone
        }catch{
            alertItem = alertContext.resetError
        }
        
    }
    
    
}

struct SignInemailView: View {
    
    @StateObject var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    
    
    var body: some View {
        ZStack{
            NavigationView{
                VStack{
                    Text("Sign In")
                        .font(.system(size: 25, weight: .semibold, design: .default))
                
                    HStack{
                        Image(systemName: "envelope")
                            .font(.callout)
                            .foregroundStyle(.gray)
                            .frame(width: 30)
                        TextField("email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(.capsule)
                    
                    HStack{
                        Image(systemName: "lock")
                            .font(.callout)
                            .foregroundStyle(.gray)
                            .frame(width: 30)
                        SecureField("password", text: $viewModel.password)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(.capsule)
                    
                    
                    HStack{
                        
                        Spacer()
                        
                        Button{
                            Task{
                                await viewModel.resetPassowrd()
                                print("Password reset")
                            }
                            
                        }label:{
                            Text("Reset Password")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .padding(.vertical, 6)
                        }
                    }
                    
                    
                    
                    
                    
                    
                    Button{
                        Task{
                            let success = await viewModel.signIn()
                            if success {
                                showSignInView = false
                            }
                        }
                        
                    }label:{
                        Text("Log in")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .tint(Color.blue)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    
                    
                    Text("Don't have an account?")
                        .font(.system(size: 15, weight: .light))
                    NavigationLink {
                        SignUpView()
                    } label: {
                        Text("Create an account")
                            .font(.system(size: 15, weight: .light))
                    }
                    
                }
                .padding()
            }
        }
        .alert(item: $viewModel.alertItem) { alert in
            Alert(title: alert.title, message: alert.message, dismissButton: alert.dismissButton)
        }
    }
}

#Preview {
    SignInemailView(showSignInView: .constant(false))
}
