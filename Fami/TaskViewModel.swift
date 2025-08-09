
import Foundation

@MainActor
final class TaskViewModel: ObservableObject {
    @Published var tasks: [ToDoItem] = []
    @Published var filter: FilterType = .all
    @Published var activeFamilyId: String?

    enum FilterType: String, CaseIterable, Identifiable {
        case all = "All"
        case incomplete = "Incomplete"
        case completed = "Completed"
        var id: String { rawValue }
    }

    private let repository: TaskRepository

    init(repository: TaskRepository) {
        self.repository = repository
    }

    var filteredTasks: [ToDoItem] {
        tasks.filter { task in
            guard let active = activeFamilyId, task.familyId == active else { return false }
            switch filter {
            case .all: return true
            case .incomplete: return !task.isCompleted
            case .completed: return task.isCompleted
            }
        }
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

    func deleteTask(_ taskId: String) async {
        do {
            try await repository.deleteTask(taskId)
            await loadTasks()
        } catch {
            print("Error deleting task: \(error)")
        }
    }
}
