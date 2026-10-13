
import SwiftUI
import SwiftData

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(
            for: [
                StudyTaskModel.self,
                EmergencyPlanModel.self,
                EmergencySubtaskModel.self
            ]
        )
    }
}
