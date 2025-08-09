
import Foundation
import FirebaseFirestore


protocol TaskRepository {
    func fetchTasks(forFamilyId: String) async throws -> [ToDoItem]
    func addTask(_ task: ToDoItem) async throws
    func updateTask(_ task: ToDoItem) async throws
    func deleteTask(_ taskId: String) async throws
}

final class FirestoreTaskRepository: TaskRepository {
    private let db = Firestore.firestore()
    private let collection = "tasks"

    func fetchTasks(forFamilyId familyId: String) async throws -> [ToDoItem] {
        let snapshot = try await db.collection(collection)
            .whereField("familyId", isEqualTo: familyId)
            .order(by: "createdAt", descending: false)
            .getDocuments()

        return try snapshot.documents.compactMap { doc in
            try doc.data(as: ToDoItem.self)
        }
    }

    func addTask(_ task: ToDoItem) async throws {
        _ = try db.collection(collection).addDocument(from: task)
    }

    func updateTask(_ task: ToDoItem) async throws {
        guard let id = task.id else { return }
        try db.collection(collection)
            .document(id)
            .setData(from: task, merge: false)
    }

    func deleteTask(_ taskId: String) async throws {
        try await db.collection(collection)
            .document(taskId)
            .delete()
    }
}
