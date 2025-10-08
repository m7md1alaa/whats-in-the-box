import SwiftUI

struct EditBoxPage: View {
    let boxId: String
    
    @Environment(Router.self) private var router
    @EnvironmentObject private var themeManager: ThemeManager
    
    @State private var boxName = "Kitchen Drawer"
    @State private var location = "Under sink"
    
    var body: some View {
        Form {
            Section {
                TextField("Box Name", text: $boxName)
                    .font(themeManager.selectedTheme.bodyTextFont)
                
                TextField("Location", text: $location)
                    .font(themeManager.selectedTheme.bodyTextFont)
            } header: {
                Text("Details")
            }
            
            Section {
                Button {
                    saveChanges()
                } label: {
                    HStack {
                        Spacer()
                        Text("Save Changes")
                            .font(themeManager.selectedTheme.normalBtnTitleFont)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(themeManager.selectedTheme.primaryThemeColor)
            }
        }
        .navigationTitle("Edit Box")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func saveChanges() {
        // TODO: Update SwiftData
        router.navigateBack()
    }
}

#Preview {
    NavigationStack {
        EditBoxPage(boxId: "1")
            .environment(Router())
            .environmentObject(ThemeManager())
    }
}
