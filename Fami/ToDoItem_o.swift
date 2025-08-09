//
//  ToDoItem.swift
//  Fami
//
//  Created by Ayse Kula on 8/8/25.
//

import Foundation
import FirebaseFirestore

struct ToDoItem: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    var taskName: String
    var assignedTo: String
    var dueDate: Date?
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date
    var familyId: String
    var notes: String?
}


protocol TaskRepository {
    func fetchTasks(forFamilyId: String) async throws -> [ToDoItem]
    func addTask(_ task: ToDoItem) async throws
    func updateTask(_ task: ToDoItem) async throws
    func deleteTask(_ taskId: String) async throws
}


class FirestoreTaskRepository: TaskRepository {
    private let db = Firestore.firestore()
    private let collection = "tasks"

    func fetchTasks(forFamilyId familyId: String) async throws -> [ToDoItem] {
        let snapshot = try await db.collection(collection)
            .whereField("familyId", isEqualTo: familyId)
            .order(by: "createdAt", descending: false)
            .getDocuments()

        return try snapshot.documents.compactMap {
            try $0.data(as: ToDoItem.self)
        }
    }

    func addTask(_ task: ToDoItem) async throws {
        _ = try db.collection(collection).addDocument(from: task)
    }

    func updateTask(_ task: ToDoItem) async throws {
        guard let id = task.id else { return }
        try db.collection(collection).document(id).setData(from: task)
    }

    func deleteTask(_ taskId: String) async throws {
        try await db.collection(collection).document(taskId).delete()
    }
}


class TaskViewModel: ObservableObject {
    @Published var tasks: [ToDoItem] = []
    @Published var activeFamilyId: String?

    private let repository: TaskRepository

    init(repository: TaskRepository) {
        self.repository = repository
    }

    func loadTasks() async {
        guard let familyId = activeFamilyId else { return }
        do {
            tasks = try await repository.fetchTasks(forFamilyId: familyId)
        } catch {
            print("Error loading tasks: \(error)")
        }
    }

    func addTask(_ task: ToDoItem) async {
        do {
            try await repository.addTask(task)
            await loadTasks()
        } catch {
            print("Error adding task: \(error)")
        }
    }

    func toggleComplete(_ task: ToDoItem) async {
        var updated = task
        updated.isCompleted.toggle()
        updated.completedAt = updated.isCompleted ? Date() : nil

        do {
            try await repository.updateTask(updated)
            await loadTasks()
        } catch {
            print("Error updating task: \(error)")
        }
    }
}
