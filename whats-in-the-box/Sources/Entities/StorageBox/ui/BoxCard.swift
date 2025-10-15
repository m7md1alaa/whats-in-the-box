import SwiftUI
import SwiftData

struct BoxCard: View {
    let box: StorageBox
    let onEdit: () -> Void
    let onDelete: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(Router.self) private var router
    
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
        #if os(iOS)
        .contextMenu {
            Button(action: onEdit) {
                Label("Edit Box", systemImage: "pencil")
            }
            
            Button(role: .destructive, action: onDelete) {
                Label("Delete Box", systemImage: "trash")
            }
        } preview: {
            BoxDetailPage(boxId: box.id.uuidString)
                .environmentObject(themeManager)
                .environment(router)
        }
        #elseif os(macOS)
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
