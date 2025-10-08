import SwiftUI

struct BoxDetailPage: View {
    let boxId: String
    
    @Environment(Router.self) private var router
    @EnvironmentObject private var themeManager: ThemeManager
    
    // Mock data
    @State private var box = BoxDetail(
        id: "1",
        name: "Kitchen Drawer",
        location: "Under sink",
        items: [
            "USB-C Cable", "Old Phone Charger", "Earbuds",
            "AA Batteries", "Screwdriver Set", "Tape Measure",
            "Flashlight", "Paper Clips"
        ]
    )
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Box Image
                boxImage
                
                // Box Info
                boxInfo
                
                // Items List
                itemsList
            }
            .padding()
        }
        .navigationTitle(box.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        router.navigate(to: .editBox(boxId: boxId))
                    } label: {
                        Label("Edit Box", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        deleteBox()
                    } label: {
                        Label("Delete Box", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(themeManager.selectedTheme.primaryThemeColor)
                }
            }
        }
    }
    
    // MARK: - Box Image
    private var boxImage: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(themeManager.selectedTheme.primaryThemeColor.opacity(0.1))
            .frame(height: 200)
            .overlay {
                VStack(spacing: 12) {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 60))
                        .foregroundColor(themeManager.selectedTheme.primaryThemeColor)
                    
                    Text("Tap to add photo")
                        .font(themeManager.selectedTheme.bodyTextFont)
                        .foregroundColor(themeManager.selectedTheme.bodyTextColor.opacity(0.6))
                }
            }
    }
    
    // MARK: - Box Info
    private var boxInfo: some View {
        VStack(alignment: .leading, spacing: 16) {
            InfoRow(
                icon: "mappin.circle.fill",
                title: "Location",
                value: box.location
            )
            
            InfoRow(
                icon: "list.bullet",
                title: "Items",
                value: "\(box.items.count) items"
            )
            
            InfoRow(
                icon: "calendar",
                title: "Last Updated",
                value: "Today"
            )
        }
        .padding()
        .background(themeManager.selectedTheme.textBoxColor)
        .cornerRadius(12)
    }
    
    // MARK: - Items List
    private var itemsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contents")
                .font(themeManager.selectedTheme.textTitleFont)
                .foregroundColor(themeManager.selectedTheme.bodyTextColor)
            
            ForEach(box.items, id: \.self) { item in
                HStack {
                    Circle()
                        .fill(themeManager.selectedTheme.secondoryThemeColor)
                        .frame(width: 8, height: 8)
                    
                    Text(item)
                        .font(themeManager.selectedTheme.bodyTextFont)
                        .foregroundColor(themeManager.selectedTheme.bodyTextColor)
                    
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    private func deleteBox() {
        router.navigateBack()
        // TODO: Implement actual deletion
    }
}

// MARK: - Info Row Component
struct InfoRow: View {
    let icon: String
    let title: String
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

// MARK: - Mock Model
struct BoxDetail {
    let id: String
    let name: String
    let location: String
    let items: [String]
}

#Preview {
    NavigationStack {
        BoxDetailPage(boxId: "1")
            .environment(Router())
            .environmentObject(ThemeManager())
    }
}
