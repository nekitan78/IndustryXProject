//
//  CategoriesThirdView.swift
//  IndustryX
//
//  Created by Andryuchshenko Nikita on 24.03.2026.
//

import SwiftUI

struct CategoriesThirdView: View {
    
    let item: EquipmentItem
    
    var body: some View {
        ZStack{
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView{
                VStack(alignment: .leading){
                    AsyncImage(url: URL(string: item.thumbnail)){ phase in
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
                    
                    
                    PriceView(price:item.price , ref: item.ref, year: item.year, dayRent: item.rentalPerDay, hours: item.hours, location: item.location, status: item.status)
                    
                    TechSpecView(tech: item.technicalSpecifications)
                    
                    
                    VStack(alignment: .leading){
                        HStack{
                            VStack(alignment: .leading){
                                Text("Rental")
                                    .font(.system(size: 20, weight: .bold))
                                    
                                Text("Availablity")
                                    .font(.system(size: 20, weight: .bold))
                                
                            }
                            .padding()
                            
                            Circle()
                                .frame(width: 15, height: 15)
                                .foregroundStyle(.green)
                            
                            Text("Available")
                                .font(.system(size: 13, weight: .semibold))
                            
                            Circle()
                                .frame(width: 15, height: 15)
                                .foregroundStyle(.red)
                            
                            Text("Booked")
                                .font(.system(size: 13, weight: .semibold))
                            
                            Circle()
                                .frame(width: 15, height: 15)
                                .foregroundStyle(.gray)
                            
                            Text("N/A")
                                .font(.system(size: 13, weight: .semibold))
                            
                        }
                        
                        
                    }
                    .frame(maxWidth: 360, alignment: .leading)
                    .background(.white)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                    
                }
            }
        }
    }
}

struct BasicInfo: View{
    
    let icon: String
    let name: String
    let metric: String
    
    var body: some View{
        VStack{
            Image(systemName: icon)
                .resizable()
                .foregroundStyle(.secondary)
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
            
            Text(name)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.secondary)
            
            Text(metric)
                .font(.system(size: 20, weight: .semibold))
            
            
        }
    }
}

struct PriceView:View {
    
    let price: Int
    let ref: String
    let year: Int
    let dayRent: Int
    let hours: Int
    let location: String
    let status: String
    
    var body: some View{
        VStack(alignment: .leading){
            Text("$\(price)")
                .font(.system(size: 25, weight: .bold))
                .padding(.leading, 25)
                .padding(.top, 25)
            
            Text("Ref \(ref) · \(year) Model")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, 30)
                .padding(.top, 3)
            
            HStack{
                Text("$\(dayRent) ")
                    .foregroundStyle(.blue)
                    .font(.system(size: 20, weight: .bold))
                Text("/ day rental")
                    .foregroundStyle(.blue)
                    .font(.system(size: 18, weight: .semibold))
            }
            .padding()
            .background(Color(.blue).opacity(0.2))
            .cornerRadius(12)
            .padding(.leading, 30)
            .padding(.top, 3)
            
            Divider()
            
            
            HStack(spacing: 25){
                Spacer()
                
                BasicInfo(icon: "clock", name: "Hours",  metric: String(hours))
                BasicInfo(icon: "mappin.and.ellipse", name: "Location",  metric: location)
                BasicInfo(icon: "checkmark.circle", name: "Status",  metric: status)
                
                Spacer()
            }
            .padding(.top, 15)
            .padding(.bottom, 15)
            
            
                
        }
        .frame(maxWidth: 360, alignment: .leading)
        .background(.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

struct TechSpec: View{
    
    let nameSpec: String
    let spec: String
    
    var body: some View{
        HStack{
            Text(nameSpec)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(spec)
                .font(.system(size: 20, weight: .semibold))
        }
        .padding(15)
        
        Divider()
    }
}

struct TechSpecView: View{
    let tech: [TechnicalSpec]
    var body: some View{
        VStack(){
            Text("Technical Specification")
                .font(.system(size: 25, weight: .bold))
                .padding(15)
            
            Divider()
            
            ForEach(tech){ item in
                TechSpec(nameSpec: item.title, spec: item.value)
            }
            
        }
        .frame(maxWidth: 360, alignment: .leading)
        .background(.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    CategoriesThirdView(item: EquipmentItem(id: "434", name: "dsds", ref: "dsds", year: 2100, price: 333, currency: "usd", rentalPerDay: 2000, hours: 1211, location: "colorado", status: "certified", badge: "heavy", thumbnail: "dsfd", gallery: [""], technicalSpecifications: []))
}
