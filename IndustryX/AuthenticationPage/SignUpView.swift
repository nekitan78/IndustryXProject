//
//  SignUpView.swift
//  IndustryX
//
//  Created by Andryuchshenko Nikita on 20.03.2026.
//

import SwiftUI
import Combine

@MainActor
final class SignUpViewModel: ObservableObject{
    @Published var email = ""
    @Published var password = ""
    @Published var alertItem: AlertItem?
    
    func signUp() async {
            guard !email.isEmpty, !password.isEmpty else {
                alertItem = alertContext.invalidForm
                return
            }
            
            do {
                let returnedData = try await AuthenticationManager.shared.createUser(email: email, password: password)
                print("Success")
                print(returnedData)
                
                try await AuthenticationManager.shared.sendVerificationEmail()
                alertItem = alertContext.verificationSent
                
                try? AuthenticationManager.shared.signOut()
            } catch {
                print("Sign up error: \(error.localizedDescription)")
                alertItem = alertContext.invalidForm
            }
    }
        
    func resendVerificationEmail() async {
            do {
                try await AuthenticationManager.shared.sendVerificationEmail()
                alertItem = alertContext.verificationResent
            } catch {
                print("Resend error: \(error.localizedDescription)")
            }
    }
    
    
}


struct SignUpView: View {
    
    @StateObject var viewModel = SignUpViewModel()
    
    var body: some View {
        ZStack{
            VStack{
                Text("Sign Up")
                    .font(.system(size: 25, weight: .semibold, design: .default))
                HStack{
                    Image(systemName: "envelope")
                        .font(.callout)
                        .foregroundStyle(.gray)
                        .frame(width: 30)
                    TextField("email", text: $viewModel.email)
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
                
                Button{
                    Task{
                        await viewModel.signUp()
                    }
                    
                }label:{
                    Text("Sign Up")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .tint(Color.blue)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)

            }
            .padding()
        }
        .alert(item: $viewModel.alertItem) { alert in
            Alert(title: alert.title, message: alert.message, dismissButton: alert.dismissButton)
        }
    }

}

#Preview {
    SignUpView()
}
