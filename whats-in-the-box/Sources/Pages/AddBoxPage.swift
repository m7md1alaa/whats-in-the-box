import SwiftUI

struct AddBoxPage: View {
    @Environment(Router.self) private var router
    @EnvironmentObject private var themeManager: ThemeManager
    
    @State private var boxName = ""
    @State private var location = ""
    
    var body: some View {
        Form {
            Section {
                // Photo Picker
                Button {
                    // Open camera/photo picker
                } label: {
                    VStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.selectedTheme.primaryThemeColor.opacity(0.1))
                            .frame(height: 180)
                            .overlay {
                                VStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(themeManager.selectedTheme.primaryThemeColor)
                                    
                                    Text("Add Photo")
                                        .font(themeManager.selectedTheme.normalBtnTitleFont)
                                        .foregroundColor(themeManager.selectedTheme.primaryThemeColor)
                                }
                            }
                        
                        Text("AI will identify items automatically")
                            .font(themeManager.selectedTheme.bodyTextFont)
                            .foregroundColor(themeManager.selectedTheme.bodyTextColor.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                }
                .buttonStyle(.plain)
            }
            
            Section {
                TextField("Box Name", text: $boxName)
                    .font(themeManager.selectedTheme.bodyTextFont)
                
                TextField("Location (optional)", text: $location)
                    .font(themeManager.selectedTheme.bodyTextFont)
            } header: {
                Text("Details")
            }
            
            Section {
                Button {
                    saveBox()
                } label: {
                    HStack {
                        Spacer()
                        Text("Save Box")
                            .font(themeManager.selectedTheme.normalBtnTitleFont)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(themeManager.selectedTheme.primaryThemeColor)
                .disabled(boxName.isEmpty)
                .opacity(boxName.isEmpty ? 0.5 : 1.0)
            }
        }
        .navigationTitle("New Box")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    router.navigateBack()
                }
                .foregroundColor(themeManager.selectedTheme.negativeBtnTitleColor)
            }
        }
    }
    
    private func saveBox() {
        // TODO: Save to SwiftData
        router.navigateBack()
    }
}

#Preview {
    NavigationStack {
        AddBoxPage()
            .environment(Router())
            .environmentObject(ThemeManager())
    }
}
