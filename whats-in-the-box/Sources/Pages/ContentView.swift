import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject var themeManager = ThemeManager()
    var body: some View {
        NavigationView {
            HomeView()
                .environmentObject(themeManager)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
