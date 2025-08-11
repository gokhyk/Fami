
import SwiftUI

struct InviteMemberView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var invitations: InvitationViewModel

    let familyId: String
    let familyName: String

    @State private var email = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Invite by Email") {
                    TextField("name@example.com", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    Button("Send Invitation") {
                        Task {
                            await invitations.sendInvite(familyId: familyId, familyName: familyName, email: email)
                            if invitations.errorMessage == nil { dismiss() }
                        }
                    }
                    .disabled(email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                if let err = invitations.errorMessage {
                    Text(err).foregroundColor(.red)
                }
            }
            .navigationTitle("Invite Member")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
    }
}
