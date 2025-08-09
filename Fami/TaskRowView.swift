
import SwiftUI

struct TaskRowView: View {
    var task: ToDoItem
    var onToggle: () -> Void

    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .imageScale(.large)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading) {
                Text(task.taskName).bold()
                if let due = task.dueDate {
                    Text("Due: \(due.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
            Text(task.assignedTo).font(.caption)
        }
        .padding(.vertical, 4)
    }
}
