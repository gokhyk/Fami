
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
                    .environmentObject(auth)
                    .onChange(of: auth.activeFamilyId) { fid in     // 👈 update when profile loads
                        guard let fid else { return }
                        tasks.setActiveFamily(id: fid, name: auth.activeFamilyName)
                    }
                    .task {                                         // handle cold start
                        if let fid = auth.activeFamilyId {
                            tasks.setActiveFamily(id: fid, name: auth.activeFamilyName)
                        }
                    }
            }
        }
    }
}
