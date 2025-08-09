//
//  FamiApp.swift
//  Fami
//
//  Created by Ayse Kula on 8/4/25.
//

import SwiftUI
import Firebase

// MARK: - Preview Entry Point

@main
struct FamiApp: App {
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        let firebaseRepo = FirestoreTaskRepository()
        let vm = TaskViewModel(repository: firebaseRepo)
        vm.activeFamilyId = "family1" // Example family ID

        WindowGroup {
            TaskListView(viewModel: vm)
        }
    }
}
