//
//  FavoriteEmptyState.swift
//  IndustryX
//
//  Created by Andryuchshenko Nikita on 29.03.2026.
//

import SwiftUI

struct FavoriteEmptyState: View {
    var body: some View {
        ZStack{
            Color(.systemBackground)
            
            VStack{
                Image("gear")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                Text("The favorite list is empty")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding()
            }
            .offset(y: -50)
        }
    }
}

#Preview {
    FavoriteEmptyState()
}
