
import SwiftUI

struct NewTaskView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var taskName = ""
    @State private var assignedTo = ""
    @State private var dueDate = Date()
    @State private var notes = ""

    var activeFamilyId: String
    var onSave: (ToDoItem) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section("Details") {
                    TextField("Task Name", text: $taskName)
                    TextField("Assign To", text: $assignedTo)
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    TextField("Notes", text: $notes)
                }

                Section {
                    Button("Save Task") {
                        let task = ToDoItem(
                            id: nil,
                            taskName: taskName,
                            assignedTo: assignedTo,
                            dueDate: dueDate,
                            isCompleted: false,
                            completedAt: nil,
                            createdAt: Date(),
                            familyId: activeFamilyId,
                            notes: notes.isEmpty ? nil : notes
                        )
                        onSave(task)
                        dismiss()
                    }
                    .disabled(taskName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
