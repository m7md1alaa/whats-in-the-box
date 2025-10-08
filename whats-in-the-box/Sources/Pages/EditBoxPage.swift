import SwiftUI
import SwiftData

struct EditBoxPage: View {
    let boxId: String
    
    @Environment(Router.self) private var router
    @EnvironmentObject private var themeManager: ThemeManager
    
    @Query private var boxes: [StorageBox]
    
    @State private var boxName: String = ""
    @State private var location: String = ""

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
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .onAppear {
                self.boxName = box.name
                self.location = box.locationHint
            }
        } else {
            ContentUnavailableView("Box Not Found", systemImage: "shippingbox.fill")
        }
    }
    
    private func saveChanges() {
        if let box = box {
            box.update(name: boxName, locationHint: location)
        }
        router.navigateBack()
    }
}
