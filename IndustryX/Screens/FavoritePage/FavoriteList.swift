import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

final class Favorite: ObservableObject {
    @Published var items: [EquipmentItem] = []

    private var db: Firestore { Firestore.firestore() }

    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    // MARK: - Load on init
    init() {
        Task { await loadFromFirestore() }
    }

    // MARK: - Public API (unchanged — your views don't need to change)
    func add(_ equipment: EquipmentItem) {
        guard !items.contains(where: { $0.id == equipment.id }) else { return }
        items.append(equipment)
        Task { await saveToFirestore(equipment, isFavorite: true) }
    }

    func remove(_ item: EquipmentItem) {
        items.removeAll { $0.id == item.id }
        Task { await saveToFirestore(item, isFavorite: false) }
    }

    func isFavorite(_ item: EquipmentItem) -> Bool {
        items.contains { $0.id == item.id }
    }

    func toggle(_ item: EquipmentItem) {
        isFavorite(item) ? remove(item) : add(item)
    }

    // MARK: - Firestore
    private func loadFromFirestore() async {
        guard let userId else { return }
        do {
            let snapshot = try await db
                .collection("users")
                .document(userId)
                .collection("favorites")
                .getDocuments()

            let loaded = try snapshot.documents.compactMap {
                try $0.data(as: EquipmentItem.self)
            }
            await MainActor.run { self.items = loaded }
        } catch {
            print("Error loading favorites: \(error)")
        }
    }

    private func saveToFirestore(_ item: EquipmentItem, isFavorite: Bool) async {
        guard let userId, let itemId = item.id else { return }
        let ref = db
            .collection("users")
            .document(userId)
            .collection("favorites")
            .document(itemId)

        do {
            if isFavorite {
                try await ref.setData([
                    "name": item.name,
                    "ref": item.ref,
                    "year": item.year,
                    "price": item.price,
                    "currency": item.currency,
                    "rentalPerDay": item.rentalPerDay,
                    "hours": item.hours,
                    "location": item.location,
                    "status": item.status,
                    "badge": item.badge,
                    "thumbnail": item.thumbnail,
                    "gallery": item.gallery,
                    "technicalSpecifications": item.technicalSpecifications.map {
                        ["title": $0.title, "value": $0.value]
                    }
                ])
            } else {
                try await ref.delete()
            }
        } catch {
            print("Error saving favorite: \(error)")
        }
    }
}
