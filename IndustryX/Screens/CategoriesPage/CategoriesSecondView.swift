//
//  CategoriesSecondView.swift
//  IndustryX
//
//  Created by Andryuchshenko Nikita on 23.03.2026.
//

import SwiftUI
import FirebaseFirestore
import Combine

final class SubcategoryViewModel: ObservableObject {
    @Published var subcategories: [Subcategory] = []
    @Published var isLoading = false

    private let db = Firestore.firestore()

    func getSubcategories(categoryId: String) async {
        isLoading = true
        do {
            let snapshot = try await db
                .collection("categories")
                .document(categoryId)
                .collection("subcategories")
                .getDocuments()

            self.subcategories = try snapshot.documents.compactMap {
                try $0.data(as: Subcategory.self)
            }
        } catch {
            print("Error loading subcategories: \(error)")
        }
        isLoading = false
    }
}


struct CategoriesSecondView: View {

    let category: Categories
    let columns: [GridItem] = [GridItem(.flexible())]
    @EnvironmentObject private var appData: AppDataStore

    var subcategories: [Subcategory] {
        appData.subcategories.filter { $0.categoryId == category.id }
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            ScrollView {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(subcategories) { subcategory in
                        NavigationLink {
                            CategoriesItemsView(
                                categoryId: category.id ?? "",
                                subcategoryId: subcategory.id ?? "",
                                subcategoryName: subcategory.name
                            )
                        } label: {
                            SecondLayerView(object: subcategory)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(category.name)
    }
}

struct SecondLayerView: View {
    
    let object: Subcategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsyncImage(url: URL(string: object.thumbnail!)){ phase in
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
            
            HStack(alignment: .top) {
                Text(object.name)
                    .font(.system(size: 25, weight: .bold, design: .default))
                    .padding(.leading, 15)
                
                Spacer()
                
                Text("\(object.units) Units")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.blue)
                    .padding(.trailing, 15)
                    .padding(.top, 6)
            }
            
            Text(object.description)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)
                .padding(.horizontal, 15)
            
            HStack(spacing: 12) {
                ForEach(object.summaryStats) { stat in
                    VStack(spacing: 6) {
                        Text(stat.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        
                        Text(stat.value)
                            .font(.system(size: 20, weight: .bold))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(width: 155, height: 85)
                    .background(Color.gray.opacity(0.12))
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal, 15)
            .padding(.bottom, 15)
        }
        .frame(width: 360)
        .background(.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        .overlay(
            VStack{
                Text(object.tag)
                    .foregroundStyle(.blue)
                    .bold()
                    .padding(7)
            }
            .background(Color(.white).opacity(0.5))
            .cornerRadius(10)
            .padding(12)
            , alignment: .topTrailing)
    }
}

#Preview {
    NavigationStack {
        CategoriesSecondView(category: Categories(id: "cat_cranes", name: "Cranes", icon: "shippingbox", availableUnits: 85))
    }
}
