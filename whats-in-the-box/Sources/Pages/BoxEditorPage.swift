import SwiftUI
import SwiftData
import PhotosUI

struct BoxEditorPage: View {
    @Environment(Router.self) private var router
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var themeManager: ThemeManager

    let boxId: String?
    @Query private var boxes: [StorageBox]
    private var box: StorageBox? { boxes.first }

    @State private var boxName: String = ""
    @State private var location: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoURL: String?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSaving = false

    private var isEditing: Bool { box != nil }
    private var navigationTitle: String { isEditing ? "Edit Box" : "Add New Box" }
    private var saveButtonTitle: String { isEditing ? "Save Changes" : "Save Box" }

    init(boxId: String?) {
        self.boxId = boxId
        var predicate: Predicate<StorageBox> = #Predicate { _ in false }
        if let idString = boxId, let id = UUID(uuidString: idString) {
            predicate = #Predicate<StorageBox> { $0.id == id }
        }
        _boxes = Query(filter: predicate)
    }

    var body: some View {
        Form {
            Section {
                PhotosPicker(
                    selection: $selectedPhoto,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    VStack(spacing: 16) {
                        if let photoURL = photoURL {
                            if let image = loadImageFromPath(photoURL) {
                                Image(platformImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 180)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(themeManager.selectedTheme.primaryThemeColor.opacity(0.1))
                                    .frame(height: 180)
                                    .overlay {
                                        Image(systemName: "photo")
                                            .font(.system(size: 40))
                                            .foregroundColor(themeManager.selectedTheme.primaryThemeColor)
                                    }
                            }
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(themeManager.selectedTheme.primaryThemeColor.opacity(0.1))
                                .frame(height: 180)
                                .overlay {
                                    VStack(spacing: 12) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(themeManager.selectedTheme.primaryThemeColor)
                                        Text(isEditing ? "Change Photo" : "Add Photo")
                                            .font(themeManager.selectedTheme.normalBtnTitleFont)
                                            .foregroundColor(themeManager.selectedTheme.primaryThemeColor)
                                    }
                                }
                        }
                        Text(photoURL != nil ? "Tap to change photo" : "AI will identify items automatically")
                            .font(themeManager.selectedTheme.bodyTextFont)
                            .foregroundColor(themeManager.selectedTheme.bodyTextColor.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                }
                .buttonStyle(.plain)
                .onChange(of: selectedPhoto) { _, newValue in
                    Task {
                        await loadPhoto(from: newValue)
                    }
                }
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
                Button(action: save) {
                    HStack {
                        Spacer()
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(saveButtonTitle)
                                .font(themeManager.selectedTheme.normalBtnTitleFont)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(themeManager.selectedTheme.primaryThemeColor)
                .disabled(boxName.isEmpty || isSaving)
                .opacity(boxName.isEmpty || isSaving ? 0.5 : 1.0)
            }
        }
        .navigationTitle(navigationTitle)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    router.navigateBack()
                }
                .foregroundColor(themeManager.selectedTheme.negativeBtnTitleColor)
                .disabled(isSaving)
            }
        }
        .onAppear(perform: setup)
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    private func setup() {
        if let box = box {
            boxName = box.name
            location = box.locationHint
            photoURL = box.photoURL
        }
    }

    private func save() {
        isSaving = true
        do {
            if let box = box {
                try box.update(context: context, name: boxName, locationHint: location, photoURL: photoURL)
            } else {
                let newBox = StorageBox(name: boxName, photoURL: photoURL, locationHint: location)
                try newBox.save(context: context)
            }
            router.navigateBack()
        } catch let error as LocalizedError {
            errorMessage = error.localizedDescription
            showError = true
            isSaving = false
        } catch {
            errorMessage = "An unexpected error occurred."
            showError = true
            isSaving = false
        }
    }

    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = PlatformImage(data: data) {
                let filename = UUID().uuidString + ".jpg"
                if let savedURL = saveImageToDocuments(image, filename: filename) {
                    await MainActor.run {
                        photoURL = savedURL.path
                    }
                }
            }
        } catch {
            errorMessage = "Failed to load photo"
            showError = true
        }
    }

    private func saveImageToDocuments(_ image: PlatformImage, filename: String) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(filename)
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
}
