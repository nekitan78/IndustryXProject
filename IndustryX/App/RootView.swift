//
//  RootView.swift
//  IndustryX
//
//  Created by Andryuchshenko Nikita on 20.03.2026.
//

import SwiftUI

struct RootView: View {
    
    @State var showSignInView: Bool = false
    
    var body: some View {
        ZStack{
            NavigationStack{
                MainPageTabBar(showSignInView: $showSignInView)
            }
        }
        .onAppear{
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack{
                SignInemailView(showSignInView: $showSignInView)
            }
        }
    }
}

#Preview {
    RootView()
}
