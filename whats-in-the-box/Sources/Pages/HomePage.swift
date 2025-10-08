import SwiftUI
import SwiftData

struct HomePage: View {
    @Environment(Router.self) private var router
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.modelContext) private var context
    
    @Query(StorageBox.recentlyUpdated) private var boxes: [StorageBox]
    
    @State private var boxToDelete: StorageBox?
    @State private var isShowingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerSection
                
                // Search Bar
                searchBar
                
                // Boxes Grid
                boxesGrid
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
                    router.navigate(to: .settings)
                } label: {
                    Image(systemName: "gear")
                        .foregroundColor(themeManager.selectedTheme.primaryThemeColor)
                }
            }
            
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
            
            Text("Search items...")
                .font(themeManager.selectedTheme.bodyTextFont)
                .foregroundColor(themeManager.selectedTheme.bodyTextColor.opacity(0.5))
            
            Spacer()
        }
        .padding()
        .background(themeManager.selectedTheme.textBoxColor)
        .cornerRadius(12)
        .onTapGesture {
            // Navigate to search page (coming soon)
        }
    }
    
    // MARK: - Boxes Grid
    private var boxesGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(boxes) { box in
                BoxCard(box: box) {
                    router.navigate(to: .editBox(boxId: box.id.uuidString))
                } onDelete: {
                    boxToDelete = box
                    isShowingDeleteAlert = true
                }
                .onTapGesture {
                    router.navigate(to: .boxDetail(boxId: box.id.uuidString))
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

// MARK: - Box Card Component
struct BoxCard: View {
    let box: StorageBox
    let onEdit: () -> Void
    let onDelete: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Box Image
            Group {
                if let photoURL = box.photoURL, let image = loadImageFromPath(photoURL) {
                    Image(platformImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    // Fallback icon
                    RoundedRectangle(cornerRadius: 12)
                        .fill(themeManager.selectedTheme.primaryThemeColor.opacity(0.1))
                        .frame(height: 120)
                        .overlay {
                            Image(systemName: "shippingbox.fill")
                                .font(.system(size: 40))
                                .foregroundColor(themeManager.selectedTheme.primaryThemeColor)
                        }
                }
            }
            
            // Box Info
            VStack(alignment: .leading, spacing: 4) {
                Text(box.name)
                    .font(themeManager.selectedTheme.textTitleFont)
                    .foregroundColor(themeManager.selectedTheme.bodyTextColor)
                    .lineLimit(1)
                
                Text("\(box.itemCount) items")
                    .font(themeManager.selectedTheme.bodyTextFont)
                    .foregroundColor(themeManager.selectedTheme.bodyTextColor.opacity(0.6))
            }
        }
        .padding()
        .background(themeManager.selectedTheme.textBoxColor)
        .cornerRadius(16)
        #if os(macOS)
        .contextMenu {
            Button(action: onEdit) {
                Label("Edit Box", systemImage: "pencil")
            }
            
            Button(role: .destructive, action: onDelete) {
                Label("Delete Box", systemImage: "trash")
            }
        }
        #endif
    }
}



#Preview {
    NavigationStack {
        HomePage()
            .environment(Router())
            .environmentObject(ThemeManager())
    }
}
