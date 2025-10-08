import SwiftUI

struct SettingsPage: View {
    @Environment(Router.self) private var router
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        List {
            // App Section
            Section {
                SettingRow(
                    icon: "paintbrush.fill",
                    title: "Appearance",
                    value: colorScheme == .dark ? "Dark" : "Light"
                )
                
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
                    value: "12.5 MB"
                )
                
                SettingRow(
                    icon: "photo.fill",
                    title: "Photos",
                    value: "45 items"
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
        .navigationBarTitleDisplayMode(.large)
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
