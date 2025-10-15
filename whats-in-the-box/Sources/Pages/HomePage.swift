import SwiftUI
import SwiftData

struct HomePage: View {
    @Environment(Router.self) private var router
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.modelContext) private var context
    
    @Query(StorageBox.recentlyUpdated) private var boxes: [StorageBox]
    
    @State private var boxToDelete: StorageBox?
    @State private var isShowingDeleteAlert = false
    @State private var searchQuery = ""
    
    private var searchResults: [SearchResult] {
        if searchQuery.isEmpty {
            return boxes.map { .box($0) }
        }

        var results: [SearchResult] = []
        let lowercasedQuery = searchQuery.lowercased()

        for box in boxes {
            let boxNameMatches = box.name.lowercased().contains(lowercasedQuery)
            
            if boxNameMatches {
                results.append(.box(box))
            } else {
                let matchingItems = box.items?.filter { $0.name.lowercased().contains(lowercasedQuery) } ?? []
                for item in matchingItems {
                    results.append(.item(item, in: box))
                }
            }
        }
        return results
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerSection
                
                // Search Bar
                searchBar
                
                // Search Results
                searchResultsList
            }
            .padding()
        }
        .navigationTitle("My Boxes")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .toolbar {
            #if os(macOS)
            Button {
                router.navigate(to: .settings)
            } label: {
                Image(systemName: "gear")
            }
            
            Button {
                router.navigate(to: .addBox)
            } label: {
                Image(systemName: "plus.circle.fill")
            }
            #else
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.navigate(to: .addBox)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(themeManager.selectedTheme.primaryThemeColor)
                }
            }
            #endif
        }
        .alert("Are you sure?", isPresented: $isShowingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteBox()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What's in the box?")
                .font(themeManager.selectedTheme.largeTitleFont)
                .foregroundColor(themeManager.selectedTheme.primaryThemeColor)
            
            Text("\(boxes.count) boxes • \(totalItems) items")
                .font(themeManager.selectedTheme.bodyTextFont)
                .foregroundColor(themeManager.selectedTheme.bodyTextColor.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(themeManager.selectedTheme.bodyTextColor.opacity(0.5))
            
            TextField("Search items...", text: $searchQuery)
                .font(themeManager.selectedTheme.bodyTextFont)
                .foregroundColor(themeManager.selectedTheme.bodyTextColor)
            
            Spacer()
        }
        .padding()
        .background(themeManager.selectedTheme.textBoxColor)
        .cornerRadius(12)
    }
    
    // MARK: - Search Results List
    private var searchResultsList: some View {
        VStack(spacing: 16) {
            ForEach(searchResults) { result in
                switch result {
                case .box(let box):
                    BoxCard(box: box) {
                        router.navigate(to: .editBox(boxId: box.id.uuidString))
                    } onDelete: {
                        boxToDelete = box
                        isShowingDeleteAlert = true
                    }
                    .onTapGesture {
                        router.navigate(to: .boxDetail(boxId: box.id.uuidString))
                    }
                case .item(let item, let box):
                    ItemSearchResultRow(item: item, box: box)
                        .onTapGesture {
                            router.navigate(to: .boxDetail(boxId: box.id.uuidString))
                        }
                }
            }
        }
    }
    
    private var totalItems: Int {
        boxes.reduce(0) { $0 + $1.itemCount }
    }
    
    private func deleteBox() {
        if let box = boxToDelete {
            context.delete(box)
            boxToDelete = nil
        }
    }
}

// MARK: - Search Result Types
private enum SearchResult: Hashable, Identifiable {
    case box(StorageBox)
    case item(BoxItem, in: StorageBox)

    var id: AnyHashable {
        switch self {
        case .box(let box):
            return "box-\(box.id.hashValue)"
        case .item(let item, _):
            return "item-\(item.id.hashValue)"
        }
    }
}

// MARK: - Item Search Result Row
private struct ItemSearchResultRow: View {
    let item: BoxItem
    let box: StorageBox
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        HStack {
            Image(systemName: "tag")
                .font(.title)
                .foregroundColor(themeManager.selectedTheme.primaryThemeColor)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading) {
                Text(item.name)
                    .font(themeManager.selectedTheme.bodyTextFont)
                    .foregroundColor(themeManager.selectedTheme.bodyTextColor)
                Text("In: \(box.name)")
                    .font(themeManager.selectedTheme.captionTxtFont)
                    .foregroundColor(themeManager.selectedTheme.bodyTextColor.opacity(0.7))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(themeManager.selectedTheme.textBoxColor)
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        HomePage()
            .environment(Router())
            .environmentObject(ThemeManager())
    }
}
