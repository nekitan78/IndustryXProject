//
//  CategoriesPageView.swift
//  IndustryX
//
//  Created by Andryuchshenko Nikita on 17.03.2026.
//

import SwiftUI

struct CategoriesPageView: View {

    @EnvironmentObject private var appData: AppDataStore
    let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(appData.categories) { item in
                            NavigationLink {
                                CategoriesSecondView(category: item)
                            } label: {
                                CategoriesCard(
                                    imageName: item.icon,
                                    equipmentName: item.name,
                                    numberofUnits: "\(item.availableUnits) units available"
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Categories")
        }
    }
}

struct CategoriesCard: View {
    let imageName: String
    let equipmentName: String
    let numberofUnits: String
    
    var body: some View{
        VStack(alignment: .leading){
            ZStack{
                Color(.blue)
                    .opacity(0.25)
                Image(systemName: imageName)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            }
            
            Text(equipmentName)
                .font(.system(size: 25, weight: .bold, design: .default))
                .padding(.leading, 15)
            Text(numberofUnits)
                .font(.system(size: 15))
                .padding(.leading, 15)
                .padding(.bottom, 15)
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)
        }
        .frame(width: 165, height: 200)
        .background(.white)
        .cornerRadius(15)
        
        
        
    }
}

#Preview {
    CategoriesPageView()
}
