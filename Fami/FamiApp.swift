
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


        return WindowGroup {
            RootRouter(auth: authVM, tasks: taskVM)
                .environmentObject(authVM)
        }

    }
}
