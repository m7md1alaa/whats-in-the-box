import SwiftUI
import SwiftData
internal import UniformTypeIdentifiers
#if os(iOS)
import PhotosUI
#endif


struct BoxEditorPage: View {
    // MARK: - Environment & Dependencies
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(Router.self) private var router
    
    // MARK: - State
    let boxId: String?
    @Query private var boxes: [StorageBox]
    private var box: StorageBox? { boxes.first }

    @State private var boxName: String = ""
    @State private var location: String = ""
    #if os(iOS)
    @State private var selectedPhoto: PhotosPickerItem?
    #endif
    @State private var photoURL: String?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSaving = false
    @State private var showFileImporter = false

    private var isEditing: Bool { box != nil }
    private var navigationTitle: LocalizedStringResource { isEditing ? "Edit Box" : "Add New Box" }
    private var saveButtonTitle: LocalizedStringResource {
        isEditing ? "Save Changes" : "Save Box"
    }
    // MARK: - Init with Query Filter
    init(boxId: String?) {
        self.boxId = boxId
        var predicate: Predicate<StorageBox> = #Predicate { _ in false }
        if let idString = boxId, let id = UUID(uuidString: idString) {
            predicate = #Predicate<StorageBox> { $0.id == id }
        }
        _boxes = Query(filter: predicate)
    }

    // MARK: - Body
    var body: some View {
        content
            .navigationTitle(navigationTitle)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #elseif os(macOS)
            .frame(minWidth: 400, maxWidth: 600, minHeight: 500)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { router.navigateBack() }
                        .disabled(isSaving)
                }
                ToolbarItem(placement: .automatic) {
                    Button("Save", action: save)
                        .disabled(boxName.isEmpty || isSaving)
                }
            }
            #endif
            .onAppear(perform: setup)
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
    }

    // MARK: - Main Content
    @ViewBuilder
    private var content: some View {
        #if os(iOS)
        iOSForm
        #elseif os(macOS)
        macForm
        #endif
    }

    // MARK: - iOS Layout
    #if os(iOS)
    private var iOSForm: some View {
        Form {
            Section {
                PhotosPicker(
                    selection: $selectedPhoto,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    photoView
                }
                .buttonStyle(.plain)
                .onChange(of: selectedPhoto) { _, newValue in
                    Task { await loadPhoto(from: newValue) }
                }
            }

            Section(header: Text("Details")) {
                TextField("Box Name", text: $boxName)
                    .font(themeManager.selectedTheme.bodyTextFont)
                TextField("Location (optional)", text: $location)
                    .font(themeManager.selectedTheme.bodyTextFont)
            }

            Section {
                Button(action: save) {
                    HStack {
                        Spacer()
                        if isSaving { ProgressView().tint(.white) }
                        else { Text(saveButtonTitle).font(themeManager.selectedTheme.normalBtnTitleFont).foregroundColor(.white) }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(themeManager.selectedTheme.primaryThemeColor)
                .disabled(boxName.isEmpty || isSaving)
                .opacity(boxName.isEmpty || isSaving ? 0.5 : 1.0)
            }
        }
    }
    #endif

    // MARK: - macOS Layout
    #if os(macOS)
    private var macForm: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Photo Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Photo")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    macPhotoView
                        .frame(height: 280)
                        .frame(maxWidth: .infinity)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .onTapGesture { showFileImporter = true }
                        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.image]) { result in
                            if case .success(let url) = result {
                                if url.startAccessingSecurityScopedResource() {
                                    photoURL = url.path
                                    url.stopAccessingSecurityScopedResource()
                                }
                            }
                        }
                        .onDrop(of: [.fileURL], isTargeted: nil, perform: handleDrop)
                }

                // Details Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Details")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Box Name")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextField("Enter box name", text: $boxName)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Location")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextField("Enter location (optional)", text: $location)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    .padding()
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
            }
            .padding(24)
        }
    }
    
    // MARK: - macOS Photo View
    @ViewBuilder
    private var macPhotoView: some View {
        if let photoURL = photoURL, let image = loadImageFromPath(photoURL) {
            GeometryReader { geometry in
                Image(platformImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .cornerRadius(10)
                    .overlay(alignment: .bottomTrailing) {
                        Button(action: { showFileImporter = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "photo.badge.plus")
                                Text("Change")
                            }
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .padding(12)
                    }
                    .contextMenu {
                        Button(action: {
                            self.photoURL = nil
                        }) {
                            Label("Remove Photo", systemImage: "trash")
                        }
                    }
            }
        } else {
            VStack(spacing: 16) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary.opacity(0.5))
                
                VStack(spacing: 8) {
                    Text(isEditing ? "Change Photo" : "Add Photo")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Click to browse or drag and drop an image")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("AI will automatically identify items")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    #endif

    // MARK: - Shared Photo View
    @ViewBuilder
    private var photoView: some View {
        VStack(spacing: 12) {
            if let photoURL = photoURL, let image = loadImageFromPath(photoURL) {
                Image(platformImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.gray.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill").font(.system(size: 32))
                            Text(isEditing ? "Change Photo" : "Add Photo")
                        }
                        .foregroundColor(.secondary)
                    }
            }

            Text(photoURL != nil ? "Tap to change photo" : "AI will identify items automatically")
                .font(themeManager.selectedTheme.bodyTextFont)
                .foregroundColor(themeManager.selectedTheme.bodyTextColor.opacity(0.6))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Setup
    private func setup() {
        if let box = box {
            boxName = box.name
            location = box.locationHint
            photoURL = box.photoURL
        }
    }

    // MARK: - Save
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

    // MARK: - Load Photo (iOS Only)
    #if os(iOS)
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
    #endif

    // MARK: - macOS Drag & Drop
    #if os(macOS)
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier("public.file-url") {
                provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
                    DispatchQueue.main.async {
                        if let urlData = item as? Data, let url = URL(dataRepresentation: urlData, relativeTo: nil) {
                            photoURL = url.path
                        }
                    }
                }
                return true
            }
        }
        return false
    }
    #endif

    // MARK: - Save Image Helper (Shared)
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
