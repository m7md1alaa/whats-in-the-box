import SwiftUI
import SwiftData

struct SettingsPage: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme
    
    @Query(StorageBox.all) private var boxes: [StorageBox]
    
    private var photoCount: Int {
        boxes.filter { $0.photoURL != nil }.count
    }

    private var storageUsed: String {
        let photoURLs = boxes.compactMap { $0.photoURL }
        var totalSize: Int64 = 0
        for urlString in photoURLs {
            let fileURL = URL(fileURLWithPath: urlString)
            if let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path) {
                totalSize += attributes[.size] as? Int64 ?? 0
            }
        }
        return ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }
    
    var body: some View {
        List {
            // App Section
            Section {
                Button {
                    SystemSettingsOpener.openAppSettings()
                } label: {
                    SettingRow(
                        icon: "paintbrush.fill",
                        title: "Appearance",
                        value: colorScheme == .dark ? "Dark" : "Light"
                    )
                }
                
                SettingRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    value: "On"
                )
            } header: {
                Text("App Settings")
                    .font(themeManager.selectedTheme.captionTxtFont)
            }
            
            // Storage Section
            Section {
                SettingRow(
                    icon: "externaldrive.fill",
                    title: "Storage Used",
                    value: storageUsed
                )
                
                SettingRow(
                    icon: "photo.fill",
                    title: "Photos",
                    value: "\(photoCount) items"
                )
                
                Button {
                    // Clear cache action
                } label: {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(themeManager.selectedTheme.negativeBtnTitleColor)
                        Text("Clear Cache")
                            .foregroundColor(themeManager.selectedTheme.negativeBtnTitleColor)
                    }
                }
            } header: {
                Text("Storage")
                    .font(themeManager.selectedTheme.captionTxtFont)
            }
            
            // AI Section
            Section {
                SettingRow(
                    icon: "brain.head.profile",
                    title: "AI Recognition",
                    value: "On-Device"
                )
                
                SettingRow(
                    icon: "antenna.radiowaves.left.and.right",
                    title: "Processing",
                    value: "Local Only"
                )
            } header: {
                Text("AI Features")
                    .font(themeManager.selectedTheme.captionTxtFont)
            } footer: {
                Text("All AI processing happens on your device. Your photos and data never leave your phone.")
                    .font(themeManager.selectedTheme.bodyTextFont)
            }
            
            // About Section
            Section {
                SettingRow(
                    icon: "info.circle.fill",
                    title: "Version",
                    value: "1.0.0"
                )
                
                Button {
                    // Open privacy policy
                } label: {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .foregroundColor(themeManager.selectedTheme.primaryThemeColor)
                        Text("Privacy Policy")
                            .foregroundColor(themeManager.selectedTheme.bodyTextColor)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(themeManager.selectedTheme.bodyTextColor.opacity(0.3))
                    }
                }
                
                Button {
                    // Open GitHub
                } label: {
                    HStack {
                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                            .foregroundColor(themeManager.selectedTheme.primaryThemeColor)
                        Text("GitHub")
                            .foregroundColor(themeManager.selectedTheme.bodyTextColor)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(themeManager.selectedTheme.bodyTextColor.opacity(0.3))
                    }
                }
            } header: {
                Text("About")
                    .font(themeManager.selectedTheme.captionTxtFont)
            }
        }
        .navigationTitle("Settings")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
}

// MARK: - Setting Row Component
struct SettingRow: View {
    let icon: String
    let title: String
    let value: String
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(themeManager.selectedTheme.primaryThemeColor)
                .frame(width: 28)
            
            Text(title)
                .font(themeManager.selectedTheme.bodyTextFont)
                .foregroundColor(themeManager.selectedTheme.bodyTextColor)
            
            Spacer()
            
            Text(value)
                .font(themeManager.selectedTheme.bodyTextFont)
                .foregroundColor(themeManager.selectedTheme.bodyTextColor.opacity(0.5))
        }
    }
}

#Preview {
    NavigationStack {
        SettingsPage()
            .environment(Router())
            .environmentObject(ThemeManager())
    }
}
