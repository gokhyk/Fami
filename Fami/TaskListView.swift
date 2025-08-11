
import SwiftUI

struct TaskListView: View {
    @ObservedObject var viewModel: TaskViewModel
    @EnvironmentObject var auth: AuthViewModel
    @State private var showNewTaskView = false
    @State private var showFamilyMgmt = false
    @State private var showInvites = false

    private func invitationVM() -> InvitationViewModel {
        InvitationViewModel(repo: FirestoreInvitationRepository(), auth: auth)
    }
    
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
            //.navigationTitle("Family Tasks")
            //.navigationTitle("Tasks – \(auth.user?.email ?? "Unknown") (\(viewModel.activeFamilyName.isEmpty ? "No Family" : viewModel.activeFamilyName)")
            //TODO - make it look better
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text(auth.user?.email ?? "Unknown")
                            .font(.subheadline)   // smaller
                            .foregroundColor(.secondary)
                        Text(viewModel.activeFamilyName.isEmpty ? "No Family" : viewModel.activeFamilyName)
                            .font(.caption)       // even smaller
                            .foregroundColor(.gray)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign Out") {auth.signOut() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showInvites = true
                        } label: {
                            Image(systemName: "envelope.badge")
                        }
                        Button {
                            showFamilyMgmt = true
                        } label: {
                            Image(systemName: "person.3.sequence")
                        }
                        Button {
                            showNewTaskView = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
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
            .sheet(isPresented: $showFamilyMgmt) {
                FamilyManagementView()
                    .environmentObject(viewModel)
                    .environmentObject(auth)
            }
            .sheet(isPresented: $showInvites) {
                InvitationsInboxView(invitations: invitationVM())
            }
            .task {
                await viewModel.loadTasks()
            }
            .onChange(of: viewModel.activeFamilyId) { 
                Task { await viewModel.loadTasks() }   // reload when family changes
            }
        }
        
    }
}
