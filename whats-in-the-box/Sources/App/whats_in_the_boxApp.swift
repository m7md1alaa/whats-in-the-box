import SwiftUI
import SwiftData

@main
struct whats_in_the_boxApp: App {
    // MARK: - Dependencies
    @State private var router = Router()
    @StateObject private var themeManager = ThemeManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                HomePage()
                    .navigationDestination(for: Route.self) { route in
                        routeView(for: route)
                    }
            }
            .environment(router)
            .environmentObject(themeManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
