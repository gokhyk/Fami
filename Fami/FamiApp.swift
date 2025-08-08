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
    
    let initialViewModel: TaskViewModel = {
        let vm = TaskViewModel()
        vm.activeFamilyID = "family1"
        vm.tasks = [
            ToDoItem(id: "1", taskName: "Buy Milk", assignedTo: "Ayse", dueDate: Date(), isCompleted: false, completedAt: nil, createdAt: Date(), familyID: "family1", notes: ""),
            ToDoItem(id: "2", taskName: "Mow Lawn", assignedTo: "Gokhan", dueDate: Date().addingTimeInterval(86400), isCompleted: true, completedAt: Date(), createdAt: Date(), familyID: "family1", notes: "")
        ]
        return vm
    }()
    
    var body: some Scene {
        WindowGroup {
            TaskListView(viewModel: initialViewModel)
        }
    }
}
