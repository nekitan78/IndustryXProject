import SwiftUI

struct HomePageView: View {

    @EnvironmentObject private var appData: AppDataStore
    @State private var showCreateSheet = false
    let columns: [GridItem] = [GridItem(.flexible())]

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                if appData.isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(appData.subcategories) { subcategory in
                                NavigationLink {
                                    if let categoryId = subcategory.categoryId,
                                       let subcategoryId = subcategory.id,
                                       !categoryId.isEmpty,
                                       !subcategoryId.isEmpty {
                                        CategoriesItemsView(
                                            categoryId: categoryId,
                                            subcategoryId: subcategoryId,
                                            subcategoryName: subcategory.name
                                        )
                                    }
                                } label: {
                                    SecondLayerView(object: subcategory)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showCreateSheet = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateListingView(
                    categories: appData.categories,
                    subcategories: appData.subcategories
                )
            }
        }
    }
}
