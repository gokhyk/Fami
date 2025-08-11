
import Foundation

@MainActor
final class InvitationViewModel: ObservableObject {
    @Published var invites: [Invitation] = []
    @Published var errorMessage: String?

    private let repo: InvitationRepository
    private let auth: AuthViewModel

    init(repo: InvitationRepository, auth: AuthViewModel) {
        self.repo = repo
        self.auth = auth
    }

    func refresh() async {
        guard let uid = auth.user?.uid, let email = auth.user?.email else { return }
        do {
            invites = try await repo.myInvitations(currentUid: uid, currentEmail: email)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func sendInvite(familyId: String, familyName: String, email: String) async {
        do {
            try await repo.sendInvite(familyId: familyId, familyName: familyName, toEmail: email)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func accept(_ invitation: Invitation) async {
        guard let uid = auth.user?.uid else { return }
        do {
            try await repo.accept(invitation: invitation, currentUid: uid)
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func decline(_ invitationId: String) async {
        do {
            try await repo.decline(invitationId: invitationId)
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
