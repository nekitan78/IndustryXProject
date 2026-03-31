//
//  FavoritesPageView.swift
//  IndustryX
//
//  Created by Andryuchshenko Nikita on 17.03.2026.
//

import SwiftUI

struct FavoritesPageView: View {
    
    @EnvironmentObject var favorite: Favorite
    let columns: [GridItem] = [GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ZStack{
                Color(.systemGroupedBackground)
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(favorite.items) { item in
                            NavigationLink {
                                CategoriesThirdView(item: item)
                            } label: {
                                ItemsLayerView(object: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                if favorite.items.isEmpty{
                    FavoriteEmptyState()
                }
            }
            .navigationTitle("Favorites")
        }
    }
}

#Preview {
    FavoritesPageView()
}
