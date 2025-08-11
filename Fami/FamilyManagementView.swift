//
//  FamilyManagementView.swift
//  Fami
//
//  Created by Ayse Kula on 8/9/25.
//

// FamilyManagementView.swift
import SwiftUI
import FirebaseFirestore


struct FamilyManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tasks: TaskViewModel
    @EnvironmentObject var auth: AuthViewModel

    @State private var families: [Family] = []
    @State private var showCreateAlert = false
    @State private var newFamilyName = ""
    
    @State private var showInvite = false
    @State private var selectedFamilyId: String?
    @State private var selectedFamilyName: String = ""
    
    private func invitationVM() -> InvitationViewModel {
        InvitationViewModel(repo: FirestoreInvitationRepository(), auth: auth)
    }

    var body: some View {
        NavigationView {
            List {
                Section("Your Families") {
                    ForEach(families) { fam in
                        HStack {
                            Text(fam.name)
                            Spacer()
                            if fam.id == (tasks.activeFamilyId ?? "") {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // On family row tap:
                            tasks.setActiveFamily(id: fam.id, name: fam.name)
                            if let uid = auth.user?.uid {
                                Task { await auth.saveActiveFamily(uid: uid, id: fam.id, name: fam.name) }
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                selectedFamilyName = fam.name
                                selectedFamilyId = fam.id
                                showInvite = true
                            } label: {
                                Label("Invite", systemImage: "envelope.badge")
                            }
                        }
                    }
                }
            }

            .navigationTitle("Families")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateAlert = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .help("Create Family")
                }
            }
            .task { await loadFamilies() }
            .alert("Create Family", isPresented: $showCreateAlert) {
                TextField("Family name", text: $newFamilyName)
                Button("Create") { Task { await createFamily() } }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enter a name for your new family.")
            }
            .sheet(isPresented: $showInvite) {
                if let fid = selectedFamilyId {
                    InviteMemberView(
                        invitations: invitationVM(),
                        familyId: fid,
                        familyName: selectedFamilyName
                        )
                } else {
                    Text("No family selected")
                }
            }
        }
    }

    // MARK: - Data

    private func loadFamilies() async {
        guard let uid = auth.user?.uid else { return }
        do {
            let snapshot = try await Firestore.firestore()
                .collection("families")
                .whereField("memberIds", arrayContains: uid)
                .getDocuments()

            self.families = snapshot.documents.compactMap { doc in
                try? doc.data(as: Family.self)    // Family: Identifiable+Codable in your Models.swift
            }
        } catch {
            print("Load families error:", error)
        }
    }

    private func createFamily() async {
        guard let uid = auth.user?.uid else { return }
        let name = newFamilyName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        let db = Firestore.firestore()
        let doc = db.collection("families").document()
        let fam = Family(id: doc.documentID, name: name)

        do {
            try await doc.setData([
                "id": fam.id,
                "name": fam.name,
                "ownerId": uid,
                "memberIds": [uid]
            ])
            newFamilyName = ""
            await loadFamilies()
        } catch {
            print("Create family error:", error)
        }
    }
}
