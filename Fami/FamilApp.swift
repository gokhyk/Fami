
import SwiftUI
import Firebase

@main
struct FamiApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        // Auth + Repo + ViewModels
        let authVM = AuthViewModel(service: AuthService())
        let taskRepo = FirestoreTaskRepository()
        let taskVM = TaskViewModel(repository: taskRepo)
        taskVM.activeFamilyId = "family1" // TODO: load from user's profile

        return WindowGroup {
            RootRouter(auth: authVM, tasks: taskVM)
        }
    }
}
