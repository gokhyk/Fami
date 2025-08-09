
import SwiftUI

struct TaskListView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var showNewTaskView = false

    var body: some View {
        NavigationView {
            VStack {
                Picker("Filter", selection: $viewModel.filter) {
                    ForEach(TaskViewModel.FilterType.allCases) { f in
                        Text(f.rawValue).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                List {
                    ForEach(viewModel.filteredTasks) { task in
                        TaskRowView(task: task) {
                            Task { await viewModel.toggleComplete(task) }
                        }
                    }
                    .onDelete { indexSet in
                        Task {
                            for idx in indexSet {
                                if let id = viewModel.filteredTasks[idx].id {
                                    await viewModel.deleteTask(id)
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Family Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNewTaskView = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showNewTaskView) {
                if let famId = viewModel.activeFamilyId {
                    NewTaskView(activeFamilyId: famId) { newTask in
                        Task { await viewModel.addTask(newTask) }
                    }
                } else {
                    Text("No active family selected.")
                        .padding()
                }
            }
            .task {
                await viewModel.loadTasks()
            }
        }
    }
}
