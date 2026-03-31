//
//  ProfilePageView.swift
//  IndustryX
//
//  Created by Andryuchshenko Nikita on 17.03.2026.
//

import SwiftUI
import Combine
import PhotosUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct UserProfile {
    var name: String = ""
    var surname: String = ""
    var email: String = ""
    var birthDay: Date = Date()
    var avatarURL: String = ""
}

@MainActor
final class ProfilePageViewModel: ObservableObject {

    @Published var profile = UserProfile()
    @Published var isSaving = false

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    func loadProfile() async {
        // Wait for a valid user, don't rely on currentUser being ready instantly
        guard let user = Auth.auth().currentUser else {
            // Auth not ready yet — listen for state change
            await withCheckedContinuation { continuation in
                var handle: AuthStateDidChangeListenerHandle?
                handle = Auth.auth().addStateDidChangeListener { _, user in
                    if user != nil {
                        Auth.auth().removeStateDidChangeListener(handle!)
                        continuation.resume()
                    }
                }
            }
            await loadProfile() // retry once Auth is ready
            return
        }

        profile.email = user.email ?? ""

        do {
            let doc = try await db.collection("users").document(user.uid).getDocument()
            guard let data = doc.data() else { return }
            profile.name      = data["name"] as? String ?? ""
            profile.surname   = data["surname"] as? String ?? ""
            profile.avatarURL = data["avatarURL"] as? String ?? ""
            if let timestamp  = data["birthDay"] as? Timestamp {
                profile.birthDay = timestamp.dateValue()
            }
        } catch {
            print("Error loading profile: \(error)")
        }
    }

    func saveProfile() async {
        guard let userId else { return }
        isSaving = true
        do {
            try await db.collection("users").document(userId).setData([
                "name":      profile.name,
                "surname":   profile.surname,
                "email":     profile.email,
                "birthDay":  Timestamp(date: profile.birthDay),
                "avatarURL": profile.avatarURL
            ], merge: true)
            print("✅ Profile saved")
        } catch {
            print("Error saving profile: \(error)")
        }
        isSaving = false
    }

    func uploadAvatar(_ image: UIImage) async {
        guard let userId,
              let imageData = image.jpegData(compressionQuality: 0.5)
        else { return }
        isSaving = true
        let ref = storage.reference().child("avatars/\(userId).jpg")
        do {
            let _ = try await ref.putDataAsync(imageData)
            let url = try await ref.downloadURL()
            profile.avatarURL = url.absoluteString
            await saveProfile()
            print("✅ Avatar uploaded")
        } catch {
            print("Error uploading avatar: \(error)")
        }
        isSaving = false
    }

    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
}


struct ProfilePageView: View {

    @StateObject var viewModel = ProfilePageViewModel()
    @Binding var showSignInView: Bool
    @State var avatarImage: UIImage?
    @State var photosPickerItem: PhotosPickerItem?

    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    HStack(spacing: 20) {
                        PhotosPicker(selection: $photosPickerItem, matching: .images) {
                            Image(uiImage: avatarImage ?? UIImage(systemName: "person")!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(.circle)
                        }

                        VStack(alignment: .leading) {
                            Text("\(viewModel.profile.name) \(viewModel.profile.surname)")
                                .font(.system(size: 20, weight: .bold))

                            Text( "User")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }
                .padding(30)
                .onChange(of: photosPickerItem) { _, _ in
                    Task {
                        if let photosPickerItem,
                           let data = try? await photosPickerItem.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            avatarImage = image
                            await viewModel.uploadAvatar(image) // ← uploads to Storage
                        }
                        photosPickerItem = nil
                    }
                }

                Form {
                    Section(header: Text("Personal Info")) {
                        TextField("Name", text: $viewModel.profile.name)
                        TextField("Surname", text: $viewModel.profile.surname)
                        HStack {
                            Text("Email")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(viewModel.profile.email.isEmpty ? "Not set" : viewModel.profile.email)
                                .foregroundStyle(.secondary)
                        }
                        DatePicker("Birthday", selection: $viewModel.profile.birthDay, displayedComponents: .date)
                    }

                    Section {
                        Button(viewModel.isSaving ? "Saving..." : "Save Profile") {
                            Task { await viewModel.saveProfile() }
                        }
                        .disabled(viewModel.isSaving)

                        Button("Log out", role: .destructive) {
                            Task {
                                do {
                                    try viewModel.signOut()
                                    showSignInView = true
                                } catch {
                                    print(error)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Profile")
            .task { await viewModel.loadProfile() }
        }
    }
}

#Preview {
    ProfilePageView(showSignInView: .constant(false))
}
