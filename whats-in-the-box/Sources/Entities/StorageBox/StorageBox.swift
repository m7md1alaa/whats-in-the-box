import SwiftUI
import SwiftData

// MARK: - Custom Errors
enum StorageBoxError: Error, LocalizedError {
    case duplicateName
    case invalidName
    case photoNotFound
    
    var errorDescription: String? {
        switch self {
        case .duplicateName:
            return "A box with this name already exists"
        case .invalidName:
            return "Box name cannot be empty"
        case .photoNotFound:
            return "Photo not found"
        }
    }
}

// MARK: - Recognition Source
enum RecognitionSource: String, Codable {
    case ai = "AI Recognition"
    case manual = "Manual Entry"
}

// MARK: - BoxItem Model (Defined First)
@Model
class BoxItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var recognizedBy: RecognitionSource
    var confidence: Double // 0.0 to 1.0
    var addedAt: Date
    
    var box: StorageBox?
    
    init(name: String, recognizedBy: RecognitionSource = .manual, confidence: Double = 1.0) {
        self.id = UUID()
        self.name = name
        self.recognizedBy = recognizedBy
        self.confidence = confidence
        self.addedAt = Date()
    }
}

// MARK: - StorageBox Model
@Model
class StorageBox {
    @Attribute(.unique) var id: UUID
    var name: String
    private var nameLowercased: String
    var photoURL: String?
    var locationHint: String
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade)
    var items: [BoxItem]?
    
    // MARK: - Computed Properties (Business Logic)
    var itemCount: Int {
        items?.count ?? 0
    }
    
    var hasPhoto: Bool {
        photoURL != nil
    }
    
    var isEmpty: Bool {
        itemCount == 0
    }
    
    // MARK: - Initializer
    init(name: String, photoURL: String? = nil, locationHint: String = "") {
        self.id = UUID()
        self.name = name
        self.nameLowercased = name.lowercased()
        self.photoURL = photoURL
        self.locationHint = locationHint
        self.createdAt = Date()
        self.updatedAt = Date()
        self.items = []
    }
    
    // MARK: - Business Logic
    
    /// Save box with validation
    func save(context: ModelContext) throws {
        // Validate name
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw StorageBoxError.invalidName
        }
        
        // Check for duplicates
        if try exists(context: context, name: name) {
            throw StorageBoxError.duplicateName
        }
        
        updatedAt = Date()
        context.insert(self)
    }
    
    /// Update box properties
    func update(context: ModelContext, name: String? = nil, locationHint: String? = nil, photoURL: String? = nil) throws {
        if let name = name {
            // Validate name
            guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
                throw StorageBoxError.invalidName
            }
            
            // Check for duplicates
            if try exists(context: context, name: name) {
                throw StorageBoxError.duplicateName
            }
            
            self.name = name
            self.nameLowercased = name.lowercased()
        }
        if let locationHint = locationHint {
            self.locationHint = locationHint
        }
        if let photoURL = photoURL {
            self.photoURL = photoURL
        }
        self.updatedAt = Date()
    }
    
    /// Add item to box
    func addItem(_ item: BoxItem) {
        if items == nil {
            items = []
        }
        items?.append(item)
        item.box = self
        updatedAt = Date()
    }
    
    /// Remove item from box
    func removeItem(_ item: BoxItem) {
        items?.removeAll { $0.id == item.id }
        updatedAt = Date()
    }
    
    // MARK: - Private Helpers
    
    /// Check if box with given name already exists
    private func exists(context: ModelContext, name: String) throws -> Bool {
        let lowercasedName = name.trimmingCharacters(in: .whitespaces).lowercased()
        let currentId = self.id
        
        let predicate = #Predicate<StorageBox> { box in
            box.nameLowercased == lowercasedName && box.id != currentId
        }
        
        let fetchDescriptor = FetchDescriptor<StorageBox>(predicate: predicate)
        let results = try context.fetch(fetchDescriptor)
        return !results.isEmpty
    }
}

// MARK: - Query Descriptors
extension StorageBox {
    /// Fetch all boxes sorted by name
    static var all: FetchDescriptor<StorageBox> {
        FetchDescriptor<StorageBox>(sortBy: [SortDescriptor(\.name, order: .forward)])
    }
    
    /// Fetch boxes sorted by most recently updated
    static var recentlyUpdated: FetchDescriptor<StorageBox> {
        FetchDescriptor<StorageBox>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
    }
    
    /// Fetch boxes with photos only
    static var withPhotos: FetchDescriptor<StorageBox> {
        let predicate = #Predicate<StorageBox> { box in
            box.photoURL != nil
        }
        return FetchDescriptor<StorageBox>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
    }
    
    /// Fetch empty boxes
    static var empty: FetchDescriptor<StorageBox> {
        let predicate = #Predicate<StorageBox> { box in
            box.items == nil || box.items!.isEmpty
        }
        return FetchDescriptor<StorageBox>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
    }
}
