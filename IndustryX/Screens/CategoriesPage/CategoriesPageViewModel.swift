//
//  CategoriesPageViewModel.swift
//  IndustryX
//
//  Created by Andryuchshenko Nikita on 23.03.2026.
//

import Foundation
import Combine
import SwiftUI
import FirebaseFirestore
import FirebaseStorage



struct Categories: Decodable, Identifiable {
    @DocumentID var id: String?
    let name: String
    let icon: String
    let availableUnits: Int
    
}

struct Subcategory: Decodable, Identifiable {
    @DocumentID var id: String?
    let name: String
    let tag: String
    let description: String
    let units: Int
    let summaryStats: [SummaryStat]
    let thumbnail: String?
    var categoryId: String?
    
}

struct SummaryStat: Decodable, Identifiable {
    let id = UUID()
    let title: String
    let value: String

    enum CodingKeys: String, CodingKey {
        case title
        case value
    }
}

struct EquipmentItem: Codable, Identifiable {
    @DocumentID var id: String?
    let name: String
    let ref: String
    let year: Int
    let price: Int
    let currency: String
    let rentalPerDay: Int
    let hours: Int
    let location: String
    let status: String
    let badge: String
    let thumbnail: String
    let gallery: [String]
    let technicalSpecifications: [TechnicalSpec]
}

struct TechnicalSpec: Codable, Identifiable {
    let id = UUID()
    var title: String
    var value: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case value
    }
}



final class CategoriesPageViewModel: ObservableObject{
    
    @Published var equipments: [Categories] = []
    @Published var alertItem: AlertItem?
    
    private let db = Firestore.firestore()
    
    func getData()async{
        
        do {
            let snapshot = try await db.collection("categories").getDocuments()
            self.equipments = try snapshot.documents.compactMap {
                try $0.data(as: Categories.self)
            }
        } catch {
            alertItem = alertContext.invalidData
            print(error)
        }
    }
    
    
    
    
}
