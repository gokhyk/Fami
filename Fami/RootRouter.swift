
import SwiftUI

struct RootRouter: View {
    @ObservedObject var auth: AuthViewModel
    @ObservedObject var tasks: TaskViewModel

    var body: some View {
        Group {
            if auth.user == nil {
                SignInView(auth: auth)
            } else {
                TaskListView(viewModel: tasks)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Sign Out") { auth.signOut() }
                        }
                    }
            }
        }
    }
}
