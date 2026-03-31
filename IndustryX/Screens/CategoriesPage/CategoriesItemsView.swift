//
//  CategoriesItemsView.swift
//  IndustryX
//
//  Created by Andryuchshenko Nikita on 26.03.2026.
//

import SwiftUI
import FirebaseFirestore
import Combine

final class ItemsViewModel: ObservableObject {
    @Published var items: [EquipmentItem] = []
    @Published var isLoading = false

    private let db = Firestore.firestore()

    func getItems(categoryId: String, subcategoryId: String) async {
        isLoading = true
        do {
            let snapshot = try await db
                .collection("categories")
                .document(categoryId)
                .collection("subcategories")
                .document(subcategoryId)
                .collection("items")
                .getDocuments()

            self.items = try snapshot.documents.compactMap {
                try $0.data(as: EquipmentItem.self)
            }
        } catch {
            print("Error loading items: \(error)")
        }
        isLoading = false
    }
}

struct CategoriesItemsView: View {
    @EnvironmentObject var favorite: Favorite
    let columns: [GridItem] = [GridItem(.flexible())]
    @StateObject private var viewModel = ItemsViewModel()
    
    let categoryId: String
    let subcategoryId: String
    let subcategoryName: String
    
    
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(viewModel.items) { item in
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
        }
        .navigationTitle(subcategoryName)
        .task {
            await viewModel.getItems(categoryId: categoryId, subcategoryId: subcategoryId)
        }
    }
}

struct ItemsLayerView: View {
    
    let object: EquipmentItem
    @EnvironmentObject var favorite: Favorite
    var body: some View {
        VStack(alignment: .leading) {
            
            AsyncImage(url: URL(string: object.thumbnail)){ phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 350, height: 220)
                        .clipped()
                        .cornerRadius(20)
                    
                case .failure(_):
                    Image("food-placeholder")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 350, height: 220)
                        .clipped()
                        .cornerRadius(20)
                @unknown default:
                    Image("food-placeholder")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 350, height: 220)
                        .clipped()
                        .cornerRadius(20)
                }
            }
            
            
            
            //Text(object.name)
               // .font(.system(size: 15, weight: .semibold, design: .default))
               // .foregroundStyle(.secondary)
                //.padding(.leading, 15)
            
            HStack{
                Text(object.name)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .padding(.leading, 15)
                
                Spacer()
                    
                Button{
                    
                    favorite.toggle(object)
                    
                }label:{
                    ZStack{
                        Circle()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.blue)
                            .padding(20)
                        
                        Image(systemName: favorite.isFavorite(object) ? "heart.fill" : "heart")
                            .foregroundStyle(.white)
                            .scaleEffect(favorite.isFavorite(object) ? 1.1 : 1.0)
                            .animation(.easeInOut, value: favorite.isFavorite(object))
                        
                    }
                }
            }
            
            
            Text("$\(object.price)")
                .font(.system(size: 25, weight: .bold, design: .default))
                .padding(.leading, 15)
                .padding(.bottom, 15)
            
        }
        .frame(width: 360)
        .background(.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}


#Preview {
    CategoriesItemsView(categoryId: "cat_cranes", subcategoryId: "sub_crawler_cranes", subcategoryName: "Crawler Cranes")
        .environmentObject(Favorite())
}
