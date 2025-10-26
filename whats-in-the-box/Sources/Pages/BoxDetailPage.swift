import SwiftUI
import SwiftData


struct BoxDetailPage: View {
    let boxId: String
    @Environment(Router.self) private var router
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.modelContext) private var context
    
    @Query private var boxes: [StorageBox]
    @State private var isShowingDeleteAlert = false
    @State private var selectedBoxForQR: StorageBox?
    
    init(boxId: String) {
        self.boxId = boxId
        if let id = UUID(uuidString: boxId) {
            let predicate = #Predicate<StorageBox> {
                $0.id == id
            }
            _boxes = Query(filter: predicate)
        }
    }
    
    private var box: StorageBox? {
        boxes.first
    }
    
    var body: some View {
        if let box = box {
            ScrollView {
                VStack(spacing: 24) {
                    // Box Image
                    boxImage(for: box)
                    
                    // Box Info
                    boxInfo(for: box)
                    
                    // Items List
                    itemsList(for: box)
                }
                .padding()
            }
            .navigationTitle(box.name)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(macOS)
                Menu {
                    Button {
                        router.navigate(to: .editBox(boxId: boxId))
                    } label: {
                        Label("Edit Box", systemImage: "pencil")
                    }
                    
                    Button {
                        selectedBoxForQR = box
                    } label: {
                        Label("Generate QR Code", systemImage: "qrcode")
                    }
                    
                    Button(role: .destructive) {
                        isShowingDeleteAlert = true
                    } label: {
                        Label("Delete Box", systemImage: "trash")
                    }
                } label: {
                    Label("Actions", systemImage: "ellipsis.circle")
                }
                #else
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            router.navigate(to: .editBox(boxId: boxId))
                        } label: {
                            Label("Edit Box", systemImage: "pencil")
                        }
                        
                        Button {
                            selectedBoxForQR = box
                        } label: {
                            Label("Generate QR Code", systemImage: "qrcode")
                        }
                        
                        Button(role: .destructive) {
                            isShowingDeleteAlert = true
                        } label: {
                            Label("Delete Box", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
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
            .sheet(item: $selectedBoxForQR) { box in
                GenerateQRSheet(box: box)
                    .environmentObject(themeManager)
            }
        } else {
            ContentUnavailableView("Box Not Found", systemImage: "shippingbox.fill")
        }
    }
    
    // MARK: - Box Image
    private func boxImage(for box: StorageBox) -> some View {
        Group {
            if let photoURL = box.photoURL, let image = loadImageFromPath(photoURL) {
                Image(platformImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.selectedTheme.primaryThemeColor.opacity(0.1))
                    .frame(height: 200)
                    .overlay {
                        VStack(spacing: 12) {
                            Image(systemName: "shippingbox.fill")
                                .font(.system(size: 60))
                                .foregroundColor(themeManager.selectedTheme.primaryThemeColor)
                            
                            Text("No photo for this box")
                                .font(themeManager.selectedTheme.bodyTextFont)
                                .foregroundColor(themeManager.selectedTheme.bodyTextColor.opacity(0.6))
                        }
                    }
            }
        }
    }
    
    // MARK: - Box Info
    private func boxInfo(for box: StorageBox) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            InfoRow(
                icon: "mappin.circle.fill",
                title: "Location",
                value: box.locationHint.isEmpty ? "Not specified" : box.locationHint
            )
            
            InfoRow(
                icon: "list.bullet",
                title: "Items",
                value: "\(box.itemCount) items"
            )
            
            InfoRow(
                icon: "calendar",
                title: "Last Updated",
                value: box.updatedAt.formatted(date: .abbreviated, time: .shortened)
            )
        }
        .padding()
        .background(themeManager.selectedTheme.textBoxColor)
        .cornerRadius(12)
    }
    
    // MARK: - Items List
    private func itemsList(for box: StorageBox) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contents")
                .font(themeManager.selectedTheme.textTitleFont)
                .foregroundColor(themeManager.selectedTheme.bodyTextColor)
            
            if let items = box.items, !items.isEmpty {
                ForEach(items) { item in
                    HStack {
                        Circle()
                            .fill(themeManager.selectedTheme.secondoryThemeColor)
                            .frame(width: 8, height: 8)
                        
                        Text(item.name)
                            .font(themeManager.selectedTheme.bodyTextFont)
                            .foregroundColor(themeManager.selectedTheme.bodyTextColor)
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            } else {
                Text("No items in this box yet.")
                    .font(themeManager.selectedTheme.bodyTextFont)
                    .foregroundColor(themeManager.selectedTheme.bodyTextColor.opacity(0.6))
            }
        }
    }
    
    private func deleteBox() {
        if let box = box {
            context.delete(box)
            router.navigateBack()
        }
    }
    

}

// MARK: - Info Row Component
struct InfoRow: View {
    let icon: String
    let title: LocalizedStringResource
    let value: String
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(themeManager.selectedTheme.primaryThemeColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(themeManager.selectedTheme.bodyTextFont)
                    .foregroundColor(themeManager.selectedTheme.bodyTextColor.opacity(0.6))
                
                Text(value)
                    .font(themeManager.selectedTheme.normalBtnTitleFont)
                    .foregroundColor(themeManager.selectedTheme.bodyTextColor)
            }
            
            Spacer()
        }
    }
}


