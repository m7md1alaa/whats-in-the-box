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
            StorageBox.self,
            BoxItem.self
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
            #if os(macOS)
            NavigationSplitView {
                SidebarView()
            } detail: {
                NavigationStack(path: $router.path) {
                    HomePage()
                        .navigationDestination(for: Route.self) { route in
                            routeView(for: route)
                        }
                }
            }
            .environment(router)
            .environmentObject(themeManager)
            #else
            TabView {
                NavigationStack(path: $router.path) {
                    HomePage()
                        .navigationDestination(for: Route.self) { route in
                            routeView(for: route)
                        }
                }
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                
                SettingsPage()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
            }
            .environment(router)
            .environmentObject(themeManager)
            #endif
        }
        .modelContainer(sharedModelContainer)
        .commands {
            #if os(macOS)
            CommandGroup(replacing: .newItem) {
                Button("New Box") {
                    router.navigate(to: .addBox)
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Divider()
            }
            // Remove View menu
            CommandGroup(replacing: .sidebar) { }
            CommandGroup(after: .appSettings) {
                Button("Settings") {
                    router.navigate(to: .settings)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
              
            // Remove Window menu
            CommandGroup(replacing: .windowList) { }
            #endif
        }
    }
}

#if os(macOS)
struct SidebarView: View {
    @Environment(Router.self) private var router
    
    var body: some View {
        List {
            Button {
                router.navigateToRoot()
            } label: {
                Label("Home", systemImage: "house")
            }
            .buttonStyle(.plain)
        }
        .listStyle(.sidebar)
        .navigationTitle("What's in the box?")
    }
}
#endif
