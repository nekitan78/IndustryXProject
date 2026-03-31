//
//  AppDataStore.swift
//  IndustryX
//
//  Created by Andryuchshenko Nikita on 31.03.2026.
//

import SwiftUI
import FirebaseFirestore
import Combine

@MainActor
final class AppDataStore: ObservableObject {
    @Published var categories: [Categories] = []
    @Published var subcategories: [Subcategory] = []
    @Published var isLoading = false
    private var isLoaded = false

    private var db: Firestore { Firestore.firestore() }

    func load() async {
        guard !isLoaded else { return }
        isLoading = true
        do {
            let categoriesSnapshot = try await db.collection("categories").getDocuments()
            var allCategories: [Categories] = []
            var allSubcategories: [Subcategory] = []

            for categoryDoc in categoriesSnapshot.documents {
                if let cat = try? categoryDoc.data(as: Categories.self) {
                    allCategories.append(cat)
                }

                let subSnapshot = try await db
                    .collection("categories")
                    .document(categoryDoc.documentID)
                    .collection("subcategories")
                    .getDocuments()

                var subs = try subSnapshot.documents.compactMap {
                    try $0.data(as: Subcategory.self)
                }
                for i in subs.indices {
                    subs[i].categoryId = categoryDoc.documentID
                }
                allSubcategories.append(contentsOf: subs)
            }

            self.categories = allCategories
            self.subcategories = allSubcategories
            isLoaded = true
        } catch {
            print("Error loading app data: \(error)")
        }
        isLoading = false
    }
}
