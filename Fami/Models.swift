
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

struct Family: Identifiable, Codable {
    var id: String
    var name: String
}
