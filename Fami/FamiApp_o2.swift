//
//import SwiftUI
//import Firebase
//
//@main
//struct FamiApp: App {
//    init() {
//        FirebaseApp.configure()
//    }
//
//    var body: some Scene {
//        let repo = FirestoreTaskRepository()
//        let vm = TaskViewModel(repository: repo)
//        vm.activeFamilyId = "family1" // TODO: replace with actual active family
//
//        return WindowGroup {
//            TaskListView(viewModel: vm)
//        }
//    }
//}
