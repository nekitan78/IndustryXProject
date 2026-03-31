import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import PhotosUI
import Combine

@MainActor
final class CreateListingViewModel: ObservableObject {

    
    @Published var name: String = ""
    @Published var price: String = ""
    @Published var rentalPerDay: String = ""
    @Published var year: String = ""
    @Published var location: String = ""
    @Published var hours: String = ""
    @Published var status: String = ""
    @Published var badge: String = ""
    @Published var currency: String = "USD"

    
    @Published var photoURLs: [String] = []
    @Published var pickedImages: [UIImage] = []
    @Published var urlInput: String = ""
    @Published var photosPickerItems: [PhotosPickerItem] = []

    
    @Published var techSpecs: [TechnicalSpec] = []

    
    @Published var isSaving = false
    @Published var didSave = false

    private var db: Firestore { Firestore.firestore() }
    private var storage: Storage { Storage.storage() }

    
    func addURL() {
        let trimmed = urlInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, trimmed.hasPrefix("http") else { return }
        photoURLs.append(trimmed)
        urlInput = ""
    }

    func removeURL(at offsets: IndexSet) {
        photoURLs.remove(atOffsets: offsets)
    }

    
    func loadPickedImages() async {
        var loaded: [UIImage] = []
        for item in photosPickerItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                loaded.append(image)
            }
        }
        pickedImages = loaded
    }

    
    private func uploadPickedImages(listingId: String) async -> [String] {
        var uploadedURLs: [String] = []
        for (index, image) in pickedImages.enumerated() {
            guard let data = image.jpegData(compressionQuality: 0.8) else { continue }
            let ref = storage.reference().child("listings/\(listingId)/photo_\(index).jpg")
            do {
                let _ = try await ref.putDataAsync(data)
                let url = try await ref.downloadURL()
                uploadedURLs.append(url.absoluteString)
                print("✅ Uploaded photo \(index)")
            } catch {
                print("❌ Failed to upload photo \(index): \(error)")
            }
        }
        return uploadedURLs
    }

    
    func addSpec() {
        techSpecs.append(TechnicalSpec(title: "", value: ""))
    }

    func removeSpec(at offsets: IndexSet) {
        techSpecs.remove(atOffsets: offsets)
    }

    
    func save(categoryId: String, subcategoryId: String) async {
        guard !name.isEmpty, !price.isEmpty,
              !categoryId.isEmpty, !subcategoryId.isEmpty else { return }

        isSaving = true
        let listingId = UUID().uuidString

        // Upload library photos and merge with manual URLs
        let uploadedURLs = await uploadPickedImages(listingId: listingId)
        let allPhotos = photoURLs + uploadedURLs
        let thumbnail = allPhotos.first ?? ""

        let data: [String: Any] = [
            "name":         name,
            "price":        Int(price) ?? 0,
            "rentalPerDay": Int(rentalPerDay) ?? 0,
            "year":         Int(year) ?? 0,
            "location":     location,
            "hours":        Int(hours) ?? 0,
            "status":       status,
            "badge":        badge,
            "currency":     currency,
            "ref":          listingId,
            "thumbnail":    thumbnail,
            "gallery":      allPhotos,
            "technicalSpecifications": techSpecs.map {
                ["title": $0.title, "value": $0.value]
            }
        ]

        do {
            try await db
                .collection("categories")
                .document(categoryId)
                .collection("subcategories")
                .document(subcategoryId)
                .collection("items")
                .document(listingId)
                .setData(data)
            print("✅ Listing saved")
            didSave = true
        } catch {
            print("❌ Error saving listing: \(error)")
        }
        isSaving = false
    }
}

struct CreateListingView: View {

    @StateObject private var viewModel = CreateListingViewModel()
    @Environment(\.dismiss) var dismiss

    let categories: [Categories]
    let subcategories: [Subcategory]

    @State private var selectedCategoryId: String = ""
    @State private var selectedSubcategoryId: String = ""

    var filteredSubcategories: [Subcategory] {
        subcategories.filter { $0.categoryId == selectedCategoryId }
    }

    var body: some View {
        NavigationView {
            Form {

                // MARK: - Basic Info
                Section(header: Text("Basic Info")) {
                    TextField("Name", text: $viewModel.name)
                    TextField("Price (USD)", text: $viewModel.price)
                        .keyboardType(.numberPad)
                    TextField("Rental per day", text: $viewModel.rentalPerDay)
                        .keyboardType(.numberPad)
                    TextField("Year", text: $viewModel.year)
                        .keyboardType(.numberPad)
                    TextField("Location", text: $viewModel.location)
                    TextField("Hours used", text: $viewModel.hours)
                        .keyboardType(.numberPad)
                    TextField("Status (e.g. Available)", text: $viewModel.status)
                    TextField("Badge (e.g. Heavy Duty)", text: $viewModel.badge)
                }

                
                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategoryId) {
                        Text("Select...").tag("")
                        ForEach(categories) { cat in
                            Text(cat.name).tag(cat.id ?? "")
                        }
                    }
                    .onChange(of: selectedCategoryId) { _, _ in
                        selectedSubcategoryId = filteredSubcategories.first?.id ?? ""
                    }

                    Picker("Subcategory", selection: $selectedSubcategoryId) {
                        Text("Select...").tag("")
                        ForEach(filteredSubcategories) { sub in
                            Text(sub.name).tag(sub.id ?? "")
                        }
                    }
                }

               
                Section(header: Text("Photos from Library")) {
                    PhotosPicker(
                        selection: $viewModel.photosPickerItems,
                        maxSelectionCount: 5,
                        matching: .images
                    ) {
                        Label("Select Photos", systemImage: "photo.on.rectangle.angled")
                    }
                    .onChange(of: viewModel.photosPickerItems) { _, _ in
                        Task { await viewModel.loadPickedImages() }
                    }

                    if !viewModel.pickedImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(viewModel.pickedImages.indices, id: \.self) { i in
                                    Image(uiImage: viewModel.pickedImages[i])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }

               
                Section(header: Text("Add Photo URL")) {
                    HStack {
                        TextField("https://...", text: $viewModel.urlInput)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        Button("Add") { viewModel.addURL() }
                            .disabled(viewModel.urlInput.isEmpty)
                    }

                    ForEach(viewModel.photoURLs, id: \.self) { url in
                        Text(url)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .onDelete { offsets in viewModel.removeURL(at: offsets) }
                }

                
                Section(header: HStack {
                    Text("Technical Specifications")
                    Spacer()
                    Button {
                        viewModel.addSpec()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }) {
                    if viewModel.techSpecs.isEmpty {
                        Text("Tap + to add specifications")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }

                    ForEach(viewModel.techSpecs.indices, id: \.self) { i in
                        HStack(spacing: 10) {
                            TextField("Title", text: $viewModel.techSpecs[i].title)
                            Divider()
                            TextField("Value", text: $viewModel.techSpecs[i].value)
                        }
                    }
                    .onDelete { offsets in viewModel.removeSpec(at: offsets) }
                }

                
                Section {
                    Button {
                        Task {
                            await viewModel.save(
                                categoryId: selectedCategoryId,
                                subcategoryId: selectedSubcategoryId
                            )
                        }
                    } label: {
                        if viewModel.isSaving {
                            HStack {
                                Spacer()
                                ProgressView()
                                Text("Saving...")
                                Spacer()
                            }
                        } else {
                            Text("Create Listing")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundStyle(.blue)
                                .bold()
                        }
                    }
                    .disabled(
                        viewModel.isSaving ||
                        viewModel.name.isEmpty ||
                        viewModel.price.isEmpty ||
                        selectedCategoryId.isEmpty ||
                        selectedSubcategoryId.isEmpty
                    )
                }
            }
            .navigationTitle("Create Listing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onChange(of: viewModel.didSave) { _, saved in
                if saved { dismiss() }
            }
            .onAppear {
                selectedCategoryId = categories.first?.id ?? ""
                selectedSubcategoryId = subcategories.first?.id ?? ""
            }
        }
    }
}
