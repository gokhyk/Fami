// FamilyTaskAppPrototype
// A minimal working SwiftUI prototype for a Family Task Coordinator

import SwiftUI

// MARK: - Models

//struct ToDoItem: Identifiable {
//    var id = UUID().uuidString
//    var taskName: String
//    var assignedTo: String
//    var dueDate: Date?
//    var isCompleted: Bool
//    var completedAt: Date?
//    var createdAt: Date
//    var familyID: String
//    var notes: String?
//}
//
//struct Family: Identifiable {
//    var id: String
//    var name: String
//}

enum TaskFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case incomplete = "Incomplete"
    case completed = "Completed"

    var id: String { self.rawValue }
}

// MARK: - ViewModel

//class TaskViewModel: ObservableObject {
//    @Published var tasks: [ToDoItem] = []
//    @Published var filterStatus: TaskFilter = .all
//    @Published var activeFamilyID: String?
//    
//    var filteredTasks: [ToDoItem] {
//        switch filterStatus {
//        case .all:
//            return tasks
//        case .incomplete:
//            return tasks.filter { !$0.isCompleted }
//        case .completed:
//            return tasks.filter { $0.isCompleted }
//        }
//    }
//
//    func toggleComplete(_ task: ToDoItem) {
//        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
//        tasks[index].isCompleted.toggle()
//        tasks[index].completedAt = tasks[index].isCompleted ? Date() : nil
//    }
//
//    func addTask(_ task: ToDoItem) {
//        tasks.append(task)
//    }
//}

// MARK: - Views

struct TaskRowView: View {
    var task: ToDoItem
    var onToggle: () -> Void

    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
            }

            VStack(alignment: .leading) {
                Text(task.taskName).bold()
                if let due = task.dueDate {
                    Text("Due: \(due.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption).foregroundColor(.gray)
                }
            }

            Spacer()

            Text(task.assignedTo).font(.caption).foregroundColor(.blue)
        }
    }
}

//struct TaskListView: View {
//    @ObservedObject var viewModel: TaskViewModel
//    @State private var showNewTask = false
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                Picker("Filter", selection: $viewModel.filterStatus) {
//                    ForEach(TaskFilter.allCases) { filter in
//                        Text(filter.rawValue).tag(filter)
//                    }
//                }
//                .pickerStyle(SegmentedPickerStyle())
//                .padding(.horizontal)
//
//                List(viewModel.filteredTasks) { task in
//                    TaskRowView(task: task) {
//                        viewModel.toggleComplete(task)
//                    }
//                }
//            }
//            .navigationTitle("My Tasks")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: { showNewTask = true }) {
//                        Image(systemName: "plus.circle.fill")
//                    }
//                }
//            }
//            .sheet(isPresented: $showNewTask) {
//                NewTaskView { newTask in
//                    viewModel.addTask(newTask)
//                    showNewTask = false
//                }
//            }
//        }
//    }
//}



struct TaskListView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var showNewTaskView = false

    var body: some View {
        NavigationView {
            VStack {
                Picker("Filter", selection: $viewModel.filterStatus) {
                    ForEach(TaskFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                List(viewModel.filteredTasks) { task in
                    TaskRowView(task: task) {
                        Task {
                            await viewModel.toggleComplete(task)
                        }
                    }
                }
            }
            .navigationTitle("Family Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showNewTaskView = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showNewTaskView) {
                NewTaskView { newTask in
                    Task {
                        await viewModel.addTask(newTask)
                        showNewTaskView = false
                    }
                }
            }
            .task {
                await viewModel.loadTasks()
            }
        }
    }
}


struct NewTaskView: View {
    @Environment(\.dismiss) var dismiss
    @State private var taskName = ""
    @State private var assignedTo = ""
    @State private var dueDate = Date()
    @State private var notes = ""
    var onSave: (ToDoItem) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Task Name", text: $taskName)
                TextField("Assign To", text: $assignedTo)
                DatePicker("Due Date", selection: $dueDate)
                TextField("Notes", text: $notes)
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let task = ToDoItem(
                            id: UUID().uuidString,
                            taskName: taskName,
                            assignedTo: assignedTo,
                            dueDate: dueDate,
                            isCompleted: false,
                            completedAt: nil,
                            createdAt: Date(),
                            familyID: "family1",
                            notes: notes

                        )
                        onSave(task)
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}


