import SwiftUI
import SwiftData
import PhotosUI

struct AddBoxPage: View {
    @Environment(Router.self) private var router
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var themeManager: ThemeManager
    
    @State private var boxName = ""
    @State private var locationHint = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoURL: String?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSaving = false
    
    var body: some View {
        Form {
            Section {
                // Photo Picker
                PhotosPicker(
                    selection: $selectedPhoto,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    VStack(spacing: 16) {
                        if let photoURL = photoURL {
                            // Show selected photo
                            if let image = loadImageFromPath(photoURL) {
                                Image(platformImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 180)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                // Fallback if image fails to load
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
                            // Photo placeholder
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
                        }
                        
                        Text(photoURL != nil ? "Tap to change photo" : "AI will identify items automatically")
                            .font(themeManager.selectedTheme.bodyTextFont)
                            .foregroundColor(themeManager.selectedTheme.bodyTextColor.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                }
                .buttonStyle(.plain)
                .onChange(of: selectedPhoto) { oldValue, newValue in
                    Task {
                        await loadPhoto(from: newValue)
                    }
                }
            }
            
            Section {
                TextField("Box Name", text: $boxName)
                    .font(themeManager.selectedTheme.bodyTextFont)
                    .autocorrectionDisabled()
                
                TextField("Location (optional)", text: $locationHint)
                    .font(themeManager.selectedTheme.bodyTextFont)
                    .autocorrectionDisabled()
            } header: {
                Text("Details")
            }
            
            Section {
                Button {
                    saveBox()
                } label: {
                    HStack {
                        Spacer()
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Save Box")
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
        .navigationTitle("New Box")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    router.navigateBack()
                }
                .foregroundColor(themeManager.selectedTheme.negativeBtnTitleColor)
                .disabled(isSaving)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Load Photo
    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = PlatformImage(data: data) {
                // Save image to documents directory
                let filename = UUID().uuidString + ".jpg"
                if let savedURL = saveImageToDocuments(image, filename: filename) {
                    await MainActor.run {
                        photoURL = savedURL.path
                    }
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load photo"
                showError = true
            }
        }
    }
    
    // MARK: - Save Image to Documents
    private func saveImageToDocuments(_ image: PlatformImage, filename: String) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        
        let fileURL = documentsPath.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    // MARK: - Load Image from Path
    private func loadImageFromPath(_ path: String) -> PlatformImage? {
        // Handle both file:// URLs and plain paths
        let fileURL: URL
        if path.hasPrefix("file://") {
            fileURL = URL(fileURLWithPath: path.replacingOccurrences(of: "file://", with: ""))
        } else {
            fileURL = URL(fileURLWithPath: path)
        }
        
        guard let data = try? Data(contentsOf: fileURL),
              let image = PlatformImage(data: data) else {
            return nil
        }
        
        return image
    }
    
    // MARK: - Save Box
    private func saveBox() {
        isSaving = true
        
        // Create new StorageBox
        let box = StorageBox(
            name: boxName.trimmingCharacters(in: .whitespaces),
            photoURL: photoURL,
            locationHint: locationHint.trimmingCharacters(in: .whitespaces)
        )
        
        do {
            // Save with validation
            try box.save(context: context)
            
            // Success - navigate back
            router.navigateBack()
            
        } catch StorageBoxError.duplicateName {
            errorMessage = "A box with this name already exists. Please choose a different name."
            showError = true
            isSaving = false
            
        } catch StorageBoxError.invalidName {
            errorMessage = "Box name cannot be empty."
            showError = true
            isSaving = false
            
        } catch {
            errorMessage = "Failed to save box: \(error.localizedDescription)"
            showError = true
            isSaving = false
        }
    }
}

