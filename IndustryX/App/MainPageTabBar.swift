import SwiftUI

struct MainPageTabBar: View {

    @Binding var showSignInView: Bool
    @StateObject private var profileViewModel = ProfilePageViewModel()
    @StateObject private var appData = AppDataStore()  // ← single source of truth

    var body: some View {
        TabView {
            HomePageView()
                .environmentObject(appData)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            CategoriesPageView()
                .environmentObject(appData)
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Categories")
                }

            FavoritesPageView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("Favorites")
                }

            ProfilePageView(viewModel: profileViewModel, showSignInView: $showSignInView)
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
        }
        .task {
            await appData.load()  // ← loads once when tab bar appears
        }
    }
}
