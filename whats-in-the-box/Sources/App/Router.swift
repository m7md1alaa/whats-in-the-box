import SwiftUI

// MARK: - Route Definition (Type-Safe Navigation)
enum Route: Hashable {
    case home
    case boxDetail(boxId: String)
    case settings
    case addBox
    case editBox(boxId: String)
}

// MARK: - Router (Navigation Manager)
@Observable
class Router {
    var path = NavigationPath()
    
    // MARK: Navigation Actions
    func navigate(to route: Route) {
        path.append(route)
    }
    
    func navigateBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func navigateToRoot() {
        path = NavigationPath()
    }
    
    func replace(with route: Route) {
        path.removeLast()
        path.append(route)
    }
}

// MARK: - Route View Builder
@ViewBuilder
func routeView(for route: Route) -> some View {
    switch route {
    case .home:
        HomePage()
        
    case .boxDetail(let boxId):
        BoxDetailPage(boxId: boxId)
        
    case .settings:
        SettingsPage()
        
    case .addBox:
        BoxEditorPage(boxId: nil)
        
    case .editBox(let boxId):
        BoxEditorPage(boxId: boxId)
    }
}
